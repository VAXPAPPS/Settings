import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/osd_notify_config.dart';

class OsdNotifyService {
  final String _basePath;

  OsdNotifyService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp';

  String get _configPath => '$_basePath/osd-notify/osd-notify.vaxp';

  Future<OsdNotifyConfig> getConfig() async {
    final file = File(_configPath);
    
    OsdNotifyConfig config = const OsdNotifyConfig();

    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        String currentSection = '';
        
        Color? notifyBgColor;
        Color? notifyBorderColor;
        Color? notifyTitleTextColor;
        Color? notifyBodyTextColor;
        Color? notifyBtnBgColor;
        Color? notifyBtnTextColor;
        Color? notifyBtnHoverBgColor;
        Color? notifyBtnHoverTextColor;
        int? notifyMarginX;
        int? notifyMarginY;
        int? notifySpacing;
        String? notifyPosition;

        Color? osdBgColor;
        Color? osdTextColor;
        Color? osdBarBgColor;
        Color? osdBarFgColor;
        Color? osdIconNormalColor;
        Color? osdIconMutedColor;

        String? soundNotification;
        String? soundChargerConnect;
        String? soundChargerDisconnect;
        String? soundUsbConnect;
        String? soundUsbDisconnect;
        String? soundLimitHigh;
        String? soundLimitLow;
        String? soundError;

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

          if (currentSection == '[Notify]') {
            switch (key) {
              case 'bg_color': notifyBgColor = _parseColor(value) ?? notifyBgColor; break;
              case 'border_color': notifyBorderColor = _parseColor(value) ?? notifyBorderColor; break;
              case 'title_text_color': notifyTitleTextColor = _parseColor(value) ?? notifyTitleTextColor; break;
              case 'body_text_color': notifyBodyTextColor = _parseColor(value) ?? notifyBodyTextColor; break;
              case 'btn_bg_color': notifyBtnBgColor = _parseColor(value) ?? notifyBtnBgColor; break;
              case 'btn_text_color': notifyBtnTextColor = _parseColor(value) ?? notifyBtnTextColor; break;
              case 'btn_hover_bg_color': notifyBtnHoverBgColor = _parseColor(value) ?? notifyBtnHoverBgColor; break;
              case 'btn_hover_text_color': notifyBtnHoverTextColor = _parseColor(value) ?? notifyBtnHoverTextColor; break;
              case 'margin_x': notifyMarginX = int.tryParse(value) ?? notifyMarginX; break;
              case 'margin_y': notifyMarginY = int.tryParse(value) ?? notifyMarginY; break;
              case 'spacing': notifySpacing = int.tryParse(value) ?? notifySpacing; break;
              case 'position': notifyPosition = value; break;
            }
          } else if (currentSection == '[OSD]') {
            switch (key) {
              case 'bg_color': osdBgColor = _parseColor(value) ?? osdBgColor; break;
              case 'text_color': osdTextColor = _parseColor(value) ?? osdTextColor; break;
              case 'bar_bg_color': osdBarBgColor = _parseColor(value) ?? osdBarBgColor; break;
              case 'bar_fg_color': osdBarFgColor = _parseColor(value) ?? osdBarFgColor; break;
              case 'icon_normal_color': osdIconNormalColor = _parseColor(value) ?? osdIconNormalColor; break;
              case 'icon_muted_color': osdIconMutedColor = _parseColor(value) ?? osdIconMutedColor; break;
            }
          } else if (currentSection == '[Sounds]') {
            switch (key) {
              case 'notification': soundNotification = value; break;
              case 'charger_connect': soundChargerConnect = value; break;
              case 'charger_disconnect': soundChargerDisconnect = value; break;
              case 'usb_connect': soundUsbConnect = value; break;
              case 'usb_disconnect': soundUsbDisconnect = value; break;
              case 'limit_high': soundLimitHigh = value; break;
              case 'limit_low': soundLimitLow = value; break;
              case 'error': soundError = value; break;
            }
          }
        }

