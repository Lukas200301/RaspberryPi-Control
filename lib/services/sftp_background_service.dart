import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/transfer_job.dart';
import '../models/ssh_connection.dart';

/// Background service for handling SFTP file transfers
class SftpBackgroundService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'sftp_transfer_channel';
  static const String _channelName = 'File Transfers';
  static const int _notificationId = 1000;

  /// Initialize the background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Shows progress of file transfers',
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'File Transfer Service',
        initialNotificationContent: 'Ready to transfer files',
        foregroundServiceNotificationId: _notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Start the background service
  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// Stop the background service
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  /// Add a transfer job to the queue
  static void addTransferJob(TransferJob job, SSHConnection connection) {
    final service = FlutterBackgroundService();
    service.invoke('addJob', {
      'job': job.toJson(),
      'connection': {
        'host': connection.host,
        'port': connection.port,
        'username': connection.username,
        'password': connection.password,
      },
    });
  }

  /// Cancel a specific transfer job
  static void cancelJob(String jobId) {
    final service = FlutterBackgroundService();
    service.invoke('cancelJob', {'jobId': jobId});
  }

  /// Listen to transfer updates
  static Stream<Map<String, dynamic>> get updates {
    final service = FlutterBackgroundService();
    return service.on('update').where((event) => event != null).cast<Map<String, dynamic>>();
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

    // Background service state
    final List<TransferJob> queue = [];
    TransferJob? currentJob;
    SSHClient? sshClient;
    SftpClient? sftpClient;
    Map<String, dynamic>? connectionInfo;
    bool isProcessing = false;

    // Update notification helper
    Future<void> updateNotification({
      required String title,
      required String body,
      int? progress,
      int? maxProgress,
    }) async {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: progress != null,
        maxProgress: maxProgress ?? 100,
        progress: progress ?? 0,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        _notificationId,
        title,
        body,
        notificationDetails,
      );
    }

    // Connect to SSH/SFTP
    Future<bool> connect() async {
      if (connectionInfo == null) return false;

      try {
        await updateNotification(
          title: 'Connecting...',
          body: 'Establishing SSH connection',
        );

        final socket = await SSHSocket.connect(
          connectionInfo!['host'],
          connectionInfo!['port'],
          timeout: const Duration(seconds: 30),
        );

        sshClient = SSHClient(
          socket,
          username: connectionInfo!['username'],
          onPasswordRequest: () => connectionInfo!['password'],
        );

        sftpClient = await sshClient!.sftp();

        debugPrint('SFTP Background: Connected successfully');
        return true;
      } catch (e) {
        debugPrint('SFTP Background: Connection failed: $e');
        await updateNotification(
          title: 'Connection Failed',
          body: 'Could not connect to server',
        );
        return false;
      }
    }

    // Disconnect SSH/SFTP
    Future<void> disconnect() async {
      try {
        sftpClient = null;
        sshClient?.close();
        sshClient = null;
        debugPrint('SFTP Background: Disconnected');
      } catch (e) {
        debugPrint('SFTP Background: Disconnect error: $e');
      }
    }

    // Process a single transfer job
    Future<void> processJob(TransferJob job) async {
      currentJob = job;

      // Send status update to UI
      service.invoke('update', {'job': job.toJson()});

      try {
        // Ensure we're connected
        if (sftpClient == null) {
          final connected = await connect();
          if (!connected) {
            throw Exception('Failed to establish connection');
          }
        }

        job = job.copyWith(status: TransferStatus.connecting);
        service.invoke('update', {'job': job.toJson()});

        if (job.type == TransferType.download) {
          await _performDownload(job, sftpClient!, service, updateNotification);
        } else {
          await _performUpload(job, sftpClient!, service, updateNotification);
        }

        // Job completed successfully
        job = job.copyWith(status: TransferStatus.completed);
        service.invoke('update', {'job': job.toJson()});

        await updateNotification(
          title: 'Transfer Complete',
          body: '${job.type == TransferType.download ? "Downloaded" : "Uploaded"}: ${job.localPath.split('/').last}',
        );

        // Wait a bit before starting next job
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        debugPrint('SFTP Background: Job failed: $e');
        job = job.copyWith(
          status: TransferStatus.failed,
          error: e.toString(),
        );
        service.invoke('update', {'job': job.toJson()});

        await updateNotification(
          title: 'Transfer Failed',
          body: e.toString(),
        );

        // Disconnect on error - will reconnect for next job
        await disconnect();
      } finally {
        currentJob = null;
      }
    }

    // Process queue
    Future<void> processQueue() async {
      if (isProcessing || queue.isEmpty) return;

      isProcessing = true;

      while (queue.isNotEmpty) {
        final job = queue.removeAt(0);
        await processJob(job);
      }

      isProcessing = false;

      // Disconnect when queue is empty
      await disconnect();

      await updateNotification(
        title: 'All Transfers Complete',
        body: 'File transfer service is idle',
      );
    }

    // Handle service commands
    service.on('addJob').listen((event) {
      if (event == null) return;

      final jobData = event['job'] as Map<String, dynamic>;
      final connData = event['connection'] as Map<String, dynamic>;

      connectionInfo = connData;

      final job = TransferJob.fromJson(jobData);
      queue.add(job);

      debugPrint('SFTP Background: Added job ${job.id} to queue (${queue.length} total)');

      service.invoke('update', {'job': job.toJson()});

      // Start processing if not already running
      processQueue();
    });

    service.on('cancelJob').listen((event) {
      if (event == null) return;

      final jobId = event['jobId'] as String;

      // Remove from queue
      queue.removeWhere((job) => job.id == jobId);

      // Cancel current job if it matches
      if (currentJob?.id == jobId) {
        currentJob = currentJob?.copyWith(status: TransferStatus.cancelled);
        if (currentJob != null) {
          service.invoke('update', {'job': currentJob!.toJson()});
        }
        disconnect();
      }

      debugPrint('SFTP Background: Cancelled job $jobId');
    });

    service.on('stop').listen((event) async {
      await disconnect();
      queue.clear();
      currentJob = null;
      await _notifications.cancel(_notificationId);
      service.stopSelf();
      debugPrint('SFTP Background: Service stopped');
    });

    // Initial notification
    await updateNotification(
      title: 'File Transfer Service',
      body: 'Ready to transfer files',
    );

    debugPrint('SFTP Background: Service started');
  }

  /// Perform file download
  static Future<void> _performDownload(
    TransferJob job,
    SftpClient sftp,
    ServiceInstance service,
    Future<void> Function({
      required String title,
      required String body,
      int? progress,
      int? maxProgress,
    }) updateNotification,
  ) async {
    debugPrint('SFTP Background: Starting download ${job.remotePath}');

    job = job.copyWith(status: TransferStatus.transferring);
    service.invoke('update', {'job': job.toJson()});

    // Get file size
    final stat = await sftp.stat(job.remotePath);
    final totalBytes = stat.size ?? 0;
    job = job.copyWith(totalBytes: totalBytes);

    final file = await sftp.open(job.remotePath);
    final localFile = File(job.localPath);
    final sink = localFile.openWrite();

    int transferredBytes = 0;
    int lastProgressUpdate = 0;

    try {
      await for (final chunk in file.read()) {
        sink.add(chunk);
        transferredBytes += chunk.length;

        // Update progress every 5%
        final progress = ((transferredBytes / totalBytes) * 100).round();
        if (progress - lastProgressUpdate >= 5 || transferredBytes == totalBytes) {
          lastProgressUpdate = progress;

          job = job.copyWith(transferredBytes: transferredBytes);
          service.invoke('update', {'job': job.toJson()});

          await updateNotification(
            title: 'Downloading',
            body: '${job.remotePath.split('/').last} - $progress%',
            progress: progress,
            maxProgress: 100,
          );
        }
      }

      await sink.flush();
      await sink.close();

      debugPrint('SFTP Background: Download complete');
    } catch (e) {
      await sink.close();
      rethrow;
    }
  }

  /// Perform file upload
  static Future<void> _performUpload(
    TransferJob job,
    SftpClient sftp,
    ServiceInstance service,
    Future<void> Function({
      required String title,
      required String body,
      int? progress,
      int? maxProgress,
    }) updateNotification,
  ) async {
    debugPrint('SFTP Background: Starting upload ${job.localPath}');

    job = job.copyWith(status: TransferStatus.transferring);
    service.invoke('update', {'job': job.toJson()});

    final localFile = File(job.localPath);
    final totalBytes = await localFile.length();
    job = job.copyWith(totalBytes: totalBytes);

    final remoteFile = await sftp.open(
      job.remotePath,
      mode: SftpFileOpenMode.create |
          SftpFileOpenMode.write |
          SftpFileOpenMode.truncate,
    );

    int transferredBytes = 0;
    int lastProgressUpdate = 0;

    try {
      final stream = localFile.openRead();

      await for (final chunk in stream) {
        await remoteFile.write(Stream.value(Uint8List.fromList(chunk)));
        transferredBytes += chunk.length;

        // Update progress every 5%
        final progress = ((transferredBytes / totalBytes) * 100).round();
        if (progress - lastProgressUpdate >= 5 || transferredBytes == totalBytes) {
          lastProgressUpdate = progress;

          job = job.copyWith(transferredBytes: transferredBytes);
          service.invoke('update', {'job': job.toJson()});

          await updateNotification(
            title: 'Uploading',
            body: '${job.localPath.split('/').last} - $progress%',
            progress: progress,
            maxProgress: 100,
          );
        }
      }

      await remoteFile.close();

      debugPrint('SFTP Background: Upload complete');
    } catch (e) {
      await remoteFile.close();
      rethrow;
    }
  }
}
