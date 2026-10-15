import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ssh_connection.dart';

/// Passwords, keys and passphrases of one device
@immutable
class DeviceSecret {
  final String password;
  final String privateKey;
  final String passphrase;

  const DeviceSecret({this.password = '', this.privateKey = '', this.passphrase = ''});

  factory DeviceSecret.of(SSHConnection c) =>
      DeviceSecret(password: c.password, privateKey: c.privateKey, passphrase: c.passphrase);

  bool get isEmpty => password.isEmpty && privateKey.isEmpty && passphrase.isEmpty;

  Map<String, String> toJson() => {
    if (password.isNotEmpty) 'password': password,
    if (privateKey.isNotEmpty) 'privateKey': privateKey,
    if (passphrase.isNotEmpty) 'passphrase': passphrase,
  };

  factory DeviceSecret.fromJson(Map<String, dynamic> j) => DeviceSecret(
    password: j['password'] as String? ?? '',
    privateKey: j['privateKey'] as String? ?? '',
    passphrase: j['passphrase'] as String? ?? '',
  );

  SSHConnection applyTo(SSHConnection c) =>
      c.copyWith(password: password, privateKey: privateKey, passphrase: passphrase);
}

/// The platform's encrypted storage (Android Keystore, Apple Keychain,
/// Windows DPAPI, libsecret) for device secrets and the app lock PIN.
///
/// When it is not available (e.g. Linux without a keyring), [available] is
/// false and secrets stay in the regular app storage as before.
class SecureStore {
  static const _secretsKey = 'device_secrets_v1';
  static const _pinKey = 'app_lock_pin_v1';

  // Never let the plugin "recover" from a read error by deleting data: a
  // transient failure would silently wipe every saved login
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: false));

  static bool available = false;
  static Map<String, DeviceSecret> _secrets = {};

  /// Loads the secrets; call once before devices are read
  static Future<void> init() async {
    try {
      _secrets = await readSecrets();
      available = true;
      await _markReady();
    } catch (e) {
      debugPrint('Secure storage unavailable, keeping secrets in app storage: $e');
      available = false;
    }
  }

  static DeviceSecret? secretOf(String id) => _secrets[id];

  // The first use creates the encryption key. If the background service did
  // that at the same moment as the app, each would hold a different key, so
  // the service only touches the storage once the app has set it up.
  static Future<File> _readyFile() async =>
      File('${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}secure_store_ready');

  static Future<void> _markReady() async {
    final f = await _readyFile();
    if (!await f.exists()) await f.writeAsString('1', flush: true);
  }

  /// For the background service: whether the app has initialised the storage
  static Future<bool> isReady() async {
    try {
      return await (await _readyFile()).exists();
    } catch (_) {
      return false;
    }
  }

  /// Fresh read, for isolates that did not call [init] (background monitor)
  static Future<Map<String, DeviceSecret>> readSecrets() async {
    final raw = await _storage.read(key: _secretsKey);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in map.entries)
        if (e.value is Map) e.key: DeviceSecret.fromJson(Map<String, dynamic>.from(e.value as Map)),
    };
  }

  /// Writes and reads back; throws when the stored copy differs, so callers
  /// only drop their plain copy once the secrets are safe
  static Future<void> writeSecrets(Map<String, DeviceSecret> secrets) async {
    final clean = {for (final e in secrets.entries) if (!e.value.isEmpty) e.key: e.value};
    final value = jsonEncode({for (final e in clean.entries) e.key: e.value.toJson()});
    await _storage.write(key: _secretsKey, value: value);
    final back = await _storage.read(key: _secretsKey);
    if (back != value) throw StateError('Secure storage did not keep the saved logins');
    _secrets = clean;
  }

  // ---------------- App lock PIN ----------------

  static const _iterations = 100000;

  /// Slow on purpose; runs on another isolate so the lock screen stays smooth
  static Future<List<int>> _derive(String pin, List<int> salt) => Isolate.run(() async {
    final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _iterations, bits: 256)
        .deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  });

  static Future<bool> hasPin() async {
    try {
      return (await _storage.read(key: _pinKey))?.isNotEmpty ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setPin(String pin) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _derive(pin, salt);
    await _storage.write(
      key: _pinKey,
      value: jsonEncode({'salt': base64Encode(salt), 'hash': base64Encode(hash), 'iterations': _iterations}),
    );
  }

  static Future<bool> verifyPin(String pin) async {
    final raw = await _storage.read(key: _pinKey);
    if (raw == null) return false;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final expected = base64Decode(j['hash'] as String);
    final actual = await _derive(pin, base64Decode(j['salt'] as String));
    if (actual.length != expected.length) return false;
    // Constant time compare
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  static Future<void> clearPin() => _storage.delete(key: _pinKey);
}
