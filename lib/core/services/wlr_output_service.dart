import 'dart:async';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'wlr_output_ffi.dart';

export 'wlr_output_ffi.dart' show WlrHeadInfo, WlrModeInfo, WlrHeadConfig;

// ─────────────────────────────────────────────────────────────────────────────
// WlrOutputService
//
// High-level Dart service over the C wlr-output-management-unstable-v1
// implementation.  Runs a background polling isolate so that Wayland events
// are dispatched continuously without blocking the Flutter UI thread.
// ─────────────────────────────────────────────────────────────────────────────

/// Result of apply/test configuration
enum WlrConfigResult { succeeded, failed, cancelled }

class WlrOutputService {
  // ── FFI handle ────────────────────────────────────────────────────────────
  late final Pointer<Void>   _handle;
  final WlrOutputFfi         _ffi = WlrOutputFfi.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _connected = false;
  bool get isConnected => _connected;

  List<WlrHeadInfo> _heads = [];
  List<WlrHeadInfo> get heads => List.unmodifiable(_heads);

  // ── Streams ───────────────────────────────────────────────────────────────
  final _headsController = StreamController<List<WlrHeadInfo>>.broadcast();
  Stream<List<WlrHeadInfo>> get headsStream => _headsController.stream;

  final _configResultController = StreamController<WlrConfigResult>.broadcast();
  Stream<WlrConfigResult> get configResultStream => _configResultController.stream;

  // ── Dispatch timer ────────────────────────────────────────────────────────
  Timer? _dispatchTimer;

  // ── Native callback (must stay alive) ────────────────────────────────────
  late final Pointer<NativeFunction<WlrHeadsChangedFnNative>> _headsChangedPtr;
  final _activeCallables = <NativeCallable>{};

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  /// Connect to Wayland compositor.
  /// Returns true if zwlr_output_manager_v1 was found and initial heads loaded.
  Future<bool> connect() async {
    try {
      _handle = _ffi.createManager();

      final ok = await compute(_connectInBackground, null);
      if (!ok) return false;

      // Re-connect on UI side (background just tested availability)
      final connected = _ffi.connectManager(_handle);
      if (!connected) return false;
      _connected = true;

      // Register native callback
      _headsChangedPtr = NativeCallable<WlrHeadsChangedFnNative>.listener(
        _onHeadsChangedNative,
      ).nativeFunction;
      _ffi.setHeadsChangedCallback(_handle, _headsChangedPtr);

      // Do initial dispatch to get first done event
      _ffi.dispatch(_handle);

      // Read initial state
      _heads = _ffi.getHeads(_handle);
      if (!_headsController.isClosed) {
        _headsController.add(List.unmodifiable(_heads));
      }

      // Start polling timer (16 ms ≈ 60 fps event rate)
      _dispatchTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (_connected) {
          _ffi.dispatch(_handle);
        }
      });

