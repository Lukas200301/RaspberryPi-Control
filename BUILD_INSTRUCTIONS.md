# Build Instructions

## ⚠️ Current Build Status

The Go agent **cannot be built** until you generate the protobuf files. This is **required** before the first build.

## Why the Build Failed

You saw this error:
```
go: go.mod file not found in current directory or any parent directory
```

This happened because the `build.bat` script changes directories, but Go needs the protobuf files generated first.

## ✅ Correct Build Order

### Step 1: Install protoc (Required)

**Windows (using Chocolatey):**
```powershell
choco install protobuf
```

**Or download manually:**
- Go to: https://github.com/protocolbuffers/protobuf/releases
- Download `protoc-XX.X-win64.zip`
- Extract to `C:\protoc`
- Add `C:\protoc\bin` to your PATH

**Verify installation:**
```bash
protoc --version
```

### Step 2: Generate Go Protobuf Code

```bash
cd agent

# Install Go protobuf tools (one-time)
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Add Go bin to PATH if needed
# Windows: Add C:\Users\<YourUsername>\go\bin to PATH

# Generate the code
protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative -I../protos ../protos/pi_control.proto
```

This will create:
- `agent/proto/pi_control.pb.go` (messages)
- `agent/proto/pi_control_grpc.pb.go` (gRPC service)

### Step 3: Build the Go Agent

Now you can build:

```bash
# Still in agent/ directory
build.bat  # Windows
# or
./build.sh  # Linux/Mac
```

This will create binaries in `assets/bin/`:
- `pi_agent_arm6` (Pi Zero)
- `pi_agent_arm7` (Pi 2/3)
- `pi_agent_arm64` (Pi 3/4/5)

### Step 4: Generate Dart Protobuf Code

```bash
# Go back to project root
cd ..

# Install Dart protobuf plugin (one-time)
dart pub global activate protoc_plugin

# Add Dart pub cache to PATH if needed
# Windows: Add C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin to PATH

# Generate the code
generate_protos.bat  # Windows
# or
./generate_protos.sh  # Linux/Mac
```

This will create files in `lib/generated/`:
- `pi_control.pb.dart`
- `pi_control.pbenum.dart`
- `pi_control.pbgrpc.dart`
- `pi_control.pbjson.dart`

### Step 5: Update gRPC Service

Uncomment the code in `lib/services/grpc_service.dart`:

```dart
// Change FROM:
// import '../generated/pi_control.pbgrpc.dart';

// TO:
import '../generated/pi_control.pbgrpc.dart';

// Then uncomment all the method implementations
```

### Step 6: Run Flutter App

```bash
flutter pub get
flutter run
```

## 🔧 Alternative: Quick Fix for Testing UI Only

If you want to test the UI **without** the Go agent, you can:

1. **Skip protobuf generation** (for now)
2. **Run the Flutter app** - it will show placeholder data
3. **Browse the UI** - all screens work, just no real data

The app is designed to gracefully handle missing data, so you can explore:
- ✅ Navigation between screens
- ✅ Glassmorphic design
- ✅ Connection manager UI
- ✅ All screen layouts
- ❌ Real-time data (requires protobuf + Go agent)

## 📝 Summary

**To see the UI only:**
```bash
flutter pub get
flutter run
```

**To get full functionality:**
1. Install protoc
2. Generate Go protobuf code
3. Build Go agent
4. Generate Dart protobuf code
5. Uncomment gRPC service code
6. Run Flutter app

## 🆘 Troubleshooting

### "protoc: command not found"
→ Install protoc and add to PATH

### "protoc-gen-go: program not found"
→ Run: `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest`
→ Add `%USERPROFILE%\go\bin` to PATH (Windows)

### "protoc-gen-dart: program not found"
→ Run: `dart pub global activate protoc_plugin`
→ Add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH (Windows)

### Go build still fails after protobuf generation
→ Run `go mod tidy` in the agent directory
→ Verify `agent/proto/` contains .pb.go files

---

**Current Status**: Flutter app ready to run (UI only). Go agent needs protobuf generation first.
