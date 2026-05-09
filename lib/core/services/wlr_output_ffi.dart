import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─────────────────────────────────────────────────────────────────────────────
// C structs (must mirror wlr_ffi_bridge.h exactly)
// ─────────────────────────────────────────────────────────────────────────────

final class WlrModeInfoNative extends Struct {
  @Int32()
  external int width;

  @Int32()
  external int height;

  @Int32()
  external int refreshMhz;

  @Bool()
  external bool preferred;
}

final class WlrHeadInfoNative extends Struct {
  // v1
  external Pointer<Utf8> name;
  external Pointer<Utf8> description;

  @Int32()
  external int physicalWidthMm;

  @Int32()
  external int physicalHeightMm;

  @Bool()
  external bool enabled;

  @Int32()
  external int posX;

  @Int32()
  external int posY;

  @Int32()
  external int transform;

  @Double()
  external double scale;

  // current mode
  @Int32()
  external int currentWidth;

  @Int32()
  external int currentHeight;

  @Int32()
  external int currentRefreshMhz;

  @Bool()
  external bool currentPreferred;

  // modes array
  external Pointer<WlrModeInfoNative> modes;

  @Int32()
  external int modeCount;

  // v2
  external Pointer<Utf8> make;
  external Pointer<Utf8> model;
  external Pointer<Utf8> serialNumber;

  // v4
  @Uint32()
  external int adaptiveSync;
}

final class WlrHeadConfigNative extends Struct {
  external Pointer<Utf8> headName;

  @Bool()
  external bool enabled;

  @Bool()
  external bool useCustomMode;

  @Int32()
  external int modeWidth;

  @Int32()
  external int modeHeight;

  @Int32()
  external int modeRefreshMhz;

  @Int32()
  external int posX;

  @Int32()
  external int posY;

  @Int32()
  external int transform;

  @Double()
  external double scale;

  @Int32()
  external int adaptiveSync;
}

// ─────────────────────────────────────────────────────────────────────────────
// Callback typedefs
// ─────────────────────────────────────────────────────────────────────────────

typedef WlrHeadsChangedFnNative = Void Function(Pointer<Void> userData);
typedef WlrHeadsChangedFnDart   = void Function(Pointer<Void> userData);

typedef WlrConfigResultFnNative = Void Function(Pointer<Void> userData, Int32 result);
typedef WlrConfigResultFnDart   = void Function(Pointer<Void> userData, int result);

// ─────────────────────────────────────────────────────────────────────────────
// Native function signatures
// ─────────────────────────────────────────────────────────────────────────────

// Lifecycle
typedef _WlrManagerCreateNative  = Pointer<Void> Function();
typedef _WlrManagerConnectNative = Bool Function(Pointer<Void> handle);
typedef _WlrManagerDisconnectNative = Void Function(Pointer<Void> handle);
typedef _WlrManagerDestroyNative = Void Function(Pointer<Void> handle);
typedef _WlrManagerDispatchNative = Void Function(Pointer<Void> handle);

// Callbacks
typedef _WlrSetHeadsChangedCbNative = Void Function(
    Pointer<Void> handle,
    Pointer<NativeFunction<WlrHeadsChangedFnNative>> cb,
    Pointer<Void> userData);

// Read
typedef _WlrGetHeadsNative = Pointer<WlrHeadInfoNative> Function(
    Pointer<Void> handle, Pointer<Int32> countOut);
typedef _WlrFreeHeadsNative = Void Function(
    Pointer<WlrHeadInfoNative> heads, Int32 count);

// Write
typedef _WlrApplyConfigNative = Bool Function(
    Pointer<Void> handle,
    Pointer<WlrHeadConfigNative> configs,
    Int32 configCount,
    Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb,
    Pointer<Void> userData);

typedef _WlrTestConfigNative = Bool Function(
    Pointer<Void> handle,
    Pointer<WlrHeadConfigNative> configs,
    Int32 configCount,
    Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb,
    Pointer<Void> userData);

typedef _WlrFreeStringNative = Void Function(Pointer<Utf8> str);

