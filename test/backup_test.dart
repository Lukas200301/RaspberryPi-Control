import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:raspberrypi_control/models/alerts.dart';
import 'package:raspberrypi_control/models/ssh_connection.dart';
import 'package:raspberrypi_control/services/backup_service.dart';

SSHConnection device(String id, {String password = ''}) =>
    SSHConnection(id: id, name: 'Pi $id', host: '10.0.0.$id', username: 'pi', password: password);

void main() {
  final contents = BackupContents(
    created: DateTime(2026, 10, 14, 12),
    appVersion: '3.4.0',
    devices: [device('1', password: 'secret')],
    includesSecrets: true,
    storage: {
      'app_settings_v2': {'themeMode': 'dark'},
      'pinned_tools': ['stats'],
    },
    alertRules: const AlertRules(enabled: true, diskPercent: 80),
  );

  test('round trip keeps everything', () async {
    final bytes = await BackupService.encrypt(contents, 'correct horse');
    // The password and data must not appear in the file
    final text = utf8.decode(bytes);
    expect(text.contains('secret'), isFalse);
    expect(text.contains('10.0.0.1'), isFalse);

    final back = await BackupService.decrypt(bytes, 'correct horse');
    expect(back.devices.single.password, 'secret');
    expect(back.storage['pinned_tools'], ['stats']);
    expect(back.alertRules!.diskPercent, 80);
    expect(back.created, contents.created);
  });

  test('wrong password and foreign files are rejected', () async {
    final bytes = await BackupService.encrypt(contents, 'right');
    expect(() => BackupService.decrypt(bytes, 'wrong'), throwsA(isA<BackupException>()));
    expect(
      () => BackupService.decrypt(Uint8List.fromList(utf8.encode('{"hello":1}')), 'x'),
      throwsA(isA<BackupException>()),
    );
    expect(() => BackupService.decrypt(Uint8List.fromList([1, 2, 3]), 'x'), throwsA(isA<BackupException>()));
  });

  test('merging keeps saved logins when the backup has none', () {
    final current = [device('1', password: 'kept'), device('2')];
    final backup = BackupContents(
      created: DateTime(2026),
      appVersion: '',
      devices: [device('1'), device('3', password: 'new')],
      includesSecrets: false,
      storage: const {},
    );
    final merged = BackupService.mergeDevices(current, backup, replace: false);
    expect(merged.map((d) => d.id), ['1', '2', '3']);
    expect(merged.first.password, 'kept');

    final replaced = BackupService.mergeDevices(current, backup, replace: true);
    expect(replaced.map((d) => d.id), ['1', '3']);
    expect(replaced.first.password, 'kept');
  });
}
