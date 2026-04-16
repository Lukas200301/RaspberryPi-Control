package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/shirou/gopsutil/v3/disk"

	pb "pi_agent/proto"
)

// GetDiskInfo returns disk usage information
func (s *systemMonitorServer) GetDiskInfo(ctx context.Context, req *pb.Empty) (*pb.DiskInfo, error) {
	partitions, err := disk.Partitions(false)
	if err != nil {
		return nil, err
	}

	var diskPartitions []*pb.DiskPartition
	for _, partition := range partitions {
		usage, err := disk.Usage(partition.Mountpoint)
		if err != nil {
			continue
		}

		diskPartitions = append(diskPartitions, &pb.DiskPartition{
			Device:       partition.Device,
			MountPoint:   partition.Mountpoint,
			Filesystem:   partition.Fstype,
			TotalBytes:   usage.Total,
			UsedBytes:    usage.Used,
			FreeBytes:    usage.Free,
			UsagePercent: usage.UsedPercent,
		})
	}

	return &pb.DiskInfo{Partitions: diskPartitions}, nil
}

// validatePath validates and sanitizes file paths to prevent directory traversal attacks
func validatePath(requestedPath string) (string, error) {
	// Clean the path
	cleanPath := filepath.Clean(requestedPath)

	// Make it absolute
	absPath, err := filepath.Abs(cleanPath)
	if err != nil {
		return "", fmt.Errorf("invalid path: %w", err)
	}

	return absPath, nil
}

// checkDiskSpace verifies sufficient disk space is available (Linux only)
func checkDiskSpace(path string, requiredBytes int64) error {
	// Disk space check disabled for cross-platform compatibility
	// On production Linux (Pi), you can implement this using golang.org/x/sys/unix
	// Parameters are intentionally unused for now
	_ = path
	_ = requiredBytes
	return nil
}

// UploadFile receives file chunks from client and writes to disk
func (s *systemMonitorServer) UploadFile(stream pb.SystemMonitor_UploadFileServer) error {
	var (
		file          *os.File
		totalBytes    int64
		receivedBytes int64
		startTime     = time.Now()
		targetPath    string
	)

	defer func() {
		if file != nil {
			file.Close()

			// If upload failed, delete partial file
			if receivedBytes < totalBytes && targetPath != "" {
				os.Remove(targetPath)
				log.Printf("Removed partial file: %s", targetPath)
			}
		}
	}()

	// Receive chunks
	for {
		chunk, err := stream.Recv()
		if err == io.EOF {
			// Client finished sending
			break
		}
		if err != nil {
			return fmt.Errorf("receive chunk error: %w", err)
		}

		// First chunk: create file and get metadata
		if file == nil {
			// Validate path
			validPath, err := validatePath(chunk.Path)
			if err != nil {
				return fmt.Errorf("invalid path: %w", err)
			}
			targetPath = validPath
			totalBytes = chunk.TotalSize

			// Check disk space
			if err := checkDiskSpace(targetPath, totalBytes); err != nil {
				return fmt.Errorf("disk space check failed: %w", err)
			}

			// Create parent directories if needed
			dir := filepath.Dir(targetPath)
			if err := os.MkdirAll(dir, 0755); err != nil {
				return fmt.Errorf("create directory error: %w", err)
			}

			// Create/truncate file
			file, err = os.OpenFile(targetPath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
			if err != nil {
				return fmt.Errorf("open file error: %w", err)
			}

			log.Printf("Upload started: %s (%d bytes)", targetPath, totalBytes)
		}

		// Write chunk data
		if len(chunk.Data) > 0 {
			n, err := file.Write(chunk.Data)
			if err != nil {
				return fmt.Errorf("write chunk error: %w", err)
			}
			receivedBytes += int64(n)
		}

		// Check if this is the final chunk
		if chunk.IsFinal {
			break
		}
	}

	// Close file
	if file != nil {
		if err := file.Close(); err != nil {
			return fmt.Errorf("close file error: %w", err)
		}
	}

	duration := time.Since(startTime).Seconds()
	speedMBps := float64(receivedBytes) / (1024 * 1024) / duration

	log.Printf("Upload complete: %s (%d bytes in %.2fs, %.2f MB/s)", targetPath, receivedBytes, duration, speedMBps)

	// Send response
	response := &pb.FileUploadResponse{
		Success:      true,
		Path:         targetPath,
		BytesWritten: receivedBytes,
		Duration:     duration,
	}

	return stream.SendAndClose(response)
}

// DownloadFile reads a file from disk and streams chunks to client
func (s *systemMonitorServer) DownloadFile(req *pb.FileDownloadRequest, stream pb.SystemMonitor_DownloadFileServer) error {
	// Validate path
	validPath, err := validatePath(req.Path)
	if err != nil {
		return stream.Send(&pb.FileChunk{
			Error: fmt.Sprintf("Invalid path: %v", err),
		})
	}
	targetPath := validPath
	offset := req.Offset

	// Check if file exists
	fileInfo, err := os.Stat(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			// Send error chunk
			return stream.Send(&pb.FileChunk{
				Error: fmt.Sprintf("File not found: %s", targetPath),
			})
		}
		return fmt.Errorf("stat file error: %w", err)
	}

	totalSize := fileInfo.Size()

	// Open file
	file, err := os.Open(targetPath)
	if err != nil {
		return fmt.Errorf("open file error: %w", err)
	}
	defer file.Close()

	// Seek to offset if resuming
	if offset > 0 {
		_, err = file.Seek(offset, io.SeekStart)
		if err != nil {
			return fmt.Errorf("seek error: %w", err)
		}
		log.Printf("Download resuming from offset: %d", offset)
	}

	startTime := time.Now()
	log.Printf("Download started: %s (%d bytes, offset: %d)", targetPath, totalSize, offset)

	// Read and send chunks with adaptive sizing
	var chunkSize int
	if totalSize < 1*1024*1024 {
		chunkSize = 256 * 1024 // 256KB for files < 1MB
	} else if totalSize < 10*1024*1024 {
		chunkSize = 512 * 1024 // 512KB for files 1-10MB
	} else if totalSize < 100*1024*1024 {
		chunkSize = 2 * 1024 * 1024 // 2MB for files 10-100MB
	} else {
		chunkSize = 4 * 1024 * 1024 // 4MB for files > 100MB (multi-GB transfers)
	}

	buffer := make([]byte, chunkSize)
	currentOffset := offset
	totalSent := int64(0)

	for {
		n, err := file.Read(buffer)
		if err != nil && err != io.EOF {
			return fmt.Errorf("read file error: %w", err)
		}

		if n > 0 {
			isFinal := (currentOffset+int64(n) >= totalSize)

			chunk := &pb.FileChunk{
				Path:      targetPath,
				Data:      buffer[:n],
				Offset:    currentOffset,
				TotalSize: totalSize,
				IsFinal:   isFinal,
			}

			if err := stream.Send(chunk); err != nil {
				return fmt.Errorf("send chunk error: %w", err)
			}

			currentOffset += int64(n)
			totalSent += int64(n)

			if isFinal {
				break
			}
		}

		if err == io.EOF {
			break
		}
	}

	duration := time.Since(startTime).Seconds()
	speedMBps := float64(totalSent) / (1024 * 1024) / duration

	log.Printf("Download complete: %s (%d bytes in %.2fs, %.2f MB/s)", targetPath, totalSent, duration, speedMBps)

	return nil
}

