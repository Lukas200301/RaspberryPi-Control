import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final bool updateAvailable;
  final List<ReleaseNote> releaseNotes;
  final String downloadUrl;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.updateAvailable,
    required this.releaseNotes,
    required this.downloadUrl,
  });
}

class ReleaseNote {
  final String version;
  final String title;
  final String body;
  final String publishedAt;
  final String downloadUrl;

  ReleaseNote({
    required this.version,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.downloadUrl,
  });

  factory ReleaseNote.fromJson(Map<String, dynamic> json) {
    String downloadUrl = '';
    
    // Find the APK asset in the release
    if (json['assets'] != null && json['assets'] is List) {
      for (var asset in json['assets']) {
        if (asset['name'].toString().endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] ?? '';
          break;
        }
      }
    }

    return ReleaseNote(
      version: (json['tag_name'] as String).replaceAll('v', ''),
      title: json['name'] ?? json['tag_name'] ?? '',
      body: json['body'] ?? 'No release notes available.',
      publishedAt: json['published_at'] ?? '',
      downloadUrl: downloadUrl,
    );
  }
}

class UpdateService {
  static const String repoOwner = 'Lukas200301';
  static const String repoName = 'RaspberryPi-Control';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName/releases';

  /// Check for updates and return update information
  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint('Current version: $currentVersion');

      // Fetch releases from GitHub
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('Failed to fetch releases: ${response.statusCode}');
        return null;
      }

      final List<dynamic> releases = json.decode(response.body);
      
      if (releases.isEmpty) {
        debugPrint('No releases found');
        return null;
      }

      // Get latest release
      final latestRelease = releases.first;
      final latestVersion = (latestRelease['tag_name'] as String).replaceAll('v', '');

      debugPrint('Latest version: $latestVersion');

      // Compare versions
      final updateAvailable = _isNewerVersion(currentVersion, latestVersion);

      // Get all release notes between current and latest
      final List<ReleaseNote> releaseNotes = [];
      
      for (var release in releases) {
        final releaseVersion = (release['tag_name'] as String).replaceAll('v', '');
        
        // Include all releases newer than current version
        if (_isNewerVersion(currentVersion, releaseVersion)) {
          releaseNotes.add(ReleaseNote.fromJson(release));
        } else {
          break; // Stop when we reach current or older versions
        }
      }

      // Find download URL for latest release
      String downloadUrl = '';
      if (latestRelease['assets'] != null && latestRelease['assets'] is List) {
        for (var asset in latestRelease['assets']) {
          if (asset['name'].toString().endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] ?? '';
            break;
          }
        }
      }

      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        updateAvailable: updateAvailable,
        releaseNotes: releaseNotes,
        downloadUrl: downloadUrl,
      );
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  /// Compare two version strings (e.g., "1.0.0" vs "1.0.1")
  bool _isNewerVersion(String currentVersion, String latestVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = latestVersion.split('.').map(int.parse).toList();

      // Pad shorter version with zeros
      while (current.length < latest.length) {
        current.add(0);
      }
      while (latest.length < current.length) {
        latest.add(0);
      }

      for (int i = 0; i < current.length; i++) {
        if (latest[i] > current[i]) {
          return true;
        } else if (latest[i] < current[i]) {
          return false;
        }
      }

      return false; // Versions are equal
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
}