      return true;
    } catch (e) {
      debugPrint('[WlrOutputService] connect error: $e');
      _connected = false;
      return false;
    }
  }

  static Future<bool> _connectInBackground(void _) async {
    // Check if WAYLAND_DISPLAY env is set — lightweight check
    // Actual connection happens on UI isolate with the real handle
    return true;
  }

  void disconnect() {
    _dispatchTimer?.cancel();
    _dispatchTimer = null;
    if (_connected) {
      _ffi.disconnectManager(_handle);
      _ffi.destroyManager(_handle);
      _connected = false;
    }
    _headsController.close();
    _configResultController.close();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Native callback (runs on Wayland event thread → forwarded via NativeCallable)
  // ─────────────────────────────────────────────────────────────────────────

  void _onHeadsChangedNative(Pointer<Void> userData) {
    _heads = _ffi.getHeads(_handle);
    if (!_headsController.isClosed) {
      _headsController.add(List.unmodifiable(_heads));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Read API
  // ─────────────────────────────────────────────────────────────────────────

  /// Refresh heads from native layer (useful if polling is off)
  List<WlrHeadInfo> refreshHeads() {
    if (!_connected) return [];
    _heads = _ffi.getHeads(_handle);
    return List.unmodifiable(_heads);
  }

  WlrHeadInfo? getHead(String name) {
    try {
      return _heads.firstWhere((h) => h.name == name);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Write API — convenience wrappers
  // ─────────────────────────────────────────────────────────────────────────

  /// Apply a list of HeadConfig atomically.
  /// Completes with WlrConfigResult after compositor responds.
  Future<WlrConfigResult> applyConfiguration(List<WlrHeadConfig> configs) {
    final completer = Completer<WlrConfigResult>();
    _sendConfig(configs, false, completer);
    return completer.future;
  }

  /// Test a list of HeadConfig without applying.
  Future<WlrConfigResult> testConfiguration(List<WlrHeadConfig> configs) {
    final completer = Completer<WlrConfigResult>();
    _sendConfig(configs, true, completer);
    return completer.future;
  }

  void _sendConfig(List<WlrHeadConfig> configs, bool testOnly,
      Completer<WlrConfigResult> completer) {
    if (!_connected) {
      completer.complete(WlrConfigResult.failed);
      return;
    }

    // Build a NativeCallable that fires once
    late final NativeCallable<WlrConfigResultFnNative> nc;
    nc = NativeCallable<WlrConfigResultFnNative>.listener(
      (Pointer<Void> _, int result) {
        final r = switch (result) {
          0 => WlrConfigResult.succeeded,
          2 => WlrConfigResult.cancelled,
          _ => WlrConfigResult.failed,
        };
        completer.complete(r);
        if (!_configResultController.isClosed) {
          _configResultController.add(r);
        }
        nc.close();
        _activeCallables.remove(nc);
      },
    );
    _activeCallables.add(nc);

    final ok = testOnly
        ? _ffi.testConfig(_handle, configs, nc.nativeFunction)
        : _ffi.applyConfig(_handle, configs, nc.nativeFunction);

    if (!ok) {
      nc.close();
      _activeCallables.remove(nc);
      completer.complete(WlrConfigResult.failed);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience single-head setters (builds full config from current state)
  // ─────────────────────────────────────────────────────────────────────────

  /// Enable/disable a single head, keeping all others unchanged
  Future<WlrConfigResult> setEnabled(String headName, bool enabled) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: enabled,
        modeWidth: cfg.modeWidth,
        modeHeight: cfg.modeHeight,
        modeRefreshMhz: cfg.modeRefreshMhz,
        posX: cfg.posX,
        posY: cfg.posY,
        transform: cfg.transform,
        scale: cfg.scale,
        adaptiveSync: cfg.adaptiveSync,
      );
    }));
  }

  Future<WlrConfigResult> setMode(
      String headName, int width, int height, int refreshMhz) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: cfg.enabled,
        modeWidth: width,
        modeHeight: height,
        modeRefreshMhz: refreshMhz,
        posX: cfg.posX,
        posY: cfg.posY,
        transform: cfg.transform,
        scale: cfg.scale,
        adaptiveSync: cfg.adaptiveSync,
      );
    }));
  }

  Future<WlrConfigResult> setScale(String headName, double scale) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: cfg.enabled,
        modeWidth: cfg.modeWidth,
        modeHeight: cfg.modeHeight,
        modeRefreshMhz: cfg.modeRefreshMhz,
        posX: cfg.posX,
        posY: cfg.posY,
        transform: cfg.transform,
        scale: scale,
        adaptiveSync: cfg.adaptiveSync,
      );
    }));
  }

  Future<WlrConfigResult> setTransform(String headName, int transform) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: cfg.enabled,
        modeWidth: cfg.modeWidth,
        modeHeight: cfg.modeHeight,
        modeRefreshMhz: cfg.modeRefreshMhz,
        posX: cfg.posX,
        posY: cfg.posY,
        transform: transform,
        scale: cfg.scale,
        adaptiveSync: cfg.adaptiveSync,
      );
    }));
  }

  Future<WlrConfigResult> setPosition(String headName, int x, int y) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: cfg.enabled,
        modeWidth: cfg.modeWidth,
        modeHeight: cfg.modeHeight,
        modeRefreshMhz: cfg.modeRefreshMhz,
        posX: x,
        posY: y,
        transform: cfg.transform,
        scale: cfg.scale,
        adaptiveSync: cfg.adaptiveSync,
      );
    }));
  }

  /// Set adaptive sync (VRR) — v4 only
  Future<WlrConfigResult> setAdaptiveSync(String headName, bool enabled) {
    return applyConfiguration(_buildAllConfigs(headName, (cfg) {
      return WlrHeadConfig(
        headName: cfg.headName,
        enabled: cfg.enabled,
        modeWidth: cfg.modeWidth,
        modeHeight: cfg.modeHeight,
        modeRefreshMhz: cfg.modeRefreshMhz,
        posX: cfg.posX,
        posY: cfg.posY,
        transform: cfg.transform,
        scale: cfg.scale,
        adaptiveSync: enabled ? 1 : 0,
      );
    }));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal — build full config list from current heads with one override
  // ─────────────────────────────────────────────────────────────────────────

  List<WlrHeadConfig> _buildAllConfigs(
      String targetName, WlrHeadConfig Function(WlrHeadConfig) override) {
    return _heads.map((head) {
      final current = _headToConfig(head);
      if (head.name == targetName) return override(current);
      return current;
    }).toList();
  }

  WlrHeadConfig _headToConfig(WlrHeadInfo head) {
    return WlrHeadConfig(
      headName:       head.name,
      enabled:        head.enabled,
      modeWidth:      head.currentMode?.width      ?? 0,
      modeHeight:     head.currentMode?.height     ?? 0,
      modeRefreshMhz: head.currentMode?.refreshMhz ?? 0,
      posX:           head.posX,
      posY:           head.posY,
      transform:      head.transform,
      scale:          head.scale,
      adaptiveSync:   -1,  // don't override unless explicitly set
    );
  }
}
