import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/models/mouse_config.dart';
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

  @override
  Future<MouseConfig> getMouseConfig() async {
    final lines = await _readLines();
    final config = MouseConfig();
    
    bool inInput = false;
    bool inTouchpad = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('input {')) {
        inInput = true;
      } else if (inInput && trimmed.startsWith('touchpad {')) {
        inTouchpad = true;
      } else if (inInput && trimmed.startsWith('}')) {
        if (inTouchpad) {
          inTouchpad = false;
        } else {
          inInput = false;
        }
      }
      
      if (!trimmed.contains('=')) continue;
      final parts = trimmed.split('=');
      final key = parts[0].trim();
      final val = parts.sublist(1).join('=').trim();

      if (inInput && !inTouchpad) {
        if (key == 'left_handed') config.primaryButton = val == 'true' ? 'right' : 'left';
        if (key == 'sensitivity') config.mousePointerSpeed = double.tryParse(val) ?? 0.0;
        if (key == 'accel_profile') config.mouseAcceleration = val != 'flat';
        if (key == 'natural_scroll') config.scrollDirection = val == 'true' ? 'natural' : 'traditional';
      } else if (inTouchpad) {
        if (key == 'disable_while_typing') config.disableWhileTyping = val != 'false';
        if (key == 'tap-to-click') config.tapToClick = val != 'false';
        if (key == 'clickfinger_behavior') config.secondaryClick = val == 'true' ? 'two-finger' : 'bottom-right';
      }
    }
    return config;
  }

  @override
  Future<void> saveMouseConfig(MouseConfig config) async {
    final lines = await _readLines();
    final newLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('left_handed =') ||
          trimmed.startsWith('sensitivity =') ||
          trimmed.startsWith('accel_profile =') ||
          trimmed.startsWith('natural_scroll =') ||
          trimmed.startsWith('disable_while_typing =') ||
          trimmed.startsWith('tap-to-click =') ||
          trimmed.startsWith('clickfinger_behavior =')) {
        continue;
      }
      newLines.add(lines[i]);
    }

    int inputIdx = newLines.indexWhere((l) => l.trim().startsWith('input {'));
    if (inputIdx == -1) {
      newLines.add('input {');
      newLines.add('    touchpad {');
      newLines.add('    }');
      newLines.add('}');
      inputIdx = newLines.length - 4;
    }

    newLines.insertAll(inputIdx + 1, [
      '    left_handed = ${config.primaryButton == 'right' ? 'true' : 'false'}',
      '    sensitivity = ${config.mousePointerSpeed.toStringAsFixed(2)}',
      '    accel_profile = ${config.mouseAcceleration ? 'adaptive' : 'flat'}',
      '    natural_scroll = ${config.scrollDirection == 'natural' ? 'true' : 'false'}',
    ]);

    int touchpadIdx = newLines.indexWhere((l) => l.trim().startsWith('touchpad {'), inputIdx);
    if (touchpadIdx == -1) {
      int endIdx = newLines.indexWhere((l) => l.trim() == '}', inputIdx + 5);
      if (endIdx != -1) {
        newLines.insert(endIdx, '    touchpad {');
        newLines.insert(endIdx + 1, '    }');
        touchpadIdx = endIdx;
      }
    }

    if (touchpadIdx != -1) {
      newLines.insertAll(touchpadIdx + 1, [
        '        disable_while_typing = ${config.disableWhileTyping ? 'true' : 'false'}',
        '        tap-to-click = ${config.tapToClick ? 'true' : 'false'}',
        '        clickfinger_behavior = ${config.secondaryClick == 'two-finger' ? 'true' : 'false'}',
      ]);
    }

    await _writeLines(newLines);
  }
}
