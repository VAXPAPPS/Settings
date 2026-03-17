import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settings/core/services/venom_display_service.dart';
import 'display_settings_event.dart';
import 'display_settings_state.dart';
import '../../power_settings/services/power_service.dart';

class DisplaySettingsBloc
    extends Bloc<DisplaySettingsEvent, DisplaySettingsState> {
  DisplayService? _displayService;
  StreamSubscription? _displayChangedSubscription;

  final Map<String, List<DisplayMode>> _modesCache = {};
  final Map<String, RotationType> _rotationCache = {};
  final Map<String, double> _scaleCache = {};

  DisplaySettingsBloc() : super(const DisplaySettingsState()) {
    on<InitializeDisplaySettings>(_onInitializeDisplaySettings);
    on<RefreshDisplays>(_onRefreshDisplays);
    on<SelectDisplay>(_onSelectDisplay);
    on<SetOrientation>(_onSetOrientation);
    on<SetResolution>(_onSetResolution);
    on<SetRefreshRate>(_onSetRefreshRate);
    on<SetBrightness>(_onSetBrightness);
    on<SetScale>(_onSetScale);
    on<SetFractionalScaling>(_onSetFractionalScaling);
    on<ToggleDisplayEnabled>(_onToggleDisplayEnabled);
    on<SetPrimaryDisplay>(_onSetPrimaryDisplay);
    on<SetMirrorMode>(_onSetMirrorMode);
    on<SaveDisplayProfile>(_onSaveDisplayProfile);
    on<LoadDisplayProfile>(_onLoadDisplayProfile);
    on<DeleteDisplayProfile>(_onDeleteDisplayProfile);
    on<DisplayChangedExternally>(_onDisplayChangedExternally);
  }

  Future<void> _onInitializeDisplaySettings(
    InitializeDisplaySettings event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    emit(state.copyWith(status: DisplaySettingsStatus.loading));

    _displayService = DisplayService();
    final connected = await _displayService!.connect().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(
        state.copyWith(
          status: DisplaySettingsStatus.error,
          errorMessage: 'Failed to connect to Display Daemon',
        ),
      );
      return;
    }

    _displayChangedSubscription?.cancel();
    _displayChangedSubscription = _displayService!.displayChangedStream.listen((
      name,
    ) {
      add(DisplayChangedExternally(name));
    });

    try {
      final displays = await _displayService!.getDisplays();
      final profiles = await _displayService!.getProfiles();

      final connectedDisplays = displays.where((d) => d.isConnected).toList();

      emit(
        state.copyWith(
          status: DisplaySettingsStatus.loaded,
          displayServer: 'X11 (Daemon)',
          displays: connectedDisplays,
          displayProfiles: profiles,
        ),
      );

      if (connectedDisplays.isEmpty) return;

      final primary = connectedDisplays.firstWhere(
        (d) => d.isPrimary,
        orElse: () => connectedDisplays.first,
      );

      add(SelectDisplay(primary.name));
      _loadBrightnessInBackground(emit);
    } catch (e) {
      debugPrint('Display init error: $e');
      emit(
        state.copyWith(
          status: DisplaySettingsStatus.error,
          errorMessage: 'Failed to load display settings: $e',
        ),
      );
    }
  }

  Future<void> _loadBrightnessInBackground(
    Emitter<DisplaySettingsState> emit,
  ) async {
    final powerService = PowerService();
    try {
      final connected = await powerService.connect();
      if (connected) {
        final current = await powerService.getBrightness();
        final max = await powerService.getMaxBrightness();
        await powerService.disconnect();

        if (max > 0) {
          emit(
            state.copyWith(
              brightness: (current / max * 100).clamp(0.0, 100.0),
              maxBrightness: max.toDouble(),
              brightnessSupported: true,
              brightnessMethod: 'venom_power',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Brightness init error: $e');
    } finally {
      await powerService.disconnect();
    }
  }

  Future<void> _onRefreshDisplays(
    RefreshDisplays event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    final displays = await _displayService!.getDisplays();
    final connected = displays.where((d) => d.isConnected).toList();

    emit(state.copyWith(displays: connected));
  }

  Future<void> _onSelectDisplay(
    SelectDisplay event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    emit(state.copyWith(selectedDisplayName: event.displayName));

    List<DisplayMode> modes;
    RotationType rotation;
    double scale;

    if (_modesCache.containsKey(event.displayName)) {
      modes = _modesCache[event.displayName]!;
      rotation = _rotationCache[event.displayName]!;
      scale = _scaleCache[event.displayName]!;
    } else {
      modes = await _displayService!.getModes(event.displayName);
      rotation = await _displayService!.getRotation(event.displayName);
      scale = await _displayService!.getScale(event.displayName);

      _modesCache[event.displayName] = modes;
      _rotationCache[event.displayName] = rotation;
      _scaleCache[event.displayName] = scale;
    }

    final display = state.displays.firstWhere(
      (d) => d.name == event.displayName,
      orElse: () => state.displays.first,
    );

    // Find current mode
    DisplayMode? currentMode;
    try {
      currentMode = modes.firstWhere(
        (m) => m.width == display.width && m.height == display.height,
      );
    } catch (_) {
      if (modes.isNotEmpty) currentMode = modes.first;
    }

    // Get refresh rates for current resolution
    final refreshRates = modes
        .where((m) => m.width == display.width && m.height == display.height)
        .map((m) => m.rateString)
        .toList();

    emit(
      state.copyWith(
        currentMode: currentMode,
        availableModes: modes,
        refreshRate: display.rateString,
        availableRefreshRates: refreshRates,
        orientation: _rotationToOrientation(rotation),
        scale: (scale * 100).round(),
      ),
    );
  }

  Future<void> _onSetOrientation(
    SetOrientation event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null || _displayService == null) return;

    emit(state.copyWith(orientation: event.orientation));

    final rotation = _orientationToRotation(event.orientation);
    final success = await _displayService!.setRotation(displayName, rotation);
    if (success) {
      _rotationCache[displayName] = rotation;
    }
  }

  Future<void> _onSetResolution(
    SetResolution event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null || _displayService == null) return;

    emit(state.copyWith(currentMode: event.mode));

    final success = await _displayService!.setResolution(
      displayName,
      event.mode.width,
      event.mode.height,
    );

    if (success) {
      final modes = _modesCache[displayName] ?? [];
      final refreshRates = modes
          .where(
            (m) => m.width == event.mode.width && m.height == event.mode.height,
          )
          .map((m) => m.rateString)
          .toList();
      emit(state.copyWith(availableRefreshRates: refreshRates));
    }
  }

  Future<void> _onSetRefreshRate(
    SetRefreshRate event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null || _displayService == null) return;

    emit(state.copyWith(refreshRate: event.refreshRate));

    final rate =
        double.tryParse(event.refreshRate.replaceAll(' Hz', '')) ?? 60.0;
    await _displayService!.setRefreshRate(displayName, rate);
  }

  Future<void> _onSetBrightness(
    SetBrightness event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    emit(state.copyWith(brightness: event.brightness));

    if (state.brightnessMethod == 'venom_power') {
      final powerService = PowerService();
      try {
        final connected = await powerService.connect();
        if (connected) {
          final absoluteValue = (event.brightness / 100.0 * state.maxBrightness)
              .round();
          await powerService.setBrightness(absoluteValue);
        }
      } finally {
        await powerService.disconnect();
      }
    }
  }

  Future<void> _onSetScale(
    SetScale event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null || _displayService == null) return;

    emit(state.copyWith(scale: event.scale));

    final scale = event.scale / 100.0;
    final success = await _displayService!.setScale(displayName, scale);
    if (success) {
      _scaleCache[displayName] = scale;
    }
  }

  Future<void> _onSetFractionalScaling(
    SetFractionalScaling event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    emit(state.copyWith(fractionalScaling: event.enabled));
  }

  Future<void> _onToggleDisplayEnabled(
    ToggleDisplayEnabled event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    bool success;
    if (event.enabled) {
      success = await _displayService!.enableOutput(event.displayName);
    } else {
      success = await _displayService!.disableOutput(event.displayName);
    }
    if (success) add(const RefreshDisplays());
  }

  Future<void> _onSetPrimaryDisplay(
    SetPrimaryDisplay event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    final success = await _displayService!.setPrimary(event.displayName);
    if (success) add(const RefreshDisplays());
  }

  Future<void> _onSetMirrorMode(
    SetMirrorMode event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    bool success;
    if (event.targetDisplay != null) {
      success = await _displayService!.setMirror(
        event.sourceDisplay,
        event.targetDisplay!,
      );
    } else {
      success = await _displayService!.disableMirror(event.sourceDisplay);
    }
    if (success) add(const RefreshDisplays());
  }

  Future<void> _onSaveDisplayProfile(
    SaveDisplayProfile event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    final success = await _displayService!.saveProfile(event.profileName);
    if (success) {
      final profiles = await _displayService!.getProfiles();
      emit(state.copyWith(displayProfiles: profiles));
    }
  }

  Future<void> _onLoadDisplayProfile(
    LoadDisplayProfile event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    final success = await _displayService!.loadProfile(event.profileName);
    if (success) {
      _modesCache.clear();
      _rotationCache.clear();
      _scaleCache.clear();
      add(const RefreshDisplays());
    }
  }

  Future<void> _onDeleteDisplayProfile(
    DeleteDisplayProfile event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_displayService == null) return;

    final success = await _displayService!.deleteProfile(event.profileName);
    if (success) {
      final profiles = await _displayService!.getProfiles();
      emit(state.copyWith(displayProfiles: profiles));
    }
  }

  Future<void> _onDisplayChangedExternally(
    DisplayChangedExternally event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    _modesCache.remove(event.displayName);
    _rotationCache.remove(event.displayName);
    _scaleCache.remove(event.displayName);
    add(const RefreshDisplays());
  }

  String _rotationToOrientation(RotationType rotation) {
    switch (rotation) {
      case RotationType.left:
        return 'Portrait Left';
      case RotationType.right:
        return 'Portrait Right';
      case RotationType.inverted:
        return 'Landscape Inverted';
      default:
        return 'Landscape';
    }
  }

  RotationType _orientationToRotation(String orientation) {
    switch (orientation) {
      case 'Portrait Left':
        return RotationType.left;
      case 'Portrait Right':
        return RotationType.right;
      case 'Landscape Inverted':
        return RotationType.inverted;
      default:
        return RotationType.normal;
    }
  }

  @override
  Future<void> close() {
    _displayChangedSubscription?.cancel();
    _displayService?.disconnect();
    return super.close();
  }
}
