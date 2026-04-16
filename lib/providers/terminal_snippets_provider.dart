import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

class TerminalSnippetsNotifier extends Notifier<List<String>> {
  final _storage = GetStorage();
  final _key = 'terminal_snippets';

  @override
  List<String> build() {
    final list = _storage.read<List<dynamic>>(_key);
    if (list != null) {
      return list.map((e) => e.toString()).toList();
    }
    return [
      'sudo apt update && sudo apt upgrade -y',
      'docker ps -a',
      'df -h',
      'top -o %CPU',
      'curl -ifconfig.me',
    ]; // Default snippets
  }

  void addSnippet(String snippet) {
    if (!state.contains(snippet) && snippet.trim().isNotEmpty) {
      final newState = [...state, snippet.trim()];
      state = newState;
      _storage.write(_key, newState);
    }
  }

  void removeSnippet(String snippet) {
    if (state.contains(snippet)) {
      final newState = state.where((s) => s != snippet).toList();
      state = newState;
      _storage.write(_key, newState);
    }
  }
}

final terminalSnippetsProvider = NotifierProvider<TerminalSnippetsNotifier, List<String>>(
  TerminalSnippetsNotifier.new,
);
