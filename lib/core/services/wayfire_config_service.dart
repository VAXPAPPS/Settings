import 'dart:io';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'compositor_config_interface.dart';

class WayfireConfigService implements CompositorConfigService {
  final String _configPath;

  WayfireConfigService([String? path])
      : _configPath = path ?? '${Platform.environment['HOME']}/.config/wayfire.ini';

  Future<String?> getValue(String section, String key) async {
    final lines = await _readLines();
    String? currentSection;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        currentSection = trimmed.substring(1, trimmed.length - 1);
      } else if (currentSection == section) {
        if (trimmed.startsWith('$key=') || trimmed.startsWith('$key =')) {
          final parts = line.split('=');
          if (parts.length >= 2) {
            return parts.sublist(1).join('=').trim();
          }
        }
      }
    }
    return null;
  }

  Future<Map<String, String>> getSectionValues(String section) async {
    final lines = await _readLines();
    String? currentSection;
    final Map<String, String> values = {};

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        currentSection = trimmed.substring(1, trimmed.length - 1);
      } else if (currentSection == section) {
        if (trimmed.isNotEmpty && !trimmed.startsWith('#') && trimmed.contains('=')) {
          final parts = line.split('=');
          final k = parts[0].trim();
          final v = parts.sublist(1).join('=').trim();
          values[k] = v;
        }
      }
    }
    return values;
  }

  Future<void> setValue(String section, String key, String value) async {
    await setValues(section, {key: value});
  }

  Future<void> setValues(String section, Map<String, String> updates) async {
    final lines = await _readLines();
    final newLines = <String>[];
    String? currentSection;
    bool sectionFound = false;

    // keep track of which keys we've updated in this section
    final Map<String, bool> updatedKeys = {for (var k in updates.keys) k: false};

    for (final line in lines) {
      final trimmed = line.trim();
      
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        // If we are leaving the target section, append any un-updated keys before we leave it
        if (currentSection == section) {
          for (final entry in updates.entries) {
            if (!updatedKeys[entry.key]!) {
              newLines.add('${entry.key} = ${entry.value}');
            }
          }
        }

        currentSection = trimmed.substring(1, trimmed.length - 1);
        if (currentSection == section) {
          sectionFound = true;
        }
        newLines.add(line);
      } else if (currentSection == section && trimmed.contains('=')) {
        final parts = line.split('=');
        final k = parts[0].trim();
        
        if (updates.containsKey(k)) {
          newLines.add('$k = ${updates[k]}');
          updatedKeys[k] = true;
        } else {
          newLines.add(line);
        }
      } else {
        newLines.add(line);
      }
    }

    // If section found, but file ended before another section
    if (currentSection == section) {
      for (final entry in updates.entries) {
        if (!updatedKeys[entry.key]!) {
          newLines.add('${entry.key} = ${entry.value}');
        }
      }
    } else if (!sectionFound) {
      // Create new section at the end
      if (newLines.isNotEmpty && newLines.last.trim().isNotEmpty) {
        newLines.add('');
      }
      newLines.add('[$section]');
      for (final entry in updates.entries) {
        newLines.add('${entry.key} = ${entry.value}');
      }
    }

    await _writeLines(newLines);
  }

  Future<void> deleteKeys(String section, List<String> keys) async {
    final lines = await _readLines();
    final newLines = <String>[];
    String? currentSection;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        currentSection = trimmed.substring(1, trimmed.length - 1);
        newLines.add(line);
      } else if (currentSection == section && trimmed.contains('=')) {
        final parts = line.split('=');
        final k = parts[0].trim();
        if (keys.contains(k)) {
          // Skip adding this line to delete it
          continue;
        } else {
          newLines.add(line);
        }
      } else {
        newLines.add(line);
      }
    }
    await _writeLines(newLines);
  }

  Future<List<String>> _readLines() async {
    final file = File(_configPath);
    if (!await file.exists()) {
      return [];
    }
    return await file.readAsLines();
  }

  Future<void> _writeLines(List<String> lines) async {
    final file = File(_configPath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
  }

  // ── CompositorConfigService Implementation ──

  @override
  Future<String> getKeyboardLayouts() async {
    return await getValue('input', 'xkb_layout') ?? 'us';
  }

  @override
  Future<void> setKeyboardLayouts(String layouts) async {
    await setValue('input', 'xkb_layout', layouts);
  }

  @override
  Future<List<ShortcutItem>> loadShortcuts() async {
    final values = await getSectionValues('command');
    final Map<String, ShortcutItem> itemsMap = {};

    for (final entry in values.entries) {
      final key = entry.key;
      final val = entry.value;

      String id = '';
      bool isBinding = false;
      bool isCommand = false;

      if (key.startsWith('binding_')) {
        id = key.substring('binding_'.length);
        isBinding = true;
      } else if (key.startsWith('repeatable_binding_')) {
        id = key.substring('repeatable_binding_'.length);
        isBinding = true;
      } else if (key.startsWith('command_')) {
        id = key.substring('command_'.length);
        isCommand = true;
      }

      if (id.isEmpty) continue;

      itemsMap.putIfAbsent(id, () => ShortcutItem(id: id, modifier: 'None', key: '', command: ''));

      if (isBinding) {
        final parsed = ShortcutItem.parseWayfireBinding(val);
        itemsMap[id]!.modifier = parsed['modifier'] ?? 'None';
        itemsMap[id]!.key = parsed['key'] ?? '';
      } else if (isCommand) {
        itemsMap[id]!.command = val;
      }
    }

    final validItems = itemsMap.values.where((i) => i.key.isNotEmpty && i.command.isNotEmpty).toList();
    validItems.sort((a, b) => a.id.compareTo(b.id));

    return validItems;
  }

  @override
  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    final existingValues = await getSectionValues('command');
    
    final Map<String, String> newValues = {};
    for (final item in items) {
      final bindString = item.toWayfireBinding();
      
      String bindingKey = 'binding_${item.id}';
      if (existingValues.containsKey('repeatable_binding_${item.id}')) {
        bindingKey = 'repeatable_binding_${item.id}';
      }
      
      newValues[bindingKey] = bindString;
      newValues['command_${item.id}'] = item.command;
    }

    final keysToDelete = <String>[];
    final activeIds = items.map((i) => i.id).toSet();

    for (final key in existingValues.keys) {
      String id = '';
      if (key.startsWith('binding_')) {
        id = key.substring('binding_'.length);
      } else if (key.startsWith('repeatable_binding_')) {
        id = key.substring('repeatable_binding_'.length);
      } else if (key.startsWith('command_')) {
        id = key.substring('command_'.length);
      }

      if (id.isNotEmpty && !activeIds.contains(id)) {
        keysToDelete.add(key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await deleteKeys('command', keysToDelete);
    }
    
    if (newValues.isNotEmpty) {
      await setValues('command', newValues);
    }
  }
}
