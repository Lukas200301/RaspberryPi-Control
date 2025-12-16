#!/usr/bin/env pwsh
# All-in-One Build Script for Raspberry Pi Control
# Generates protobufs and builds agent binaries

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Raspberry Pi Control - Complete Build" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# Step 1: Add Dart pub cache to PATH temporarily
# ============================================================================
Write-Host "[1/5] Setting up environment..." -ForegroundColor Yellow
$dartPubCache = "$env:LOCALAPPDATA\Pub\Cache\bin"
if (Test-Path $dartPubCache) {
    $env:PATH = "$dartPubCache;$env:PATH"
    Write-Host "✓ Added Dart pub cache to PATH: $dartPubCache" -ForegroundColor Green
} else {
    Write-Host "✗ Warning: Dart pub cache not found at $dartPubCache" -ForegroundColor Red
}

# ============================================================================
# Step 2: Install protoc plugins
# ============================================================================
Write-Host ""
Write-Host "[2/5] Installing/updating protoc plugins..." -ForegroundColor Yellow

# Install Dart protoc plugin
Write-Host "Installing Dart protoc plugin..."
dart pub global activate protoc_plugin
Write-Host "✓ Dart protoc plugin ready" -ForegroundColor Green

# Install Go protoc plugins
Write-Host "Installing Go protoc plugins..."
try {
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    Write-Host "✓ Go protoc plugins ready" -ForegroundColor Green
} catch {
    Write-Host "✗ Warning: Failed to install Go plugins. Make sure Go is installed." -ForegroundColor Red
}

# ============================================================================
# Step 3: Generate Go protobuf files
# ============================================================================
Write-Host ""
Write-Host "[3/5] Generating Go protobuf files..." -ForegroundColor Yellow

$protoFile = "protos/pi_control.proto"
$goOutDir = "agent/proto"

if (!(Test-Path $protoFile)) {
    Write-Host "✗ Error: Proto file not found: $protoFile" -ForegroundColor Red
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Force -Path $goOutDir | Out-Null

# Check if protoc is available
$protocExists = Get-Command protoc -ErrorAction SilentlyContinue
if (!$protocExists) {
    Write-Host "✗ Error: protoc not found. Please install Protocol Buffers compiler." -ForegroundColor Red
    Write-Host "  Download from: https://github.com/protocolbuffers/protobuf/releases" -ForegroundColor Yellow
    Write-Host "  Or install with: choco install protobuf" -ForegroundColor Yellow
    exit 1
}

# Generate Go files
protoc --go_out=$goOutDir --go_opt=paths=source_relative `
       --go-grpc_out=$goOutDir --go-grpc_opt=paths=source_relative `
       -I=protos $protoFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Go protobuf files generated in $goOutDir" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to generate Go protobuf files" -ForegroundColor Red
    exit 1
}

# ============================================================================
# Step 4: Generate Dart protobuf files
# ============================================================================
Write-Host ""
Write-Host "[4/5] Generating Dart protobuf files..." -ForegroundColor Yellow

$dartOutDir = "lib/generated"
New-Item -ItemType Directory -Force -Path $dartOutDir | Out-Null

# Check if protoc-gen-dart is now available
$protocGenDart = Get-Command protoc-gen-dart -ErrorAction SilentlyContinue
if (!$protocGenDart) {
    Write-Host "✗ Warning: protoc-gen-dart still not found in PATH" -ForegroundColor Red
    Write-Host "  Trying with full path..." -ForegroundColor Yellow
}

protoc --dart_out=grpc:$dartOutDir -I=protos $protoFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dart protobuf files generated in $dartOutDir" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to generate Dart protobuf files" -ForegroundColor Red
    Write-Host "  You may need to add $dartPubCache to your system PATH permanently" -ForegroundColor Yellow
}

# ============================================================================
# Step 5: Build agent binaries
# ============================================================================
Write-Host ""
Write-Host "[5/5] Building agent binaries for all architectures..." -ForegroundColor Yellow

$agentDir = "agent"
$outputDir = "assets/bin"

# Create output directory and clean old binaries
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Remove-Item "$outputDir/pi-agent-*" -Force -ErrorAction SilentlyContinue

Push-Location $agentDir

try {
    # Build for ARM64 (Pi 3/4/5)
    Write-Host "  Building ARM64 (Pi 3/4/5)..."
    $env:GOOS = "linux"
    $env:GOARCH = "arm64"
    go build -ldflags "-s -w" -o "../$outputDir/pi-agent-arm64" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ ARM64 binary built" -ForegroundColor Green
    } else {
        throw "ARM64 build failed"
    }

    # Build for ARMv7 (Pi 2/3)
    Write-Host "  Building ARMv7 (Pi 2/3)..."
    $env:GOARCH = "arm"
    $env:GOARM = "7"
    go build -ldflags "-s -w" -o "../$outputDir/pi-agent-arm7" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ ARMv7 binary built" -ForegroundColor Green
    } else {
        throw "ARMv7 build failed"
    }

    # Build for ARMv6 (Pi Zero/1)
    Write-Host "  Building ARMv6 (Pi Zero/1)..."
    $env:GOARM = "6"
    go build -ldflags "-s -w" -o "../$outputDir/pi-agent-arm6" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ ARMv6 binary built" -ForegroundColor Green
    } else {
        throw "ARMv6 build failed"
    }

    Write-Host ""
    Write-Host "✓ All binaries built successfully!" -ForegroundColor Green
    
    # Show file sizes
    Write-Host ""
    Write-Host "Binary sizes:" -ForegroundColor Cyan
    Get-ChildItem "../$outputDir/pi-agent-*" | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  $($_.Name): $sizeMB MB" -ForegroundColor Gray
    }

} catch {
    Write-Host "✗ Build failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Yellow
Write-Host "  • Go protobuf: agent/proto/" -ForegroundColor Gray
Write-Host "  • Dart protobuf: lib/generated/" -ForegroundColor Gray
Write-Host "  • Agent binaries: assets/bin/" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: flutter pub get" -ForegroundColor White
Write-Host "  2. Run: flutter build apk --debug" -ForegroundColor White
Write-Host ""
Write-Host "Note: If Dart protobuf generation failed, add this to your system PATH:" -ForegroundColor Yellow
Write-Host "  $dartPubCache" -ForegroundColor Gray
Write-Host ""
