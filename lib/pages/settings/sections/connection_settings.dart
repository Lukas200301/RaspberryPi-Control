import 'package:flutter/material.dart';
import '../utils/settings_utils.dart';

class ConnectionSettings extends StatelessWidget {
  final String defaultPort;
  final Function(String) onDefaultPortChanged;
  final bool autoReconnect;
  final Function(bool) onAutoReconnectChanged;
  final int autoReconnectAttempts;
  final Function(int?) onAutoReconnectAttemptsChanged;
  final int connectionRetryDelay;
  final Function(int?) onConnectionRetryDelayChanged;
  final int connectionTimeout;
  final Function(int?) onConnectionTimeoutChanged;
  final String sshKeepAliveInterval;
  final Function(String) onSshKeepAliveIntervalChanged;
  final int securityTimeout;
  final Function(int?) onSecurityTimeoutChanged;
  final bool sshCompression;
  final Function(bool) onSshCompressionChanged;
  final Function() saveSettings;

  const ConnectionSettings({
    Key? key,
    required this.defaultPort,
    required this.onDefaultPortChanged,
    required this.autoReconnect,
    required this.onAutoReconnectChanged,
    required this.autoReconnectAttempts,
    required this.onAutoReconnectAttemptsChanged,
    required this.connectionRetryDelay,
    required this.onConnectionRetryDelayChanged,
    required this.connectionTimeout,
    required this.onConnectionTimeoutChanged,
    required this.sshKeepAliveInterval,
    required this.onSshKeepAliveIntervalChanged,
    required this.securityTimeout,
    required this.onSecurityTimeoutChanged,
    required this.sshCompression,
    required this.onSshCompressionChanged,
    required this.saveSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'Connection Settings'),
        ListTile(
          leading: const Icon(Icons.numbers),
          title: const Text('Default SSH Port'),
          subtitle: const Text('Default port used when adding new connections'),
          trailing: SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: defaultPort,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) {
                onDefaultPortChanged(value.isEmpty ? '22' : value);
                saveSettings();
              },
            ),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.sync),
          title: const Text('Auto-Reconnect'),
          subtitle: const Text('Automatically retry connection when disconnected'),
          value: autoReconnect,
          onChanged: (value) {
            onAutoReconnectChanged(value);
            saveSettings();
          },
        ),
        
        if (autoReconnect) ...[
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Reconnect Attempts'),
            subtitle: const Text('Maximum number of times to try reconnecting'),
            trailing: DropdownButton<int>(
              value: autoReconnectAttempts,
              onChanged: (value) {
                if (value != null) {
                  onAutoReconnectAttemptsChanged(value);
                  saveSettings();
                }
              },
              items: [1, 2, 3, 5, 10].map((attempts) {
                return DropdownMenuItem<int>(
                  value: attempts,
                  child: Text('$attempts'),
                );
              }).toList(),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text('Connection Retry Delay'),
            subtitle: const Text('Time to wait between reconnection attempts'),
            trailing: DropdownButton<int>(
              value: connectionRetryDelay,
              onChanged: (value) {
                if (value != null) {
                  onConnectionRetryDelayChanged(value);
                  saveSettings();
                }
              },
              items: [2, 5, 10, 15, 30].map((delay) {
                return DropdownMenuItem<int>(
                  value: delay,
                  child: Text('$delay sec'),
                );
              }).toList(),
            ),
          ),
        ],
        
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Connection Timeout'),
          subtitle: const Text('Maximum time allowed for SSH connection to establish'),
          trailing: DropdownButton<int>(
            value: connectionTimeout,
            onChanged: (value) {
              if (value != null) {
                onConnectionTimeoutChanged(value);
                saveSettings();
              }
            },
            items: [10, 20, 30, 45, 60, 90, 120].map((timeout) {
              return DropdownMenuItem<int>(
                value: timeout,
                child: Text('$timeout sec'),
              );
            }).toList(),
          ),
        ),
        
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('SSH Keep-Alive Interval'),
          subtitle: const Text('Prevent connection drops by sending periodic signals'),
          trailing: SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: sshKeepAliveInterval,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(),
                suffixText: 's',
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onSshKeepAliveIntervalChanged,
              onEditingComplete: saveSettings,
            ),
          ),
        ),
              
        ListTile(
          leading: const Icon(Icons.timer_off),
          title: const Text('Security Timeout'),
          subtitle: const Text('Automatically disconnect after inactivity'),
          trailing: DropdownButton<int>(
            value: securityTimeout,
            onChanged: (value) {
              if (value != null) {
                onSecurityTimeoutChanged(value);
                saveSettings();
              }
            },
            items: [0, 5, 10, 15, 30, 60].map((timeout) {
              return DropdownMenuItem<int>(
                value: timeout,
                child: Text(timeout == 0 ? 'Disabled' : '$timeout min'),
              );
            }).toList(),
          ),
        ),
        
        SwitchListTile(
          secondary: const Icon(Icons.compress),
          title: const Text('SSH Compression'),
          subtitle: const Text('Save data usage on slow networks (may reduce performance)'),
          value: sshCompression,
          onChanged: (value) {
            onSshCompressionChanged(value);
            saveSettings();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
