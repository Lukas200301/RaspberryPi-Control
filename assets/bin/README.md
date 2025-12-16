# Agent Binaries

This folder should contain the compiled Go agent binaries for different ARM architectures.

## Required Files

You need to build and place the following binaries in this directory:

- `pi-agent-arm6` - For Raspberry Pi Zero, Pi 1 (ARMv6)
- `pi-agent-arm7` - For Raspberry Pi 2, Pi 3 (ARMv7)
- `pi-agent-arm64` - For Raspberry Pi 3, Pi 4, Pi 5 (ARMv8/ARM64)

## Building the Agent

Navigate to the `agent/` directory and run the build scripts:

### On Windows:
```bash
.\build.bat
```

### On Linux/macOS:
```bash
./build.sh
```

The build scripts will compile the Go agent for all three ARM architectures and place the binaries in this folder.

## Manual Build (if scripts don't work)

From the `agent/` directory:

```bash
# ARM64 (Pi 3/4/5)
GOOS=linux GOARCH=arm64 go build -o ../assets/bin/pi-agent-arm64 .

# ARMv7 (Pi 2/3)
GOOS=linux GOARCH=arm GOARM=7 go build -o ../assets/bin/pi-agent-arm7 .

# ARMv6 (Pi Zero/1)
GOOS=linux GOARCH=arm GOARM=6 go build -o ../assets/bin/pi-agent-arm6 .
```

## Note

These binaries are embedded in the Flutter app and deployed to your Raspberry Pi during the first connection or when you choose to install/update the agent.
