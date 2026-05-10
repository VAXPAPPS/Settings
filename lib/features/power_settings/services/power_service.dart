import 'dart:async';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// خدمة الطاقة الرسمية — تتصل بـ:
//   • UPower          (org.freedesktop.UPower)          ← البطارية
//   • power-profiles  (net.hadess.PowerProfiles)         ← بروفايلات الأداء
//   • logind          (org.freedesktop.login1)           ← أوامر الطاقة
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════ ثوابت D-Bus ═══════════════════════════════════

// UPower
const String _kUpowerService = 'org.freedesktop.UPower';
const String _kUpowerRootPath = '/org/freedesktop/UPower';
const String _kUpowerInterface = 'org.freedesktop.UPower';
const String _kUpowerDisplayPath =
    '/org/freedesktop/UPower/devices/DisplayDevice';
const String _kUpowerDeviceInterface = 'org.freedesktop.UPower.Device';

// power-profiles-daemon
const String _kPpService = 'net.hadess.PowerProfiles';
const String _kPpPath = '/net/hadess/PowerProfiles';
const String _kPpInterface = 'net.hadess.PowerProfiles';

// logind
const String _kLogindService = 'org.freedesktop.login1';
const String _kLogindPath = '/org/freedesktop/login1';
const String _kLogindManagerIface = 'org.freedesktop.login1.Manager';
const String _kLogindSessionIface = 'org.freedesktop.login1.Session';

// D-Bus Properties
const String _kPropertiesIface = 'org.freedesktop.DBus.Properties';

// ═══════════════════════════════════════════════════════════════════════════════

/// حالة UPower — قيم خاصية State
enum _UPowerState {
  unknown(0),
  charging(1),
  discharging(2),
  empty(3),
  fullyCharged(4),
  pendingCharge(5),
  pendingDischarge(6);

  final int value;
  const _UPowerState(this.value);

