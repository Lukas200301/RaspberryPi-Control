import 'package:flutter/material.dart';

class ConnectionStatusOverlay extends StatelessWidget {
  final bool isReconnecting;
  final VoidCallback onManualReconnect;
  final VoidCallback onCancel;

  const ConnectionStatusOverlay({
    Key? key,
    required this.isReconnecting,
    required this.onManualReconnect,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final safeHeight = screenSize.height - kBottomNavigationBarHeight - bottomPadding - 20;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        height: safeHeight,
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Connection Lost',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'The SSH connection to the server was lost.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  if (isReconnecting) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Reconnecting...',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            child: const Text('Go to Connections'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onManualReconnect,
                            child: const Text('Reconnect'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
