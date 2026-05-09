import 'package:dbus/dbus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// wl_output_transform enum (matches Wayland protocol values)
// ─────────────────────────────────────────────────────────────────────────────
enum WlTransform {
  normal(0),
  rotated90(1),
  rotated180(2),
  rotated270(3),
  flipped(4),
  flipped90(5),
  flipped180(6),
  flipped270(7);

  const WlTransform(this.value);
  final int value;

  static WlTransform fromValue(int v) =>
      WlTransform.values.firstWhere((e) => e.value == v,
          orElse: () => WlTransform.normal);

  String get label => switch (this) {
    WlTransform.normal     => 'Landscape',
    WlTransform.rotated90  => 'Portrait Left',
    WlTransform.rotated180 => 'Landscape Inverted',
    WlTransform.rotated270 => 'Portrait Right',
    WlTransform.flipped    => 'Landscape (Flipped)',
    WlTransform.flipped90  => 'Portrait Left (Flipped)',
    WlTransform.flipped180 => 'Landscape Inverted (Flipped)',
    WlTransform.flipped270 => 'Portrait Right (Flipped)',
  };
}

/// نموذج معلومات الشاشة
class DisplayInfo {
  final String name;
  final int width;
  final int height;
  final double refreshRate;
  final bool isConnected;
  final bool isPrimary;
  final int x;
  final int y;

  // Extended Wayland fields
  final String make;
  final String model;
  final String serialNumber;
  final int physicalWidthMm;
  final int physicalHeightMm;
  final int transform;           // WlTransform.value
  final double scale;
  final bool adaptiveSyncEnabled;
  final bool isWaylandSource;    // true if populated from WLR protocol

  DisplayInfo({
    required this.name,
    required this.width,
    required this.height,
    required this.refreshRate,
    required this.isConnected,
    required this.isPrimary,
    required this.x,
    required this.y,
    // Wayland extras (optional — DBus fallback keeps defaults)
    this.make = '',
    this.model = '',
    this.serialNumber = '',
    this.physicalWidthMm = 0,
    this.physicalHeightMm = 0,
    this.transform = 0,
    this.scale = 1.0,
    this.adaptiveSyncEnabled = false,
    this.isWaylandSource = false,
  });

  factory DisplayInfo.fromDBus(DBusStruct struct) {
    final values = struct.children.toList();
    return DisplayInfo(
      name: (values[0] as DBusString).value,
      width: (values[1] as DBusInt32).value,
      height: (values[2] as DBusInt32).value,
      refreshRate: (values[3] as DBusDouble).value,
      isConnected: (values[4] as DBusBoolean).value,
      isPrimary: (values[5] as DBusBoolean).value,
      x: (values[6] as DBusInt32).value,
      y: (values[7] as DBusInt32).value,
    );
  }

  String get resolution => '${width}x$height';
  String get rateString => '${refreshRate.toStringAsFixed(1)} Hz';
  WlTransform get wlTransform => WlTransform.fromValue(transform);
  String get orientationLabel => wlTransform.label;
}

/// نموذج وضع العرض
class DisplayMode {
  final int width;
  final int height;
  final double refreshRate;
  final bool preferred;
  final int refreshMhz; // millihertz (from Wayland)

  DisplayMode({
    required this.width,
    required this.height,
    required this.refreshRate,
    this.preferred = false,
    int? refreshMhz,
  }) : refreshMhz = refreshMhz ?? (refreshRate * 1000).round();

  factory DisplayMode.fromDBus(DBusStruct struct) {
    final values = struct.children.toList();
    return DisplayMode(
      width: (values[0] as DBusInt32).value,
      height: (values[1] as DBusInt32).value,
      refreshRate: (values[2] as DBusDouble).value,
    );
  }

