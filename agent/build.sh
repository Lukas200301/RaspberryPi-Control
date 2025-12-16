#!/bin/bash
# Cross-compile Go agent for Raspberry Pi

set -e

echo "Building Pi Control Agent..."

# Version
VERSION="3.0.0"

# Output directory
OUTPUT_DIR="../assets/bin"
mkdir -p "$OUTPUT_DIR"

# Build for Raspberry Pi Zero (ARMv6)
echo "Building for Raspberry Pi Zero (linux/arm ARMv6)..."
GOOS=linux GOARCH=arm GOARM=6 go build -ldflags "-s -w" -o "$OUTPUT_DIR/pi-agent-arm6" .

# Build for Raspberry Pi 2/3 (ARMv7)
echo "Building for Raspberry Pi 2/3 (linux/arm ARMv7)..."
GOOS=linux GOARCH=arm GOARM=7 go build -ldflags "-s -w" -o "$OUTPUT_DIR/pi-agent-arm7" .

# Build for Raspberry Pi 3/4/5 64-bit (ARM64)
echo "Building for Raspberry Pi 3/4/5 64-bit (linux/arm64)..."
GOOS=linux GOARCH=arm64 go build -ldflags "-s -w" -o "$OUTPUT_DIR/pi-agent-arm64" .

echo ""
echo "Build complete! Binaries:"
ls -lh "$OUTPUT_DIR"/pi-agent-*

echo ""
echo "To test locally (if on ARM): ./$OUTPUT_DIR/pi-agent-arm64 --version"
