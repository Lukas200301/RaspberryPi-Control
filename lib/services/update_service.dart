import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static const String _githubApiUrl = 'https://api.github.com/repos/Lukas200301/RaspberryPi-Control/releases/latest';
  static const String _githubReleaseUrl = 'https://github.com/Lukas200301/RaspberryPi-Control/releases/latest';
  
  static Future<Map<String, dynamic>> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      String cleanCurrentVersion = currentVersion;
      
      if (cleanCurrentVersion.contains('+')) {
        cleanCurrentVersion = cleanCurrentVersion.split('+')[0];
      }
      
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to check for updates: ${response.statusCode}');
      }
      
      final data = json.decode(response.body);
      
      String latestVersion = data['tag_name'] as String;
      if (latestVersion.startsWith('v')) {
        latestVersion = latestVersion.substring(1);
      }
      
      final bool updateAvailable = _isNewerVersion(latestVersion, cleanCurrentVersion);
      
      return {
        'currentVersion': cleanCurrentVersion,
        'latestVersion': latestVersion,
        'updateAvailable': updateAvailable,
        'releaseNotes': data['body'] as String? ?? 'No release notes available',
        'downloadUrl': data['assets']?.firstWhere(
          (asset) => asset['name'].toString().endsWith('.apk'),
          orElse: () => {'browser_download_url': null},
        )['browser_download_url'] as String?,
        'releaseUrl': data['html_url'] as String? ?? _githubReleaseUrl,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'updateAvailable': false,
      };
    }
  }
  
  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    final List<int> latest = latestVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    
    final List<int> current = currentVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    
    while (latest.length < current.length) latest.add(0);
    while (current.length < latest.length) current.add(0);
    
    for (int i = 0; i < latest.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    
    return false;
  }
  
  static Future<void> downloadAndInstallUpdate(
    String url,
    Function(double) onProgress,
    VoidCallback onError,
    VoidCallback onSuccess,
  ) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          onError();
          return;
        }
      }
      
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/raspberrypi_control_update.apk';
      final file = File(filePath);
      
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final contentLength = response.contentLength;
      int totalBytesDownloaded = 0;
      
      final fileStream = file.openWrite();
      
      await for (var data in response) {
        fileStream.add(data);
        totalBytesDownloaded += data.length;
        
        if (contentLength > 0) {
          final progress = totalBytesDownloaded / contentLength;
          onProgress(progress);
        }
      }
      
      await fileStream.flush();
      await fileStream.close();
      
      if (file.existsSync()) {
        if (Platform.isAndroid) {
          final uri = Uri.file(file.path);
          final installed = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (installed) {
            onSuccess();
          } else {
            onError();
          }
        } else {
          final uri = Uri.parse(_githubReleaseUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            onSuccess();
          } else {
            onError();
          }
        }
      } else {
        onError();
      }
    } catch (e) {
      print('Error during update: $e');
      onError();
    }
  }
}
