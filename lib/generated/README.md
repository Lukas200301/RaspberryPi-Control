# Generated Protobuf Files

This directory will contain the generated Dart code from the protobuf definitions.

## To Generate

1. Install `protoc` compiler (see SETUP_INSTRUCTIONS.md in the root directory)
2. Run the generation script:
   - Windows: `generate_protos.bat`
   - Linux/macOS: `./generate_protos.sh`

## Expected Files

After generation, you should see:
- `pi_control.pb.dart` - Protocol buffer message classes
- `pi_control.pbenum.dart` - Enum definitions
- `pi_control.pbgrpc.dart` - gRPC client stubs
- `pi_control.pbjson.dart` - JSON encoding/decoding

## Using Without Generated Files

If you haven't generated the files yet, the app will show compilation errors. You must generate these files before running the Flutter app.
