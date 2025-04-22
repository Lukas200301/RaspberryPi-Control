import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

class UpdateService {
  static const String _githubAllReleasesUrl = 'https://api.github.com/repos/Lukas200301/RaspberryPi-Control/releases';
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
        Uri.parse(_githubAllReleasesUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to check for updates: ${response.statusCode}');
      }
      
      final List<dynamic> releases = json.decode(response.body);
      
      if (releases.isEmpty) {
        throw Exception('No releases found');
      }
      
      final latestRelease = releases.first;
      
      String latestVersion = latestRelease['tag_name'] as String;
      if (latestVersion.startsWith('v')) {
        latestVersion = latestVersion.substring(1);
      }
      
      final bool updateAvailable = _isNewerVersion(latestVersion, cleanCurrentVersion);
      
      List<Map<String, dynamic>> newerReleases = [];
      for (var release in releases) {
        String releaseVersion = release['tag_name'] as String;
        if (releaseVersion.startsWith('v')) {
          releaseVersion = releaseVersion.substring(1);
        }
        
        if (_isNewerVersion(releaseVersion, cleanCurrentVersion)) {
          newerReleases.add({
            'version': releaseVersion,
            'notes': release['body'] as String? ?? 'No release notes available',
            'date': release['published_at'] as String? ?? '',
          });
        }
      }
      
      newerReleases.sort((a, b) => _compareVersions(b['version'] as String, a['version'] as String));
      
      final StringBuffer combinedNotes = StringBuffer();
      for (var release in newerReleases) {
        combinedNotes.writeln('## Version ${release['version']}');
        if (release['date'].isNotEmpty) {
          try {
            final DateTime releaseDate = DateTime.parse(release['date']);
            combinedNotes.writeln('_Released: ${releaseDate.toIso8601String().split('T')[0]}_\n');
          } catch (e) {
          }
        }
        combinedNotes.writeln('${release['notes']}\n');
        combinedNotes.writeln('---\n');
      }
      
      String? downloadUrl;
      String? windowsDownloadUrl;
      
      if (latestRelease['assets'] != null && (latestRelease['assets'] as List).isNotEmpty) {
        for (var asset in latestRelease['assets']) {
          final assetName = asset['name'].toString().toLowerCase();
          final browserDownloadUrl = asset['browser_download_url'] as String?;
          
          if (assetName.endsWith('.apk')) {
            downloadUrl = browserDownloadUrl;
          } else if (assetName.endsWith('.exe') || assetName.endsWith('.msi')) {
            windowsDownloadUrl = browserDownloadUrl;
          }
        }
      }
      
