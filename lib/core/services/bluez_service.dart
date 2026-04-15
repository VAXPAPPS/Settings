import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Bluetooth Models
// ═══════════════════════════════════════════════════════════════════════════

class BluetoothDevice {
  final String address;
  final String name;
  final String icon;
  final bool paired;
  final bool connected;
  final bool trusted;
  final DBusObjectPath devicePath;

  BluetoothDevice({
    required this.address,
    required this.name,
    required this.icon,
    required this.paired,
    required this.connected,
    required this.trusted,
    required this.devicePath,
  });

  /// Build from BlueZ Device1 properties dict
  static BluetoothDevice fromBlueZ({
    required DBusObjectPath path,
    required Map<String, DBusValue> props,
  }) {
    return BluetoothDevice(
      address: (props['Address'] as DBusString?)?.value ?? '',
      name: (props['Name'] as DBusString?)?.value ??
          (props['Alias'] as DBusString?)?.value ??
          'Unknown',
      icon: (props['Icon'] as DBusString?)?.value ?? 'bluetooth',
      paired: (props['Paired'] as DBusBoolean?)?.value ?? false,
      connected: (props['Connected'] as DBusBoolean?)?.value ?? false,
      trusted: (props['Trusted'] as DBusBoolean?)?.value ?? false,
      devicePath: path,
    );
  }
}

class BluetoothStatus {
  final bool powered;
  final bool discovering;
  final String name;
  final String address;

  BluetoothStatus({
    required this.powered,
    required this.discovering,
    required this.name,
    required this.address,
  });

