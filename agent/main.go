package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	pb "pi_agent/proto"
)

const (
	Version = "3.0.0"
	Port    = 50051
)

func main() {
	// Command line flags
	version := flag.Bool("version", false, "Print version and exit")
	port := flag.Int("port", Port, "gRPC server port")
	host := flag.String("host", "0.0.0.0", "Host address to bind to")
	flag.Parse()

	if *version {
		fmt.Printf("Pi Control Agent v%s\n", Version)
		os.Exit(0)
	}

	// Start gRPC server
	listenAddr := fmt.Sprintf("%s:%d", *host, *port)
	lis, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("Failed to listen on %s: %v", listenAddr, err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterSystemMonitorServer(grpcServer, &systemMonitorServer{})

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
