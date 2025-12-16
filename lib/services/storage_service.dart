import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/ssh_connection.dart';
import '../constants/app_constants.dart';

class StorageService {
  final _storage = GetStorage();

  Future<void> init() async {
    await GetStorage.init();
  }

  // SSH Connections
  List<SSHConnection> getConnections() {
    final data = _storage.read(AppConstants.storageKeyConnections);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => SSHConnection.fromJson(json)).toList();
  }

  Future<void> saveConnections(List<SSHConnection> connections) async {
    final jsonList = connections.map((c) => c.toJson()).toList();
    await _storage.write(AppConstants.storageKeyConnections, jsonEncode(jsonList));
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
