import 'package:equatable/equatable.dart';
import 'package:antidote/features/window_manager/models/window_node.dart';

enum WindowManagerStatus { initial, loading, loaded, error }

class WindowManagerState extends Equatable {
  final WindowManagerStatus status;

  // Windows
  final List<WindowNode> windows;
  final WindowNode? focusedWindow;

  // Desktops
  final List<Desktop> desktops;
  final String? activeDesktop;

  // Monitors
  final List<Monitor> monitors;
  final String? activeMonitor;

  // Configuration
  final WindowManagerConfig config;

  // Preselection
  final String? preselectionDirection;
  final double preselectionRatio;

  final String? errorMessage;

  const WindowManagerState({
    this.status = WindowManagerStatus.initial,
    this.windows = const [],
    this.focusedWindow,
    this.desktops = const [],
    this.activeDesktop,
    this.monitors = const [],
    this.activeMonitor,
    this.config = const WindowManagerConfig(
      floatingMode: false,
      snapToEdge: false,
      snapThreshold: 20,
      borderWidth: 2,
      focusedBorderColor: '#5e81ac',
      normalBorderColor: '#3b4252',
      windowGap: 10,
      topPadding: 30,
      bottomPadding: 0,
      focusOpacity: true,
      inactiveOpacity: 0.85,
      activeOpacity: 1.0,
    ),
    this.preselectionDirection,
    this.preselectionRatio = 0.5,
    this.errorMessage,
  });

  WindowManagerState copyWith({
    WindowManagerStatus? status,
    List<WindowNode>? windows,
    WindowNode? focusedWindow,
    List<Desktop>? desktops,
    String? activeDesktop,
    List<Monitor>? monitors,
    String? activeMonitor,
    WindowManagerConfig? config,
    String? preselectionDirection,
    double? preselectionRatio,
    String? errorMessage,
  }) {
    return WindowManagerState(
      status: status ?? this.status,
      windows: windows ?? this.windows,
      focusedWindow: focusedWindow ?? this.focusedWindow,
      desktops: desktops ?? this.desktops,
      activeDesktop: activeDesktop ?? this.activeDesktop,
      monitors: monitors ?? this.monitors,
      activeMonitor: activeMonitor ?? this.activeMonitor,
      config: config ?? this.config,
      preselectionDirection: preselectionDirection ?? this.preselectionDirection,
      preselectionRatio: preselectionRatio ?? this.preselectionRatio,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    windows,
    focusedWindow,
    desktops,
    activeDesktop,
    monitors,
    activeMonitor,
    config,
    preselectionDirection,
    preselectionRatio,
    errorMessage,
  ];
}
