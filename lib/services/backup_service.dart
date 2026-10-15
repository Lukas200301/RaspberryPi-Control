import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import '../models/alerts.dart';
import '../models/ssh_connection.dart';

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}

/// What a backup holds once decrypted
class BackupContents {
  final DateTime created;
  final String appVersion;
  final List<SSHConnection> devices;
  final bool includesSecrets;

  /// App storage (settings, layout, pinned tools, ...) except the devices
  final Map<String, dynamic> storage;
  final AlertRules? alertRules;

  const BackupContents({
    required this.created,
    required this.appVersion,
    required this.devices,
    required this.includesSecrets,
    required this.storage,
    this.alertRules,
  });

  Map<String, dynamic> toJson() => {
    'created': created.toIso8601String(),
    'appVersion': appVersion,
    'includesSecrets': includesSecrets,
    'devices': devices.map((d) => d.toJson()).toList(),
    'storage': storage,
    if (alertRules != null) 'alertRules': alertRules!.toJson(),
  };

  factory BackupContents.fromJson(Map<String, dynamic> j) => BackupContents(
    created: DateTime.tryParse(j['created'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    appVersion: j['appVersion'] as String? ?? '',
    includesSecrets: j['includesSecrets'] as bool? ?? false,
    devices: [
      for (final d in (j['devices'] as List?) ?? const [])
        if (d is Map) SSHConnection.fromJson(Map<String, dynamic>.from(d)),
    ],
    storage: Map<String, dynamic>.from((j['storage'] as Map?) ?? const {}),
    alertRules: j['alertRules'] is Map ? AlertRules.fromJson(Map<String, dynamic>.from(j['alertRules'] as Map)) : null,
  );
}

/// Password-protected backups: PBKDF2-HMAC-SHA256 derives an AES-256-GCM key.
///
/// File layout (JSON): format, version, kdf {iterations, salt}, nonce, mac, data
/// (all binary values base64).
class BackupService {
  static const format = 'raspberrypi-control-backup';
  static const version = 1;
  static const _iterations = 210000;
  static const fileExtension = 'pibackup';

  static String suggestedFileName([DateTime? now]) {
    final t = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'pi-control-${t.year}-${two(t.month)}-${two(t.day)}.$fileExtension';
  }

  /// Everything worth keeping from the app storage, devices excluded
  static Map<String, dynamic> collectStorage() {
    final box = GetStorage();
    final keys = box.getKeys<Iterable<String>>();
    return {
      for (final k in keys)
        if (k != AppConstants.storageKeyConnections) k: box.read(k),
    };
  }

  static Future<Uint8List> encrypt(BackupContents contents, String password) {
    final plain = utf8.encode(jsonEncode(contents.toJson()));
    return Isolate.run(() async {
      final random = Random.secure();
      final salt = List<int>.generate(16, (_) => random.nextInt(256));
      final key = await _key(password, salt, _iterations);
      final algorithm = AesGcm.with256bits();
      final box = await algorithm.encrypt(plain, secretKey: key, nonce: algorithm.newNonce());
      return Uint8List.fromList(utf8.encode(jsonEncode({
        'format': format,
        'version': version,
        'kdf': {'name': 'pbkdf2-hmac-sha256', 'iterations': _iterations, 'salt': base64Encode(salt)},
        'cipher': 'aes-256-gcm',
        'nonce': base64Encode(box.nonce),
        'mac': base64Encode(box.mac.bytes),
        'data': base64Encode(box.cipherText),
      })));
    });
  }

  /// Throws [BackupException] for foreign files and wrong passwords
  static Future<BackupContents> decrypt(Uint8List bytes, String password) async {
    final Map<String, dynamic> file;
    try {
      file = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException('This is not a Raspberry Pi Control backup.');
    }
    if (file['format'] != format) throw const BackupException('This is not a Raspberry Pi Control backup.');
    if ((file['version'] as num? ?? 0) > version) {
      throw const BackupException('This backup was made by a newer version of the app. Update the app first.');
    }
    final plain = await Isolate.run(() async {
      try {
        final kdf = file['kdf'] as Map<String, dynamic>;
        final key = await _key(password, base64Decode(kdf['salt'] as String), (kdf['iterations'] as num).toInt());
        return await AesGcm.with256bits().decrypt(
          SecretBox(
            base64Decode(file['data'] as String),
            nonce: base64Decode(file['nonce'] as String),
            mac: Mac(base64Decode(file['mac'] as String)),
          ),
          secretKey: key,
        );
      } on SecretBoxAuthenticationError {
        return null;
      }
    });
    if (plain == null) throw const BackupException('Wrong password, or the file is damaged.');
    return BackupContents.fromJson(jsonDecode(utf8.decode(plain)) as Map<String, dynamic>);
  }

  static Future<SecretKey> _key(String password, List<int> salt, int iterations) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256)
          .deriveKeyFromPassword(password: password, nonce: salt);

  /// Writes the stored values back; keys the backup does not have stay as they are
  static Future<void> restoreStorage(Map<String, dynamic> storage) async {
    final box = GetStorage();
    for (final e in storage.entries) {
      if (e.key == AppConstants.storageKeyConnections) continue;
      await box.write(e.key, e.value);
    }
  }

  /// Devices after an import: [replace] drops devices missing in the backup.
  /// Without secrets in the backup, known devices keep their saved logins.
  static List<SSHConnection> mergeDevices(List<SSHConnection> current, BackupContents backup, {required bool replace}) {
    final byId = {for (final c in current) c.id: c};
    final result = <SSHConnection>[if (!replace) ...current];
    for (final d in backup.devices) {
      final existing = byId[d.id];
      final hasSecrets = d.password.isNotEmpty || d.privateKey.isNotEmpty;
      final merged = existing != null && !hasSecrets
          ? d.copyWith(password: existing.password, privateKey: existing.privateKey, passphrase: existing.passphrase)
          : d;
      final i = result.indexWhere((c) => c.id == d.id);
      if (i >= 0) {
        result[i] = merged;
      } else {
        result.add(merged);
      }
    }
    return result;
  }
}
