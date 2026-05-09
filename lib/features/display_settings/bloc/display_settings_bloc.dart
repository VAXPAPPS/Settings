import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:settings/core/services/venom_display_service.dart';
import 'package:settings/core/services/wlr_output_service.dart';
import 'package:settings/features/power_settings/services/power_service.dart';

import 'display_settings_event.dart';
import 'display_settings_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DisplaySettingsBloc
//
// On Wayland: uses WlrOutputService (FFI → C++ → zwlr_output_manager_v1)
// On X11/fallback: uses the existing DisplayService (DBus daemon)
// ─────────────────────────────────────────────────────────────────────────────

class DisplaySettingsBloc
    extends Bloc<DisplaySettingsEvent, DisplaySettingsState> {

  // ── Backends ───────────────────────────────────────────────────────────────
  DisplayService?     _dbusService;          // X11 / DBus fallback
  WlrOutputService?   _wlrService;           // Wayland backend

  // ── Subscriptions ──────────────────────────────────────────────────────────
  StreamSubscription? _displayChangedSub;    // DBus change signal
  StreamSubscription? _wlrHeadsSub;          // Wayland heads stream

  // ── Local caches (used by both backends) ──────────────────────────────────
  final Map<String, List<DisplayMode>> _modesCache    = {};
  final Map<String, RotationType>      _rotationCache = {};
  final Map<String, double>            _scaleCache    = {};

  // ── Constructor ───────────────────────────────────────────────────────────

  DisplaySettingsBloc() : super(const DisplaySettingsState()) {
    on<InitializeDisplaySettings>(_onInitialize);
    on<RefreshDisplays>          (_onRefreshDisplays);
    on<SelectDisplay>            (_onSelectDisplay);
    on<SetOrientation>           (_onSetOrientation);
    on<SetResolution>            (_onSetResolution);
    on<SetRefreshRate>           (_onSetRefreshRate);
    on<SetBrightness>            (_onSetBrightness);
    on<SetScale>                 (_onSetScale);
    on<SetFractionalScaling>     (_onSetFractionalScaling);
    on<ToggleDisplayEnabled>     (_onToggleDisplayEnabled);
    on<SetPrimaryDisplay>        (_onSetPrimaryDisplay);
    on<SetMirrorMode>            (_onSetMirrorMode);
    on<SaveDisplayProfile>       (_onSaveDisplayProfile);
    on<LoadDisplayProfile>       (_onLoadDisplayProfile);
    on<DeleteDisplayProfile>     (_onDeleteDisplayProfile);
    on<DisplayChangedExternally> (_onDisplayChangedExternally);

    // ── Wayland-specific ────────────────────────────────────────────────────
    on<WlrHeadsChanged>    (_onWlrHeadsChanged);
    on<SetAdaptiveSync>    (_onSetAdaptiveSync);
    on<TestConfiguration>  (_onTestConfiguration);
    on<SetDisplayPosition> (_onSetDisplayPosition);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize — detect session type and choose backend
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onInitialize(
    InitializeDisplaySettings event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    emit(state.copyWith(status: DisplaySettingsStatus.loading));

    final isWayland = _detectWayland();

    if (isWayland) {
      await _initWaylandBackend(emit);
    } else {
      await _initDbusBackend(emit);
    }
  }

  static bool _detectWayland() {
    final waylandDisplay = Platform.environment['WAYLAND_DISPLAY'];
    if (waylandDisplay != null && waylandDisplay.isNotEmpty) return true;
    final sessionType = Platform.environment['XDG_SESSION_TYPE'];
    return sessionType?.toLowerCase() == 'wayland';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wayland backend initialisation
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initWaylandBackend(
    Emitter<DisplaySettingsState> emit,
  ) async {
    try {
      _wlrService = WlrOutputService();
      final connected = await _wlrService!.connect().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (!connected) {
        debugPrint('[Bloc] WLR service failed — falling back to DBus');
        _wlrService = null;
        await _initDbusBackend(emit);
        return;
      }

      // Listen to head changes
      _wlrHeadsSub = _wlrService!.headsStream.listen((_) {
        add(const WlrHeadsChanged());
      });

      // Build state from initial heads
      final displays = _buildDisplaysFromWlr(_wlrService!.heads);
      emit(state.copyWith(
        status: DisplaySettingsStatus.loaded,
        displayServer: 'Wayland (wlr-output-management v1)',
        isWaylandBackend: true,
        displays: displays,
        displayProfiles: const [],  // profiles not supported via WLR directly
      ));

      _loadBrightnessInBackground(emit);

      if (displays.isNotEmpty) {
        final primary = displays.firstWhere(
          (d) => d.isPrimary,
          orElse: () => displays.first,
        );
        add(SelectDisplay(primary.name));
      }
    } catch (e) {
      debugPrint('[Bloc] Wayland init error: $e');
      _wlrService = null;
      await _initDbusBackend(emit);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DBus / X11 backend initialisation (original logic)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initDbusBackend(
    Emitter<DisplaySettingsState> emit,
  ) async {
    _dbusService = DisplayService();
    final connected = await _dbusService!.connect().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(state.copyWith(
        status: DisplaySettingsStatus.error,
        errorMessage: 'Failed to connect to Display Daemon',
      ));
      return;
    }

    _displayChangedSub?.cancel();
    _displayChangedSub = _dbusService!.displayChangedStream.listen((name) {
      add(DisplayChangedExternally(name));
    });

    try {
      final displays = await _dbusService!.getDisplays();
      final profiles = await _dbusService!.getProfiles();
      final connectedDisplays = displays.where((d) => d.isConnected).toList();

      emit(state.copyWith(
        status: DisplaySettingsStatus.loaded,
        displayServer: 'X11 (Daemon)',
        isWaylandBackend: false,
        displays: connectedDisplays,
        displayProfiles: profiles,
      ));

      if (connectedDisplays.isEmpty) return;

      final primary = connectedDisplays.firstWhere(
        (d) => d.isPrimary,
        orElse: () => connectedDisplays.first,
      );

      add(SelectDisplay(primary.name));
      _loadBrightnessInBackground(emit);
    } catch (e) {
      debugPrint('[Bloc] DBus init error: $e');
      emit(state.copyWith(
        status: DisplaySettingsStatus.error,
        errorMessage: 'Failed to load display settings: $e',
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WLR heads → DisplayInfo conversion
  // ─────────────────────────────────────────────────────────────────────────

  List<DisplayInfo> _buildDisplaysFromWlr(List<WlrHeadInfo> heads) {
    return heads.map((h) {
      return DisplayInfo(
        name:                h.name,
        width:               h.currentMode?.width      ?? 0,
        height:              h.currentMode?.height     ?? 0,
        refreshRate:         h.currentMode?.refreshHz  ?? 0.0,
        isConnected:         true,
        isPrimary:           heads.indexOf(h) == 0,  // first head is primary
        x:                   h.posX,
        y:                   h.posY,
        make:                h.make,
        model:               h.model,
        serialNumber:        h.serialNumber,
        physicalWidthMm:     h.physicalWidthMm,
        physicalHeightMm:    h.physicalHeightMm,
        transform:           h.transform,
        scale:               h.scale,
        adaptiveSyncEnabled: h.adaptiveSyncEnabled,
        isWaylandSource:     true,
      );
    }).toList();
  }

  List<DisplayMode> _buildModesFromWlr(List<WlrModeInfo> wlrModes) {
    return wlrModes
        .map((m) => DisplayMode.fromWlr(
              width:       m.width,
              height:      m.height,
              refreshMhz:  m.refreshMhz,
              preferred:   m.preferred,
            ))
        .toList()
      ..sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Brightness (shared between both backends)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadBrightnessInBackground(
    Emitter<DisplaySettingsState> emit,
  ) async {
    final powerService = PowerService();
    try {
      final connected = await powerService.connect();
      if (connected) {
        final current = await powerService.getBrightness();
        final max     = await powerService.getMaxBrightness();
        await powerService.disconnect();

        if (max > 0) {
          emit(state.copyWith(
            brightness:         (current / max * 100).clamp(0.0, 100.0),
            maxBrightness:      max.toDouble(),
            brightnessSupported: true,
            brightnessMethod:   'venom_power',
          ));
        }
      }
    } catch (e) {
      debugPrint('[Bloc] Brightness init error: $e');
    } finally {
      await powerService.disconnect();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Event handlers — shared
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRefreshDisplays(
    RefreshDisplays event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService != null) {
      final heads = _wlrService!.refreshHeads();
      final displays = _buildDisplaysFromWlr(heads);
      emit(state.copyWith(displays: displays));
    } else if (_dbusService != null) {
      final displays = await _dbusService!.getDisplays();
      final connected = displays.where((d) => d.isConnected).toList();
      emit(state.copyWith(displays: connected));
    }
  }

  Future<void> _onSelectDisplay(
    SelectDisplay event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    emit(state.copyWith(selectedDisplayName: event.displayName));

    if (_wlrService != null) {
      // ── Wayland path ─────────────────────────────────────────────────────
      final head = _wlrService!.getHead(event.displayName);
      if (head == null) return;

      final modes = _buildModesFromWlr(head.modes);

      // Find current mode in list
      DisplayMode? currentMode;
      if (head.currentMode != null) {
        try {
          currentMode = modes.firstWhere((m) =>
              m.width == head.currentMode!.width &&
              m.height == head.currentMode!.height);
        } catch (_) {
          if (modes.isNotEmpty) currentMode = modes.first;
        }
      }

      final refreshRates = modes
          .where((m) =>
              m.width == (currentMode?.width ?? 0) &&
              m.height == (currentMode?.height ?? 0))
          .map((m) => m.rateString)
          .toList();

      emit(state.copyWith(
        currentMode:          currentMode,
        availableModes:       modes,
        refreshRate:          currentMode?.rateString ?? '',
        availableRefreshRates: refreshRates,
        orientation:          WlTransform.fromValue(head.transform).label,
        scale:                (head.scale * 100).round(),
        adaptiveSyncEnabled:  head.adaptiveSyncEnabled,
        displayPositionX:     head.posX,
        displayPositionY:     head.posY,
      ));
    } else if (_dbusService != null) {
      // ── DBus / X11 path ──────────────────────────────────────────────────
      List<DisplayMode> modes;
      RotationType rotation;
      double scale;

      if (_modesCache.containsKey(event.displayName)) {
        modes    = _modesCache[event.displayName]!;
        rotation = _rotationCache[event.displayName]!;
        scale    = _scaleCache[event.displayName]!;
      } else {
        modes    = await _dbusService!.getModes(event.displayName);
        rotation = await _dbusService!.getRotation(event.displayName);
        scale    = await _dbusService!.getScale(event.displayName);

        _modesCache[event.displayName]    = modes;
        _rotationCache[event.displayName] = rotation;
        _scaleCache[event.displayName]    = scale;
      }

      final display = state.displays.firstWhere(
        (d) => d.name == event.displayName,
        orElse: () => state.displays.first,
      );

      DisplayMode? currentMode;
      try {
        currentMode = modes.firstWhere(
          (m) => m.width == display.width && m.height == display.height,
        );
      } catch (_) {
        if (modes.isNotEmpty) currentMode = modes.first;
      }

      final refreshRates = modes
          .where((m) =>
              m.width == display.width && m.height == display.height)
          .map((m) => m.rateString)
          .toList();

      emit(state.copyWith(
        currentMode:           currentMode,
        availableModes:        modes,
        refreshRate:           display.rateString,
        availableRefreshRates: refreshRates,
        orientation:           _rotationToOrientation(rotation),
        scale:                 (scale * 100).round(),
      ));
    }
  }

  Future<void> _onSetOrientation(
    SetOrientation event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null) return;

    emit(state.copyWith(orientation: event.orientation));

    if (_wlrService != null) {
      final transform = _orientationToWlTransform(event.orientation);
      await _wlrService!.setTransform(displayName, transform);
    } else if (_dbusService != null) {
      final rotation = _orientationToRotation(event.orientation);
      final success  = await _dbusService!.setRotation(displayName, rotation);
      if (success) _rotationCache[displayName] = rotation;
    }
  }

  Future<void> _onSetResolution(
    SetResolution event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null) return;

    emit(state.copyWith(currentMode: event.mode));

    final modes = state.availableModes;
    final refreshRates = modes
        .where((m) => m.width == event.mode.width && m.height == event.mode.height)
        .map((m) => m.rateString)
        .toList();

    if (_wlrService != null) {
      await _wlrService!.setMode(
        displayName,
        event.mode.width,
        event.mode.height,
        event.mode.refreshMhz,
      );
    } else if (_dbusService != null) {
      await _dbusService!.setResolution(
        displayName,
        event.mode.width,
        event.mode.height,
      );
    }

    emit(state.copyWith(availableRefreshRates: refreshRates));
  }

  Future<void> _onSetRefreshRate(
    SetRefreshRate event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    final displayName = state.selectedDisplayName;
    if (displayName == null) return;

    emit(state.copyWith(refreshRate: event.refreshRate));
    final rate = double.tryParse(event.refreshRate.replaceAll(' Hz', '')) ?? 60.0;

    if (_wlrService != null && state.currentMode != null) {
      final mhz = (rate * 1000).round();
      await _wlrService!.setMode(
        displayName,
        state.currentMode!.width,
        state.currentMode!.height,
        mhz,
      );
    } else if (_dbusService != null) {
      await _dbusService!.setRefreshRate(displayName, rate);
    }
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
          final abs = (event.brightness / 100.0 * state.maxBrightness).round();
          await powerService.setBrightness(abs);
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
    if (displayName == null) return;

    emit(state.copyWith(scale: event.scale));
    final scale = event.scale / 100.0;

    if (_wlrService != null) {
      await _wlrService!.setScale(displayName, scale);
    } else if (_dbusService != null) {
      final success = await _dbusService!.setScale(displayName, scale);
      if (success) _scaleCache[displayName] = scale;
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
    bool success;
    if (_wlrService != null) {
      final result = await _wlrService!.setEnabled(event.displayName, event.enabled);
      success = result == WlrConfigResult.succeeded;
    } else if (_dbusService != null) {
      success = event.enabled
          ? await _dbusService!.enableOutput(event.displayName)
          : await _dbusService!.disableOutput(event.displayName);
    } else {
      return;
    }
    if (success) add(const RefreshDisplays());
  }

  Future<void> _onSetPrimaryDisplay(
    SetPrimaryDisplay event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_dbusService != null) {
      final success = await _dbusService!.setPrimary(event.displayName);
      if (success) add(const RefreshDisplays());
    }
    // WLR protocol does not have a "set primary" concept; handled by compositor
  }

  Future<void> _onSetMirrorMode(
    SetMirrorMode event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService != null) {
      // On Wayland: mirror = same position for both heads
      if (event.targetDisplay != null) {
        final sourceHead = _wlrService!.getHead(event.sourceDisplay);
        if (sourceHead != null) {
          await _wlrService!.setPosition(
              event.targetDisplay!, sourceHead.posX, sourceHead.posY);
        }
      }
      add(const RefreshDisplays());
    } else if (_dbusService != null) {
      bool success;
      if (event.targetDisplay != null) {
        success = await _dbusService!.setMirror(
            event.sourceDisplay, event.targetDisplay!);
      } else {
        success = await _dbusService!.disableMirror(event.sourceDisplay);
      }
      if (success) add(const RefreshDisplays());
    }
  }

  // ── Profile events (DBus only — WLR doesn't expose profile storage) ────────

  Future<void> _onSaveDisplayProfile(
    SaveDisplayProfile event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_dbusService == null) return;
    final success = await _dbusService!.saveProfile(event.profileName);
    if (success) {
      final profiles = await _dbusService!.getProfiles();
      emit(state.copyWith(displayProfiles: profiles));
    }
  }

  Future<void> _onLoadDisplayProfile(
    LoadDisplayProfile event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_dbusService == null) return;
    final success = await _dbusService!.loadProfile(event.profileName);
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
    if (_dbusService == null) return;
    final success = await _dbusService!.deleteProfile(event.profileName);
    if (success) {
      final profiles = await _dbusService!.getProfiles();
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

  // ─────────────────────────────────────────────────────────────────────────
  // Wayland-specific event handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onWlrHeadsChanged(
    WlrHeadsChanged event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService == null) return;
    final displays = _buildDisplaysFromWlr(_wlrService!.heads);
    emit(state.copyWith(displays: displays));

    // Re-select current display to refresh its properties
    if (state.selectedDisplayName != null) {
      add(SelectDisplay(state.selectedDisplayName!));
    }
  }

  Future<void> _onSetAdaptiveSync(
    SetAdaptiveSync event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService == null) return;

    emit(state.copyWith(adaptiveSyncEnabled: event.enabled));
    await _wlrService!.setAdaptiveSync(event.displayName, event.enabled);
  }

  Future<void> _onTestConfiguration(
    TestConfiguration event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService == null || state.selectedDisplayName == null) return;

    final head = _wlrService!.getHead(state.selectedDisplayName!);
    if (head == null) return;

    final config = WlrHeadConfig(
      headName:       head.name,
      enabled:        head.enabled,
      modeWidth:      state.currentMode?.width      ?? head.currentMode?.width      ?? 0,
      modeHeight:     state.currentMode?.height     ?? head.currentMode?.height     ?? 0,
      modeRefreshMhz: state.currentMode?.refreshMhz ?? head.currentMode?.refreshMhz ?? 0,
      posX:           state.displayPositionX,
      posY:           state.displayPositionY,
      transform:      head.transform,
      scale:          state.scale / 100.0,
      adaptiveSync:   -1,
    );

    final result = await _wlrService!.testConfiguration([config]);
    final testResult = switch (result) {
      WlrConfigResult.succeeded => ConfigTestResult.succeeded,
      WlrConfigResult.cancelled => ConfigTestResult.cancelled,
      _                        => ConfigTestResult.failed,
    };
    emit(state.copyWith(configTestResult: testResult));
  }

  Future<void> _onSetDisplayPosition(
    SetDisplayPosition event,
    Emitter<DisplaySettingsState> emit,
  ) async {
    if (_wlrService == null) return;

    emit(state.copyWith(
      displayPositionX: event.x,
      displayPositionY: event.y,
    ));

    await _wlrService!.setPosition(event.displayName, event.x, event.y);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Orientation helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _rotationToOrientation(RotationType rotation) {
    switch (rotation) {
      case RotationType.left:     return 'Portrait Left';
      case RotationType.right:    return 'Portrait Right';
      case RotationType.inverted: return 'Landscape Inverted';
      default:                    return 'Landscape';
    }
  }

  RotationType _orientationToRotation(String orientation) {
    switch (orientation) {
      case 'Portrait Left':       return RotationType.left;
      case 'Portrait Right':      return RotationType.right;
      case 'Landscape Inverted':  return RotationType.inverted;
      default:                    return RotationType.normal;
    }
  }

  int _orientationToWlTransform(String orientation) {
    switch (orientation) {
      case 'Portrait Left':            return 1;   // WL_OUTPUT_TRANSFORM_90
      case 'Landscape Inverted':       return 2;   // WL_OUTPUT_TRANSFORM_180
      case 'Portrait Right':           return 3;   // WL_OUTPUT_TRANSFORM_270
      case 'Landscape (Flipped)':      return 4;
      case 'Portrait Left (Flipped)':  return 5;
      case 'Landscape Inverted (Flipped)': return 6;
      case 'Portrait Right (Flipped)': return 7;
      default:                         return 0;   // WL_OUTPUT_TRANSFORM_NORMAL
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _displayChangedSub?.cancel();
    _wlrHeadsSub?.cancel();
    _dbusService?.disconnect();
    _wlrService?.disconnect();
    return super.close();
  }
}
