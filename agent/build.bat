@echo off
REM Cross-compile Go agent for Raspberry Pi (Windows)

echo Building Pi Control Agent...

set VERSION=3.0.0
set OUTPUT_DIR=..\assets\bin

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo Building for Raspberry Pi Zero (linux/arm ARMv6)...
set GOOS=linux
set GOARCH=arm
set GOARM=6
go build -ldflags "-s -w" -o "%OUTPUT_DIR%\pi-agent-arm6" .

echo Building for Raspberry Pi 2/3 (linux/arm ARMv7)...
set GOARM=7
go build -ldflags "-s -w" -o "%OUTPUT_DIR%\pi-agent-arm7" .

echo Building for Raspberry Pi 3/4/5 64-bit (linux/arm64)...
set GOARCH=arm64
go build -ldflags "-s -w" -o "%OUTPUT_DIR%\pi-agent-arm64" .

echo.
echo Build complete! Binaries are in %OUTPUT_DIR%
dir "%OUTPUT_DIR%\pi-agent-*"

pause
