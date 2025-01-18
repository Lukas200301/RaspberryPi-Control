
# RaspberryPi-Control

RaspberryPi-Control is a Flutter application that allows you to control and monitor your Raspberry Pi remotely. You can execute commands, view system stats, and manage SSH connections.

## Features

- Connect to Raspberry Pi via SSH
- Execute commands on the Raspberry Pi
- View system stats (temperature, memory, uptime, etc.)
- Manage multiple SSH connections
- Light and dark theme support

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter
- A Raspberry Pi with SSH enabled

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/RaspberryPi-Control.git
    cd RaspberryPi-Control
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Run the app:
    ```bash
    flutter run
    ```

## Usage

1. Launch the app on your device or emulator.
2. Navigate to the "Connections" tab to add a new SSH connection.
3. Enter the connection details (name, host, port, username, password) and save the connection.
4. Select the saved connection to connect to your Raspberry Pi.
5. Use the "Commands" tab to execute commands on the Raspberry Pi.
6. Use the "Stats" tab to view system stats.

## Dependencies

- `flutter`: The Flutter SDK
- `dartssh2`: SSH client library for Dart
- `shared_preferences`: For storing connection details locally
- `convert`: For encoding and decoding data

## Development

### Building

To build the app, run:
```bash
flutter build apk
```

### Testing

To run tests, use:
```bash
flutter test
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
