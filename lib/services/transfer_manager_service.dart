import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background Transfer Manager Service
/// Handles persistent SFTP connections and file transfers in a background isolate
class TransferManagerService {
  static const String _channelId = 'transfer_manager_channel';
  static const int _notificationId = 2000;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      'Transfer Manager',
      description: 'Manages file transfers with persistent SFTP connection',
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Configure background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Transfer Manager',
        initialNotificationContent: 'Ready',
        foregroundServiceNotificationId: _notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// iOS background handler
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Main background service entry point
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    debugPrint('TransferManager: Service started');

    // Service state
    SSHClient? sshClient;
    SftpClient? sftpClient;
    Map<String, dynamic>? connectionConfig;
    Timer? keepaliveTimer;
    bool isConnected = false;

    // Update notification helper
    Future<void> updateNotification(String title, String body, {int? progress}) async {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        'Transfer Manager',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: progress != null,
        maxProgress: 100,
        progress: progress ?? 0,
        ongoing: true,
        autoCancel: false,
      );

      await _notifications.show(
        _notificationId,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
    }

    // Keepalive mechanism - sends dummy command every 30 seconds
    void startKeepalive() {
      keepaliveTimer?.cancel();
      keepaliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (!isConnected || sshClient == null) {
          timer.cancel();
          return;
        }

        try {
          // Send a simple echo command to keep connection alive
          await sshClient!.run('echo "keepalive"').timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('TransferManager: Keepalive timeout');
              return Uint8List(0);
            },
          );
          debugPrint('TransferManager: Keepalive sent');
        } catch (e) {
          debugPrint('TransferManager: Keepalive error: $e');
          if (e.toString().contains('closed') || e.toString().contains('Closed')) {
            isConnected = false;
            timer.cancel();
            service.invoke('connectionLost');
          }
        }
      });
    }

    // Connect to SSH/SFTP
    Future<bool> connect(Map<String, dynamic> config) async {
      try {
        connectionConfig = config;

        await updateNotification('Connecting...', 'Establishing SFTP connection');

        final socket = await SSHSocket.connect(
          config['host'],
          config['port'],
          timeout: const Duration(seconds: 30),
        );

        sshClient = SSHClient(
          socket,
          username: config['username'],
          onPasswordRequest: () => config['password'],
        );

        sftpClient = await sshClient!.sftp();
        isConnected = true;

        startKeepalive();

        await updateNotification('Connected', 'SFTP connection established');
        service.invoke('connected');

        debugPrint('TransferManager: Connected to ${config['host']}');
        return true;
      } catch (e) {
        debugPrint('TransferManager: Connection failed: $e');
        await updateNotification('Connection Failed', e.toString());
        service.invoke('connectionFailed', {'error': e.toString()});
        return false;
      }
    }

    // Disconnect
    Future<void> disconnect() async {
      keepaliveTimer?.cancel();
      keepaliveTimer = null;
      sftpClient = null;
      sshClient?.close();
      sshClient = null;
      isConnected = false;
      await updateNotification('Disconnected', 'SFTP connection closed');
      debugPrint('TransferManager: Disconnected');
    }

    // Reconnect if connection was lost
    Future<bool> reconnect() async {
      if (connectionConfig == null) return false;
      await disconnect();
      await Future.delayed(const Duration(seconds: 2));
      return await connect(connectionConfig!);
    }

    // Download a single file
    Future<void> downloadFile({
      required String remotePath,
      required String localPath,
    }) async {
      if (sftpClient == null) {
        throw Exception('Not connected');
      }

      debugPrint('TransferManager: Downloading $remotePath -> $localPath');

      try {
        // Get file size
        final stat = await sftpClient!.stat(remotePath);
        final totalBytes = stat.size ?? 0;

        await updateNotification(
          'Downloading',
          remotePath.split('/').last,
          progress: 0,
        );

        final remoteFile = await sftpClient!.open(remotePath);
        final localFile = File(localPath);
        final sink = localFile.openWrite();

        int transferredBytes = 0;
        int lastProgress = 0;

        await for (final chunk in remoteFile.read()) {
          sink.add(chunk);
          transferredBytes += chunk.length;

          final progress = totalBytes > 0 ? ((transferredBytes / totalBytes) * 100).round() : 0;
          if (progress - lastProgress >= 5 || transferredBytes == totalBytes) {
            lastProgress = progress;
            await updateNotification(
              'Downloading',
              '${remotePath.split('/').last} - $progress%',
              progress: progress,
            );
            service.invoke('downloadProgress', {
              'remotePath': remotePath,
              'localPath': localPath,
              'progress': progress,
              'transferred': transferredBytes,
              'total': totalBytes,
            });
          }
        }

        await sink.flush();
        await sink.close();

        service.invoke('downloadComplete', {
          'remotePath': remotePath,
          'localPath': localPath,
        });

        debugPrint('TransferManager: Download complete: $localPath');
      } catch (e) {
        debugPrint('TransferManager: Download failed: $e');
        service.invoke('downloadFailed', {
          'remotePath': remotePath,
          'error': e.toString(),
        });
        rethrow;
      }
    }

    // Upload a single file
    Future<void> uploadFile({
      required String localPath,
      required String remotePath,
    }) async {
      if (sftpClient == null) {
        throw Exception('Not connected');
      }

      debugPrint('TransferManager: Uploading $localPath -> $remotePath');

      try {
        final localFile = File(localPath);
        final totalBytes = await localFile.length();

        await updateNotification(
          'Uploading',
          localPath.split('/').last,
          progress: 0,
        );

        final remoteFile = await sftpClient!.open(
          remotePath,
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.write |
              SftpFileOpenMode.truncate,
        );

        int transferredBytes = 0;
        int lastProgress = 0;

        final stream = localFile.openRead();

        await for (final chunk in stream) {
          await remoteFile.write(Stream.value(Uint8List.fromList(chunk)));
          transferredBytes += chunk.length;

          final progress = ((transferredBytes / totalBytes) * 100).round();
          if (progress - lastProgress >= 5 || transferredBytes == totalBytes) {
            lastProgress = progress;
            await updateNotification(
              'Uploading',
              '${localPath.split('/').last} - $progress%',
              progress: progress,
            );
            service.invoke('uploadProgress', {
              'localPath': localPath,
              'remotePath': remotePath,
              'progress': progress,
              'transferred': transferredBytes,
              'total': totalBytes,
            });
          }
        }

        await remoteFile.close();

        service.invoke('uploadComplete', {
          'localPath': localPath,
          'remotePath': remotePath,
        });

        debugPrint('TransferManager: Upload complete: $remotePath');
      } catch (e) {
        debugPrint('TransferManager: Upload failed: $e');
        service.invoke('uploadFailed', {
          'localPath': localPath,
          'error': e.toString(),
        });
        rethrow;
      }
    }

    // Recursive folder upload
    Future<void> uploadDirectory({
      required String localPath,
      required String remotePath,
    }) async {
      if (sftpClient == null) {
        final errorMsg = 'SFTP client is null - not connected to server';
        debugPrint('TransferManager: ERROR - $errorMsg');
        service.invoke('uploadFolderFailed', {
          'localPath': localPath,
          'error': errorMsg,
        });
        throw Exception(errorMsg);
      }

      if (!isConnected) {
        final errorMsg = 'Not connected to SSH server';
        debugPrint('TransferManager: ERROR - $errorMsg');
        service.invoke('uploadFolderFailed', {
          'localPath': localPath,
          'error': errorMsg,
        });
        throw Exception(errorMsg);
      }

      debugPrint('TransferManager: Uploading directory $localPath -> $remotePath');

      try {
        await updateNotification(
          'Uploading Folder',
          localPath.split('/').last,
        );

        // Check if remote directory exists, create if not
        try {
          await sftpClient!.stat(remotePath);
          debugPrint('TransferManager: Remote directory exists: $remotePath');
        } catch (e) {
          // Directory doesn't exist, create it
          debugPrint('TransferManager: Creating remote directory: $remotePath');
          await sftpClient!.mkdir(remotePath);
        }

        // List local directory contents
        final localDir = Directory(localPath);
        final items = await localDir.list().toList();

        int totalItems = items.length;
        int processedItems = 0;

        for (final item in items) {
          final itemName = item.path.split('/').last;
          final itemRemotePath = '$remotePath/$itemName';

          if (item is Directory) {
            // Recursively upload subdirectory
            await uploadDirectory(
              localPath: item.path,
              remotePath: itemRemotePath,
            );
          } else if (item is File) {
            // Upload file
            await uploadFile(
              localPath: item.path,
              remotePath: itemRemotePath,
            );
          }

          processedItems++;
          final progress = ((processedItems / totalItems) * 100).round();
          service.invoke('uploadFolderProgress', {
            'localPath': localPath,
            'remotePath': remotePath,
            'progress': progress,
            'processed': processedItems,
            'total': totalItems,
          });
        }

        service.invoke('uploadFolderComplete', {
          'localPath': localPath,
          'remotePath': remotePath,
        });

        await updateNotification('Folder Uploaded', localPath.split('/').last);
        debugPrint('TransferManager: Folder upload complete: $remotePath');
      } catch (e) {
        debugPrint('TransferManager: Folder upload failed: $e');
        service.invoke('uploadFolderFailed', {
          'localPath': localPath,
          'error': e.toString(),
        });
        rethrow;
      }
    }

    // Recursive folder download
    Future<void> downloadDirectory({
      required String remotePath,
      required String localPath,
    }) async {
      if (sftpClient == null) {
        final errorMsg = 'SFTP client is null - not connected to server';
        debugPrint('TransferManager: ERROR - $errorMsg');
        service.invoke('folderFailed', {
          'remotePath': remotePath,
          'error': errorMsg,
        });
        throw Exception(errorMsg);
      }

      if (!isConnected) {
        final errorMsg = 'Not connected to SSH server';
        debugPrint('TransferManager: ERROR - $errorMsg');
        service.invoke('folderFailed', {
          'remotePath': remotePath,
          'error': errorMsg,
        });
        throw Exception(errorMsg);
      }

      debugPrint('TransferManager: Downloading directory $remotePath -> $localPath');

      try {
        await updateNotification(
          'Downloading Folder',
          remotePath.split('/').last,
        );

        // Create local directory
        final localDir = Directory(localPath);
        if (!await localDir.exists()) {
          await localDir.create(recursive: true);
        }

        // List remote directory contents
        final items = await sftpClient!.listdir(remotePath);

        int totalItems = items.length;
        int processedItems = 0;

        for (final item in items) {
          // Skip . and ..
          if (item.filename == '.' || item.filename == '..') continue;

          final itemRemotePath = '$remotePath/${item.filename}';
          final itemLocalPath = '$localPath/${item.filename}';

          if (item.attr.isDirectory) {
            // Recursively download subdirectory
            await downloadDirectory(
              remotePath: itemRemotePath,
              localPath: itemLocalPath,
            );
          } else {
            // Download file
            await downloadFile(
              remotePath: itemRemotePath,
              localPath: itemLocalPath,
            );
          }

          processedItems++;
          final progress = ((processedItems / totalItems) * 100).round();
          service.invoke('folderProgress', {
            'remotePath': remotePath,
            'localPath': localPath,
            'progress': progress,
            'processed': processedItems,
            'total': totalItems,
          });
        }

        service.invoke('folderComplete', {
          'remotePath': remotePath,
          'localPath': localPath,
        });

        await updateNotification('Folder Downloaded', remotePath.split('/').last);
        debugPrint('TransferManager: Folder download complete: $localPath');
      } catch (e) {
        debugPrint('TransferManager: Folder download failed: $e');
        service.invoke('folderFailed', {
          'remotePath': remotePath,
          'error': e.toString(),
        });
        rethrow;
      }
    }

    // Handle commands from UI
    service.on('connect').listen((config) async {
      debugPrint('TransferManager: Received connect command');
      if (config == null) {
        debugPrint('TransferManager: ERROR - config is null');
        return;
      }
      debugPrint('TransferManager: Connecting to ${config['host']}:${config['port']}');
      await connect(Map<String, dynamic>.from(config));
    });

    service.on('disconnect').listen((event) async {
      await disconnect();
    });

    service.on('reconnect').listen((event) async {
      await reconnect();
    });

    service.on('downloadFile').listen((data) async {
      if (data == null) return;
      final params = Map<String, dynamic>.from(data);
      try {
        await downloadFile(
          remotePath: params['remotePath'],
          localPath: params['localPath'],
        );
      } catch (e) {
        debugPrint('TransferManager: Error in downloadFile: $e');
      }
    });

    service.on('uploadFile').listen((data) async {
      if (data == null) return;
      final params = Map<String, dynamic>.from(data);
      try {
        await uploadFile(
          localPath: params['localPath'],
          remotePath: params['remotePath'],
        );
      } catch (e) {
        debugPrint('TransferManager: Error in uploadFile: $e');
      }
    });

    service.on('uploadFolder').listen((data) async {
      debugPrint('TransferManager: Received uploadFolder command');
      if (data == null) {
        debugPrint('TransferManager: ERROR - uploadFolder data is null');
        return;
      }
      final params = Map<String, dynamic>.from(data);
      debugPrint('TransferManager: Uploading folder from ${params['localPath']} to ${params['remotePath']}');
      try {
        await uploadDirectory(
          localPath: params['localPath'],
          remotePath: params['remotePath'],
        );
      } catch (e) {
        debugPrint('TransferManager: Error in uploadFolder: $e');
      }
    });

    service.on('downloadFolder').listen((data) async {
      debugPrint('TransferManager: Received downloadFolder command');
      if (data == null) {
        debugPrint('TransferManager: ERROR - downloadFolder data is null');
        return;
      }
      final params = Map<String, dynamic>.from(data);
      debugPrint('TransferManager: Downloading folder from ${params['remotePath']} to ${params['localPath']}');
      try {
        await downloadDirectory(
          remotePath: params['remotePath'],
          localPath: params['localPath'],
        );
      } catch (e) {
        debugPrint('TransferManager: Error in downloadFolder: $e');
      }
    });

    service.on('stop').listen((event) async {
      await disconnect();
      await _notifications.cancel(_notificationId);
      service.stopSelf();
      debugPrint('TransferManager: Service stopped');
    });

    // Initial notification
    await updateNotification('Transfer Manager', 'Ready');
  }

  /// Start the service
  static Future<void> start() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    
    if (!isRunning) {
      debugPrint('TransferManagerService: Starting background service...');
      await service.startService();
      // Wait for service to initialize
      await Future.delayed(const Duration(seconds: 1));
      final nowRunning = await service.isRunning();
      debugPrint('TransferManagerService: Service running: $nowRunning');
    } else {
      debugPrint('TransferManagerService: Background service already running');
    }
  }

  /// Stop the service
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  /// Connect to SFTP
  static void connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) {
    debugPrint('TransferManagerService: Sending connect command to background service');
    debugPrint('TransferManagerService: Host=$host, Port=$port, Username=$username');
    final service = FlutterBackgroundService();
    service.invoke('connect', {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    });
  }

  /// Disconnect from SFTP
  static void disconnect() {
    final service = FlutterBackgroundService();
    service.invoke('disconnect');
  }

  /// Download a file
  static void downloadFile({
    required String remotePath,
    required String localPath,
  }) {
    final service = FlutterBackgroundService();
    service.invoke('downloadFile', {
      'remotePath': remotePath,
      'localPath': localPath,
    });
  }

  /// Upload a file
  static void uploadFile({
    required String localPath,
    required String remotePath,
  }) {
    final service = FlutterBackgroundService();
    service.invoke('uploadFile', {
      'localPath': localPath,
      'remotePath': remotePath,
    });
  }

  /// Upload a folder recursively
  static Future<void> uploadFolder({
    required String localPath,
    required String remotePath,
  }) async {
    final service = FlutterBackgroundService();
    
    // Check if service is running
    final isRunning = await service.isRunning();
    if (!isRunning) {
      debugPrint('TransferManagerService: ERROR - Background service is not running!');
      debugPrint('TransferManagerService: Starting service now...');
      await start();
    }
    
    debugPrint('TransferManagerService: Sending uploadFolder command');
    debugPrint('TransferManagerService: LocalPath=$localPath, RemotePath=$remotePath');
    
    service.invoke('uploadFolder', {
      'localPath': localPath,
      'remotePath': remotePath,
    });
    
    debugPrint('TransferManagerService: Command invoked');
  }

  /// Download a folder recursively
  static Future<void> downloadFolder({
    required String remotePath,
    required String localPath,
  }) async {
    final service = FlutterBackgroundService();
    
    // Check if service is running
    final isRunning = await service.isRunning();
    if (!isRunning) {
      debugPrint('TransferManagerService: ERROR - Background service is not running!');
      debugPrint('TransferManagerService: Starting service now...');
      await start();
    }
    
    debugPrint('TransferManagerService: Sending downloadFolder command');
    debugPrint('TransferManagerService: RemotePath=$remotePath, LocalPath=$localPath');
    
    service.invoke('downloadFolder', {
      'remotePath': remotePath,
      'localPath': localPath,
    });
    
    debugPrint('TransferManagerService: Command invoked');
  }

  /// Listen to service events
  static Stream<Map<String, dynamic>?> get events {
    final service = FlutterBackgroundService();
    // Listen to all events
    return Stream.multi((controller) {
      service.on('connected').listen((event) => controller.add({'type': 'connected'}));
      service.on('connectionFailed').listen((event) => controller.add({'type': 'connectionFailed', 'data': event}));
      service.on('connectionLost').listen((event) => controller.add({'type': 'connectionLost'}));
      service.on('downloadProgress').listen((event) => controller.add({'type': 'downloadProgress', 'data': event}));
      service.on('downloadComplete').listen((event) => controller.add({'type': 'downloadComplete', 'data': event}));
      service.on('downloadFailed').listen((event) => controller.add({'type': 'downloadFailed', 'data': event}));
      service.on('uploadProgress').listen((event) => controller.add({'type': 'uploadProgress', 'data': event}));
      service.on('uploadComplete').listen((event) => controller.add({'type': 'uploadComplete', 'data': event}));
      service.on('uploadFailed').listen((event) => controller.add({'type': 'uploadFailed', 'data': event}));
      service.on('uploadFolderProgress').listen((event) => controller.add({'type': 'uploadFolderProgress', 'data': event}));
      service.on('uploadFolderComplete').listen((event) => controller.add({'type': 'uploadFolderComplete', 'data': event}));
      service.on('uploadFolderFailed').listen((event) => controller.add({'type': 'uploadFolderFailed', 'data': event}));
      service.on('folderProgress').listen((event) => controller.add({'type': 'folderProgress', 'data': event}));
      service.on('folderComplete').listen((event) => controller.add({'type': 'folderComplete', 'data': event}));
      service.on('folderFailed').listen((event) => controller.add({'type': 'folderFailed', 'data': event}));
    });
  }
}
