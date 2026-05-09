import 'package:equatable/equatable.dart';
import 'package:settings/core/services/venom_display_service.dart';

enum DisplaySettingsStatus { initial, loading, loaded, error }

/// Result of a test-configuration request
enum ConfigTestResult { none, succeeded, failed, cancelled }

class DisplaySettingsState extends Equatable {
  final DisplaySettingsStatus status;
  final String displayServer;
  final String orientation;
  final DisplayMode? currentMode;
  final List<DisplayMode> availableModes;
  final String refreshRate;
  final List<String> availableRefreshRates;
  final int scale;
  final bool fractionalScaling;
  final double brightness;
  final double maxBrightness;
  final bool brightnessSupported;
  final String brightnessMethod;
  final List<DisplayInfo> displays;
  final String? selectedDisplayName;
  final List<String> displayProfiles;
  final String? errorMessage;

  // ── Wayland-specific fields ────────────────────────────────────────────────
  final bool isWaylandBackend;
  final bool adaptiveSyncEnabled;
  final ConfigTestResult configTestResult;
  final int displayPositionX;
  final int displayPositionY;

  const DisplaySettingsState({
    this.status = DisplaySettingsStatus.initial,
    this.displayServer = 'Unknown',
    this.orientation = 'Landscape',
    this.currentMode,
    this.availableModes = const [],
    this.refreshRate = '60.00 Hz',
    this.availableRefreshRates = const [],
    this.scale = 100,
    this.fractionalScaling = false,
    this.brightness = 100.0,
    this.maxBrightness = 100.0,
    this.brightnessSupported = false,
    this.brightnessMethod = 'none',
    this.displays = const [],
    this.selectedDisplayName,
    this.displayProfiles = const [],
    this.errorMessage,
    // Wayland extras
    this.isWaylandBackend = false,
    this.adaptiveSyncEnabled = false,
    this.configTestResult = ConfigTestResult.none,
    this.displayPositionX = 0,
    this.displayPositionY = 0,
  });

  DisplayInfo? get selectedDisplay {
    if (selectedDisplayName == null || displays.isEmpty) return null;
    try {
      return displays.firstWhere((d) => d.name == selectedDisplayName);
    } catch (_) {
      return displays.isNotEmpty ? displays.first : null;
    }
  }

  String get currentResolution => currentMode?.resolution ?? '';

  DisplaySettingsState copyWith({
    DisplaySettingsStatus? status,
    String? displayServer,
    String? orientation,
    DisplayMode? currentMode,
    List<DisplayMode>? availableModes,
    String? refreshRate,
    List<String>? availableRefreshRates,
    int? scale,
    bool? fractionalScaling,
    double? brightness,
    double? maxBrightness,
    bool? brightnessSupported,
    String? brightnessMethod,
    List<DisplayInfo>? displays,
    String? selectedDisplayName,
    List<String>? displayProfiles,
    String? errorMessage,
    bool? isWaylandBackend,
    bool? adaptiveSyncEnabled,
    ConfigTestResult? configTestResult,
    int? displayPositionX,
    int? displayPositionY,
  }) {
    return DisplaySettingsState(
      status: status ?? this.status,
      displayServer: displayServer ?? this.displayServer,
      orientation: orientation ?? this.orientation,
      currentMode: currentMode ?? this.currentMode,
      availableModes: availableModes ?? this.availableModes,
      refreshRate: refreshRate ?? this.refreshRate,
      availableRefreshRates:
          availableRefreshRates ?? this.availableRefreshRates,
      scale: scale ?? this.scale,
      fractionalScaling: fractionalScaling ?? this.fractionalScaling,
      brightness: brightness ?? this.brightness,
      maxBrightness: maxBrightness ?? this.maxBrightness,
      brightnessSupported: brightnessSupported ?? this.brightnessSupported,
      brightnessMethod: brightnessMethod ?? this.brightnessMethod,
      displays: displays ?? this.displays,
      selectedDisplayName: selectedDisplayName ?? this.selectedDisplayName,
      displayProfiles: displayProfiles ?? this.displayProfiles,
      errorMessage: errorMessage,
      isWaylandBackend: isWaylandBackend ?? this.isWaylandBackend,
      adaptiveSyncEnabled: adaptiveSyncEnabled ?? this.adaptiveSyncEnabled,
      configTestResult: configTestResult ?? this.configTestResult,
      displayPositionX: displayPositionX ?? this.displayPositionX,
      displayPositionY: displayPositionY ?? this.displayPositionY,
    );
  }

  @override
  List<Object?> get props => [
    status,
    displayServer,
    orientation,
    currentMode,
    availableModes,
    refreshRate,
    availableRefreshRates,
    scale,
    fractionalScaling,
    brightness,
    maxBrightness,
    brightnessSupported,
    brightnessMethod,
    displays,
    selectedDisplayName,
    displayProfiles,
    errorMessage,
    isWaylandBackend,
    adaptiveSyncEnabled,
    configTestResult,
    displayPositionX,
    displayPositionY,
  ];
}
