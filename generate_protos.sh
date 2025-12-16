#!/bin/bash
# Script to generate Dart protobuf code from .proto files

echo "Generating Dart code from protobuf definitions..."

# Install protoc_plugin if not already installed
dart pub global activate protoc_plugin

# Generate Dart code
protoc --dart_out=grpc:lib/generated -Iprotos protos/pi_control.proto

echo "Done! Generated files are in lib/generated/"
