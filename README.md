# Raspberry Pi Control

A high-performance, real-time monitoring and control application for Raspberry Pi devices with a beautiful glassmorphic UI.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![Go](https://img.shields.io/badge/Go-1.25+-00ADD8?logo=go)
![gRPC](https://img.shields.io/badge/gRPC-Protocol-244c5a)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 📊 Real-Time Dashboard
- **Live System Stats**: CPU, RAM, Temperature, Uptime updated every 500ms
- **CPU Charts**: Smooth vector graphs showing 60-second history
- **Memory Visualization**: Detailed breakdown of Used/Free/Cached/Swap
- **Thermal Monitoring**: Color-coded temperature gauges for CPU & GPU
- **Top Processes**: View and manage resource-intensive processes

### 📁 File Explorer (SFTP)
- Browse remote directories with intuitive navigation
- Upload/Download files with progress tracking
- File previews with syntax highlighting
- Rename, delete, create folders, change permissions

### 💻 Terminal Emulator
- Full `xterm-256color` compatible SSH shell
- Custom accessory keyboard (Esc, Tab, Ctrl, Alt, Arrows)
- Command history support

### ⚙️ Service Manager
- List all systemd services (Active/Inactive/Failed)
- Start, Stop, Restart, Enable, Disable services
- Search and filter by service name

### 📜 System Logs
- Real-time log streaming via journalctl
- Filter by log level (Error/Warning/Info)
- Service-specific filtering

### 🔌 Connection Manager
- Save multiple Pi connections securely
- Favorite connections for quick access
- Auto-reconnect with configurable retry logic

## 🎨 Design

**Cyberpunk / Sci-Fi Glassmorphism Theme**
- Pure AMOLED Black background (#000000) for battery efficiency
- Frosted glass cards with blur effects
- Electric Indigo (#6366F1) and Teal (#14B8A6) accents
- Smooth animations and transitions

## 🏗️ Architecture

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Mobile App** | Flutter 3.10+ | Cross-platform UI (iOS/Android) |
| **Backend Agent** | Go 1.25+ | Zero-dependency binary for Pi |
| **Communication** | gRPC + Protobuf | High-speed binary streaming |
| **Security** | SSH Tunnel | All traffic encrypted via SSH |

### How It Works

1. **User connects** via standard SSH (port 22)
2. **App checks** if Go agent is installed on Pi
3. **Auto-deploys** agent if missing/outdated (takes ~5 seconds)
4. **Establishes** SSH tunnel for gRPC traffic
5. **Streams** real-time stats at 500ms intervals

## 🚀 Quick Start

### Prerequisites

1. **Flutter SDK** 3.10 or higher
   ```bash
   flutter doctor
   ```

2. **Go** 1.25 or higher (for building agent)
   ```bash
   go version
   ```

3. **Protocol Buffers Compiler** (protoc)
   - Windows: `choco install protobuf`
   - macOS: `brew install protobuf`
   - Linux: `sudo apt-get install protobuf-compiler`

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/raspberrypi-control.git
   cd raspberrypi-control
   ```

2. **Generate Protobuf files**
   ```bash
   # Install Dart protobuf plugin
   dart pub global activate protoc_plugin

   # Generate code
   # Windows:
   generate_protos.bat

   # Linux/macOS:
   chmod +x generate_protos.sh
   ./generate_protos.sh
   ```

3. **Build the Go agent**
   ```bash
   cd agent

   # Windows:
   build.bat

   # Linux/macOS:
   chmod +x build.sh
   ./build.sh
   ```

4. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### First Time Setup

1. **Launch the app**
2. **Tap "Connections"** from the drawer menu
3. **Add a new connection** with your Pi's details:
   - Name: e.g., "My Raspberry Pi 4"
   - Host: IP address or hostname
   - Port: 22 (default SSH port)
   - Username: e.g., "pi"
   - Password: your SSH password

4. **Connect** to your Pi
5. **Install agent** when prompted (automatic, ~5 seconds)
6. **Start monitoring!**

### Supported Raspberry Pi Models

- ✅ Raspberry Pi Zero/Zero W (ARMv6)
- ✅ Raspberry Pi 2/3 (ARMv7)
- ✅ Raspberry Pi 3/4/5 64-bit (ARM64)

The app automatically detects your Pi's architecture and deploys the correct binary.

## 🔧 Development

### Project Structure

```
raspberrypi-control/
├── agent/                  # Go agent source
│   ├── main.go            # Entry point
│   ├── server.go          # gRPC server implementation
│   ├── build.sh           # Cross-compilation script
│   └── proto/             # Generated Go protobuf code
│
├── lib/                   # Flutter app source
│   ├── main.dart          # App entry point
│   ├── models/            # Data models
│   ├── providers/         # Riverpod state management
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   ├── theme/             # Glassmorphism theme
│   ├── widgets/           # Reusable components
│   └── generated/         # Generated Dart protobuf code
│
├── protos/                # Protocol Buffer definitions
│   └── pi_control.proto   # API contract
│
├── assets/
│   └── bin/               # Compiled Go agent binaries
│
└── README.md
```

### Building for Production

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### Agent Development

The Go agent runs on the Raspberry Pi and provides system information via gRPC.

**Rebuild agent after changes:**
```bash
cd agent
./build.sh  # Creates binaries for all Pi architectures
```

**Test agent locally:**
```bash
cd agent
go run . --version
go run . --port 50051
```

## 🔒 Security

- **Encrypted Communication**: All traffic flows through SSH tunnel
- **No Open Ports**: No firewall configuration needed
- **Secure Storage**: Passwords encrypted in device keychain
- **No Remote Access**: Agent only listens on localhost via SSH

## 🛠️ Troubleshooting

### Protobuf Generation Fails

**Error**: `protoc: command not found`

**Solution**: Install Protocol Buffers compiler (see Prerequisites)

### SSH Connection Failed

**Possible causes**:
1. SSH not enabled on Pi: `sudo raspi-config` → Interface Options → SSH
2. Wrong credentials: Double-check username/password
3. Firewall blocking: Ensure port 22 is accessible
4. Wrong IP address: Verify with `hostname -I` on Pi

### Agent Installation Fails

**Error**: Permission denied

**Solution**: Ensure SSH user has write permissions to home directory

### App Won't Compile

**Error**: Missing generated files

**Solution**: Run `generate_protos.bat` or `./generate_protos.sh` first

## 📝 API Documentation

See [protos/pi_control.proto](protos/pi_control.proto) for the complete gRPC API definition.

### Key Services

- `StreamStats`: Real-time system statistics (500ms intervals)
- `ListProcesses`: Get all running processes
- `KillProcess`: Terminate a process by PID
- `ListServices`: Get all systemd services
- `ManageService`: Start/stop/restart/enable/disable services
- `StreamLogs`: Real-time log streaming
- `GetDiskInfo`: Disk usage information
- `GetNetworkInfo`: Network interface details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Go](https://golang.org/) - Agent implementation
- [gRPC](https://grpc.io/) - High-performance RPC framework
- [gopsutil](https://github.com/shirou/gopsutil) - System information library
- [dartssh2](https://pub.dev/packages/dartssh2) - SSH implementation for Dart

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Made with ❤️ for the Raspberry Pi community