  /// Build from Wayland millihertz value
  factory DisplayMode.fromWlr({
    required int width,
    required int height,
    required int refreshMhz,
    bool preferred = false,
  }) {
    return DisplayMode(
      width: width,
      height: height,
      refreshRate: refreshMhz / 1000.0,
      preferred: preferred,
      refreshMhz: refreshMhz,
    );
  }

  String get resolution => '${width}x$height';
  String get rateString => '${refreshRate.toStringAsFixed(1)} Hz';
  @override
  String toString() => '$resolution @ $rateString';
}

/// نوع التدوير
enum RotationType { normal, left, inverted, right }

extension RotationTypeExtension on RotationType {
  int get degrees => [0, 90, 180, 270][index];
  static RotationType fromDegrees(int deg) {
    switch (deg) {
      case 90:
        return RotationType.left;
      case 180:
        return RotationType.inverted;
      case 270:
        return RotationType.right;
      default:
        return RotationType.normal;
    }
  }
}

/// إعدادات Night Light
class NightLightSettings {
  final bool enabled;
  final int temperature;

  NightLightSettings({required this.enabled, required this.temperature});

  factory NightLightSettings.fromDBus(DBusStruct struct) {
    final values = struct.children.toList();
    return NightLightSettings(
      enabled: (values[0] as DBusBoolean).value,
      temperature: (values[1] as DBusInt32).value,
    );
  }
}

/// خدمة الاتصال بـ Venom Display Daemon
class DisplayService {
  static const String serviceName = 'org.venom.Display';
  static const String objectPath = '/org/venom/Display';
  static const String interfaceName = 'org.venom.Display';

