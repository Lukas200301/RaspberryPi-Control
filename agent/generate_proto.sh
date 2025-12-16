#!/bin/bash
# Generate Go code from protobuf

echo "Generating Go protobuf code..."

# Install dependencies if needed
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Create proto directory
mkdir -p proto

# Generate Go code
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    -I../protos ../protos/pi_control.proto

echo "Done! Generated files are in proto/"