  static BluetoothStatus empty() => BluetoothStatus(
    powered: false,
    discovering: false,
    name: '',
    address: '',
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📡 BlueZ Service
// ═══════════════════════════════════════════════════════════════════════════
//
// Talks directly to org.bluez on the System Bus.
// No intermediate daemon required.
//
// Key D-Bus paths:
//   /org/bluez                          → ObjectManager root
//   /org/bluez/hci0                     → Adapter1 (first BT adapter)
//   /org/bluez/hci0/dev_XX_XX_XX_XX_XX  → Device1 for each device
// ═══════════════════════════════════════════════════════════════════════════

class BlueZService {
  static const _blueZService = 'org.bluez';
  static const _adapter1Iface = 'org.bluez.Adapter1';
  static const _device1Iface = 'org.bluez.Device1';
  static const _objectManagerIface = 'org.freedesktop.DBus.ObjectManager';
  static const _propIface = 'org.freedesktop.DBus.Properties';

  late DBusClient _client;
  DBusObjectPath? _adapterPath;
  bool _connected = false;

  // Stream controllers for real-time device updates
  final _devicesAddedController =
      StreamController<BluetoothDevice>.broadcast();
  final _devicesRemovedController =
      StreamController<DBusObjectPath>.broadcast();

  Stream<BluetoothDevice> get onDeviceAdded => _devicesAddedController.stream;
  Stream<DBusObjectPath> get onDeviceRemoved =>
      _devicesRemovedController.stream;

  StreamSubscription<DBusSignal>? _interfacesAddedSub;
  StreamSubscription<DBusSignal>? _interfacesRemovedSub;
  StreamSubscription<DBusSignal>? _propertiesChangedSub;

  bool get isConnected => _connected;

  // ────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> connect() async {
    try {
      _client = DBusClient.system();
      await _discoverAdapter();
      _subscribeSignals();
      _connected = true;
      return true;
    } catch (e) {
      debugPrint('[BlueZ] connect error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    if (!_connected) return;
    await _interfacesAddedSub?.cancel();
    await _interfacesRemovedSub?.cancel();
    await _propertiesChangedSub?.cancel();
    await _devicesAddedController.close();
    await _devicesRemovedController.close();
    await _client.close();
    _connected = false;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Adapter discovery
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _discoverAdapter() async {
    final root = DBusRemoteObject(
      _client,
      name: _blueZService,
      path: DBusObjectPath('/'),
    );

    final result = await root.callMethod(
      _objectManagerIface,
      'GetManagedObjects',
      [],
      replySignature: DBusSignature('a{oa{sa{sv}}}'),
    );

    final objects = result.values.first as DBusDict;
    for (final entry in objects.children.entries) {
      final objPath = (entry.key as DBusObjectPath).value;
      final ifaceDict = entry.value as DBusDict;
      final ifaces = ifaceDict.children.keys
          .map((k) => (k as DBusString).value)
          .toSet();

      if (ifaces.contains(_adapter1Iface)) {
        _adapterPath = DBusObjectPath(objPath);
        break; // Use the first adapter (hci0)
      }
    }

    if (_adapterPath == null) {
      debugPrint('[BlueZ] No Bluetooth adapter found!');
    } else {
      debugPrint('[BlueZ] Adapter found at ${_adapterPath!.value}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Real-time signal subscriptions
  // ────────────────────────────────────────────────────────────────────────

  void _subscribeSignals() {
    // InterfacesAdded — emitted when a new device is discovered
    _interfacesAddedSub = DBusSignalStream(
      _client,
      sender: _blueZService,
      interface: _objectManagerIface,
      name: 'InterfacesAdded',
    ).listen(_onInterfacesAdded);

    // InterfacesRemoved — emitted when a device is removed
    _interfacesRemovedSub = DBusSignalStream(
      _client,
      sender: _blueZService,
      interface: _objectManagerIface,
      name: 'InterfacesRemoved',
    ).listen(_onInterfacesRemoved);
  }

  void _onInterfacesAdded(DBusSignal signal) {
    try {
      final path = signal.values[0] as DBusObjectPath;
      final ifaceDict = signal.values[1] as DBusDict;

      for (final entry in ifaceDict.children.entries) {
        if ((entry.key as DBusString).value == _device1Iface) {
          final propsDict = entry.value as DBusDict;
          final props = _unwrapPropsDict(propsDict);
          final device = BluetoothDevice.fromBlueZ(path: path, props: props);
          _devicesAddedController.add(device);
          break;
        }
      }
    } catch (e) {
      debugPrint('[BlueZ] InterfacesAdded parse error: $e');
    }
  }

  void _onInterfacesRemoved(DBusSignal signal) {
    try {
      final path = signal.values[0] as DBusObjectPath;
      final ifaces =
          (signal.values[1] as DBusArray).children
              .map((v) => (v as DBusString).value)
              .toList();
      if (ifaces.contains(_device1Iface)) {
        _devicesRemovedController.add(path);
      }
    } catch (e) {
      debugPrint('[BlueZ] InterfacesRemoved parse error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  DBusRemoteObject _obj(String path) =>
      DBusRemoteObject(_client, name: _blueZService, path: DBusObjectPath(path));

  Future<Map<String, DBusValue>> _getProps(String path, String iface) async {
    try {
      final obj = _obj(path);
      final result = await obj.callMethod(
        _propIface,
        'GetAll',
        [DBusString(iface)],
        replySignature: DBusSignature('a{sv}'),
      );
      return _unwrapPropsDict(result.values.first as DBusDict);
    } catch (e) {
      debugPrint('[BlueZ] getProps $path error: $e');
      return {};
    }
  }

  Future<bool> _setProp(
    String path,
    String iface,
    String prop,
    DBusValue value,
  ) async {
    try {
      await _obj(path).callMethod(
        _propIface,
        'Set',
        [DBusString(iface), DBusString(prop), DBusVariant(value)],
      );
      return true;
    } catch (e) {
      debugPrint('[BlueZ] setProp $path/$prop error: $e');
      return false;
    }
  }

  static Map<String, DBusValue> _unwrapPropsDict(DBusDict dict) {
    return {
      for (final e in dict.children.entries)
        (e.key as DBusString).value: (e.value as DBusVariant).value,
    };
  }

  // ────────────────────────────────────────────────────────────────────────
  // 🔵 Adapter Status
  // ────────────────────────────────────────────────────────────────────────

  Future<BluetoothStatus> getAdapterStatus() async {
    if (_adapterPath == null) return BluetoothStatus.empty();
    try {
      final props = await _getProps(_adapterPath!.value, _adapter1Iface);
      return BluetoothStatus(
        powered: (props['Powered'] as DBusBoolean?)?.value ?? false,
        discovering: (props['Discovering'] as DBusBoolean?)?.value ?? false,
        name: (props['Name'] as DBusString?)?.value ??
            (props['Alias'] as DBusString?)?.value ??
            '',
        address: (props['Address'] as DBusString?)?.value ?? '',
      );
    } catch (e) {
      debugPrint('[BlueZ] getAdapterStatus error: $e');
      return BluetoothStatus.empty();
    }
  }

  Future<bool> setAdapterPowered(bool powered) async {
    if (_adapterPath == null) return false;
    return _setProp(
      _adapterPath!.value,
      _adapter1Iface,
      'Powered',
      DBusBoolean(powered),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // 🔍 Discovery
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> startDiscovery() async {
    if (_adapterPath == null) return false;
    try {
      await _obj(_adapterPath!.value).callMethod(
        _adapter1Iface,
        'StartDiscovery',
        [],
      );
      return true;
    } catch (e) {
      debugPrint('[BlueZ] startDiscovery error: $e');
      return false;
    }
  }

  Future<bool> stopDiscovery() async {
    if (_adapterPath == null) return false;
    try {
      await _obj(_adapterPath!.value).callMethod(
        _adapter1Iface,
        'StopDiscovery',
        [],
      );
      return true;
    } catch (e) {
      debugPrint('[BlueZ] stopDiscovery error: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📋 Devices
  // ────────────────────────────────────────────────────────────────────────

  Future<List<BluetoothDevice>> getManagedDevices() async {
    try {
      final root = DBusRemoteObject(
        _client,
        name: _blueZService,
        path: DBusObjectPath('/'),
      );

      final result = await root.callMethod(
        _objectManagerIface,
        'GetManagedObjects',
        [],
        replySignature: DBusSignature('a{oa{sa{sv}}}'),
      );

      final objects = result.values.first as DBusDict;
      final devices = <BluetoothDevice>[];

      for (final entry in objects.children.entries) {
        final objPath = entry.key as DBusObjectPath;
        final ifaceDict = entry.value as DBusDict;

        // Only look at objects that implement Device1
        for (final ifaceEntry in ifaceDict.children.entries) {
          if ((ifaceEntry.key as DBusString).value == _device1Iface) {
            final propsDict = ifaceEntry.value as DBusDict;
            final props = _unwrapPropsDict(propsDict);
            devices.add(
              BluetoothDevice.fromBlueZ(path: objPath, props: props),
            );
            break;
          }
        }
      }

      return devices;
    } catch (e) {
      debugPrint('[BlueZ] getManagedDevices error: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 🔗 Device operations (by DBusObjectPath)
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> pairDevice(DBusObjectPath devicePath) async {
    try {
      await _obj(devicePath.value).callMethod(_device1Iface, 'Pair', []);
      return true;
    } catch (e) {
      debugPrint('[BlueZ] pairDevice error: $e');
      return false;
    }
  }

  Future<bool> connectDevice(DBusObjectPath devicePath) async {
    try {
      await _obj(devicePath.value).callMethod(_device1Iface, 'Connect', []);
      return true;
    } catch (e) {
      debugPrint('[BlueZ] connectDevice error: $e');
      return false;
    }
  }

  Future<bool> disconnectDevice(DBusObjectPath devicePath) async {
    try {
      await _obj(devicePath.value).callMethod(_device1Iface, 'Disconnect', []);
      return true;
    } catch (e) {
      debugPrint('[BlueZ] disconnectDevice error: $e');
      return false;
    }
  }

  Future<bool> removeDevice(DBusObjectPath devicePath) async {
    if (_adapterPath == null) return false;
    try {
      await _obj(_adapterPath!.value).callMethod(
        _adapter1Iface,
        'RemoveDevice',
        [devicePath],
      );
      return true;
    } catch (e) {
      debugPrint('[BlueZ] removeDevice error: $e');
      return false;
    }
  }

  Future<bool> trustDevice(DBusObjectPath devicePath, bool trusted) =>
      _setProp(devicePath.value, _device1Iface, 'Trusted', DBusBoolean(trusted));
}
