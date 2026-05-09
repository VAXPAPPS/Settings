import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/services/wayfire_config_service.dart';

class VenomShortcutManager {
  final WayfireConfigService _wayfire = WayfireConfigService();

  Future<List<ShortcutItem>> loadShortcuts() async {
    final values = await _wayfire.getSectionValues('command');
    
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

    // Include items that might be missing command or binding but let's assume they are valid
    final validItems = itemsMap.values.where((i) => i.key.isNotEmpty && i.command.isNotEmpty).toList();
    
    validItems.sort((a, b) => a.id.compareTo(b.id));

    return validItems;
  }

  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    final existingValues = await _wayfire.getSectionValues('command');
    
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
      await _wayfire.deleteKeys('command', keysToDelete);
    }
    
    if (newValues.isNotEmpty) {
      await _wayfire.setValues('command', newValues);
    }
  }

  Future<void> restartDaemon() async {
    // Wayfire handles reloading automatically via inotify on the ini file.
  }
}
