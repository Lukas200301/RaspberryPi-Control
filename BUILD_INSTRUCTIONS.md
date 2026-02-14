# Build Instructions

## Prerequisites

1. **Flutter SDK** 3.10 or higher

   ```bash
   flutter doctor
   ```

2. **Go** 1.25 or higher

   ```bash
   go version
   ```

3. **Protocol Buffers Compiler** (protoc)
   - Windows: `choco install protobuf`
   - macOS: `brew install protobuf`
   - Linux: `sudo apt-get install protobuf-compiler`

   Verify: `protoc --version`

## ✅ Build Everything (Recommended)

The `build_all.ps1` script handles the entire build pipeline in one command:

```powershell
.\build_all.ps1
```

**This script automatically:**

1. Syncs version numbers across all files (from `pubspec.yaml`)
2. Installs/updates Dart and Go protoc plugins
3. Generates Go protobuf files → `agent/proto/`
4. Generates Dart protobuf files → `lib/generated/`
5. Cross-compiles the Go agent for all Raspberry Pi architectures → `assets/bin/`

**Output binaries:**
| Binary | Architecture | Supported Models |
|--------|-------------|------------------|
| `pi-agent-arm64` | ARM64 | Raspberry Pi 3/4/5 (64-bit) |
| `pi-agent-arm7` | ARMv7 | Raspberry Pi 2/3 |
| `pi-agent-arm6` | ARMv6 | Raspberry Pi Zero/1 |

## Run the Flutter App

After `build_all.ps1` completes:

```bash
flutter pub get
flutter run
```

Or build a release APK:

```bash
flutter build apk --release
```

## 🔧 Manual Build Steps (Advanced)

If you need to run individual steps instead of `build_all.ps1`:

### Generate Protobuf Code

```bash
# Install plugins (one-time)
dart pub global activate protoc_plugin
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate Dart code
protoc --dart_out=grpc:lib/generated -Iprotos protos/pi_control.proto

# Generate Go code
protoc --go_out=agent/proto --go_opt=paths=source_relative --go-grpc_out=agent/proto --go-grpc_opt=paths=source_relative -Iprotos protos/pi_control.proto
```

### Build Go Agent

```bash
cd agent

# ARM64 (Pi 3/4/5)
$env:GOOS="linux"; $env:GOARCH="arm64"; go build -ldflags="-s -w" -o ../assets/bin/pi-agent-arm64

# ARMv7 (Pi 2/3)
$env:GOOS="linux"; $env:GOARCH="arm"; $env:GOARM="7"; go build -ldflags="-s -w" -o ../assets/bin/pi-agent-arm7

# ARMv6 (Pi Zero/1)
$env:GOOS="linux"; $env:GOARCH="arm"; $env:GOARM="6"; go build -ldflags="-s -w" -o ../assets/bin/pi-agent-arm6
```

## 🆘 Troubleshooting

| Error                                    | Solution                                                                                                    |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `protoc: command not found`              | Install protoc and add to PATH                                                                              |
| `protoc-gen-go: program not found`       | Run `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest` and add `%USERPROFILE%\go\bin` to PATH |
| `protoc-gen-dart: program not found`     | Run `dart pub global activate protoc_plugin` and add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH                 |
| Go build fails after protobuf generation | Run `go mod tidy` in the `agent/` directory                                                                 |
| Dart analysis errors after build         | Run `flutter pub get` to refresh dependencies                                                               |

---

**Quick Start**: Just run `.\build_all.ps1` then `flutter run` — everything else is handled automatically.
