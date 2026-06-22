import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/models/mouse_config.dart';
import 'package:uuid/uuid.dart';
import 'compositor_config_interface.dart';

class AetherConfigService implements CompositorConfigService {
  final String _keybindingsPath;
  final String _configPath;

  AetherConfigService([String? basePath])
      : _keybindingsPath = '${basePath ?? Platform.environment['HOME']}/.config/aether/keybindings.conf',
        _configPath = '${basePath ?? Platform.environment['HOME']}/.config/aether/config.conf';

  Future<List<String>> _readLines(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    return await file.readAsLines();
  }

  Future<void> _writeLines(String path, List<String> lines) async {
    final file = File(path);
    if (!await file.exists()) await file.create(recursive: true);
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
  }

  @override
  Future<String> getKeyboardLayouts() async {
    final lines = await _readLines(_keybindingsPath);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('xkb_rules_layout') && trimmed.contains('=')) {
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
    final lines = await _readLines(_keybindingsPath);
    final newLines = <String>[];
    bool found = false;
    
    for (final line in lines) {
      if (line.trim().startsWith('xkb_rules_layout') && line.contains('=')) {
        newLines.add('xkb_rules_layout=$layouts');
        found = true;
      } else {
        newLines.add(line);
      }
    }

    if (!found) {
      newLines.add('xkb_rules_layout=$layouts');
    }

    await _writeLines(_keybindingsPath, newLines);
  }

  @override
  Future<List<ShortcutItem>> loadShortcuts() async {
    final lines = await _readLines(_keybindingsPath);
    final items = <ShortcutItem>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('bind=') || trimmed.startsWith('bind =')) {
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final bindArgs = parts.sublist(1).join('=').split(',');
          if (bindArgs.length >= 2) {
            final modStr = bindArgs[0].trim();
            final keyStr = bindArgs[1].trim();
            final commandStr = bindArgs.length > 2 ? bindArgs.sublist(2).join(',').trim() : '';
            
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
              command: commandStr
            ));
          }
        }
      }
    }
    return items;
  }

  @override
  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    final lines = await _readLines(_keybindingsPath);
    final newLines = <String>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('bind=') && !trimmed.startsWith('bind =')) {
        newLines.add(line);
      }
    }

    newLines.add('');
    newLines.add('# Generated Binds');
    for (final item in items) {
      String modStr = 'none';
      switch (item.modifier) {
        case 'Ctrl': modStr = 'CTRL'; break;
        case 'Alt': modStr = 'ALT'; break;
        case 'Shift': modStr = 'SHIFT'; break;
        case 'Super': modStr = 'SUPER'; break;
        case 'Ctrl+Alt': modStr = 'CTRL+ALT'; break;
        case 'Ctrl+Shift': modStr = 'CTRL+SHIFT'; break;
        case 'Super+Shift': modStr = 'SUPER+SHIFT'; break;
        default: modStr = 'none'; break;
      }

      newLines.add('bind=$modStr,${item.key},${item.command}');
    }

    await _writeLines(_keybindingsPath, newLines);
  }

  @override
  Future<MouseConfig> getMouseConfig() async {
    final lines = await _readLines(_configPath);
    final config = MouseConfig();
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.contains('=')) continue;
      
      final parts = trimmed.split('=');
      final key = parts[0].trim();
      final val = parts.sublist(1).join('=').trim();

      if (key == 'disable_trackpad') {
        config.touchpadEnabled = val == '0';
      } else if (key == 'tap_to_click') {
        config.tapToClick = val == '1';
      } else if (key == 'disable_while_typing') {
        config.disableWhileTyping = val == '1';
      } else if (key == 'left_handed') {
        config.primaryButton = val == '1' ? 'right' : 'left';
      } else if (key == 'trackpad_natural_scrolling' || key == 'mouse_natural_scrolling') {
        if (val == '1') {
          config.scrollDirection = 'natural';
        } else {
          config.scrollDirection = 'traditional';
        }
      }
    }
    return config;
  }

  @override
  Future<void> saveMouseConfig(MouseConfig config) async {
    final lines = await _readLines(_configPath);
    final newLines = <String>[];
    
    final Map<String, String> newValues = {
      'disable_trackpad': config.touchpadEnabled ? '0' : '1',
      'tap_to_click': config.tapToClick ? '1' : '0',
      'disable_while_typing': config.disableWhileTyping ? '1' : '0',
      'left_handed': config.primaryButton == 'right' ? '1' : '0',
      'trackpad_natural_scrolling': config.scrollDirection == 'natural' ? '1' : '0',
      'mouse_natural_scrolling': config.scrollDirection == 'natural' ? '1' : '0',
    };

    final Map<String, bool> replaced = {
      for (var k in newValues.keys) k: false
    };

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      
      bool matched = false;
      for (final key in newValues.keys) {
        if (trimmed.startsWith('$key=') || trimmed.startsWith('$key =')) {
          newLines.add('$key=${newValues[key]}');
          replaced[key] = true;
          matched = true;
          break;
        }
      }
      
      if (!matched) {
        newLines.add(line);
      }
    }

    // Append any missing keys
    bool missingKeys = false;
    for (final key in replaced.keys) {
      if (!replaced[key]!) {
        if (!missingKeys) {
          newLines.add('');
          newLines.add('# Generated Mouse Settings');
          missingKeys = true;
        }
        newLines.add('$key=${newValues[key]}');
      }
    }

    await _writeLines(_configPath, newLines);
  }
}