        config = config.copyWith(
          notifyBgColor: notifyBgColor,
          notifyBorderColor: notifyBorderColor,
          notifyTitleTextColor: notifyTitleTextColor,
          notifyBodyTextColor: notifyBodyTextColor,
          notifyBtnBgColor: notifyBtnBgColor,
          notifyBtnTextColor: notifyBtnTextColor,
          notifyBtnHoverBgColor: notifyBtnHoverBgColor,
          notifyBtnHoverTextColor: notifyBtnHoverTextColor,
          notifyMarginX: notifyMarginX,
          notifyMarginY: notifyMarginY,
          notifySpacing: notifySpacing,
          notifyPosition: notifyPosition,
          
          osdBgColor: osdBgColor,
          osdTextColor: osdTextColor,
          osdBarBgColor: osdBarBgColor,
          osdBarFgColor: osdBarFgColor,
          osdIconNormalColor: osdIconNormalColor,
          osdIconMutedColor: osdIconMutedColor,

          soundNotification: soundNotification,
          soundChargerConnect: soundChargerConnect,
          soundChargerDisconnect: soundChargerDisconnect,
          soundUsbConnect: soundUsbConnect,
          soundUsbDisconnect: soundUsbDisconnect,
          soundLimitHigh: soundLimitHigh,
          soundLimitLow: soundLimitLow,
          soundError: soundError,
        );

      } catch (e) {
        debugPrint('Error reading osd-notify: $e');
      }
    }

    return config;
  }

  Future<void> saveConfig(OsdNotifyConfig config) async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final lines = await file.readAsLines();
      final newLines = <String>[];
      
      final Map<String, Map<String, String>> newValues = {
        '[Notify]': {
          'bg_color': _formatColor(config.notifyBgColor, true),
          'border_color': _formatColor(config.notifyBorderColor, true),
          'title_text_color': _formatColor(config.notifyTitleTextColor, false),
          'body_text_color': _formatColor(config.notifyBodyTextColor, false),
          'btn_bg_color': _formatColor(config.notifyBtnBgColor, false),
          'btn_text_color': _formatColor(config.notifyBtnTextColor, false),
          'btn_hover_bg_color': _formatColor(config.notifyBtnHoverBgColor, false),
          'btn_hover_text_color': _formatColor(config.notifyBtnHoverTextColor, false),
          'margin_x': config.notifyMarginX.toString(),
          'margin_y': config.notifyMarginY.toString(),
          'spacing': config.notifySpacing.toString(),
          'position': config.notifyPosition,
        },
        '[OSD]': {
          'bg_color': _formatColor(config.osdBgColor, true),
          'text_color': _formatColor(config.osdTextColor, false),
          'bar_bg_color': _formatColor(config.osdBarBgColor, true),
          'bar_fg_color': _formatColor(config.osdBarFgColor, false),
          'icon_normal_color': _formatColor(config.osdIconNormalColor, false),
          'icon_muted_color': _formatColor(config.osdIconMutedColor, false),
        },
        '[Sounds]': {
          'notification': config.soundNotification,
          'charger_connect': config.soundChargerConnect,
          'charger_disconnect': config.soundChargerDisconnect,
          'usb_connect': config.soundUsbConnect,
          'usb_disconnect': config.soundUsbDisconnect,
          'limit_high': config.soundLimitHigh,
          'limit_low': config.soundLimitLow,
          'error': config.soundError,
        }
      };

      String currentSection = '';
      final Map<String, Map<String, bool>> replaced = {
        '[Notify]': { for (var k in newValues['[Notify]']!.keys) k: false },
        '[OSD]': { for (var k in newValues['[OSD]']!.keys) k: false },
        '[Sounds]': { for (var k in newValues['[Sounds]']!.keys) k: false },
      };
      
      final Map<String, bool> sectionFound = {
        '[Notify]': false,
        '[OSD]': false,
        '[Sounds]': false,
      };

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();

        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          currentSection = trimmed;
          sectionFound[currentSection] = true;
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

      // Append any missing sections and their keys
      for (final section in newValues.keys) {
        if (!sectionFound[section]!) {
          newLines.add('');
          newLines.add(section);
          for (final key in newValues[section]!.keys) {
            newLines.add('$key=${newValues[section]![key]}');
          }
        }
      }

      final finalLines = <String>[];
      currentSection = '';
      for (int i = 0; i < newLines.length; i++) {
        final line = newLines[i];
        final trimmed = line.trim();

        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          if (replaced.containsKey(currentSection)) {
            for (final key in replaced[currentSection]!.keys) {
              if (!replaced[currentSection]![key]!) {
                finalLines.add('$key=${newValues[currentSection]![key]}');
                replaced[currentSection]![key] = true;
              }
            }
          }
          currentSection = trimmed;
        }
        finalLines.add(line);
      }
      
      if (replaced.containsKey(currentSection)) {
        for (final key in replaced[currentSection]!.keys) {
          if (!replaced[currentSection]![key]!) {
            finalLines.add('$key=${newValues[currentSection]![key]}');
            replaced[currentSection]![key] = true;
          }
        }
      }

      await file.writeAsString('${finalLines.join('\n')}\n', flush: true);
    } catch (e) {
      debugPrint('Error writing osd-notify: $e');
    }
  }

  Color? _parseColor(String value) {
    value = value.trim();
    try {
      if (value.startsWith('#')) {
        String hex = value.replaceFirst('#', '');
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
      } else if (value.startsWith('rgba(') && value.endsWith(')')) {
        final parts = value.substring(5, value.length - 1).split(',');
        if (parts.length == 4) {
          final r = int.parse(parts[0].trim());
          final g = int.parse(parts[1].trim());
          final b = int.parse(parts[2].trim());
          final a = double.parse(parts[3].trim());
          return Color.fromRGBO(r, g, b, a);
        }
      }
    } catch (e) {
      debugPrint('Failed to parse color: $value');
    }
    return null;
  }

  String _formatColor(Color color, bool allowRgba) {
    if (allowRgba && color.a < 1.0) {
      // Use rgba formatting
      String alpha = color.a.toStringAsFixed(3).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      if (alpha.isEmpty) alpha = '0';
      if (alpha == '1') alpha = '1.0';
      return 'rgba(${(color.r * 255).round()},${(color.g * 255).round()},${(color.b * 255).round()},$alpha)';
    } else {
      // Use hex formatting (#RRGGBB)
      return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    }
  }
}
