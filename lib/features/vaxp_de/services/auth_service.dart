import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/auth_config.dart';

class AuthService {
  final String _basePath;

  AuthService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp';

  String get _configPath => '$_basePath/auth/auth.vaxp';

  Future<AuthConfig> getConfig() async {
    final file = File(_configPath);
    
    AuthConfig config = const AuthConfig();

    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        String currentSection = '';
        
        String? theme;

        Color? minBg, minText, minInBg, minInText, minInFoc, minPri, minPriHov, minSec, minSecHov, minAva;
        Color? polBg, polBor, polText, polAcc, polAccHov, polUsr, polInBg, polInText, polBtn, polBtnHov;
        Color? terBg, terBor, terTit, terText, terPro, terInBg, terInText, terHin, terWar, terCom, terPath, terDotR, terDotY, terDotG;

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

          if (currentSection == '[General]') {
            if (key == 'Theme') theme = value;
          } else if (currentSection == '[Theme.Minimal]') {
            switch (key) {
              case 'BackgroundColor': minBg = _parseColor(value) ?? minBg; break;
              case 'TextColor': minText = _parseColor(value) ?? minText; break;
              case 'InputBackground': minInBg = _parseColor(value) ?? minInBg; break;
              case 'InputTextColor': minInText = _parseColor(value) ?? minInText; break;
              case 'InputFocusBorder': minInFoc = _parseColor(value) ?? minInFoc; break;
              case 'PrimaryButton': minPri = _parseColor(value) ?? minPri; break;
              case 'PrimaryButtonHover': minPriHov = _parseColor(value) ?? minPriHov; break;
              case 'SecondaryButton': minSec = _parseColor(value) ?? minSec; break;
              case 'SecondaryButtonHover': minSecHov = _parseColor(value) ?? minSecHov; break;
              case 'AvatarRing': minAva = _parseColor(value) ?? minAva; break;
            }
          } else if (currentSection == '[Theme.Polkit]') {
            switch (key) {
              case 'BackgroundColor': polBg = _parseColor(value) ?? polBg; break;
              case 'BorderColor': polBor = _parseColor(value) ?? polBor; break;
              case 'TextColor': polText = _parseColor(value) ?? polText; break;
              case 'AccentColor': polAcc = _parseColor(value) ?? polAcc; break;
              case 'AccentColorHover': polAccHov = _parseColor(value) ?? polAccHov; break;
              case 'UserRowBackground': polUsr = _parseColor(value) ?? polUsr; break;
              case 'InputBackground': polInBg = _parseColor(value) ?? polInBg; break;
              case 'InputTextColor': polInText = _parseColor(value) ?? polInText; break;
              case 'ButtonBackground': polBtn = _parseColor(value) ?? polBtn; break;
              case 'ButtonHover': polBtnHov = _parseColor(value) ?? polBtnHov; break;
            }
          } else if (currentSection == '[Theme.Terminal]') {
            switch (key) {
              case 'BackgroundColor': terBg = _parseColor(value) ?? terBg; break;
              case 'BorderColor': terBor = _parseColor(value) ?? terBor; break;
              case 'TitleBarColor': terTit = _parseColor(value) ?? terTit; break;
              case 'TextColor': terText = _parseColor(value) ?? terText; break;
              case 'PromptColor': terPro = _parseColor(value) ?? terPro; break;
              case 'InputBackground': terInBg = _parseColor(value) ?? terInBg; break;
              case 'InputTextColor': terInText = _parseColor(value) ?? terInText; break;
              case 'HintColor': terHin = _parseColor(value) ?? terHin; break;
              case 'WarningColor': terWar = _parseColor(value) ?? terWar; break;
              case 'CommandColor': terCom = _parseColor(value) ?? terCom; break;
              case 'PathColor': terPath = _parseColor(value) ?? terPath; break;
              case 'DotRed': terDotR = _parseColor(value) ?? terDotR; break;
              case 'DotYellow': terDotY = _parseColor(value) ?? terDotY; break;
              case 'DotGreen': terDotG = _parseColor(value) ?? terDotG; break;
            }
          }
        }