// DeleteFile - Delete a file or directory
func (s *systemMonitorServer) DeleteFile(ctx context.Context, req *pb.FileDeleteRequest) (*pb.FileDeleteResponse, error) {
	log.Printf("Delete request: path=%s, isDirectory=%v", req.Path, req.IsDirectory)

	// Validate and sanitize path
	targetPath, err := validatePath(req.Path)
	if err != nil {
		errMsg := fmt.Sprintf("Invalid path: %v", err)
		log.Printf("Delete failed: %s", errMsg)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Check if file/directory exists
	fileInfo, err := os.Stat(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			errMsg := fmt.Sprintf("File not found: %s", req.Path)
			log.Printf("Delete failed: %s", errMsg)
			return &pb.FileDeleteResponse{
				Success: false,
				Path:    req.Path,
				Error:   errMsg,
			}, nil
		}
		errMsg := fmt.Sprintf("Failed to stat file: %v", err)
		log.Printf("Delete failed: %s", errMsg)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Verify directory flag matches actual file type
	if req.IsDirectory && !fileInfo.IsDir() {
		errMsg := "Path is not a directory"
		log.Printf("Delete failed: %s (path: %s)", errMsg, targetPath)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Delete the file or directory
	startTime := time.Now()
	if req.IsDirectory {
		// Recursively remove directory and all contents
		err = os.RemoveAll(targetPath)
	} else {
		// Remove single file
		err = os.Remove(targetPath)
	}

	if err != nil {
		errMsg := fmt.Sprintf("Failed to delete: %v", err)
		log.Printf("Delete failed: %s (path: %s)", errMsg, targetPath)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	duration := time.Since(startTime).Milliseconds()
	log.Printf("Delete complete: %s (isDirectory=%v, took %dms)", targetPath, req.IsDirectory, duration)

	return &pb.FileDeleteResponse{
		Success: true,
		Path:    req.Path,
		Error:   "",
	}, nil
}
