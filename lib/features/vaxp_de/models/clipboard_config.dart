import 'package:flutter/material.dart';

class ClipboardConfig {
  // [Settings]
  final bool ghostMode;

  // [Colors]
  final Color windowBoxBg;
  final Color windowBoxBorder;
  final Color glassPanelBg;
  final Color headerTitle;
  final Color ghostPillBg;
  final Color ghostPillText;
  final Color ghostPillBorder;
  final Color ghostActiveText;
  final Color ghostActiveBg;
  final Color ghostActiveBorder;
  final Color searchBoxBg;
  final Color searchBoxBorder;
  final Color searchBoxText;
  final Color searchBoxFocusBorder;
  final Color tabBtnBg;
  final Color tabBtnText;
  final Color tabBtnCheckedBg;
  final Color tabBtnCheckedText;
  final Color tabBtnCheckedBorder;
  final Color cardBg;
  final Color cardBorder;
  final Color cardHoverBorder;
  final Color cardText;
  final Color cardCodeText;
  final Color metaText;
  final Color pinFlagBg;
  final Color pinFlagText;
  final Color menuBg;
  final Color menuBorder;
  final Color menuItemText;
  final Color menuItemHoverBg;

  const ClipboardConfig({
    this.ghostMode = false,
    this.windowBoxBg = const Color.fromRGBO(0, 0, 0, 0.3),
    this.windowBoxBorder = const Color.fromRGBO(255, 255, 255, 0.09),
    this.glassPanelBg = const Color.fromRGBO(0, 0, 0, 0),
    this.headerTitle = const Color.fromRGBO(255, 255, 255, 1.0),
    this.ghostPillBg = const Color.fromRGBO(255, 255, 255, 0.05),
    this.ghostPillText = const Color.fromRGBO(155, 148, 184, 1.0),
    this.ghostPillBorder = const Color.fromRGBO(255, 255, 255, 0.09),
    this.ghostActiveText = const Color.fromRGBO(251, 113, 133, 1.0),
    this.ghostActiveBg = const Color.fromRGBO(251, 113, 133, 0.14),
    this.ghostActiveBorder = const Color.fromRGBO(251, 113, 133, 0.4),
    this.searchBoxBg = const Color.fromRGBO(255, 255, 255, 0.05),
    this.searchBoxBorder = const Color.fromRGBO(255, 255, 255, 0.09),
    this.searchBoxText = const Color.fromRGBO(255, 255, 255, 1.0),
    this.searchBoxFocusBorder = const Color.fromRGBO(0, 0, 0, 0.44),
    this.tabBtnBg = const Color.fromRGBO(255, 255, 255, 0.05),
    this.tabBtnText = const Color.fromRGBO(155, 148, 184, 1.0),
    this.tabBtnCheckedBg = const Color.fromRGBO(192, 132, 252, 0.16),
    this.tabBtnCheckedText = const Color.fromRGBO(192, 132, 252, 1.0),
    this.tabBtnCheckedBorder = const Color.fromRGBO(192, 132, 252, 0.3),
    this.cardBg = const Color.fromRGBO(255, 255, 255, 0.05),
    this.cardBorder = const Color.fromRGBO(255, 255, 255, 0.09),
    this.cardHoverBorder = const Color.fromRGBO(192, 132, 252, 1.0),
    this.cardText = const Color.fromRGBO(255, 255, 255, 1.0),
    this.cardCodeText = const Color.fromRGBO(96, 217, 201, 1.0),
    this.metaText = const Color.fromRGBO(155, 148, 184, 1.0),
    this.pinFlagBg = const Color.fromRGBO(251, 191, 103, 0.18),
    this.pinFlagText = const Color.fromRGBO(251, 191, 103, 1.0),
    this.menuBg = const Color.fromRGBO(0, 0, 0, 0.4),
    this.menuBorder = const Color.fromRGBO(0, 0, 0, 0.5),
    this.menuItemText = const Color.fromRGBO(255, 255, 255, 1.0),
    this.menuItemHoverBg = const Color.fromRGBO(0, 0, 0, 0.72),
  });

  ClipboardConfig copyWith({
    bool? ghostMode,
    Color? windowBoxBg,
    Color? windowBoxBorder,
    Color? glassPanelBg,
    Color? headerTitle,
    Color? ghostPillBg,
    Color? ghostPillText,
    Color? ghostPillBorder,
    Color? ghostActiveText,
    Color? ghostActiveBg,
    Color? ghostActiveBorder,
    Color? searchBoxBg,
    Color? searchBoxBorder,
    Color? searchBoxText,
    Color? searchBoxFocusBorder,
    Color? tabBtnBg,
    Color? tabBtnText,
    Color? tabBtnCheckedBg,
    Color? tabBtnCheckedText,
    Color? tabBtnCheckedBorder,
    Color? cardBg,
    Color? cardBorder,
    Color? cardHoverBorder,
    Color? cardText,
    Color? cardCodeText,
    Color? metaText,
    Color? pinFlagBg,
    Color? pinFlagText,
    Color? menuBg,
    Color? menuBorder,
    Color? menuItemText,
    Color? menuItemHoverBg,
  }) {
    return ClipboardConfig(
      ghostMode: ghostMode ?? this.ghostMode,
      windowBoxBg: windowBoxBg ?? this.windowBoxBg,
      windowBoxBorder: windowBoxBorder ?? this.windowBoxBorder,
      glassPanelBg: glassPanelBg ?? this.glassPanelBg,
      headerTitle: headerTitle ?? this.headerTitle,
      ghostPillBg: ghostPillBg ?? this.ghostPillBg,
      ghostPillText: ghostPillText ?? this.ghostPillText,
      ghostPillBorder: ghostPillBorder ?? this.ghostPillBorder,
      ghostActiveText: ghostActiveText ?? this.ghostActiveText,
      ghostActiveBg: ghostActiveBg ?? this.ghostActiveBg,
      ghostActiveBorder: ghostActiveBorder ?? this.ghostActiveBorder,
      searchBoxBg: searchBoxBg ?? this.searchBoxBg,
      searchBoxBorder: searchBoxBorder ?? this.searchBoxBorder,
      searchBoxText: searchBoxText ?? this.searchBoxText,
      searchBoxFocusBorder: searchBoxFocusBorder ?? this.searchBoxFocusBorder,
      tabBtnBg: tabBtnBg ?? this.tabBtnBg,
      tabBtnText: tabBtnText ?? this.tabBtnText,
      tabBtnCheckedBg: tabBtnCheckedBg ?? this.tabBtnCheckedBg,
      tabBtnCheckedText: tabBtnCheckedText ?? this.tabBtnCheckedText,
      tabBtnCheckedBorder: tabBtnCheckedBorder ?? this.tabBtnCheckedBorder,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      cardHoverBorder: cardHoverBorder ?? this.cardHoverBorder,
      cardText: cardText ?? this.cardText,
      cardCodeText: cardCodeText ?? this.cardCodeText,
      metaText: metaText ?? this.metaText,
      pinFlagBg: pinFlagBg ?? this.pinFlagBg,
      pinFlagText: pinFlagText ?? this.pinFlagText,
      menuBg: menuBg ?? this.menuBg,
      menuBorder: menuBorder ?? this.menuBorder,
      menuItemText: menuItemText ?? this.menuItemText,
      menuItemHoverBg: menuItemHoverBg ?? this.menuItemHoverBg,
    );
  }
}
