import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/clipboard_config.dart';

class ClipboardService {
  final String _basePath;

  ClipboardService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp';

  String get _configPath => '$_basePath/clipboard/clipboard.vaxp';

  Future<ClipboardConfig> getConfig() async {
    final file = File(_configPath);
    
    ClipboardConfig config = const ClipboardConfig();

    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        String currentSection = '';
        
        bool? ghostMode;
        
        Color? winBg, winBor, glassBg, headTit, ghPillBg, ghPillTxt, ghPillBor, ghActTxt, ghActBg, ghActBor;
        Color? searchBg, searchBor, searchTxt, searchFoc;
        Color? tabBg, tabTxt, tabChkBg, tabChkTxt, tabChkBor;
        Color? cardBg, cardBor, cardHov, cardTxt, cardCode, metaTxt;
        Color? pinBg, pinTxt, menuBg, menuBor, menuTxt, menuHov;

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

          if (currentSection == '[Settings]') {
            if (key == 'GhostMode') ghostMode = value.toLowerCase() == 'true';
          } else if (currentSection == '[Colors]') {
            switch (key) {
              case 'WindowBoxBg': winBg = _parseColor(value) ?? winBg; break;
              case 'WindowBoxBorder': winBor = _parseColor(value) ?? winBor; break;
              case 'GlassPanelBg': glassBg = _parseColor(value) ?? glassBg; break;
              case 'HeaderTitle': headTit = _parseColor(value) ?? headTit; break;
              case 'GhostPillBg': ghPillBg = _parseColor(value) ?? ghPillBg; break;
              case 'GhostPillText': ghPillTxt = _parseColor(value) ?? ghPillTxt; break;
              case 'GhostPillBorder': ghPillBor = _parseColor(value) ?? ghPillBor; break;
              case 'GhostActiveText': ghActTxt = _parseColor(value) ?? ghActTxt; break;
              case 'GhostActiveBg': ghActBg = _parseColor(value) ?? ghActBg; break;
              case 'GhostActiveBorder': ghActBor = _parseColor(value) ?? ghActBor; break;
              case 'SearchBoxBg': searchBg = _parseColor(value) ?? searchBg; break;
              case 'SearchBoxBorder': searchBor = _parseColor(value) ?? searchBor; break;
              case 'SearchBoxText': searchTxt = _parseColor(value) ?? searchTxt; break;
              case 'SearchBoxFocusBorder': searchFoc = _parseColor(value) ?? searchFoc; break;
              case 'TabBtnBg': tabBg = _parseColor(value) ?? tabBg; break;
              case 'TabBtnText': tabTxt = _parseColor(value) ?? tabTxt; break;
              case 'TabBtnCheckedBg': tabChkBg = _parseColor(value) ?? tabChkBg; break;
              case 'TabBtnCheckedText': tabChkTxt = _parseColor(value) ?? tabChkTxt; break;
              case 'TabBtnCheckedBorder': tabChkBor = _parseColor(value) ?? tabChkBor; break;
              case 'CardBg': cardBg = _parseColor(value) ?? cardBg; break;
              case 'CardBorder': cardBor = _parseColor(value) ?? cardBor; break;
              case 'CardHoverBorder': cardHov = _parseColor(value) ?? cardHov; break;
              case 'CardText': cardTxt = _parseColor(value) ?? cardTxt; break;
              case 'CardCodeText': cardCode = _parseColor(value) ?? cardCode; break;
              case 'MetaText': metaTxt = _parseColor(value) ?? metaTxt; break;
              case 'PinFlagBg': pinBg = _parseColor(value) ?? pinBg; break;
              case 'PinFlagText': pinTxt = _parseColor(value) ?? pinTxt; break;
              case 'MenuBg': menuBg = _parseColor(value) ?? menuBg; break;
              case 'MenuBorder': menuBor = _parseColor(value) ?? menuBor; break;
              case 'MenuItemText': menuTxt = _parseColor(value) ?? menuTxt; break;
              case 'MenuItemHoverBg': menuHov = _parseColor(value) ?? menuHov; break;
            }
          }
        }