  late DBusClient _client;
  late DBusRemoteObject _object;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// الاتصال بالعفريت
  Future<bool> connect() async {
    try {
      _client = DBusClient.session();
      _object = DBusRemoteObject(
        _client,
        name: serviceName,
        path: DBusObjectPath(objectPath),
      );
      _isConnected = true;
      return true;
    } catch (e) {
      print('Error connecting: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_isConnected) {
      await _client.close();
      _isConnected = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🖥️ معلومات الشاشات
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<DisplayInfo>> getDisplays() async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetDisplays', []);
      final array = result.values.first as DBusArray;
      return array.children
          .map((v) => DisplayInfo.fromDBus(v as DBusStruct))
          .toList();
    } catch (e) {
      print('GetDisplays error: $e');
      return [];
    }
  }

  Future<DisplayInfo?> getPrimaryDisplay() async {
    try {
      final result = await _object.callMethod(
        interfaceName,
        'GetPrimaryDisplay',
        [],
      );
      return DisplayInfo.fromDBus(result.values.first as DBusStruct);
    } catch (e) {
      print('GetPrimaryDisplay error: $e');
      return null;
    }
  }

  Future<DisplayInfo?> getDisplayInfo(String name) async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetDisplayInfo', [
        DBusString(name),
      ]);
      return DisplayInfo.fromDBus(result.values.first as DBusStruct);
    } catch (e) {
      print('GetDisplayInfo error: $e');
      return null;
    }
  }

  Future<List<DisplayMode>> getModes(String name) async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetModes', [
        DBusString(name),
      ]);
      final array = result.values.first as DBusArray;
      return array.children
          .map((v) => DisplayMode.fromDBus(v as DBusStruct))
          .toList();
    } catch (e) {
      print('GetModes error: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚙️ إعدادات أساسية
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> setResolution(String name, int width, int height) => _callBool(
    'SetResolution',
    [DBusString(name), DBusInt32(width), DBusInt32(height)],
  );

  Future<bool> setRefreshRate(String name, double rate) =>
      _callBool('SetRefreshRate', [DBusString(name), DBusDouble(rate)]);

  Future<bool> setMode(String name, int width, int height, double rate) =>
      _callBool('SetMode', [
        DBusString(name),
        DBusInt32(width),
        DBusInt32(height),
        DBusDouble(rate),
      ]);

  Future<bool> setPosition(String name, int x, int y) =>
      _callBool('SetPosition', [DBusString(name), DBusInt32(x), DBusInt32(y)]);

  Future<bool> setPrimary(String name) =>
      _callBool('SetPrimary', [DBusString(name)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 التدوير
  // ═══════════════════════════════════════════════════════════════════════════

  Future<RotationType> getRotation(String name) async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetRotation', [
        DBusString(name),
      ]);
      return RotationTypeExtension.fromDegrees(
        (result.values.first as DBusInt32).value,
      );
    } catch (e) {
      print('GetRotation error: $e');
      return RotationType.normal;
    }
  }

  Future<bool> setRotation(String name, RotationType rotation) =>
      _callBool('SetRotation', [DBusString(name), DBusInt32(rotation.degrees)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔌 تشغيل/إيقاف
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> enableOutput(String name) =>
      _callBool('EnableOutput', [DBusString(name)]);

  Future<bool> disableOutput(String name) =>
      _callBool('DisableOutput', [DBusString(name)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🪞 المطابقة
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> setMirror(String source, String target) =>
      _callBool('SetMirror', [DBusString(source), DBusString(target)]);

  Future<bool> disableMirror(String name) =>
      _callBool('DisableMirror', [DBusString(name)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 التكبير
  // ═══════════════════════════════════════════════════════════════════════════

  Future<double> getScale(String name) async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetScale', [
        DBusString(name),
      ]);
      return (result.values.first as DBusDouble).value;
    } catch (e) {
      print('GetScale error: $e');
      return 1.0;
    }
  }

  Future<bool> setScale(String name, double scale) =>
      _callBool('SetScale', [DBusString(name), DBusDouble(scale)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌙 Night Light
  // ═══════════════════════════════════════════════════════════════════════════

  Future<NightLightSettings> getNightLight() async {
    try {
      final result = await _object.callMethod(
        interfaceName,
        'GetNightLight',
        [],
      );
      return NightLightSettings.fromDBus(result.values.first as DBusStruct);
    } catch (e) {
      print('GetNightLight error: $e');
      return NightLightSettings(enabled: false, temperature: 6500);
    }
  }

  Future<bool> setNightLight(bool enabled, int temperature) => _callBool(
    'SetNightLight',
    [DBusBoolean(enabled), DBusInt32(temperature)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 البروفايلات
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> saveProfile(String name) =>
      _callBool('SaveProfile', [DBusString(name)]);

  Future<bool> loadProfile(String name) =>
      _callBool('LoadProfile', [DBusString(name)]);

  Future<List<String>> getProfiles() async {
    try {
      final result = await _object.callMethod(interfaceName, 'GetProfiles', []);
      final array = result.values.first as DBusArray;
      return array.children.map((v) => (v as DBusString).value).toList();
    } catch (e) {
      print('GetProfiles error: $e');
      return [];
    }
  }

  Future<bool> deleteProfile(String name) =>
      _callBool('DeleteProfile', [DBusString(name)]);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📢 الإشارات
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<String> get displayChangedStream => DBusSignalStream(
    _client,
    sender: serviceName,
    interface: interfaceName,
    name: 'DisplayChanged',
    path: DBusObjectPath(objectPath),
  ).map((s) => s.values.first.asString());

  Stream<NightLightSettings> get nightLightChangedStream =>
      DBusSignalStream(
        _client,
        sender: serviceName,
        interface: interfaceName,
        name: 'NightLightChanged',
        path: DBusObjectPath(objectPath),
      ).map(
        (s) => NightLightSettings(
          enabled: (s.values[0] as DBusBoolean).value,
          temperature: (s.values[1] as DBusInt32).value,
        ),
      );

  // Helper
  Future<bool> _callBool(String method, List<DBusValue> args) async {
    try {
      final result = await _object.callMethod(interfaceName, method, args);
      return result.values.first.asBoolean();
    } catch (e) {
      print('$method error: $e');
      return false;
    }
  }
}
