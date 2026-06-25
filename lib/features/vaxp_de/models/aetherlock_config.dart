import 'package:flutter/material.dart';

class AetherLockConfig {
  // [Weather]
  final String weatherLocation;

  // [Colors]
  final Color panelBackground;
  final Color panelBorder;
  final double panelBorderWidth;
  final Color outerBorder;
  final double outerBorderWidth;
  final Color textBright;
  final Color textDim;
  final Color accent;
  final Color accentDim;
  final Color background;

  // [Notifications]
  final bool hideContent;

  const AetherLockConfig({
    // Weather
    this.weatherLocation = 'karbala',

    // Colors
    this.panelBackground = const Color(0x8C141C1E),
    this.panelBorder = const Color(0x12FFFFFF),
    this.panelBorderWidth = 1.0,
    this.outerBorder = const Color(0x12FFFFFF),
    this.outerBorderWidth = 1.0,
    this.textBright = const Color(0xFFE6F5F0),
    this.textDim = const Color(0xFF9FB3B0),
    this.accent = const Color(0xFF7EE0C9),
    this.accentDim = const Color(0x267EE0C9),
    this.background = const Color(0xFF111111),

    // Notifications
    this.hideContent = false,
  });

  AetherLockConfig copyWith({
    String? weatherLocation,
    Color? panelBackground,
    Color? panelBorder,
    double? panelBorderWidth,
    Color? outerBorder,
    double? outerBorderWidth,
    Color? textBright,
    Color? textDim,
    Color? accent,
    Color? accentDim,
    Color? background,
    bool? hideContent,
  }) {
    return AetherLockConfig(
      weatherLocation: weatherLocation ?? this.weatherLocation,
      panelBackground: panelBackground ?? this.panelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      panelBorderWidth: panelBorderWidth ?? this.panelBorderWidth,
      outerBorder: outerBorder ?? this.outerBorder,
      outerBorderWidth: outerBorderWidth ?? this.outerBorderWidth,
      textBright: textBright ?? this.textBright,
      textDim: textDim ?? this.textDim,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      background: background ?? this.background,
      hideContent: hideContent ?? this.hideContent,
    );
  }
}
