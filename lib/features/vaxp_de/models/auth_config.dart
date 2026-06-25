import 'package:flutter/material.dart';

class AuthConfig {
  // [General]
  final String theme;

  // [Theme.Minimal]
  final Color minimalBackgroundColor;
  final Color minimalTextColor;
  final Color minimalInputBackground;
  final Color minimalInputTextColor;
  final Color minimalInputFocusBorder;
  final Color minimalPrimaryButton;
  final Color minimalPrimaryButtonHover;
  final Color minimalSecondaryButton;
  final Color minimalSecondaryButtonHover;
  final Color minimalAvatarRing;

  // [Theme.Polkit]
  final Color polkitBackgroundColor;
  final Color polkitBorderColor;
  final Color polkitTextColor;
  final Color polkitAccentColor;
  final Color polkitAccentColorHover;
  final Color polkitUserRowBackground;
  final Color polkitInputBackground;
  final Color polkitInputTextColor;
  final Color polkitButtonBackground;
  final Color polkitButtonHover;

  // [Theme.Terminal]
  final Color terminalBackgroundColor;
  final Color terminalBorderColor;
  final Color terminalTitleBarColor;
  final Color terminalTextColor;
  final Color terminalPromptColor;
  final Color terminalInputBackground;
  final Color terminalInputTextColor;
  final Color terminalHintColor;
  final Color terminalWarningColor;
  final Color terminalCommandColor;
  final Color terminalPathColor;
  final Color terminalDotRed;
  final Color terminalDotYellow;
  final Color terminalDotGreen;

  const AuthConfig({
    this.theme = 'Terminal',

    // Minimal
    this.minimalBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.3),
    this.minimalTextColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.minimalInputBackground = const Color.fromRGBO(0, 0, 0, 0.3),
    this.minimalInputTextColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.minimalInputFocusBorder = const Color.fromRGBO(21, 23, 28, 1.0),
    this.minimalPrimaryButton = const Color.fromRGBO(0, 0, 0, 0.3),
    this.minimalPrimaryButtonHover = const Color.fromRGBO(0, 0, 0, 1.0),
    this.minimalSecondaryButton = const Color.fromRGBO(241, 242, 245, 1.0),
    this.minimalSecondaryButtonHover = const Color.fromRGBO(232, 234, 239, 1.0),
    this.minimalAvatarRing = const Color.fromRGBO(21, 23, 28, 1.0),

    // Polkit
    this.polkitBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.3),
    this.polkitBorderColor = const Color.fromRGBO(0, 0, 0, 0.4),
    this.polkitTextColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.polkitAccentColor = const Color.fromRGBO(21, 23, 28, 1.0),
    this.polkitAccentColorHover = const Color.fromRGBO(0, 0, 0, 1.0),
    this.polkitUserRowBackground = const Color.fromRGBO(0, 0, 0, 0.3),
    this.polkitInputBackground = const Color.fromRGBO(0, 0, 0, 0.3),
    this.polkitInputTextColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.polkitButtonBackground = const Color.fromRGBO(0, 0, 0, 0.4),
    this.polkitButtonHover = const Color.fromRGBO(0, 0, 0, 0.56),

