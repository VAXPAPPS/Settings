import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:uuid/uuid.dart';
import 'compositor_config_interface.dart';

class HyprlandConfigService implements CompositorConfigService {
  final String _configPath;

  HyprlandConfigService([String? path])
      : _configPath = path ?? '${Platform.environment['HOME']}/.config/hypr/hyprland.conf';

  Future<List<String>> _readLines() async {
    final file = File(_configPath);
    if (!await file.exists()) return [];
    return await file.readAsLines();
  }

  Future<void> _writeLines(List<String> lines) async {
    final file = File(_configPath);
    if (!await file.exists()) await file.create(recursive: true);
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
  }

  @override
  Future<String> getKeyboardLayouts() async {
    final lines = await _readLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('kb_layout') && trimmed.contains('=')) {
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          return parts.sublist(1).join('=').trim();
        }
      }
    }
    return 'us';
  }

  @override
  Future<void> setKeyboardLayouts(String layouts) async {
    final lines = await _readLines();
    final newLines = <String>[];
    
    for (final line in lines) {
      if (line.trim().startsWith('kb_layout') && line.contains('=')) {
        newLines.add('    kb_layout = $layouts');
      } else {
        newLines.add(line);
      }
    }

    await _writeLines(newLines);
  }

  @override
  Future<List<ShortcutItem>> loadShortcuts() async {
    final lines = await _readLines();
    final items = <ShortcutItem>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('bind') && trimmed.contains('=')) {
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final bindArgs = parts.sublist(1).join('=').split(',');
          if (bindArgs.length >= 4) {
            final modStr = bindArgs[0].trim();
            final keyStr = bindArgs[1].trim();
            final action = bindArgs[2].trim();
            final cmd = bindArgs.sublist(3).join(',').trim();
            
            String uiMod = 'None';
            final upperMod = modStr.toUpperCase();
            if (upperMod.contains('CTRL') && upperMod.contains('ALT')) {
              uiMod = 'Ctrl+Alt';
            } else if (upperMod.contains('CTRL') && upperMod.contains('SHIFT')) {
              uiMod = 'Ctrl+Shift';
            } else if (upperMod.contains('SUPER') && upperMod.contains('SHIFT')) {
              uiMod = 'Super+Shift';
            } else if (upperMod.contains('SUPER')) {
              uiMod = 'Super';
            } else if (upperMod.contains('CTRL')) {
              uiMod = 'Ctrl';
            } else if (upperMod.contains('ALT')) {
              uiMod = 'Alt';
            } else if (upperMod.contains('SHIFT')) {
              uiMod = 'Shift';
            }

            items.add(ShortcutItem(
              id: const Uuid().v4(),
              modifier: uiMod,
              key: keyStr,
              command: '$action, $cmd'
            ));
          }
        }
      }
    }
    return items;
  }

  @override
  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    final lines = await _readLines();
    final newLines = <String>[];
    
    for (final line in lines) {
      if (!line.trim().startsWith('bind') || !line.contains('=')) {
        newLines.add(line);
      }
    }

    newLines.add('');
    newLines.add('# Generated Binds');
    for (final item in items) {
      String modStr = '';
      switch (item.modifier) {
        case 'Ctrl': modStr = 'CTRL'; break;
        case 'Alt': modStr = 'ALT'; break;
        case 'Shift': modStr = 'SHIFT'; break;
        case 'Super': modStr = 'SUPER'; break;
        case 'Ctrl+Alt': modStr = 'CTRL ALT'; break;
        case 'Ctrl+Shift': modStr = 'CTRL SHIFT'; break;
        case 'Super+Shift': modStr = 'SUPER SHIFT'; break;
        default: modStr = ''; break;
      }

      String cmdStr = item.command;
      if (!cmdStr.contains(',')) {
        cmdStr = 'exec, $cmdStr';
      }
      
      newLines.add('bind = $modStr, ${item.key}, $cmdStr');
    }

    await _writeLines(newLines);
  }
}
