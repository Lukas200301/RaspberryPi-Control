# Quick Start Guide

Get the Raspberry Pi Control app running in 5 minutes!

## Prerequisites Check

Before you begin, ensure you have:

- [ ] Flutter SDK 3.10+ installed (`flutter doctor`)
- [ ] Go 1.25+ installed (`go version`)
- [ ] Protocol Buffers compiler (protoc)

## Step 1: Install protoc

Choose your operating system:

**Windows (using Chocolatey):**
```powershell
choco install protobuf
```

**macOS:**
```bash
brew install protobuf
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y protobuf-compiler
```

Verify installation:
```bash
protoc --version
```

## Step 2: Generate Protocol Buffer Code

### For Dart (Flutter app):

```bash
# Install Dart protobuf plugin
dart pub global activate protoc_plugin

# Add to PATH (Windows)
# C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin

# Generate Dart code
# Windows:
generate_protos.bat

# Linux/macOS:
chmod +x generate_protos.sh
./generate_protos.sh
```

You should see files created in `lib/generated/`:
- `pi_control.pb.dart`
- `pi_control.pbenum.dart`
- `pi_control.pbgrpc.dart`
- `pi_control.pbjson.dart`

### For Go (Agent):

```bash
cd agent

# Install Go protobuf tools
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate Go code
chmod +x generate_proto.sh
./generate_proto.sh
```

You should see a `proto/` directory created with generated Go files.

## Step 3: Build the Go Agent

```bash
cd agent

# Windows:
build.bat

# Linux/macOS:
chmod +x build.sh
./build.sh
```

This creates binaries in `assets/bin/`:
- `pi_agent_arm6` (Pi Zero)
- `pi_agent_arm7` (Pi 2/3)
- `pi_agent_arm64` (Pi 3/4/5 64-bit)

## Step 4: Get Flutter Dependencies

```bash
# Go back to project root
cd ..

flutter pub get
```

## Step 5: Run the App

```bash
flutter run
```

Or use your IDE:
- **VS Code**: Press F5
- **Android Studio**: Click Run

## Step 6: Connect to Your Pi

1. Open the app drawer (swipe from left or tap ☰)
2. Tap **"Connections"**
3. Tap the **"+ Add Connection"** button
4. Fill in your Pi's details:
   - **Name**: My Raspberry Pi
   - **Host**: 192.168.1.100 (your Pi's IP)
   - **Port**: 22
   - **Username**: pi
   - **Password**: raspberry (or your password)
5. Tap **"Add"**
6. Tap on the connection to connect
7. Tap **"Install & Connect"** when prompted
8. Wait ~5 seconds for agent installation
9. Start monitoring!

## Troubleshooting

### "protoc: command not found"
→ Install protoc (see Step 1)

### "Undefined name 'LiveStats'"
→ Generate protobuf files (see Step 2)

### "No such file: assets/bin/pi_agent_arm64"
→ Build Go agent (see Step 3)

### "SSH Connection Failed"
→ Check:
- Pi is powered on and connected to network
- SSH is enabled: `sudo raspi-config` → Interface → SSH
- Correct IP address: run `hostname -I` on Pi
- Correct username/password

### "Agent Installation Failed"
→ Check:
- SSH user has write permissions to home directory
- Pi has internet connection (for first-time dependencies)

## Next Steps

Once connected, explore:

1. **Dashboard** - View real-time CPU, RAM, temperature
2. **Files** - Browse Pi filesystem
3. **Terminal** - Run commands on Pi
4. **Services** - Manage systemd services
5. **Logs** - View system logs

## Tips

- **First connection takes longer**: Agent installation + first-time setup
- **Subsequent connections**: Instant (agent already installed)
- **Multiple Pis**: Add all your Pis, switch between them easily
- **Favorites**: Star frequently used connections

## Need Help?

- Check [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for detailed setup
- Check [PROJECT_STATUS.md](PROJECT_STATUS.md) for implementation status
- Check [README.md](README.md) for full documentation

---

Enjoy monitoring your Raspberry Pi! 🎉
