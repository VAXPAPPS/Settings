import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/aetherlock_config.dart';

class AetherLockService {
  final String _basePath;

  AetherLockService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp';

  String get _configPath => '$_basePath/aetherlock/aetherlock.vaxp';

  Future<AetherLockConfig> getConfig() async {
    final file = File(_configPath);
    
    AetherLockConfig config = const AetherLockConfig();

    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        String currentSection = '';
        
        String? weatherLocation;
        
        Color? panelBackground;
        Color? panelBorder;
        double? panelBorderWidth;
        Color? outerBorder;
        double? outerBorderWidth;
        Color? textBright;
        Color? textDim;
        Color? accent;
        Color? accentDim;
        Color? background;

        bool? hideContent;

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            currentSection = trimmed;
            continue;
          }

          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

          final parts = trimmed.split('=');
          if (parts.length < 2) continue;

          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();

          if (currentSection == '[Weather]') {
            if (key == 'Location') weatherLocation = value;
          } else if (currentSection == '[Colors]') {
            switch (key) {
              case 'PanelBackground': panelBackground = _parseColor(value) ?? panelBackground; break;
              case 'PanelBorder': panelBorder = _parseColor(value) ?? panelBorder; break;
              case 'PanelBorderWidth': panelBorderWidth = double.tryParse(value) ?? panelBorderWidth; break;
              case 'OuterBorder': outerBorder = _parseColor(value) ?? outerBorder; break;
              case 'OuterBorderWidth': outerBorderWidth = double.tryParse(value) ?? outerBorderWidth; break;
              case 'TextBright': textBright = _parseColor(value) ?? textBright; break;
              case 'TextDim': textDim = _parseColor(value) ?? textDim; break;
              case 'Accent': accent = _parseColor(value) ?? accent; break;
              case 'AccentDim': accentDim = _parseColor(value) ?? accentDim; break;
              case 'Background': background = _parseColor(value) ?? background; break;
            }
          } else if (currentSection == '[Notifications]') {
            if (key == 'HideContent') hideContent = value.toLowerCase() == 'true';
          }
        }

        config = config.copyWith(
          weatherLocation: weatherLocation,
          panelBackground: panelBackground,
          panelBorder: panelBorder,
          panelBorderWidth: panelBorderWidth,
          outerBorder: outerBorder,
          outerBorderWidth: outerBorderWidth,
          textBright: textBright,
          textDim: textDim,
          accent: accent,
          accentDim: accentDim,
          background: background,
          hideContent: hideContent,
        );

      } catch (e) {
        debugPrint('Error reading aetherlock config: $e');
      }
    }

    return config;
  }

  Future<void> saveConfig(AetherLockConfig config) async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final lines = await file.readAsLines();
      final newLines = <String>[];
      
      final Map<String, Map<String, String>> newValues = {
        '[Weather]': {
          'Location': config.weatherLocation,
        },
        '[Colors]': {
          'PanelBackground': _formatColor(config.panelBackground),
          'PanelBorder': _formatColor(config.panelBorder),
          'PanelBorderWidth': config.panelBorderWidth.toStringAsFixed(1),
          'OuterBorder': _formatColor(config.outerBorder),
          'OuterBorderWidth': config.outerBorderWidth.toStringAsFixed(1),
          'TextBright': _formatColor(config.textBright),
          'TextDim': _formatColor(config.textDim),
          'Accent': _formatColor(config.accent),
          'AccentDim': _formatColor(config.accentDim),
          'Background': _formatColor(config.background),
        },
        '[Notifications]': {
          'HideContent': config.hideContent.toString(),
        }
      };

      String currentSection = '';
      final Map<String, Map<String, bool>> replaced = {
        '[Weather]': { for (var k in newValues['[Weather]']!.keys) k: false },
        '[Colors]': { for (var k in newValues['[Colors]']!.keys) k: false },
        '[Notifications]': { for (var k in newValues['[Notifications]']!.keys) k: false },
      };
      
      final Map<String, bool> sectionFound = {
        '[Weather]': false,
        '[Colors]': false,
        '[Notifications]': false,
      };

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();

        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          if (replaced.containsKey(currentSection)) {
            for (final key in replaced[currentSection]!.keys) {
              if (!replaced[currentSection]![key]!) {
                newLines.add('$key=${newValues[currentSection]![key]}');
                replaced[currentSection]![key] = true;
              }
            }
          }
          currentSection = trimmed;
          if (sectionFound.containsKey(currentSection)) {
            sectionFound[currentSection] = true;
          }
          newLines.add(line);
          continue;
        }

        if (newValues.containsKey(currentSection) && trimmed.contains('=')) {
          final parts = trimmed.split('=');
          final key = parts[0].trim();
          
          if (newValues[currentSection]!.containsKey(key)) {
            newLines.add('$key=${newValues[currentSection]![key]}');
            replaced[currentSection]![key] = true;
          } else {
            newLines.add(line);
          }
        } else {
          newLines.add(line);
        }
      }

      if (replaced.containsKey(currentSection)) {
        for (final key in replaced[currentSection]!.keys) {
          if (!replaced[currentSection]![key]!) {
            newLines.add('$key=${newValues[currentSection]![key]}');
            replaced[currentSection]![key] = true;
          }
        }
      }

      for (final section in newValues.keys) {
        if (!sectionFound[section]!) {
          newLines.add('');
          newLines.add(section);
          for (final key in newValues[section]!.keys) {
            newLines.add('$key=${newValues[section]![key]}');
          }
        }
      }

      await file.writeAsString('${newLines.join('\n')}\n', flush: true);
    } catch (e) {
      debugPrint('Error writing aetherlock config: $e');
    }
  }

  Color? _parseColor(String value) {
    value = value.trim();
    try {
      if (value.startsWith('#')) {
        String hex = value.replaceFirst('#', '');
        if (hex.length == 6) {
          hex = 'FF$hex';
        } else if (hex.length == 8) {
          // RRGGBBAA to AARRGGBB
          String r = hex.substring(0, 2);
          String g = hex.substring(2, 4);
          String b = hex.substring(4, 6);
          String a = hex.substring(6, 8);
          hex = '$a$r$g$b';
        }
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      debugPrint('Failed to parse color: $value');
    }
    return null;
  }

  String _formatColor(Color color) {
    // AARRGGBB to RRGGBBAA
    String argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    String a = argb.substring(0, 2);
    String r = argb.substring(2, 4);
    String g = argb.substring(4, 6);
    String b = argb.substring(6, 8);
    return '#$r$g$b$a';
  }
}
