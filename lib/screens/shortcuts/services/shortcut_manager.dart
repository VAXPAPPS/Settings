import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';

class VenomShortcutManager {
  
  final String _csvPath = '/etc/venom/shortcuts.csv';
  final String _daemonPath = '/usr/bin/venom_shortcuts';

  Future<List<ShortcutItem>> loadShortcuts() async {
    final file = File(_csvPath);
    if (!await file.exists()) {
      
      try {
        await file.create();
      } catch (e) {
        return [];
      }
      return [];
    }

    final lines = await file.readAsLines();
    List<ShortcutItem> shortcuts = [];

    for (var line in lines) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;
      final parts = line.split(',');
      if (parts.length >= 3) {
        String cmd = parts.sublist(2).join(',');
        shortcuts.add(
          ShortcutItem(parts[0].trim(), parts[1].trim(), cmd.trim()),
        );
      }
    }
    return shortcuts;
  }

  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    final file = File(_csvPath);
    final buffer = StringBuffer();

    buffer.writeln('# Venom Shortcuts Config');
    buffer.writeln('# Modifier, Key, Command');

    for (var item in items) {
      buffer.writeln(item.toCsvLine());
    }

    
    await file.writeAsString(buffer.toString(), flush: true);

    
    await restartDaemon();
  }

  Future<void> restartDaemon() async {
    try {
      
      await Process.run('pkill', ['-9', 'venom_shortcuts']);

      
      await Future.delayed(const Duration(milliseconds: 300));

      
      if (!await File(_daemonPath).exists()) {
        return;
      }

      
      await Process.start(_daemonPath, [], mode: ProcessStartMode.detached);
    } catch (e) {
      
    }
  }
}
