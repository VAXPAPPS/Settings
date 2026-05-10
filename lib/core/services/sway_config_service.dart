import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/models/mouse_config.dart';
import 'package:uuid/uuid.dart';
import 'compositor_config_interface.dart';

class SwayConfigService implements CompositorConfigService {
  final String _configPath;

  SwayConfigService([String? path])
    : _configPath =
          path ?? '${Platform.environment['HOME']}/.config/sway/config';

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
      if (trimmed.startsWith('xkb_layout')) {
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          return parts.sublist(1).join(' ').trim();
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
      if (line.trim().startsWith('xkb_layout')) {
        newLines.add('    xkb_layout $layouts');
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
      if (trimmed.startsWith('bindsym')) {
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final bindArgs = parts[1];
          final cmd = parts.sublist(2).join(' ').trim();

          final keyParts = bindArgs.split('+');
          final keyStr = keyParts.last;
          final modStr = keyParts.length > 1
              ? keyParts.sublist(0, keyParts.length - 1).join('+').toUpperCase()
              : '';

          String uiMod = 'None';
          if (modStr.contains('CTRL') && modStr.contains('MOD1')) {
            uiMod = 'Ctrl+Alt'; // Mod1 = Alt
          } else if (modStr.contains('CTRL') && modStr.contains('SHIFT')) {
            uiMod = 'Ctrl+Shift';
          } else if (modStr.contains('MOD4') && modStr.contains('SHIFT')) {
            uiMod = 'Super+Shift'; // Mod4 = Super
          } else if (modStr.contains('MOD4')) {
            uiMod = 'Super';
          } else if (modStr.contains('CTRL')) {
            uiMod = 'Ctrl';
          } else if (modStr.contains('MOD1')) {
            uiMod = 'Alt';
          } else if (modStr.contains('SHIFT')) {
            uiMod = 'Shift';
          }

          items.add(
            ShortcutItem(
              id: const Uuid().v4(),
              modifier: uiMod,
              key: keyStr,
              command: cmd,
            ),
          );
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
      if (!line.trim().startsWith('bindsym')) {
        newLines.add(line);
      }
    }

    newLines.add('');
    newLines.add('# Generated Binds');
    for (final item in items) {
      String modStr = '';
      switch (item.modifier) {
        case 'Ctrl':
          modStr = 'Ctrl+';
          break;
        case 'Alt':
          modStr = 'Mod1+';
          break;
        case 'Shift':
          modStr = 'Shift+';
          break;
        case 'Super':
          modStr = 'Mod4+';
          break;
        case 'Ctrl+Alt':
          modStr = 'Ctrl+Mod1+';
          break;
        case 'Ctrl+Shift':
          modStr = 'Ctrl+Shift+';
          break;
        case 'Super+Shift':
          modStr = 'Mod4+Shift+';
          break;
        default:
          modStr = '';
          break;
      }

      String cmdStr = item.command;
      if (!cmdStr.startsWith('exec')) {
        cmdStr = 'exec $cmdStr';
      }

      newLines.add('bindsym $modStr${item.key} $cmdStr');
    }

    await _writeLines(newLines);
  }

  @override
  Future<MouseConfig> getMouseConfig() async {
    final lines = await _readLines();
    final config = MouseConfig();

    bool inInput = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('input * {') ||
          trimmed.startsWith('input type:pointer {') ||
          trimmed.startsWith('input type:touchpad {')) {
        inInput = true;
      } else if (inInput && trimmed.startsWith('}')) {
        inInput = false;
      }

      if (!inInput) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final key = parts[0].trim();
      final val = parts[1].trim();

      if (key == 'left_handed') {
        config.primaryButton = val == 'enabled' ? 'right' : 'left';
      }
      if (key == 'pointer_accel') {
        config.mousePointerSpeed = double.tryParse(val) ?? 0.0;
      }
      if (key == 'accel_profile') config.mouseAcceleration = val != 'flat';
      if (key == 'natural_scroll') {
        config.scrollDirection = val == 'enabled' ? 'natural' : 'traditional';
      }
      if (key == 'dwt') config.disableWhileTyping = val != 'disabled';
      if (key == 'tap') config.tapToClick = val != 'disabled';
    }
    return config;
  }

  @override
  Future<void> saveMouseConfig(MouseConfig config) async {
    final lines = await _readLines();
    final newLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('left_handed ') ||
          trimmed.startsWith('pointer_accel ') ||
          trimmed.startsWith('accel_profile ') ||
          trimmed.startsWith('natural_scroll ') ||
          trimmed.startsWith('dwt ') ||
          trimmed.startsWith('tap ')) {
        continue;
      }
      newLines.add(lines[i]);
    }

    int inputIdx = newLines.indexWhere((l) => l.trim().startsWith('input * {'));
    if (inputIdx == -1) {
      newLines.add('input * {');
      newLines.add('}');
      inputIdx = newLines.length - 2;
    }

    newLines.insertAll(inputIdx + 1, [
      '    left_handed ${config.primaryButton == 'right' ? 'enabled' : 'disabled'}',
      '    pointer_accel ${config.mousePointerSpeed.toStringAsFixed(2)}',
      '    accel_profile ${config.mouseAcceleration ? 'adaptive' : 'flat'}',
      '    natural_scroll ${config.scrollDirection == 'natural' ? 'enabled' : 'disabled'}',
      '    dwt ${config.disableWhileTyping ? 'enabled' : 'disabled'}',
      '    tap ${config.tapToClick ? 'enabled' : 'disabled'}',
    ]);

    await _writeLines(newLines);
  }
}
