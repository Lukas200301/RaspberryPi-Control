import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UpdateExecutor {
  static Future<bool> runSilentUpdate(String installerPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final batchFilePath = '${tempDir.path}\\update_app.bat';
      final batchFile = File(batchFilePath);
      final batchContent = '''
@echo off
echo Running update in background...
start /b /wait "" "${installerPath}" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS=no /NOICONS
echo Update complete.
del "%~f0"
exit
''';

      await batchFile.writeAsString(batchContent);
      
      Process.start(
        'cmd.exe', 
        ['/c', 'start', '/b', batchFilePath], 
        mode: ProcessStartMode.detached,
        runInShell: true,
      );
      
      return true;
    } catch (e) {
      print('Error during background update: $e');
      return false;
    }
  }
}