    // Terminal
    this.terminalBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.3),
    this.terminalBorderColor = const Color.fromRGBO(0, 0, 0, 0.4),
    this.terminalTitleBarColor = const Color.fromRGBO(0, 0, 0, 0),
    this.terminalTextColor = const Color.fromRGBO(0, 0, 0, 0.4),
    this.terminalPromptColor = const Color.fromRGBO(88, 224, 140, 1.0),
    this.terminalInputBackground = const Color.fromRGBO(0, 0, 0, 0.4),
    this.terminalInputTextColor = const Color.fromRGBO(255, 255, 255, 0.91),
    this.terminalHintColor = const Color.fromRGBO(90, 96, 110, 1.0),
    this.terminalWarningColor = const Color.fromRGBO(255, 180, 84, 1.0),
    this.terminalCommandColor = const Color.fromRGBO(232, 233, 236, 1.0),
    this.terminalPathColor = const Color.fromRGBO(255, 255, 255, 0.91),
    this.terminalDotRed = const Color.fromRGBO(255, 95, 87, 1.0),
    this.terminalDotYellow = const Color.fromRGBO(255, 189, 46, 1.0),
    this.terminalDotGreen = const Color.fromRGBO(40, 200, 64, 1.0),
  });

  AuthConfig copyWith({
    String? theme,
    Color? minimalBackgroundColor,
    Color? minimalTextColor,
    Color? minimalInputBackground,
    Color? minimalInputTextColor,
    Color? minimalInputFocusBorder,
    Color? minimalPrimaryButton,
    Color? minimalPrimaryButtonHover,
    Color? minimalSecondaryButton,
    Color? minimalSecondaryButtonHover,
    Color? minimalAvatarRing,
    Color? polkitBackgroundColor,
    Color? polkitBorderColor,
    Color? polkitTextColor,
    Color? polkitAccentColor,
    Color? polkitAccentColorHover,
    Color? polkitUserRowBackground,
    Color? polkitInputBackground,
    Color? polkitInputTextColor,
    Color? polkitButtonBackground,
    Color? polkitButtonHover,
    Color? terminalBackgroundColor,
    Color? terminalBorderColor,
    Color? terminalTitleBarColor,
    Color? terminalTextColor,
    Color? terminalPromptColor,
    Color? terminalInputBackground,
    Color? terminalInputTextColor,
    Color? terminalHintColor,
    Color? terminalWarningColor,
    Color? terminalCommandColor,
    Color? terminalPathColor,
    Color? terminalDotRed,
    Color? terminalDotYellow,
    Color? terminalDotGreen,
  }) {
    return AuthConfig(
      theme: theme ?? this.theme,
      minimalBackgroundColor: minimalBackgroundColor ?? this.minimalBackgroundColor,
      minimalTextColor: minimalTextColor ?? this.minimalTextColor,
      minimalInputBackground: minimalInputBackground ?? this.minimalInputBackground,
      minimalInputTextColor: minimalInputTextColor ?? this.minimalInputTextColor,
      minimalInputFocusBorder: minimalInputFocusBorder ?? this.minimalInputFocusBorder,
      minimalPrimaryButton: minimalPrimaryButton ?? this.minimalPrimaryButton,
      minimalPrimaryButtonHover: minimalPrimaryButtonHover ?? this.minimalPrimaryButtonHover,
      minimalSecondaryButton: minimalSecondaryButton ?? this.minimalSecondaryButton,
      minimalSecondaryButtonHover: minimalSecondaryButtonHover ?? this.minimalSecondaryButtonHover,
      minimalAvatarRing: minimalAvatarRing ?? this.minimalAvatarRing,
      polkitBackgroundColor: polkitBackgroundColor ?? this.polkitBackgroundColor,
      polkitBorderColor: polkitBorderColor ?? this.polkitBorderColor,
      polkitTextColor: polkitTextColor ?? this.polkitTextColor,
      polkitAccentColor: polkitAccentColor ?? this.polkitAccentColor,
      polkitAccentColorHover: polkitAccentColorHover ?? this.polkitAccentColorHover,
      polkitUserRowBackground: polkitUserRowBackground ?? this.polkitUserRowBackground,
      polkitInputBackground: polkitInputBackground ?? this.polkitInputBackground,
      polkitInputTextColor: polkitInputTextColor ?? this.polkitInputTextColor,
      polkitButtonBackground: polkitButtonBackground ?? this.polkitButtonBackground,
      polkitButtonHover: polkitButtonHover ?? this.polkitButtonHover,
      terminalBackgroundColor: terminalBackgroundColor ?? this.terminalBackgroundColor,
      terminalBorderColor: terminalBorderColor ?? this.terminalBorderColor,
      terminalTitleBarColor: terminalTitleBarColor ?? this.terminalTitleBarColor,
      terminalTextColor: terminalTextColor ?? this.terminalTextColor,
      terminalPromptColor: terminalPromptColor ?? this.terminalPromptColor,
      terminalInputBackground: terminalInputBackground ?? this.terminalInputBackground,
      terminalInputTextColor: terminalInputTextColor ?? this.terminalInputTextColor,
      terminalHintColor: terminalHintColor ?? this.terminalHintColor,
      terminalWarningColor: terminalWarningColor ?? this.terminalWarningColor,
      terminalCommandColor: terminalCommandColor ?? this.terminalCommandColor,
      terminalPathColor: terminalPathColor ?? this.terminalPathColor,
      terminalDotRed: terminalDotRed ?? this.terminalDotRed,
      terminalDotYellow: terminalDotYellow ?? this.terminalDotYellow,
      terminalDotGreen: terminalDotGreen ?? this.terminalDotGreen,
    );
  }
}