      return {
        'currentVersion': cleanCurrentVersion,
        'latestVersion': latestVersion,
        'updateAvailable': updateAvailable,
        'releaseNotes': combinedNotes.toString().trim(),
        'downloadUrl': downloadUrl,
        'windowsDownloadUrl': windowsDownloadUrl,
        'releaseUrl': latestRelease['html_url'] as String? ?? _githubReleaseUrl,
        'newerReleases': newerReleases,
      };
    } catch (e) {
      print('Error checking for updates: $e');
      return {
        'error': e.toString(),
        'updateAvailable': false,
      };
    }
  }
  
  static int _compareVersions(String version1, String version2) {
    final List<int> v1 = version1.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    final List<int> v2 = version2.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    
    while (v1.length < v2.length) v1.add(0);
    while (v2.length < v1.length) v2.add(0);
    
    for (int i = 0; i < v1.length; i++) {
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }
    
    return 0;
  }
  
  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    return _compareVersions(latestVersion, currentVersion) > 0;
  }
  
  static Future<bool> _requestStoragePermission() async {
    int? sdkVersion;
    
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      sdkVersion = androidInfo.version.sdkInt;
      print('Android SDK version: $sdkVersion');
    } catch (e) {
      print('Failed to get Android SDK version: $e');
      sdkVersion = null;
    }
    
    if (sdkVersion != null && sdkVersion >= 30) { 
      if (await ph.Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      final status = await ph.Permission.manageExternalStorage.request();
      return status.isGranted;
    } 
    else {
      if (await ph.Permission.storage.isGranted) {
        return true;
      }
      
      bool hasPermission = (await ph.Permission.storage.request()).isGranted;
      
      try {
        if (!hasPermission) {
          hasPermission = (await ph.Permission.manageExternalStorage.request()).isGranted;
        }
      } catch (e) {
        print('Could not request manageExternalStorage: $e');
      }
      
      return hasPermission;
    }
  }
  
  static Future<bool> _requestInstallPermission() async {
    if (await ph.Permission.requestInstallPackages.isGranted) {
      return true;
    }
    
    final status = await ph.Permission.requestInstallPackages.request();
    return status.isGranted;
  }
  
  static Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      print('Failed to open app settings: $e');
      return false;
    }
  }
  
  static Future<bool> openInstallPackageSettings() async {
    try {
      if (Platform.isAndroid) {
        String packageName;
        try {
          final info = await PackageInfo.fromPlatform();
          packageName = info.packageName;
        } catch (e) {
          print('Error getting package info: $e');
          packageName = 'com.lukas200301.raspberrypi_control';
        }
        
        final intent = AndroidIntent(
          action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
          data: 'package:$packageName',
        );
        
        try {
          await intent.launch();
          return true;
        } catch (e) {
          print('Error launching MANAGE_UNKNOWN_APP_SOURCES intent: $e');
          
          final appSettingsIntent = AndroidIntent(
            action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
            data: 'package:$packageName',
          );
          
          try {
            await appSettingsIntent.launch();
            return true;
          } catch (e2) {
            print('Error launching APPLICATION_DETAILS_SETTINGS intent: $e2');
            return await ph.openAppSettings();
          }
        }
      } else {
        return await ph.openAppSettings();
      }
    } catch (e) {
      print('Failed to open install package settings: $e');
      return false;
    }
  }
  
  static Future<bool> launchUrlSafely(String url, {bool useInAppBrowser = true}) async {
    final Uri uri = Uri.parse(url);
    try {
      return await launchUrl(
        uri, 
        mode: useInAppBrowser 
          ? LaunchMode.inAppWebView 
          : LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Failed to launch URL: $e');
      return false;
    }
  }
  
  static Future<void> downloadAndInstallUpdate(
    String url,
    Function(double) onProgress,
    Function(String) onError,
    VoidCallback onSuccess,
  ) async {
    try {
      print('Starting download and install process...');
      
      if (Platform.isWindows) {
        await _downloadAndInstallWindowsUpdate(url, onProgress, onError, onSuccess);
        return;
      }
      
      if (Platform.isAndroid) {
        bool storageGranted = await _requestStoragePermission();
        
        if (!storageGranted) {
          onError('Storage permission denied. Cannot download update without storage access.');
          return;
        }
        
        print('Storage permission granted, proceeding with download');
      }
      
      Directory? directory;
      try {
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          print('External storage directory: ${directory?.path}');
        }
      } catch (e) {
        print('Failed to get external storage directory: $e');
      }
      
      directory ??= await getTemporaryDirectory();
      
      final filePath = '${directory.path}/raspberrypi_control_update.apk';
      final file = File(filePath);
      
      print('Will download to: $filePath');
      
      if (file.existsSync()) {
        try {
          await file.delete();
          print('Deleted existing file');
        } catch (e) {
          print('Failed to delete existing file: $e');
          onError('Failed to prepare for download: $e');
          return;
        }
      }
      
      try {
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
          print('Created directory: ${directory.path}');
        }
      } catch (e) {
        print('Failed to create directory: $e');
        onError('Failed to create download directory: $e');
        return;
      }
      
      try {
        final testFile = File('${directory.path}/test_write.txt');
        await testFile.writeAsString('test');
        await testFile.delete();
        print('Successfully tested write permissions');
      } catch (e) {
        print('Failed to write test file: $e');
        onError('No write permission to download directory: $e');
        return;
      }
      
      print('Starting actual download...');
      final client = http.Client();
      
      try {
        final response = await client.send(http.Request('GET', Uri.parse(url)));
        
        if (response.statusCode != 200) {
          onError('Failed to download update: HTTP ${response.statusCode}');
          client.close();
          return;
        }
        
        final contentLength = response.contentLength ?? 0;
        int totalBytesDownloaded = 0;
        
        final fileStream = file.openWrite();
        
        await response.stream.forEach((data) {
          fileStream.add(data);
          totalBytesDownloaded += data.length;
          
          if (contentLength > 0) {
            final progress = totalBytesDownloaded / contentLength;
            onProgress(progress);
          }
        });
        
        await fileStream.flush();
        await fileStream.close();
        print('Download completed successfully');
      } catch (e) {
        print('Error during download: $e');
        onError('Download error: $e');
        client.close();
        return;
      } finally {
        client.close();
      }
      
      print('APK downloaded to: ${file.path}');
      print('File exists: ${file.existsSync()}');
      print('File size: ${file.lengthSync()} bytes');
      
      if (file.existsSync()) {
        if (Platform.isAndroid) {
          try {
            bool installPermissionGranted = await _requestInstallPermission();
            
            if (!installPermissionGranted) {
              onError('Permission to install packages denied.\n\nPlease enable "Install unknown apps" for this app in Settings > Apps > Special app access > Install unknown apps.');
              return;
            }
            
            print('Install permission granted, attempting to install APK');
            
            final platform = MethodChannel('com.lukas200301.raspberrypi_control');
            
            try {
              print('Calling native install method with path: ${file.path}');
              final result = await platform.invokeMethod('installApk', {
                'filePath': file.path,
              });
              
              print('Install method result: $result');
              
              if (result == true) {
                print('Installation process started');
                onSuccess();
              } else {
                throw Exception('Failed to launch installer');
              }
            } catch (e) {
              print('Error calling native install method: $e');
              onError('Installation failed: $e\n\nPlease try opening the release page and downloading manually.');
              
              try {
                await launchUrl(
                  Uri.parse(_githubReleaseUrl),
                  mode: LaunchMode.externalApplication
                );
              } catch (e) {
                print('Failed to open release page: $e');
              }
            }
          } catch (e) {
            print('Error installing APK: $e');
            onError('Installation failed: $e');
            
            try {
              await launchUrl(
                Uri.parse(_githubReleaseUrl),
                mode: LaunchMode.externalApplication
              );
            } catch (e) {
              print('Failed to open release page: $e');
            }
          }
        } else {
          try {
            await launchUrl(
              Uri.parse(_githubReleaseUrl),
              mode: LaunchMode.externalApplication
            );
            onSuccess();
          } catch (e) {
            onError('Error opening release page: $e');
          }
        }
      } else {
        onError('Downloaded file not found');
      }
    } catch (e) {
      print('Error during update process: $e');
      onError(e.toString());
    }
  }
  
  static Future<void> _downloadAndInstallWindowsUpdate(
    String url,
    Function(double) onProgress,
    Function(String) onError,
    VoidCallback onSuccess,
  ) async {
    try {
      print('Starting Windows update download and installation process...');
      
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = url.split('/').last;
      final String fileExtension = fileName.split('.').last.toLowerCase();
      
      if (fileExtension != 'exe' && fileExtension != 'msi') {
        onError('Invalid Windows installer file format. Expected .exe or .msi, got .$fileExtension');
        return;
      }
      
      final String filePath = '${tempDir.path}\\$fileName';
      final File file = File(filePath);
      
      print('Will download Windows installer to: $filePath');
      
      if (file.existsSync()) {
        try {
          await file.delete();
          print('Deleted existing installer file');
        } catch (e) {
          print('Failed to delete existing file: $e');
          onError('Failed to prepare for download: $e');
          return;
        }
      }
      
      try {
        if (!tempDir.existsSync()) {
          tempDir.createSync(recursive: true);
        }
      } catch (e) {
        print('Failed to create temporary directory: $e');
        onError('Failed to create download directory: $e');
        return;
      }
      
      print('Starting Windows installer download...');
      final client = http.Client();
      
      try {
        final response = await client.send(http.Request('GET', Uri.parse(url)));
        
        if (response.statusCode != 200) {
          onError('Failed to download update: HTTP ${response.statusCode}');
          client.close();
          return;
        }
        
        final contentLength = response.contentLength ?? 0;
        int totalBytesDownloaded = 0;
        
        final fileStream = file.openWrite();
        
        await response.stream.forEach((data) {
          fileStream.add(data);
          totalBytesDownloaded += data.length;
          
          if (contentLength > 0) {
            final progress = totalBytesDownloaded / contentLength;
            onProgress(progress);
          }
        });
        
        await fileStream.flush();
        await fileStream.close();
        print('Download completed successfully: ${file.path}');
      } catch (e) {
        print('Error during download: $e');
        onError('Download error: $e');
        client.close();
        return;
      } finally {
        client.close();
      }
      
      if (!file.existsSync()) {
        onError('Downloaded file not found');
        return;
      }
      
      if (file.lengthSync() == 0) {
        onError('Downloaded file is empty');
        return;
      }
      
      print('Installer downloaded to: ${file.path}');
      print('File exists: ${file.existsSync()}');
      print('File size: ${file.lengthSync()} bytes');
      
      try {
        print('Launching Windows installer: ${file.path}');
        
        final ProcessResult result = await Process.run(
          file.path,
          [], 
          runInShell: true,
        );
        
        if (result.exitCode != 0) {
          print('Installer non-zero exit code: ${result.exitCode}');
          print('Installer stderr: ${result.stderr}');
          
          onSuccess();
        } else {
          print('Installer launched successfully');
          onSuccess();
        }
      } catch (e) {
        print('Error launching installer: $e');
        
        try {
          final Uri fileUri = Uri.file(file.path);
          if (await launchUrl(fileUri)) {
            print('Launched installer via URL protocol');
            onSuccess();
          } else {
            throw Exception('Failed to launch via URL protocol');
          }
        } catch (urlError) {
          print('Error launching via URL: $urlError');
          onError('Failed to launch installer. Please try downloading it manually.');
          
          try {
            await launchUrl(
              Uri.parse(_githubReleaseUrl),
              mode: LaunchMode.externalApplication
            );
          } catch (e) {
            print('Failed to open release page: $e');
          }
        }
      }
    } catch (e) {
      print('Error during Windows update process: $e');
      onError(e.toString());
    }
  }
}
