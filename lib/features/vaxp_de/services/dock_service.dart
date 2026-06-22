import 'dart:io';
import 'package:settings/features/vaxp_de/models/dock_config.dart';

class DockService {
  final String _configPath;

  DockService([String? basePath])
      : _configPath = '${basePath ?? Platform.environment['HOME']}/.config/vaxp/dock/dock_state.vaxp';

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

  Future<DockConfig> getDockConfig() async {
    final lines = await _readLines();
    var config = const DockConfig();
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.contains('=')) continue;
      
      final parts = trimmed.split('=');
      final key = parts[0].trim();
      final val = parts.sublist(1).join('=').trim();

      switch (key) {
        case 'Position':
          config = config.copyWith(position: val);
          break;
        case 'BackgroundColor':
          config = config.copyWith(backgroundColor: DockConfig.parseColor(val));
          break;
        case 'ContextMenuColor':
          config = config.copyWith(contextMenuColor: DockConfig.parseColor(val));
          break;
        case 'IndicatorColor':
          config = config.copyWith(indicatorColor: DockConfig.parseColor(val));
          break;
        case 'LaunchRingColor':
          config = config.copyWith(launchRingColor: DockConfig.parseColor(val));
          break;
        case 'LaunchAnimation':
          config = config.copyWith(launchAnimation: int.tryParse(val) ?? 4);
          break;
      }
    }
    return config;
  }

  Future<void> saveDockConfig(DockConfig config) async {
    final lines = await _readLines();
    final newLines = <String>[];
    
    final Map<String, String> newValues = {
      'Position': config.position,
      'BackgroundColor': DockConfig.formatColor(config.backgroundColor, isRgba: true),
      'ContextMenuColor': DockConfig.formatColor(config.contextMenuColor, isRgba: true),
      'IndicatorColor': DockConfig.formatColor(config.indicatorColor, isRgba: false),
      'LaunchRingColor': DockConfig.formatColor(config.launchRingColor, isRgba: false),
      'LaunchAnimation': config.launchAnimation.toString(),
    };

    final Map<String, bool> replaced = {
      for (var k in newValues.keys) k: false
    };

    bool inDockSection = false;
    bool dockSectionFound = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('[')) {
        if (trimmed == '[Dock]') {
          inDockSection = true;
          dockSectionFound = true;
        } else {
          inDockSection = false;
        }
      }

      if (inDockSection && trimmed.contains('=')) {
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
      } else {
        newLines.add(line);
      }
    }

    if (!dockSectionFound) {
      newLines.add('[Dock]');
      for (final key in newValues.keys) {
        newLines.add('$key=${newValues[key]}');
      }
    } else {
      // Find where [Dock] section ends and insert missing keys
      int insertIndex = newLines.indexOf('[Dock]') + 1;
      while (insertIndex < newLines.length && !newLines[insertIndex].trim().startsWith('[')) {
        insertIndex++;
      }
      for (final key in replaced.keys) {
        if (!replaced[key]!) {
          newLines.insert(insertIndex, '$key=${newValues[key]}');
          insertIndex++;
        }
      }
    }

    await _writeLines(newLines);
  }
}
