import 'package:flutter/material.dart';

class DockConfig {
  final String position;
  final Color backgroundColor;
  final Color contextMenuColor;
  final Color indicatorColor;
  final Color launchRingColor;
  final int launchAnimation;

  const DockConfig({
    this.position = 'bottom',
    this.backgroundColor = const Color(0x4D000000), // rgba(0, 0, 0, 0.300)
    this.contextMenuColor = const Color(0xC7080A0E), // rgba(8, 10, 14, 0.78)
    this.indicatorColor = const Color(0xFF00FCD2),
    this.launchRingColor = const Color(0xFF00FCD2),
    this.launchAnimation = 4,
  });

  DockConfig copyWith({
    String? position,
    Color? backgroundColor,
    Color? contextMenuColor,
    Color? indicatorColor,
    Color? launchRingColor,
    int? launchAnimation,
  }) {
    return DockConfig(
      position: position ?? this.position,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contextMenuColor: contextMenuColor ?? this.contextMenuColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      launchRingColor: launchRingColor ?? this.launchRingColor,
      launchAnimation: launchAnimation ?? this.launchAnimation,
    );
  }

  // Parse color from string (rgba or hex)
  static Color parseColor(String colorStr) {
    try {
      colorStr = colorStr.trim();
      if (colorStr.startsWith('#')) {
        String hex = colorStr.replaceFirst('#', '');
        if (hex.length == 6) {
          hex = 'FF$hex'; // Add alpha if missing
        }
        return Color(int.parse(hex, radix: 16));
      } else if (colorStr.startsWith('rgba(')) {
        final content = colorStr.substring(5, colorStr.length - 1);
        final parts = content.split(',').map((e) => e.trim()).toList();
        if (parts.length == 4) {
          final r = int.parse(parts[0]);
          final g = int.parse(parts[1]);
          final b = int.parse(parts[2]);
          final a = double.parse(parts[3]);
          return Color.fromRGBO(r, g, b, a);
        }
      }
    } catch (e) {
      debugPrint('Failed to parse color: $colorStr');
    }
    return Colors.transparent; // Fallback
  }

  // Format color to string based on isRgba preference
  static String formatColor(Color color, {bool isRgba = false}) {
    if (isRgba) {
      return 'rgba(${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}, ${color.a.toStringAsFixed(3)})';
    } else {
      return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'; // Exclude alpha for hex to match `#00fcd2` format
    }
  }
}
