package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"

	pb "pi_agent/proto"
)

const (
	Version = "4.0.0"
	Port    = 50051
)

func main() {
	// Command line flags
	version := flag.Bool("version", false, "Print version and exit")
	port := flag.Int("port", Port, "gRPC server port")
	// The agent has no authentication of its own: the app reaches it through
	// the SSH tunnel, so it only listens on the loopback interface
	host := flag.String("host", "127.0.0.1", "Address to listen on (loopback only)")
	allowRemote := flag.Bool("allow-remote", false, "Allow a non-loopback --host (exposes root access to the network)")
	flag.Parse()

	if *version {
		fmt.Printf("Pi Control Agent v%s\n", Version)
		os.Exit(0)
	}

	if !isLoopbackHost(*host) {
		if !*allowRemote {
			// Older apps start the agent with --host 0.0.0.0; stay safe anyway
			log.Printf("Refusing to listen on %s: the agent would be reachable from the network. "+
				"Listening on 127.0.0.1 instead (use --allow-remote to override).", *host)
			*host = "127.0.0.1"
		} else {
			log.Printf("WARNING: listening on %s without authentication", *host)
		}
	}

	// Start gRPC server
	listenAddr := net.JoinHostPort(*host, strconv.Itoa(*port))
	lis, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("Failed to listen on %s: %v", listenAddr, err)
	}

	grpcServer := grpc.NewServer(
		grpc.MaxRecvMsgSize(100*1024*1024), // 100MB max receive for large file chunks
		grpc.MaxSendMsgSize(100*1024*1024), // 100MB max send for large file chunks
		grpc.WriteBufferSize(1024*1024),    // 1MB write buffer
		grpc.ReadBufferSize(1024*1024),     // 1MB read buffer
		// Ping idle clients so streams of a phone that vanished (lost
		// network, killed app) are cancelled instead of running forever
		grpc.KeepaliveParams(keepalive.ServerParameters{
			Time:    30 * time.Second,
			Timeout: 10 * time.Second,
		}),
	)
	pb.RegisterSystemMonitorServer(grpcServer, &systemMonitorServer{})

	// Initialize and register Docker service
	dockerService, err := newDockerService()
	if err != nil {
		log.Printf("Warning: Failed to initialize Docker service: %v", err)
	} else {
		pb.RegisterDockerServiceServer(grpcServer, dockerService)
		log.Println("Docker service initialized successfully")
	}

	// PM2 is resolved lazily per request, so it can be installed later
	pb.RegisterPm2ServiceServer(grpcServer, newPm2Service())
	pb.RegisterSystemAdminServer(grpcServer, &systemAdminServer{})

	// Enable reflection for debugging
	reflection.Register(grpcServer)

	log.Printf("Pi Control Agent v%s starting on %s...", Version, listenAddr)

	// Handle graceful shutdown
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
		<-sigChan
		log.Println("Shutting down gracefully...")
		grpcServer.GracefulStop()
	}()

	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

// isLoopbackHost reports whether host is a loopback address or "localhost"
func isLoopbackHost(host string) bool {
	if host == "localhost" {
		return true
	}
	ip := net.ParseIP(host)
	return ip != nil && ip.IsLoopback()
}
