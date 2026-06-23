import 'package:flutter/material.dart';

class OsdNotifyConfig {
  // [Notify]
  final Color notifyBgColor;
  final Color notifyBorderColor;
  final Color notifyTitleTextColor;
  final Color notifyBodyTextColor;
  final Color notifyBtnBgColor;
  final Color notifyBtnTextColor;
  final Color notifyBtnHoverBgColor;
  final Color notifyBtnHoverTextColor;
  final int notifyMarginX;
  final int notifyMarginY;
  final int notifySpacing;
  final String notifyPosition;

  // [OSD]
  final Color osdBgColor;
  final Color osdTextColor;
  final Color osdBarBgColor;
  final Color osdBarFgColor;
  final Color osdIconNormalColor;
  final Color osdIconMutedColor;

  // [Sounds]
  final String soundNotification;
  final String soundChargerConnect;
  final String soundChargerDisconnect;
  final String soundUsbConnect;
  final String soundUsbDisconnect;
  final String soundLimitHigh;
  final String soundLimitLow;
  final String soundError;

  const OsdNotifyConfig({
    // Notify defaults
    this.notifyBgColor = const Color.fromARGB(100, 0, 0, 0), // rgba(0,0,0,0.39)
    this.notifyBorderColor = const Color.fromARGB(204, 255, 255, 255), // rgba(255,255,255,0.8)
    this.notifyTitleTextColor = const Color(0xFF00FFFF),
    this.notifyBodyTextColor = const Color(0xFFEEEEEE),
    this.notifyBtnBgColor = const Color(0xFF222222),
    this.notifyBtnTextColor = const Color(0xFF00FFFF),
    this.notifyBtnHoverBgColor = const Color(0xFF00FFFF),
    this.notifyBtnHoverTextColor = const Color(0xFF000000),
    this.notifyMarginX = 20,
    this.notifyMarginY = 50,
    this.notifySpacing = 10,
    this.notifyPosition = 'top-right',

    // OSD defaults
    this.osdBgColor = const Color.fromARGB(76, 0, 0, 0), // rgba(0,0,0,0.3)
    this.osdTextColor = const Color(0xFF00FFFF),
    this.osdBarBgColor = const Color.fromARGB(255, 76, 76, 76), // rgba(76,76,76,1.0)
    this.osdBarFgColor = const Color(0xFF00FFFF),
    this.osdIconNormalColor = const Color(0xFFFFFFFF),
    this.osdIconMutedColor = const Color(0xFFFF3333),

    // Sounds defaults
    this.soundNotification = '',
    this.soundChargerConnect = '',
    this.soundChargerDisconnect = '',
    this.soundUsbConnect = '',
    this.soundUsbDisconnect = '',
    this.soundLimitHigh = '',
    this.soundLimitLow = '',
    this.soundError = '',
  });

  OsdNotifyConfig copyWith({
    Color? notifyBgColor,
    Color? notifyBorderColor,
    Color? notifyTitleTextColor,
    Color? notifyBodyTextColor,
    Color? notifyBtnBgColor,
    Color? notifyBtnTextColor,
    Color? notifyBtnHoverBgColor,
    Color? notifyBtnHoverTextColor,
    int? notifyMarginX,
    int? notifyMarginY,
    int? notifySpacing,
    String? notifyPosition,

    Color? osdBgColor,
    Color? osdTextColor,
    Color? osdBarBgColor,
    Color? osdBarFgColor,
    Color? osdIconNormalColor,
    Color? osdIconMutedColor,

    String? soundNotification,
    String? soundChargerConnect,
    String? soundChargerDisconnect,
    String? soundUsbConnect,
    String? soundUsbDisconnect,
    String? soundLimitHigh,
    String? soundLimitLow,
    String? soundError,
  }) {
    return OsdNotifyConfig(
      notifyBgColor: notifyBgColor ?? this.notifyBgColor,
      notifyBorderColor: notifyBorderColor ?? this.notifyBorderColor,
      notifyTitleTextColor: notifyTitleTextColor ?? this.notifyTitleTextColor,
      notifyBodyTextColor: notifyBodyTextColor ?? this.notifyBodyTextColor,
      notifyBtnBgColor: notifyBtnBgColor ?? this.notifyBtnBgColor,
      notifyBtnTextColor: notifyBtnTextColor ?? this.notifyBtnTextColor,
      notifyBtnHoverBgColor: notifyBtnHoverBgColor ?? this.notifyBtnHoverBgColor,
      notifyBtnHoverTextColor: notifyBtnHoverTextColor ?? this.notifyBtnHoverTextColor,
      notifyMarginX: notifyMarginX ?? this.notifyMarginX,
      notifyMarginY: notifyMarginY ?? this.notifyMarginY,
      notifySpacing: notifySpacing ?? this.notifySpacing,
      notifyPosition: notifyPosition ?? this.notifyPosition,

      osdBgColor: osdBgColor ?? this.osdBgColor,
      osdTextColor: osdTextColor ?? this.osdTextColor,
      osdBarBgColor: osdBarBgColor ?? this.osdBarBgColor,
      osdBarFgColor: osdBarFgColor ?? this.osdBarFgColor,
      osdIconNormalColor: osdIconNormalColor ?? this.osdIconNormalColor,
      osdIconMutedColor: osdIconMutedColor ?? this.osdIconMutedColor,

      soundNotification: soundNotification ?? this.soundNotification,
      soundChargerConnect: soundChargerConnect ?? this.soundChargerConnect,
      soundChargerDisconnect: soundChargerDisconnect ?? this.soundChargerDisconnect,
      soundUsbConnect: soundUsbConnect ?? this.soundUsbConnect,
      soundUsbDisconnect: soundUsbDisconnect ?? this.soundUsbDisconnect,
      soundLimitHigh: soundLimitHigh ?? this.soundLimitHigh,
      soundLimitLow: soundLimitLow ?? this.soundLimitLow,
      soundError: soundError ?? this.soundError,
    );
  }

  static const List<String> positions = [
    'top-right',
    'top-left',
    'bottom-right',
    'bottom-left',
    'top-center',
    'bottom-center',
  ];
}
