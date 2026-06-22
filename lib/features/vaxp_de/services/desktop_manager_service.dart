import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/desktop_manager_config.dart';

class DesktopManagerService {
  final String _basePath;

  DesktopManagerService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp/desktop';

  Future<String> _readSingleLine(String fileName, String defaultValue) async {
    try {
      final file = File('$_basePath/$fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.trim();
      }
    } catch (e) {
      debugPrint('Error reading $fileName: $e');
    }
    return defaultValue;
  }

  Future<void> _writeSingleLine(String fileName, String value) async {
    try {
      final file = File('$_basePath/$fileName');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString('$value\n', flush: true);
    } catch (e) {
      debugPrint('Error writing $fileName: $e');
    }
  }

  Future<DesktopManagerConfig> getConfig() async {
    final mode = await _readSingleLine('desktop-mode', 'normal');
    final wallpaper = await _readSingleLine('wallpaper', '');
    final wallpaperDirs = await _readSingleLine('wallpaper-dirs', '');
    final animStr = await _readSingleLine('wallpaper-anim', '1');
    final anim = int.tryParse(animStr) ?? 1;

    // Read widgets-theme
    Color themeColor = Colors.black;
    double themeOpacity = 0.3;
    try {
      final themeFile = File('$_basePath/widgets-theme');
      if (await themeFile.exists()) {
        final lines = await themeFile.readAsLines();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('Color=')) {
            final hex = trimmed.substring(6).trim();
            if (hex.startsWith('#')) {
              themeColor = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
            }
          } else if (trimmed.startsWith('Opacity=')) {
            themeOpacity = double.tryParse(trimmed.substring(8).trim()) ?? 0.3;
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading widgets-theme: $e');
    }

    // Read available widgets
    List<String> available = [];
    try {
      final dir = Directory('$_basePath/widgets');
      if (await dir.exists()) {
        final entities = await dir.list().toList();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.so')) {
            available.add(entity.uri.pathSegments.last);
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading available widgets: $e');
    }

    // Read disabled widgets
    List<String> disabled = [];
    try {
      final enabledFile = File('$_basePath/widgets-enabled');
      if (await enabledFile.exists()) {
        final lines = await enabledFile.readAsLines();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('disabled:')) {
            disabled.add(trimmed.substring(9).trim());
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading widgets-enabled: $e');
    }

    return DesktopManagerConfig(
      desktopMode: mode,
      wallpaperPath: wallpaper,
      wallpaperDirs: wallpaperDirs,
      wallpaperAnim: anim,
      themeColor: themeColor,
      themeOpacity: themeOpacity,
      availableWidgets: available,
      disabledWidgets: disabled,
    );
  }

  Future<void> saveConfig(DesktopManagerConfig config) async {
    await _writeSingleLine('desktop-mode', config.desktopMode);
    await _writeSingleLine('wallpaper', config.wallpaperPath);
    await _writeSingleLine('wallpaper-dirs', config.wallpaperDirs);
    await _writeSingleLine('wallpaper-anim', config.wallpaperAnim.toString());

    // Save widgets-theme
    try {
      final themeFile = File('$_basePath/widgets-theme');
      if (!await themeFile.exists()) {
        await themeFile.create(recursive: true);
      }
      final colorHex = '#${config.themeColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      final themeContent = '[Theme]\nColor=$colorHex\nOpacity=${config.themeOpacity}\n';
      await themeFile.writeAsString(themeContent, flush: true);
    } catch (e) {
      debugPrint('Error writing widgets-theme: $e');
    }

    // Save widgets-enabled
    try {
      final enabledFile = File('$_basePath/widgets-enabled');
      if (!await enabledFile.exists()) {
        await enabledFile.create(recursive: true);
      }
      final content = '${config.disabledWidgets.map((w) => 'disabled:$w').join('\n')}\n';
      await enabledFile.writeAsString(content, flush: true);
    } catch (e) {
      debugPrint('Error writing widgets-enabled: $e');
    }
  }
}
