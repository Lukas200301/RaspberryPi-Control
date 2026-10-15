import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../models/ssh_connection.dart';
import '../constants/app_constants.dart';
import 'secure_store.dart';

class StorageService {
  final _storage = GetStorage();

  Future<void> init() async {
    await GetStorage.init();
    await SecureStore.init();
    await _migrateSecrets();
  }

  List<SSHConnection> _readStored() {
    final data = _storage.read(AppConstants.storageKeyConnections);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => SSHConnection.fromJson(json)).toList();
  }

  /// Moves passwords and keys saved by older versions into secure storage
  Future<void> _migrateSecrets() async {
    if (!SecureStore.available) return;
    final stored = _readStored();
    if (stored.every((c) => DeviceSecret.of(c).isEmpty)) return;
    await saveConnections(getConnections());
  }

  // SSH Connections
  List<SSHConnection> getConnections() {
    return [
      for (final c in _readStored())
        if (SecureStore.available && DeviceSecret.of(c).isEmpty)
          SecureStore.secretOf(c.id)?.applyTo(c) ?? c
        else
          c,
    ];
  }

  /// Saves devices; with secure storage the secrets are kept there and the
  /// regular storage only holds names, hosts and users
  Future<void> saveConnections(List<SSHConnection> connections) async {
    if (SecureStore.available) {
      try {
        await SecureStore.writeSecrets({for (final c in connections) c.id: DeviceSecret.of(c)});
        connections = [for (final c in connections) const DeviceSecret().applyTo(c)];
      } catch (e) {
        // Keep working with the old behaviour rather than losing logins
        debugPrint('Secure storage write failed: $e');
      }
    }
    final jsonList = connections.map((c) => c.toJson()).toList();
    await _storage.write(
      AppConstants.storageKeyConnections,
      jsonEncode(jsonList),
    );
  }

  Future<void> addConnection(SSHConnection connection) async {
    final connections = getConnections();
    connections.add(connection);
    await saveConnections(connections);
  }

  Future<void> updateConnection(SSHConnection connection) async {
    final connections = getConnections();
    final index = connections.indexWhere((c) => c.id == connection.id);
    if (index != -1) {
      connections[index] = connection;
      await saveConnections(connections);
    }
  }

  Future<void> deleteConnection(String id) async {
    final connections = getConnections();
    connections.removeWhere((c) => c.id == id);
    await saveConnections(connections);
  }

  // Settings
  Map<String, dynamic> getSettings() {
    final data = _storage.read(AppConstants.storageKeySettings);
    if (data == null) return {};
    return jsonDecode(data);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _storage.write(AppConstants.storageKeySettings, jsonEncode(settings));
  }

  Future<void> clear() async {
    await _storage.erase();
  }
}
