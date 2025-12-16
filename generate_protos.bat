@echo off
REM Script to generate Dart protobuf code from .proto files

echo Generating Dart code from protobuf definitions...

REM Install protoc_plugin if not already installed
call dart pub global activate protoc_plugin

REM Generate Dart code
protoc --dart_out=grpc:lib/generated -Iprotos protos/pi_control.proto

echo Done! Generated files are in lib/generated/
pause