  static _UPowerState fromInt(int v) => _UPowerState.values.firstWhere(
        (e) => e.value == v,
        orElse: () => _UPowerState.unknown,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════

class PowerService {
  late DBusClient _bus;
  bool _isConnected = false;

  // كائنات D-Bus الرئيسية
  late DBusRemoteObject _displayDevice; // UPower DisplayDevice
  DBusRemoteObject? _ppObj;             // power-profiles-daemon (اختياري)
  late DBusRemoteObject _logindMgr;     // logind Manager
  DBusRemoteObject? _logindSession;     // logind Session الحالية

  bool get isConnected => _isConnected;
  bool get isProfilesAvailable => _ppObj != null;

  // ─────────────────────────────────────────────────────────────────────────
  // الاتصال
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> connect() async {
    try {
      _bus = DBusClient.system();

      // UPower — DisplayDevice
      _displayDevice = DBusRemoteObject(
        _bus,
        name: _kUpowerService,
        path: DBusObjectPath(_kUpowerDisplayPath),
      );

      // power-profiles-daemon (اختياري)
      await _tryConnectPowerProfiles();

      // logind — Manager
      _logindMgr = DBusRemoteObject(
        _bus,
        name: _kLogindService,
        path: DBusObjectPath(_kLogindPath),
      );

      // logind — Session الحالية
      await _resolveLogindSession();

      _isConnected = true;
      return true;
    } catch (e) {
      debugPrint('[PowerService] connect error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// محاولة الاتصال بـ power-profiles-daemon — تتجاهل الخطأ إن لم يكن موجوداً.
  Future<void> _tryConnectPowerProfiles() async {
    try {
      final obj = DBusRemoteObject(
        _bus,
        name: _kPpService,
        path: DBusObjectPath(_kPpPath),
      );
      // نتحقق بقراءة الخاصية لمعرفة إن كان الـ daemon متاحاً
      await obj.callMethod(
        _kPropertiesIface,
        'Get',
        [DBusString(_kPpInterface), DBusString('ActiveProfile')],
        replySignature: DBusSignature('v'),
      );
      _ppObj = obj;
      debugPrint('[PowerService] power-profiles-daemon متاح');
    } catch (e) {
      _ppObj = null;
      debugPrint('[PowerService] power-profiles-daemon غير متاح: $e');
    }
  }

  /// الحصول على مسار الجلسة الحالية من logind.
  Future<void> _resolveLogindSession() async {
    try {
      String? sessionPath;

      // أولاً: استخدام XDG_SESSION_ID
      final sessionId = Platform.environment['XDG_SESSION_ID'];
      if (sessionId != null && sessionId.isNotEmpty) {
        try {
          final result = await _logindMgr.callMethod(
            _kLogindManagerIface,
            'GetSession',
            [DBusString(sessionId)],
            replySignature: DBusSignature('o'),
          );
          sessionPath = (result.values.first as DBusObjectPath).value;
        } catch (_) {}
      }

      // fallback: GetSessionByPID
      if (sessionPath == null) {
        try {
          final result = await _logindMgr.callMethod(
            _kLogindManagerIface,
            'GetSessionByPID',
            [DBusUint32(pid)],
            replySignature: DBusSignature('o'),
          );
          sessionPath = (result.values.first as DBusObjectPath).value;
        } catch (e) {
          debugPrint('[PowerService] GetSessionByPID error: $e');
        }
      }

      if (sessionPath != null) {
        _logindSession = DBusRemoteObject(
          _bus,
          name: _kLogindService,
          path: DBusObjectPath(sessionPath),
        );
        debugPrint('[PowerService] logind session: $sessionPath');
      }
    } catch (e) {
      debugPrint('[PowerService] _resolveLogindSession error: $e');
    }
  }

  Future<void> disconnect() async {
    if (_isConnected) {
      await _bus.close();
      _isConnected = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔋 البطارية — UPower DisplayDevice
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final result = await _displayDevice.callMethod(
        _kPropertiesIface,
        'GetAll',
        [DBusString(_kUpowerDeviceInterface)],
        replySignature: DBusSignature('a{sv}'),
      );

      final props = _parseProperties(result.values.first);
      final percentage = (props['Percentage'] as DBusDouble?)?.value ?? 0.0;
      final stateInt = (props['State'] as DBusUint32?)?.value.toInt() ?? 0;
      final state = _UPowerState.fromInt(stateInt);
      final isCharging = state == _UPowerState.charging ||
          state == _UPowerState.fullyCharged ||
          state == _UPowerState.pendingCharge;
      final timeToEmpty = (props['TimeToEmpty'] as DBusInt64?)?.value ?? 0;
      final timeToFull = (props['TimeToFull'] as DBusInt64?)?.value ?? 0;

      return {
        'percentage': percentage,
        'charging': isCharging,
        'timeToEmpty': timeToEmpty,
        'timeToFull': timeToFull,
        'state': stateInt,
      };
    } catch (e) {
      debugPrint('[PowerService] getBatteryInfo error: $e');
      return {
        'percentage': 0.0,
        'charging': false,
        'timeToEmpty': 0,
        'timeToFull': 0,
        'state': 0,
      };
    }
  }

  Future<bool> isOnBattery() async {
    try {
      final result = await _displayDevice.callMethod(
        _kPropertiesIface,
        'Get',
        [DBusString(_kUpowerDeviceInterface), DBusString('State')],
        replySignature: DBusSignature('v'),
      );
      final stateInt =
          ((result.values.first as DBusVariant).value as DBusUint32)
              .value
              .toInt();
      return _UPowerState.fromInt(stateInt) == _UPowerState.discharging;
    } catch (e) {
      debugPrint('[PowerService] isOnBattery error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ⚡ بروفايلات الأداء — power-profiles-daemon
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> getActiveProfile() async {
    if (_ppObj == null) return 'balanced';
    try {
      final result = await _ppObj!.callMethod(
        _kPropertiesIface,
        'Get',
        [DBusString(_kPpInterface), DBusString('ActiveProfile')],
        replySignature: DBusSignature('v'),
      );
      return ((result.values.first as DBusVariant).value as DBusString).value;
    } catch (e) {
      debugPrint('[PowerService] getActiveProfile error: $e');
      return 'balanced';
    }
  }

  Future<bool> setActiveProfile(String profile) async {
    if (_ppObj == null) return false;
    try {
      await _ppObj!.callMethod(
        _kPropertiesIface,
        'Set',
        [
          DBusString(_kPpInterface),
          DBusString('ActiveProfile'),
          DBusVariant(DBusString(profile)),
        ],
        replySignature: DBusSignature(''),
      );
      return true;
    } catch (e) {
      debugPrint('[PowerService] setActiveProfile error: $e');
      return false;
    }
  }

  Future<List<String>> getProfiles() async {
    if (_ppObj == null) return ['power-saver', 'balanced', 'performance'];
    try {
      final result = await _ppObj!.callMethod(
        _kPropertiesIface,
        'Get',
        [DBusString(_kPpInterface), DBusString('Profiles')],
        replySignature: DBusSignature('v'),
      );
      final array =
          (result.values.first as DBusVariant).value as DBusArray;
      return array.children
          .map((v) =>
              ((v as DBusStruct).children.first as DBusString).value)
          .toList();
    } catch (e) {
      debugPrint('[PowerService] getProfiles error: $e');
      return ['power-saver', 'balanced', 'performance'];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ⚡ أوامر الطاقة — logind
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> shutdown() => _callLogindPower('PowerOff');
  Future<bool> reboot() => _callLogindPower('Reboot');
  Future<bool> suspend() => _callLogindPower('Suspend');
  Future<bool> hibernate() => _callLogindPower('Hibernate');

  Future<bool> _callLogindPower(String method) async {
    try {
      await _logindMgr.callMethod(
        _kLogindManagerIface,
        method,
        [DBusBoolean(false)], // interactive = false
        replySignature: DBusSignature(''),
      );
      return true;
    } catch (e) {
      debugPrint('[PowerService] $method error: $e');
      return false;
    }
  }

  /// قفل الشاشة عبر logind Session.Lock()
  Future<bool> lockScreen() async {
    if (_logindSession == null) return false;
    try {
      await _logindSession!.callMethod(
        _kLogindSessionIface,
        'Lock',
        [],
        replySignature: DBusSignature(''),
      );
      return true;
    } catch (e) {
      debugPrint('[PowerService] lockScreen error: $e');
      return false;
    }
  }

  /// تسجيل الخروج — logind Session.Terminate() مع fallback للمجمّع
  Future<bool> logout() async {
    // أولاً: logind
    if (_logindSession != null) {
      try {
        await _logindSession!.callMethod(
          _kLogindSessionIface,
          'Terminate',
          [],
          replySignature: DBusSignature(''),
        );
        return true;
      } catch (e) {
        debugPrint('[PowerService] logout via logind failed: $e');
      }
    }

    // fallback: Hyprland
    final hyprSig =
        Platform.environment['HYPRLAND_INSTANCE_SIGNATURE'];
    if (hyprSig != null && hyprSig.isNotEmpty) {
      try {
        final r = await Process.run('hyprctl', ['dispatch', 'exit', '']);
        if (r.exitCode == 0) return true;
      } catch (_) {}
    }

    // fallback: Sway
    final swaySock = Platform.environment['SWAYSOCK'];
    if (swaySock != null && swaySock.isNotEmpty) {
      try {
        final r = await Process.run('swaymsg', ['exit']);
        if (r.exitCode == 0) return true;
      } catch (_) {}
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📡 الاشتراك في الإشارات
  // ─────────────────────────────────────────────────────────────────────────

  /// يراقب تغييرات البطارية عبر PropertiesChanged و DeviceChanged.
  Stream<Map<String, dynamic>> get batteryChangedStream {
    final ctrl =
        StreamController<Map<String, dynamic>>.broadcast();

    // PropertiesChanged على DisplayDevice
    DBusSignalStream(
      _bus,
      sender: _kUpowerService,
      interface: _kPropertiesIface,
      name: 'PropertiesChanged',
      path: DBusObjectPath(_kUpowerDisplayPath),
    ).listen((signal) async {
      if (signal.values.isNotEmpty) {
        final iface = (signal.values[0] as DBusString).value;
        if (iface == _kUpowerDeviceInterface) {
          ctrl.add(await getBatteryInfo());
        }
      }
    });

    // DeviceChanged على UPower root
    DBusSignalStream(
      _bus,
      sender: _kUpowerService,
      interface: _kUpowerInterface,
      name: 'DeviceChanged',
      path: DBusObjectPath(_kUpowerRootPath),
    ).listen((_) async {
      ctrl.add(await getBatteryInfo());
    });

    return ctrl.stream;
  }

  /// يراقب تغييرات بروفايل الأداء.
  Stream<String> get profileChangedStream {
    if (_ppObj == null) return const Stream.empty();

    return DBusSignalStream(
      _bus,
      sender: _kPpService,
      interface: _kPropertiesIface,
      name: 'PropertiesChanged',
      path: DBusObjectPath(_kPpPath),
    ).where((signal) {
      if (signal.values.length < 2) return false;
      final iface = (signal.values[0] as DBusString).value;
      if (iface != _kPpInterface) return false;
      final changed = signal.values[1] as DBusDict;
      return changed.children.keys.any(
        (k) => (k as DBusString).value == 'ActiveProfile',
      );
    }).asyncMap((_) => getActiveProfile());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 💡 سطوع الشاشة — عبر brightnessctl (أو /sys/class/backlight كـ fallback)
  // ─────────────────────────────────────────────────────────────────────────

  /// يُعيد السطوع الحالي (قيمة مطلقة) أو -1 عند الخطأ.
  Future<int> getBrightness() async {
    try {
      final result =
          await Process.run('brightnessctl', ['get'], runInShell: false);
      if (result.exitCode == 0) {
        return int.tryParse((result.stdout as String).trim()) ?? -1;
      }
    } catch (_) {}
    // fallback: قراءة من /sys/class/backlight
    return _readSysBacklight('brightness');
  }

  /// يُعيد الحد الأقصى للسطوع أو -1 عند الخطأ.
  Future<int> getMaxBrightness() async {
    try {
      final result =
          await Process.run('brightnessctl', ['max'], runInShell: false);
      if (result.exitCode == 0) {
        return int.tryParse((result.stdout as String).trim()) ?? -1;
      }
    } catch (_) {}
    return _readSysBacklight('max_brightness');
  }

  /// يضبط السطوع إلى قيمة مطلقة.
  Future<bool> setBrightness(int level) async {
    try {
      final result = await Process.run(
        'brightnessctl',
        ['set', '$level'],
        runInShell: false,
      );
      return result.exitCode == 0;
    } catch (_) {}
    // fallback: الكتابة إلى /sys/class/backlight
    return _writeSysBacklight(level);
  }

  /// يقرأ ملف من أول جهاز backlight موجود في /sys/class/backlight.
  Future<int> _readSysBacklight(String file) async {
    try {
      final dir = Directory('/sys/class/backlight');
      if (!await dir.exists()) return -1;
      final entries = await dir.list().toList();
      if (entries.isEmpty) return -1;
      final path = '${entries.first.path}/$file';
      final content = await File(path).readAsString();
      return int.tryParse(content.trim()) ?? -1;
    } catch (_) {
      return -1;
    }
  }

  /// يكتب قيمة السطوع مباشرة إلى /sys/class/backlight (يتطلب صلاحيات).
  Future<bool> _writeSysBacklight(int level) async {
    try {
      final dir = Directory('/sys/class/backlight');
      if (!await dir.exists()) return false;
      final entries = await dir.list().toList();
      if (entries.isEmpty) return false;
      final path = '${entries.first.path}/brightness';
      await File(path).writeAsString('$level');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🛠️ مساعدات
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, DBusValue> _parseProperties(DBusValue value) {
    final dict = value as DBusDict;
    return Map.fromEntries(
      dict.children.entries.map(
        (e) => MapEntry(
          (e.key as DBusString).value,
          (e.value as DBusVariant).value,
        ),
      ),
    );
  }
}