        config = config.copyWith(
          theme: theme,
          minimalBackgroundColor: minBg, minimalTextColor: minText, minimalInputBackground: minInBg, minimalInputTextColor: minInText, minimalInputFocusBorder: minInFoc, minimalPrimaryButton: minPri, minimalPrimaryButtonHover: minPriHov, minimalSecondaryButton: minSec, minimalSecondaryButtonHover: minSecHov, minimalAvatarRing: minAva,
          polkitBackgroundColor: polBg, polkitBorderColor: polBor, polkitTextColor: polText, polkitAccentColor: polAcc, polkitAccentColorHover: polAccHov, polkitUserRowBackground: polUsr, polkitInputBackground: polInBg, polkitInputTextColor: polInText, polkitButtonBackground: polBtn, polkitButtonHover: polBtnHov,
          terminalBackgroundColor: terBg, terminalBorderColor: terBor, terminalTitleBarColor: terTit, terminalTextColor: terText, terminalPromptColor: terPro, terminalInputBackground: terInBg, terminalInputTextColor: terInText, terminalHintColor: terHin, terminalWarningColor: terWar, terminalCommandColor: terCom, terminalPathColor: terPath, terminalDotRed: terDotR, terminalDotYellow: terDotY, terminalDotGreen: terDotG,
        );
      } catch (e) {
        debugPrint('Error reading auth config: $e');
      }
    }

    return config;
  }

  Future<void> saveConfig(AuthConfig config) async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final lines = await file.readAsLines();
      final newLines = <String>[];
      
      final Map<String, Map<String, String>> newValues = {
        '[General]': {
          'Theme': config.theme,
        },
        '[Theme.Minimal]': {
          'BackgroundColor': _formatColor(config.minimalBackgroundColor),
          'TextColor': _formatColor(config.minimalTextColor),
          'InputBackground': _formatColor(config.minimalInputBackground),
          'InputTextColor': _formatColor(config.minimalInputTextColor),
          'InputFocusBorder': _formatColor(config.minimalInputFocusBorder),
          'PrimaryButton': _formatColor(config.minimalPrimaryButton),
          'PrimaryButtonHover': _formatColor(config.minimalPrimaryButtonHover),
          'SecondaryButton': _formatColor(config.minimalSecondaryButton),
          'SecondaryButtonHover': _formatColor(config.minimalSecondaryButtonHover),
          'AvatarRing': _formatColor(config.minimalAvatarRing),
        },
        '[Theme.Polkit]': {
          'BackgroundColor': _formatColor(config.polkitBackgroundColor),
          'BorderColor': _formatColor(config.polkitBorderColor),
          'TextColor': _formatColor(config.polkitTextColor),
          'AccentColor': _formatColor(config.polkitAccentColor),
          'AccentColorHover': _formatColor(config.polkitAccentColorHover),
          'UserRowBackground': _formatColor(config.polkitUserRowBackground),
          'InputBackground': _formatColor(config.polkitInputBackground),
          'InputTextColor': _formatColor(config.polkitInputTextColor),
          'ButtonBackground': _formatColor(config.polkitButtonBackground),
          'ButtonHover': _formatColor(config.polkitButtonHover),
        },
        '[Theme.Terminal]': {
          'BackgroundColor': _formatColor(config.terminalBackgroundColor),
          'BorderColor': _formatColor(config.terminalBorderColor),
          'TitleBarColor': _formatColor(config.terminalTitleBarColor),
          'TextColor': _formatColor(config.terminalTextColor),
          'PromptColor': _formatColor(config.terminalPromptColor),
          'InputBackground': _formatColor(config.terminalInputBackground),
          'InputTextColor': _formatColor(config.terminalInputTextColor),
          'HintColor': _formatColor(config.terminalHintColor),
          'WarningColor': _formatColor(config.terminalWarningColor),
          'CommandColor': _formatColor(config.terminalCommandColor),
          'PathColor': _formatColor(config.terminalPathColor),
          'DotRed': _formatColor(config.terminalDotRed),
          'DotYellow': _formatColor(config.terminalDotYellow),
          'DotGreen': _formatColor(config.terminalDotGreen),
        }
      };

      String currentSection = '';
      final Map<String, Map<String, bool>> replaced = {
        '[General]': { for (var k in newValues['[General]']!.keys) k: false },
        '[Theme.Minimal]': { for (var k in newValues['[Theme.Minimal]']!.keys) k: false },
        '[Theme.Polkit]': { for (var k in newValues['[Theme.Polkit]']!.keys) k: false },
        '[Theme.Terminal]': { for (var k in newValues['[Theme.Terminal]']!.keys) k: false },
      };
      
      final Map<String, bool> sectionFound = {
        '[General]': false,
        '[Theme.Minimal]': false,
        '[Theme.Polkit]': false,
        '[Theme.Terminal]': false,
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
      debugPrint('Error writing auth config: $e');
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
      } else if (value.startsWith('#')) {
        String hex = value.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
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
