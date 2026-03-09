import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🪟 Window Models
// ═══════════════════════════════════════════════════════════════════════════

enum WindowState { tiled, floating, fullscreen, maximized }

enum WindowDirection { north, south, east, west, next, prev }

class WindowNode extends Equatable {
  final String id;
  final String title;
  final WindowState state;
  final bool hidden;
  final int x;
  final int y;
  final int width;
  final int height;

  const WindowNode({
    required this.id,
    required this.title,
    required this.state,
    required this.hidden,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    state,
    hidden,
    x,
    y,
    width,
    height,
  ];
}

class Desktop extends Equatable {
  final String name;
  final String layout;
  final bool active;
  final int windowCount;

  const Desktop({
    required this.name,
    required this.layout,
    required this.active,
    required this.windowCount,
  });

  @override
  List<Object?> get props => [name, layout, active, windowCount];
}

class Monitor extends Equatable {
  final String name;
  final int width;
  final int height;
  final int x;
  final int y;
  final bool primary;

  const Monitor({
    required this.name,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.primary,
  });

  @override
  List<Object?> get props => [name, width, height, x, y, primary];
}

class WindowManagerConfig extends Equatable {
  final bool floatingMode;
  final bool snapToEdge;
  final int snapThreshold;
  final int borderWidth;
  final String focusedBorderColor;
  final String normalBorderColor;
  final int windowGap;
  final int topPadding;
  final int bottomPadding;
  final bool focusOpacity;
  final double inactiveOpacity;
  final double activeOpacity;

  const WindowManagerConfig({
    required this.floatingMode,
    required this.snapToEdge,
    required this.snapThreshold,
    required this.borderWidth,
    required this.focusedBorderColor,
    required this.normalBorderColor,
    required this.windowGap,
    required this.topPadding,
    required this.bottomPadding,
    required this.focusOpacity,
    required this.inactiveOpacity,
    required this.activeOpacity,
  });

  WindowManagerConfig copyWith({
    bool? floatingMode,
    bool? snapToEdge,
    int? snapThreshold,
    int? borderWidth,
    String? focusedBorderColor,
    String? normalBorderColor,
    int? windowGap,
    int? topPadding,
    int? bottomPadding,
    bool? focusOpacity,
    double? inactiveOpacity,
    double? activeOpacity,
  }) {
    return WindowManagerConfig(
      floatingMode: floatingMode ?? this.floatingMode,
      snapToEdge: snapToEdge ?? this.snapToEdge,
      snapThreshold: snapThreshold ?? this.snapThreshold,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      normalBorderColor: normalBorderColor ?? this.normalBorderColor,
      windowGap: windowGap ?? this.windowGap,
      topPadding: topPadding ?? this.topPadding,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      focusOpacity: focusOpacity ?? this.focusOpacity,
      inactiveOpacity: inactiveOpacity ?? this.inactiveOpacity,
      activeOpacity: activeOpacity ?? this.activeOpacity,
    );
  }

  @override
  List<Object?> get props => [
    floatingMode,
    snapToEdge,
    snapThreshold,
    borderWidth,
    focusedBorderColor,
    normalBorderColor,
    windowGap,
    topPadding,
    bottomPadding,
    focusOpacity,
    inactiveOpacity,
    activeOpacity,
  ];
}
