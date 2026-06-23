import 'package:flutter/material.dart';

class DesktopManagerConfig {
  final String desktopMode;
  final String wallpaperPath;
  final String wallpaperDirs;
  final int wallpaperAnim;
  final Color themeColor;
  final double themeOpacity;
  final List<String> availableWidgets;
  final List<String> disabledWidgets;

  const DesktopManagerConfig({
    this.desktopMode = 'normal',
    this.wallpaperPath = '',
    this.wallpaperDirs = '',
    this.wallpaperAnim = 1,
    this.themeColor = Colors.black,
    this.themeOpacity = 0.3,
    this.availableWidgets = const [],
    this.disabledWidgets = const [],
  });

  DesktopManagerConfig copyWith({
    String? desktopMode,
    String? wallpaperPath,
    String? wallpaperDirs,
    int? wallpaperAnim,
    Color? themeColor,
    double? themeOpacity,
    List<String>? availableWidgets,
    List<String>? disabledWidgets,
  }) {
    return DesktopManagerConfig(
      desktopMode: desktopMode ?? this.desktopMode,
      wallpaperPath: wallpaperPath ?? this.wallpaperPath,
      wallpaperDirs: wallpaperDirs ?? this.wallpaperDirs,
      wallpaperAnim: wallpaperAnim ?? this.wallpaperAnim,
      themeColor: themeColor ?? this.themeColor,
      themeOpacity: themeOpacity ?? this.themeOpacity,
      availableWidgets: availableWidgets ?? this.availableWidgets,
      disabledWidgets: disabledWidgets ?? this.disabledWidgets,
    );
  }

  bool isWidgetEnabled(String widgetName) {
    return !disabledWidgets.contains(widgetName);
  }

  static const List<String> animationNames = [
    'Sliding Doors',
    'Circle Reveal',
    'Smooth Crossfade',
    'Wipe Right',
    'Zoom Out & Fade',
    'Blinds',
    'Swipe Up',
    'Grid/Mosaic',
    'Diagonal Wipe',
    'Spin & Fade',
  ];
}