// ─────────────────────────────────────────────────────────────────────────────
// Dart-side typedefs (for lookup)
// ─────────────────────────────────────────────────────────────────────────────

typedef _WlrManagerCreateDart  = Pointer<Void> Function();
typedef _WlrManagerConnectDart = bool Function(Pointer<Void> handle);
typedef _WlrManagerDisconnectDart = void Function(Pointer<Void> handle);
typedef _WlrManagerDestroyDart = void Function(Pointer<Void> handle);
typedef _WlrManagerDispatchDart = void Function(Pointer<Void> handle);

typedef _WlrSetHeadsChangedCbDart = void Function(
    Pointer<Void> handle,
    Pointer<NativeFunction<WlrHeadsChangedFnNative>> cb,
    Pointer<Void> userData);

typedef _WlrGetHeadsDart = Pointer<WlrHeadInfoNative> Function(
    Pointer<Void> handle, Pointer<Int32> countOut);
typedef _WlrFreeHeadsDart = void Function(
    Pointer<WlrHeadInfoNative> heads, int count);

typedef _WlrApplyConfigDart = bool Function(
    Pointer<Void> handle,
    Pointer<WlrHeadConfigNative> configs,
    int configCount,
    Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb,
    Pointer<Void> userData);

typedef _WlrTestConfigDart = bool Function(
    Pointer<Void> handle,
    Pointer<WlrHeadConfigNative> configs,
    int configCount,
    Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb,
    Pointer<Void> userData);

typedef _WlrFreeStringDart = void Function(Pointer<Utf8> str);

// ─────────────────────────────────────────────────────────────────────────────
// Dart data models (mirroring C structs but idiomatic)
// ─────────────────────────────────────────────────────────────────────────────

class WlrModeInfo {
  final int width;
  final int height;
  final int refreshMhz;
  final bool preferred;

  const WlrModeInfo({
    required this.width,
    required this.height,
    required this.refreshMhz,
    required this.preferred,
  });

  /// Refresh rate in Hz as double
  double get refreshHz => refreshMhz / 1000.0;

  /// e.g. "1920x1080"
  String get resolution => '${width}x$height';

  /// e.g. "60.0 Hz"
  String get rateString => '${refreshHz.toStringAsFixed(1)} Hz';

  @override
  String toString() => '$resolution @ $rateString${preferred ? ' (preferred)' : ''}';
}

class WlrHeadInfo {
  final String name;
  final String description;
  final int physicalWidthMm;
  final int physicalHeightMm;
  final bool enabled;
  final int posX;
  final int posY;
  final int transform;        // wl_output_transform (0=normal,1=90,2=180,3=270,4-7=flipped)
  final double scale;
  final WlrModeInfo? currentMode;
  final List<WlrModeInfo> modes;
  // v2
  final String make;
  final String model;
  final String serialNumber;
  // v4
  final int adaptiveSync;     // 0=disabled, 1=enabled

  const WlrHeadInfo({
    required this.name,
    required this.description,
    required this.physicalWidthMm,
    required this.physicalHeightMm,
    required this.enabled,
    required this.posX,
    required this.posY,
    required this.transform,
    required this.scale,
    required this.currentMode,
    required this.modes,
    required this.make,
    required this.model,
    required this.serialNumber,
    required this.adaptiveSync,
  });

  bool get adaptiveSyncEnabled => adaptiveSync == 1;

  String get resolution => currentMode?.resolution ?? '';
  String get rateString  => currentMode?.rateString  ?? '';
}

// Config sent to apply/test
class WlrHeadConfig {
  final String headName;
  final bool enabled;
  final bool useCustomMode;
  final int modeWidth;
  final int modeHeight;
  final int modeRefreshMhz;
  final int posX;
  final int posY;
  final int transform;
  final double scale;
  final int adaptiveSync;   // -1 = don't set

