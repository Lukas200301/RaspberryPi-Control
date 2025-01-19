import 'package:flutter/material.dart';
import 'ssh_service.dart';

class CommandScreen extends StatelessWidget {
  final SSHService? sshService;
  final TextEditingController commandController;
  final String commandOutput;
  final VoidCallback sendCommand;

  const CommandScreen({
    super.key,
    required this.sshService,
    required this.commandController,
    required this.commandOutput,
    required this.sendCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              commandOutput,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: commandController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter command',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (value) => sendCommand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}