        config = config.copyWith(
          ghostMode: ghostMode,
          windowBoxBg: winBg, windowBoxBorder: winBor, glassPanelBg: glassBg, headerTitle: headTit,
          ghostPillBg: ghPillBg, ghostPillText: ghPillTxt, ghostPillBorder: ghPillBor,
          ghostActiveText: ghActTxt, ghostActiveBg: ghActBg, ghostActiveBorder: ghActBor,
          searchBoxBg: searchBg, searchBoxBorder: searchBor, searchBoxText: searchTxt, searchBoxFocusBorder: searchFoc,
          tabBtnBg: tabBg, tabBtnText: tabTxt, tabBtnCheckedBg: tabChkBg, tabBtnCheckedText: tabChkTxt, tabBtnCheckedBorder: tabChkBor,
          cardBg: cardBg, cardBorder: cardBor, cardHoverBorder: cardHov, cardText: cardTxt, cardCodeText: cardCode, metaText: metaTxt,
          pinFlagBg: pinBg, pinFlagText: pinTxt, menuBg: menuBg, menuBorder: menuBor, menuItemText: menuTxt, menuItemHoverBg: menuHov,
        );
      } catch (e) {
        debugPrint('Error reading clipboard config: $e');
      }
    }

    return config;
  }

  Future<void> saveConfig(ClipboardConfig config) async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final lines = await file.readAsLines();
      final newLines = <String>[];
      
      final Map<String, Map<String, String>> newValues = {
        '[Settings]': {
          'GhostMode': config.ghostMode.toString(),
        },
        '[Colors]': {
          'WindowBoxBg': _formatColor(config.windowBoxBg),
          'WindowBoxBorder': _formatColor(config.windowBoxBorder),
          'GlassPanelBg': _formatColor(config.glassPanelBg),
          'HeaderTitle': _formatColor(config.headerTitle),
          'GhostPillBg': _formatColor(config.ghostPillBg),
          'GhostPillText': _formatColor(config.ghostPillText),
          'GhostPillBorder': _formatColor(config.ghostPillBorder),
          'GhostActiveText': _formatColor(config.ghostActiveText),
          'GhostActiveBg': _formatColor(config.ghostActiveBg),
          'GhostActiveBorder': _formatColor(config.ghostActiveBorder),
          'SearchBoxBg': _formatColor(config.searchBoxBg),
          'SearchBoxBorder': _formatColor(config.searchBoxBorder),
          'SearchBoxText': _formatColor(config.searchBoxText),
          'SearchBoxFocusBorder': _formatColor(config.searchBoxFocusBorder),
          'TabBtnBg': _formatColor(config.tabBtnBg),
          'TabBtnText': _formatColor(config.tabBtnText),
          'TabBtnCheckedBg': _formatColor(config.tabBtnCheckedBg),
          'TabBtnCheckedText': _formatColor(config.tabBtnCheckedText),
          'TabBtnCheckedBorder': _formatColor(config.tabBtnCheckedBorder),
          'CardBg': _formatColor(config.cardBg),
          'CardBorder': _formatColor(config.cardBorder),
          'CardHoverBorder': _formatColor(config.cardHoverBorder),
          'CardText': _formatColor(config.cardText),
          'CardCodeText': _formatColor(config.cardCodeText),
          'MetaText': _formatColor(config.metaText),
          'PinFlagBg': _formatColor(config.pinFlagBg),
          'PinFlagText': _formatColor(config.pinFlagText),
          'MenuBg': _formatColor(config.menuBg),
          'MenuBorder': _formatColor(config.menuBorder),
          'MenuItemText': _formatColor(config.menuItemText),
          'MenuItemHoverBg': _formatColor(config.menuItemHoverBg),
        }
      };

      String currentSection = '';
      final Map<String, Map<String, bool>> replaced = {
        '[Settings]': { for (var k in newValues['[Settings]']!.keys) k: false },
        '[Colors]': { for (var k in newValues['[Colors]']!.keys) k: false },
      };
      
      final Map<String, bool> sectionFound = {
        '[Settings]': false,
        '[Colors]': false,
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
      debugPrint('Error writing clipboard config: $e');
    }
  }

  Color? _parseColor(String value) {
    value = value.trim().replaceAll(' ', '');
    if (value.startsWith('rgbargba(')) {
      value = value.replaceFirst('rgbargba(', 'rgba(');
    }
    try {
      if (value.startsWith('rgba(') && value.endsWith(')')) {
        final parts = value.substring(5, value.length - 1).split(',');
        if (parts.length == 4) {
          final r = int.parse(parts[0]);
          final g = int.parse(parts[1]);
          final b = int.parse(parts[2]);
          final a = double.parse(parts[3]);
          return Color.fromRGBO(r, g, b, a);
        }
      }
    } catch (e) {
      debugPrint('Failed to parse color: $value');
    }
    return null;
  }

  String _formatColor(Color color) {
    String alpha = color.a.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    if (alpha.isEmpty) alpha = '0';
    if (alpha == '1') alpha = '1.0';
    return 'rgba(${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}, $alpha)';
  }
}
