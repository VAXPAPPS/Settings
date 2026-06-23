import 'dart:io';
import 'package:flutter/material.dart';
import 'package:settings/features/vaxp_de/models/desktop_manager_config.dart';

class DesktopManagerService {
  final String _basePath;

  DesktopManagerService([String? basePath])
      : _basePath = basePath ?? '${Platform.environment['HOME']}/.config/vaxp/desktop';

  Future<DesktopManagerConfig> getConfig() async {
    final file = File('$_basePath/desktop.vaxp');
    
    String mode = 'normal';
    String wallpaper = '';
    String wallpaperDirs = '';
    int anim = 1;
    Color themeColor = Colors.black;
    double themeOpacity = 0.3;
    List<String> disabled = [];

    if (await file.exists()) {
      try {
        final lines = await file.readAsLines();
        String currentSection = '';

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            currentSection = trimmed;
            continue;
          }

          if (trimmed.isEmpty) continue;

          if (currentSection == '[Widgets]') {
            if (trimmed.startsWith('Disabled=')) {
              final widgetsStr = trimmed.substring(9);
              disabled = widgetsStr.split(';').where((w) => w.isNotEmpty).toList();
            }
          } else if (currentSection == '[Desktop]') {
            if (trimmed.startsWith('Mode=')) {
              mode = trimmed.substring(5);
            } else if (trimmed.startsWith('Wallpaper=')) {
              wallpaper = trimmed.substring(10);
            } else if (trimmed.startsWith('WallpaperDirs=')) {
              wallpaperDirs = trimmed.substring(14);
            } else if (trimmed.startsWith('WallpaperAnim=')) {
              anim = int.tryParse(trimmed.substring(14)) ?? 1;
            }
          } else if (currentSection == '[WidgetsTheme]') {
            if (trimmed.startsWith('Color=')) {
              final hex = trimmed.substring(6).trim();
              if (hex.startsWith('#')) {
                themeColor = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
              }
            } else if (trimmed.startsWith('Opacity=')) {
              themeOpacity = double.tryParse(trimmed.substring(8)) ?? 0.3;
            }
          }
        }
      } catch (e) {
        debugPrint('Error reading desktop.vaxp: $e');
      }
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
    try {
      final file = File('$_basePath/desktop.vaxp');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final buffer = StringBuffer();
      
      // [Widgets] section
      buffer.writeln('[Widgets]');
      final disabledStr = config.disabledWidgets.isEmpty ? '' : '${config.disabledWidgets.join(';')};';
      buffer.writeln('Disabled=$disabledStr');
      buffer.writeln();

      // [Desktop] section
      buffer.writeln('[Desktop]');
      buffer.writeln('Mode=${config.desktopMode}');
      buffer.writeln('Wallpaper=${config.wallpaperPath}');
      final dirs = config.wallpaperDirs.endsWith(';') || config.wallpaperDirs.isEmpty 
          ? config.wallpaperDirs 
          : '${config.wallpaperDirs};';
      buffer.writeln('WallpaperDirs=$dirs');
      buffer.writeln('WallpaperAnim=${config.wallpaperAnim}');
      buffer.writeln();

      // [WidgetsTheme] section
      buffer.writeln('[WidgetsTheme]');
      final colorHex = '#${config.themeColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      buffer.writeln('Color=$colorHex');
      buffer.writeln('Opacity=${config.themeOpacity}');
      buffer.writeln();

      await file.writeAsString(buffer.toString(), flush: true);
    } catch (e) {
      debugPrint('Error writing desktop.vaxp: $e');
    }
  }
}