  const WlrHeadConfig({
    required this.headName,
    required this.enabled,
    this.useCustomMode = false,
    this.modeWidth = 0,
    this.modeHeight = 0,
    this.modeRefreshMhz = 0,
    this.posX = 0,
    this.posY = 0,
    this.transform = 0,
    this.scale = 1.0,
    this.adaptiveSync = -1,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FFI Loader
// ─────────────────────────────────────────────────────────────────────────────

class WlrOutputFfi {
  static WlrOutputFfi? _instance;
  static WlrOutputFfi get instance => _instance ??= WlrOutputFfi._load();

  late final DynamicLibrary _lib;

  // Bound functions
  late final _WlrManagerCreateDart  _create;
  late final _WlrManagerConnectDart _connect;
  late final _WlrManagerDisconnectDart _disconnect;
  late final _WlrManagerDestroyDart _destroy;
  late final _WlrManagerDispatchDart _dispatch;
  late final _WlrSetHeadsChangedCbDart _setHeadsChangedCb;
  late final _WlrGetHeadsDart _getHeads;
  late final _WlrFreeHeadsDart _freeHeads;
  late final _WlrApplyConfigDart _applyConfig;
  late final _WlrTestConfigDart  _testConfig;
  late final _WlrFreeStringDart  _freeString;

  WlrOutputFfi._load() {
    // Search in executable directory and standard lib paths
    final candidates = [
      '${File(Platform.resolvedExecutable).parent.path}/lib/libwlr_output.so',
      '${File(Platform.resolvedExecutable).parent.path}/libwlr_output.so',
      'libwlr_output.so',
    ];

    DynamicLibrary? lib;
    for (final path in candidates) {
      try {
        lib = DynamicLibrary.open(path);
        break;
      } catch (_) {}
    }
    if (lib == null) {
      throw UnsupportedError(
          '[WlrOutputFfi] Cannot load libwlr_output.so. '
          'Ensure the library is built and placed in the bundle lib/ directory.');
    }
    _lib = lib;

    _create     = _lib.lookupFunction<_WlrManagerCreateNative,  _WlrManagerCreateDart> ('wlr_manager_create');
    _connect    = _lib.lookupFunction<_WlrManagerConnectNative, _WlrManagerConnectDart>('wlr_manager_connect');
    _disconnect = _lib.lookupFunction<_WlrManagerDisconnectNative, _WlrManagerDisconnectDart>('wlr_manager_disconnect');
    _destroy    = _lib.lookupFunction<_WlrManagerDestroyNative, _WlrManagerDestroyDart>('wlr_manager_destroy');
    _dispatch   = _lib.lookupFunction<_WlrManagerDispatchNative, _WlrManagerDispatchDart>('wlr_manager_dispatch');
    _setHeadsChangedCb = _lib.lookupFunction<_WlrSetHeadsChangedCbNative, _WlrSetHeadsChangedCbDart>('wlr_manager_set_heads_changed_cb');
    _getHeads   = _lib.lookupFunction<_WlrGetHeadsNative, _WlrGetHeadsDart>('wlr_manager_get_heads');
    _freeHeads  = _lib.lookupFunction<_WlrFreeHeadsNative, _WlrFreeHeadsDart>('wlr_free_heads');
    _applyConfig = _lib.lookupFunction<_WlrApplyConfigNative, _WlrApplyConfigDart>('wlr_manager_apply_config');
    _testConfig  = _lib.lookupFunction<_WlrTestConfigNative,  _WlrTestConfigDart> ('wlr_manager_test_config');
    _freeString  = _lib.lookupFunction<_WlrFreeStringNative,  _WlrFreeStringDart> ('wlr_free_string');
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Pointer<Void> createManager() => _create();

  bool connectManager(Pointer<Void> handle) => _connect(handle);

  void disconnectManager(Pointer<Void> handle) => _disconnect(handle);

  void destroyManager(Pointer<Void> handle) => _destroy(handle);

  void dispatch(Pointer<Void> handle) => _dispatch(handle);

  void setHeadsChangedCallback(
      Pointer<Void> handle,
      Pointer<NativeFunction<WlrHeadsChangedFnNative>> cb) {
    _setHeadsChangedCb(handle, cb, nullptr);
  }

  /// Reads all heads from native layer and converts to Dart objects
  List<WlrHeadInfo> getHeads(Pointer<Void> handle) {
    final countPtr = calloc<Int32>();
    try {
      final raw = _getHeads(handle, countPtr);
      final count = countPtr.value;
      if (count == 0 || raw == nullptr) return [];

      final result = <WlrHeadInfo>[];
      for (int i = 0; i < count; i++) {
        final h = raw[i];
        result.add(_convertHead(h));
      }
      _freeHeads(raw, count);
      return result;
    } finally {
      calloc.free(countPtr);
    }
  }

  WlrHeadInfo _convertHead(WlrHeadInfoNative h) {
    // Convert modes
    final modes = <WlrModeInfo>[];
    for (int j = 0; j < h.modeCount; j++) {
      final m = h.modes[j];
      modes.add(WlrModeInfo(
        width: m.width,
        height: m.height,
        refreshMhz: m.refreshMhz,
        preferred: m.preferred,
      ));
    }

    WlrModeInfo? currentMode;
    if (h.currentWidth > 0 && h.currentHeight > 0) {
      currentMode = WlrModeInfo(
        width: h.currentWidth,
        height: h.currentHeight,
        refreshMhz: h.currentRefreshMhz,
        preferred: h.currentPreferred,
      );
    }

    return WlrHeadInfo(
      name:             h.name.toDartString(),
      description:      h.description.toDartString(),
      physicalWidthMm:  h.physicalWidthMm,
      physicalHeightMm: h.physicalHeightMm,
      enabled:          h.enabled,
      posX:             h.posX,
      posY:             h.posY,
      transform:        h.transform,
      scale:            h.scale,
      currentMode:      currentMode,
      modes:            modes,
      make:             h.make.toDartString(),
      model:            h.model.toDartString(),
      serialNumber:     h.serialNumber.toDartString(),
      adaptiveSync:     h.adaptiveSync,
    );
  }

  bool applyConfig(Pointer<Void> handle, List<WlrHeadConfig> configs,
      Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb) {
    return _sendConfig(handle, configs, resultCb, false);
  }

  bool testConfig(Pointer<Void> handle, List<WlrHeadConfig> configs,
      Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb) {
    return _sendConfig(handle, configs, resultCb, true);
  }

  bool _sendConfig(
      Pointer<Void> handle,
      List<WlrHeadConfig> configs,
      Pointer<NativeFunction<WlrConfigResultFnNative>> resultCb,
      bool testOnly) {
    if (configs.isEmpty) return false;

    final nativeConfigs = calloc<WlrHeadConfigNative>(configs.length);
    final namePtrs = <Pointer<Utf8>>[];
    try {
      for (int i = 0; i < configs.length; i++) {
        final c   = configs[i];
        final ptr = c.headName.toNativeUtf8();
        namePtrs.add(ptr);

        nativeConfigs[i].headName       = ptr;
        nativeConfigs[i].enabled        = c.enabled;
        nativeConfigs[i].useCustomMode  = c.useCustomMode;
        nativeConfigs[i].modeWidth      = c.modeWidth;
        nativeConfigs[i].modeHeight     = c.modeHeight;
        nativeConfigs[i].modeRefreshMhz = c.modeRefreshMhz;
        nativeConfigs[i].posX           = c.posX;
        nativeConfigs[i].posY           = c.posY;
        nativeConfigs[i].transform      = c.transform;
        nativeConfigs[i].scale          = c.scale;
        nativeConfigs[i].adaptiveSync   = c.adaptiveSync;
      }

      final fn = testOnly ? _testConfig : _applyConfig;
      return fn(handle, nativeConfigs, configs.length, resultCb, nullptr);
    } finally {
      for (final p in namePtrs) {
        calloc.free(p);
      }
      calloc.free(nativeConfigs);
    }
  }

  /// Free a C string returned by the native library (rarely needed directly)
  void freeString(Pointer<Utf8> str) => _freeString(str);
}
