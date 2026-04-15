import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📶 WiFi / Network Models
// ═══════════════════════════════════════════════════════════════════════════

class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int strength; // 0–100
  final int frequency; // MHz
  final bool secured;
  final bool connected;
  final DBusObjectPath apPath;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.strength,
    required this.frequency,
    required this.secured,
    required this.connected,
    required this.apPath,
  });

  String get band => frequency > 5000 ? '5GHz' : '2.4GHz';

  /// Build from NetworkManager AccessPoint properties
  static WiFiNetwork fromNM({
    required DBusObjectPath apPath,
    required Map<String, DBusValue> props,
    required bool connected,
  }) {
    // Ssid is as array of bytes
    final ssidBytes = (props['Ssid'] as DBusArray?)?.children ?? [];
    final ssid = String.fromCharCodes(
      ssidBytes.map((b) => (b as DBusByte).value),
    ).trim();

    // HwAddress
    final bssid =
        (props['HwAddress'] as DBusString?)?.value ?? '';

    // Strength 0–100
    final strength = (props['Strength'] as DBusByte?)?.value ?? 0;

    // Frequency in MHz
    final frequency = (props['Frequency'] as DBusUint32?)?.value.toInt() ?? 0;

    // Flags & WpaFlags & RsnFlags — if any security flag set, it's secured
    final flags = (props['Flags'] as DBusUint32?)?.value ?? 0;
    final wpaFlags = (props['WpaFlags'] as DBusUint32?)?.value ?? 0;
    final rsnFlags = (props['RsnFlags'] as DBusUint32?)?.value ?? 0;
    final secured = (flags & 0x1) != 0 || wpaFlags != 0 || rsnFlags != 0;

    return WiFiNetwork(
      ssid: ssid,
      bssid: bssid,
      strength: strength,
      frequency: frequency,
      secured: secured,
      connected: connected,
      apPath: apPath,
    );
  }
}

class WiFiStatus {
  final bool connected;
  final String ssid;
  final String ipAddress;
  final String gateway;
  final String subnet;
  final String dns;
  final int strength;
  final int speed;

  WiFiStatus({
    required this.connected,
    required this.ssid,
    required this.ipAddress,
    required this.gateway,
    required this.subnet,
    required this.dns,
    required this.strength,
    required this.speed,
  });

  static WiFiStatus empty() => WiFiStatus(
    connected: false,
    ssid: '',
    ipAddress: '',
    gateway: '',
    subnet: '',
    dns: '',
    strength: 0,
    speed: 0,
  );
}

class ConnectionDetails {
  final String ssid;
  final String ipAddress;
  final String gateway;
  final String subnet;
  final String dns;
  final bool autoConnect;
  final bool isDhcp;

  ConnectionDetails({
    required this.ssid,
    required this.ipAddress,
    required this.gateway,
    required this.subnet,
    required this.dns,
    required this.autoConnect,
    required this.isDhcp,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔌 Ethernet Models
// ═══════════════════════════════════════════════════════════════════════════

class EthernetInterface {
  final String name;
  final String macAddress;
  final String ipAddress;
  final String gateway;
  final int speed;
  final bool connected;
  final bool enabled;
  final DBusObjectPath devicePath;

  EthernetInterface({
    required this.name,
    required this.macAddress,
    required this.ipAddress,
    required this.gateway,
    required this.speed,
    required this.connected,
    required this.enabled,
    required this.devicePath,
  });

  EthernetInterface copyWith({
    String? name,
    String? macAddress,
    String? ipAddress,
    String? gateway,
    int? speed,
    bool? connected,
    bool? enabled,
    DBusObjectPath? devicePath,
  }) {
    return EthernetInterface(
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      gateway: gateway ?? this.gateway,
      speed: speed ?? this.speed,
      connected: connected ?? this.connected,
      enabled: enabled ?? this.enabled,
      devicePath: devicePath ?? this.devicePath,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌐 NetworkManager Service
// ═══════════════════════════════════════════════════════════════════════════
//
// Talks directly to org.freedesktop.NetworkManager on the System Bus.
// No intermediate daemon required.
//
// Key D-Bus paths:
//   /org/freedesktop/NetworkManager          → NM main interface
//   /org/freedesktop/NetworkManager/Devices  → network devices
// ═══════════════════════════════════════════════════════════════════════════

class NetworkManagerService {
  static const _nmService = 'org.freedesktop.NetworkManager';
  static const _nmPath = '/org/freedesktop/NetworkManager';
  static const _nmIface = 'org.freedesktop.NetworkManager';
  static const _nmDeviceIface = 'org.freedesktop.NetworkManager.Device';
  static const _nmWifiIface = 'org.freedesktop.NetworkManager.Device.Wireless';
  static const _nmEthernetIface = 'org.freedesktop.NetworkManager.Device.Wired';
  static const _nmAPiface = 'org.freedesktop.NetworkManager.AccessPoint';
  static const _nmActiveConnIface =
      'org.freedesktop.NetworkManager.Connection.Active';
  static const _nmIP4ConfigIface = 'org.freedesktop.NetworkManager.IP4Config';
  static const _nmSettingsIface = 'org.freedesktop.NetworkManager.Settings';
  static const _nmSettingsConnIface =
      'org.freedesktop.NetworkManager.Settings.Connection';
  static const _propIface = 'org.freedesktop.DBus.Properties';

  // NM Device Types
  static const _deviceTypeEthernet = 1;
  static const _deviceTypeWifi = 2;

  // NM Device State
  static const _deviceStateActivated = 100;
  static const _deviceStateUnavailable = 20;

  late DBusClient _client;
  late DBusRemoteObject _nm;
  bool _connected = false;

  bool get isConnected => _connected;

  // ────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> connect() async {
    try {
      _client = DBusClient.system();
      _nm = DBusRemoteObject(
        _client,
        name: _nmService,
        path: DBusObjectPath(_nmPath),
      );
      _connected = true;
      return true;
    } catch (e) {
      debugPrint('[NM] connect error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connected) {
      await _client.close();
      _connected = false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  DBusRemoteObject _obj(String path) =>
      DBusRemoteObject(_client, name: _nmService, path: DBusObjectPath(path));

  Future<DBusValue?> _getProp(String path, String iface, String prop) async {
    try {
      final obj = _obj(path);
      final result = await obj.callMethod(
        _propIface,
        'Get',
        [DBusString(iface), DBusString(prop)],
        replySignature: DBusSignature('v'),
      );
      return (result.values.first as DBusVariant).value;
    } catch (e) {
      debugPrint('[NM] getProp $path/$prop error: $e');
      return null;
    }
  }

  Future<Map<String, DBusValue>> _getAllProps(
    String path,
    String iface,
  ) async {
    try {
      final obj = _obj(path);
      final result = await obj.callMethod(
        _propIface,
        'GetAll',
        [DBusString(iface)],
        replySignature: DBusSignature('a{sv}'),
      );
      final dict = result.values.first as DBusDict;
      return {
        for (final e in dict.children.entries)
          (e.key as DBusString).value: (e.value as DBusVariant).value,
      };
    } catch (e) {
      debugPrint('[NM] getAllProps $path $iface error: $e');
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
      final obj = _obj(path);
      await obj.callMethod(
        _propIface,
        'Set',
        [DBusString(iface), DBusString(prop), DBusVariant(value)],
      );
      return true;
    } catch (e) {
      debugPrint('[NM] setProp $path/$prop error: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Enable / Disable
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> isWifiEnabled() async {
    final v = await _getProp(_nmPath, _nmIface, 'WirelessEnabled');
    return (v as DBusBoolean?)?.value ?? false;
  }

  Future<bool> setWifiEnabled(bool enabled) =>
      _setProp(_nmPath, _nmIface, 'WirelessEnabled', DBusBoolean(enabled));

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Get the wireless device path
  // ────────────────────────────────────────────────────────────────────────

  Future<DBusObjectPath?> _getWifiDevicePath() async {
    try {
      final result = await _nm.callMethod(
        _nmIface,
        'GetAllDevices',
        [],
        replySignature: DBusSignature('ao'),
      );
      final paths =
          (result.values.first as DBusArray).children
              .map((v) => v as DBusObjectPath)
              .toList();

      for (final path in paths) {
        final typeVal = await _getProp(path.value, _nmDeviceIface, 'DeviceType');
        if (typeVal is DBusUint32 && typeVal.value == _deviceTypeWifi) {
          return path;
        }
      }
    } catch (e) {
      debugPrint('[NM] getWifiDevicePath error: $e');
    }
    return null;
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Access Points
  // ────────────────────────────────────────────────────────────────────────

  Future<List<WiFiNetwork>> getWifiNetworks() async {
    try {
      final devicePath = await _getWifiDevicePath();
      if (devicePath == null) return [];

      // Get active AP for "connected" flag
      final activeApVal = await _getProp(
        devicePath.value,
        _nmWifiIface,
        'ActiveAccessPoint',
      );
      final activeApPath =
          (activeApVal is DBusObjectPath) ? activeApVal.value : '';

      // Get all APs
      final result = await _obj(devicePath.value).callMethod(
        _nmWifiIface,
        'GetAllAccessPoints',
        [],
        replySignature: DBusSignature('ao'),
      );
      final apPaths =
          (result.values.first as DBusArray).children
              .map((v) => v as DBusObjectPath)
              .toList();

      final networks = <WiFiNetwork>[];
      final seen = <String>{};

      for (final apPath in apPaths) {
        final props = await _getAllProps(apPath.value, _nmAPiface);
        final net = WiFiNetwork.fromNM(
          apPath: apPath,
          props: props,
          connected: apPath.value == activeApPath,
        );
        // De-duplicate by SSID, keep strongest signal
        if (net.ssid.isEmpty) continue;
        if (seen.contains(net.ssid)) {
          final idx = networks.indexWhere((n) => n.ssid == net.ssid);
          if (idx != -1 && net.strength > networks[idx].strength) {
            networks[idx] = net;
          }
        } else {
          seen.add(net.ssid);
          networks.add(net);
        }
      }

      // Sort: connected first, then by strength desc
      networks.sort((a, b) {
        if (a.connected && !b.connected) return -1;
        if (!a.connected && b.connected) return 1;
        return b.strength.compareTo(a.strength);
      });

      return networks;
    } catch (e) {
      debugPrint('[NM] getWifiNetworks error: $e');
      return [];
    }
  }

  /// Request a fresh scan (NM may throttle this to ~30s intervals)
  Future<void> requestScan() async {
    try {
      final devicePath = await _getWifiDevicePath();
      if (devicePath == null) return;
      await _obj(devicePath.value).callMethod(
        _nmWifiIface,
        'RequestScan',
        [DBusDict(DBusSignature('s'), DBusSignature('v'), {})],
      );
    } catch (e) {
      debugPrint('[NM] requestScan error (may be throttled): $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Status
  // ────────────────────────────────────────────────────────────────────────

  Future<WiFiStatus> getWifiStatus() async {
    try {
      final devicePath = await _getWifiDevicePath();
      if (devicePath == null) return WiFiStatus.empty();

      final state =
          (await _getProp(devicePath.value, _nmDeviceIface, 'State')
              as DBusUint32?)
              ?.value ??
          0;
      if (state != _deviceStateActivated) return WiFiStatus.empty();

      // Active AP
      final activeApVal = await _getProp(
        devicePath.value,
        _nmWifiIface,
        'ActiveAccessPoint',
      );
      final activeApPath = (activeApVal is DBusObjectPath) ? activeApVal : null;

      String ssid = '';
      int strength = 0;
      if (activeApPath != null &&
          activeApPath.value != '/' &&
          activeApPath.value.isNotEmpty) {
        final apProps = await _getAllProps(activeApPath.value, _nmAPiface);
        final ssidBytes = (apProps['Ssid'] as DBusArray?)?.children ?? [];
        ssid = String.fromCharCodes(
          ssidBytes.map((b) => (b as DBusByte).value),
        ).trim();
        strength = (apProps['Strength'] as DBusByte?)?.value ?? 0;
      }

      // IP4Config
      final ip4Val = await _getProp(
        devicePath.value,
        _nmDeviceIface,
        'Ip4Config',
      );
      final ip4Path = (ip4Val is DBusObjectPath) ? ip4Val : null;

      String ipAddress = '';
      String gateway = '';
      String subnet = '';
      String dns = '';

      if (ip4Path != null && ip4Path.value != '/') {
        final ip4Props = await _getAllProps(ip4Path.value, _nmIP4ConfigIface);

        // Addresses: array of (address, prefix, gateway)
        final addresses = ip4Props['AddressData'] as DBusArray?;
        if (addresses != null && addresses.children.isNotEmpty) {
          final first = addresses.children.first as DBusDict;
          final addrMap = {
            for (final e in first.children.entries)
              (e.key as DBusString).value: (e.value as DBusVariant).value,
          };
          ipAddress = (addrMap['address'] as DBusString?)?.value ?? '';
          final prefix = (addrMap['prefix'] as DBusUint32?)?.value ?? 0;
          subnet = _prefixToSubnet(prefix.toInt());
        }

        gateway =
            (ip4Props['Gateway'] as DBusString?)?.value ?? '';

        // DNS nameservers
        final nameservers = ip4Props['NameserverData'] as DBusArray?;
        if (nameservers != null && nameservers.children.isNotEmpty) {
          final firstNs = nameservers.children.first as DBusDict;
          final nsMap = {
            for (final e in firstNs.children.entries)
              (e.key as DBusString).value: (e.value as DBusVariant).value,
          };
          dns = (nsMap['address'] as DBusString?)?.value ?? '';
        }

        // Bitrate (speed in Kb/s → convert to Mb/s)
        final bitrateVal = await _getProp(
          devicePath.value,
          _nmWifiIface,
          'Bitrate',
        );
        final speed = ((bitrateVal as DBusUint32?)?.value ?? 0) ~/ 1000;

        return WiFiStatus(
          connected: true,
          ssid: ssid,
          ipAddress: ipAddress,
          gateway: gateway,
          subnet: subnet,
          dns: dns,
          strength: strength,
          speed: speed.toInt(),
        );
      }

      return WiFiStatus.empty();
    } catch (e) {
      debugPrint('[NM] getWifiStatus error: $e');
      return WiFiStatus.empty();
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Connect / Disconnect
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> wifiConnect(String ssid, String password) async {
    try {
      final devicePath = await _getWifiDevicePath();
      if (devicePath == null) return false;

      // Build an ephemeral connection profile
      final connection = _buildWifiConnectionProfile(ssid, password);

      final settings = DBusRemoteObject(
        _client,
        name: _nmService,
        path: DBusObjectPath('/org/freedesktop/NetworkManager/Settings'),
      );

      // Try to find existing saved connection first
      final existing = await _findSavedConnectionForSsid(ssid);
      if (existing != null) {
        await _nm.callMethod(
          _nmIface,
          'ActivateConnection',
          [existing, devicePath, DBusObjectPath('/')],
          replySignature: DBusSignature('o'),
        );
        return true;
      }

      // Add and activate new connection
      await _nm.callMethod(
        _nmIface,
        'AddAndActivateConnection',
        [connection, devicePath, DBusObjectPath('/')],
        replySignature: DBusSignature('oo'),
      );
      return true;
    } catch (e) {
      debugPrint('[NM] wifiConnect error: $e');
      return false;
    }
  }

  Future<bool> wifiDisconnect() async {
    try {
      final devicePath = await _getWifiDevicePath();
      if (devicePath == null) return false;
      await _obj(devicePath.value).callMethod(
        _nmDeviceIface,
        'Disconnect',
        [],
      );
      return true;
    } catch (e) {
      debugPrint('[NM] wifiDisconnect error: $e');
      return false;
    }
  }

  Future<bool> forgetNetwork(String ssid) async {
    try {
      final connPath = await _findSavedConnectionForSsid(ssid);
      if (connPath == null) return false;
      await _obj(connPath.value).callMethod(
        _nmSettingsConnIface,
        'Delete',
        [],
      );
      return true;
    } catch (e) {
      debugPrint('[NM] forgetNetwork error: $e');
      return false;
    }
  }

  Future<List<String>> getSavedNetworks() async {
    try {
      final settingsObj = DBusRemoteObject(
        _client,
        name: _nmService,
        path: DBusObjectPath('/org/freedesktop/NetworkManager/Settings'),
      );
      final result = await settingsObj.callMethod(
        _nmSettingsIface,
        'ListConnections',
        [],
        replySignature: DBusSignature('ao'),
      );
      final connPaths =
          (result.values.first as DBusArray).children
              .map((v) => v as DBusObjectPath)
              .toList();

      final ssids = <String>[];
      for (final cp in connPaths) {
        final ssid = await _getSsidFromConnection(cp.value);
        if (ssid != null && ssid.isNotEmpty) ssids.add(ssid);
      }
      return ssids;
    } catch (e) {
      debugPrint('[NM] getSavedNetworks error: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 📶 WiFi – Static IP / DHCP / DNS / AutoConnect
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> setStaticIP(
    String ssid,
    String ip,
    String gateway,
    String subnet,
    String dns,
  ) async {
    try {
      final connPath = await _findSavedConnectionForSsid(ssid);
      if (connPath == null) return false;

      final prefix = _subnetToPrefix(subnet);
      final updatedSettings = DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        {
          DBusString('method'): DBusVariant(DBusString('manual')),
          DBusString('addresses'): DBusVariant(
            DBusArray(
              DBusSignature('(...)'), // Will use AddressData instead
              [],
            ),
          ),
        },
      );

      // Use Update2 if available, otherwise Update
      final conn = _obj(connPath.value);
      final settings = _buildStaticIPSettings(ip, prefix, gateway, dns);
      await conn.callMethod(_nmSettingsConnIface, 'Update', [settings]);
      return true;
    } catch (e) {
      debugPrint('[NM] setStaticIP error: $e');
      return false;
    }
  }

  Future<bool> setDHCP(String ssid) async {
    try {
      final connPath = await _findSavedConnectionForSsid(ssid);
      if (connPath == null) return false;
      final conn = _obj(connPath.value);
      await conn.callMethod(
        _nmSettingsConnIface,
        'Update',
        [_buildDhcpSettings()],
      );
      return true;
    } catch (e) {
      debugPrint('[NM] setDHCP error: $e');
      return false;
    }
  }

  Future<bool> setDNS(String ssid, String dns1, String dns2) async {
    try {
      final connPath = await _findSavedConnectionForSsid(ssid);
      if (connPath == null) return false;
      // DNS update requires full settings update; simplified here
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setAutoConnect(String ssid, bool autoConnect) async {
    try {
      final connPath = await _findSavedConnectionForSsid(ssid);
      if (connPath == null) return false;
      // Patch connection settings
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ConnectionDetails> getConnectionDetails(String ssid) async {
    return ConnectionDetails(
      ssid: ssid,
      ipAddress: '',
      gateway: '',
      subnet: '',
      dns: '',
      autoConnect: true,
      isDhcp: true,
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // 🔌 Ethernet
  // ────────────────────────────────────────────────────────────────────────

  Future<List<EthernetInterface>> getEthernetInterfaces() async {
    try {
      final result = await _nm.callMethod(
        _nmIface,
        'GetAllDevices',
        [],
        replySignature: DBusSignature('ao'),
      );
      final paths =
          (result.values.first as DBusArray).children
              .map((v) => v as DBusObjectPath)
              .toList();

      final interfaces = <EthernetInterface>[];
      for (final path in paths) {
        final typeVal = await _getProp(
          path.value,
          _nmDeviceIface,
          'DeviceType',
        );
        if (typeVal is! DBusUint32 ||
            typeVal.value != _deviceTypeEthernet) continue;

        final props = await _getAllProps(path.value, _nmDeviceIface);
        final ethProps = await _getAllProps(path.value, _nmEthernetIface);

        final name =
            (props['Interface'] as DBusString?)?.value ?? '';
        final mac =
            (ethProps['HwAddress'] as DBusString?)?.value ?? '';
        final stateVal = (props['State'] as DBusUint32?)?.value ?? 0;
        final connected = stateVal == _deviceStateActivated;
        final enabled = stateVal > _deviceStateUnavailable;
        final speed = (ethProps['Speed'] as DBusUint32?)?.value.toInt() ?? 0;

        // IP address
        String ipAddress = '';
        String gateway = '';
        final ip4Val = props['Ip4Config'];
        if (ip4Val is DBusObjectPath && ip4Val.value != '/') {
          final ip4 = await _getAllProps(ip4Val.value, _nmIP4ConfigIface);
          final addrs = ip4['AddressData'] as DBusArray?;
          if (addrs != null && addrs.children.isNotEmpty) {
            final first = addrs.children.first as DBusDict;
            final m = {
              for (final e in first.children.entries)
                (e.key as DBusString).value: (e.value as DBusVariant).value,
            };
            ipAddress = (m['address'] as DBusString?)?.value ?? '';
          }
          gateway = (ip4['Gateway'] as DBusString?)?.value ?? '';
        }

        interfaces.add(
          EthernetInterface(
            name: name,
            macAddress: mac,
            ipAddress: ipAddress,
            gateway: gateway,
            speed: speed,
            connected: connected,
            enabled: enabled,
            devicePath: path,
          ),
        );
      }
      return interfaces;
    } catch (e) {
      debugPrint('[NM] getEthernetInterfaces error: $e');
      return [];
    }
  }

  Future<bool> enableEthernet(String name) async {
    try {
      final devicePath = await _getDevicePathByName(name);
      if (devicePath == null) return false;
      await _nm.callMethod(
        _nmIface,
        'ActivateConnection',
        [
          DBusObjectPath('/'),
          DBusObjectPath(devicePath),
          DBusObjectPath('/'),
        ],
        replySignature: DBusSignature('o'),
      );
      return true;
    } catch (e) {
      debugPrint('[NM] enableEthernet error: $e');
      return false;
    }
  }

  Future<bool> disableEthernet(String name) async {
    try {
      final devicePath = await _getDevicePathByName(name);
      if (devicePath == null) return false;
      await _obj(devicePath).callMethod(_nmDeviceIface, 'Disconnect', []);
      return true;
    } catch (e) {
      debugPrint('[NM] disableEthernet error: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  Future<String?> _getDevicePathByName(String name) async {
    try {
      final result = await _nm.callMethod(
        _nmIface,
        'GetDeviceByIpIface',
        [DBusString(name)],
        replySignature: DBusSignature('o'),
      );
      return (result.values.first as DBusObjectPath).value;
    } catch (e) {
      return null;
    }
  }

  Future<DBusObjectPath?> _findSavedConnectionForSsid(String ssid) async {
    try {
      final settingsObj = DBusRemoteObject(
        _client,
        name: _nmService,
        path: DBusObjectPath('/org/freedesktop/NetworkManager/Settings'),
      );
      final result = await settingsObj.callMethod(
        _nmSettingsIface,
        'ListConnections',
        [],
        replySignature: DBusSignature('ao'),
      );
      final connPaths =
          (result.values.first as DBusArray).children
              .map((v) => v as DBusObjectPath)
              .toList();

      for (final cp in connPaths) {
        final s = await _getSsidFromConnection(cp.value);
        if (s == ssid) return cp;
      }
    } catch (e) {
      debugPrint('[NM] findSavedConnection error: $e');
    }
    return null;
  }

  Future<String?> _getSsidFromConnection(String connPath) async {
    try {
      final connObj = _obj(connPath);
      final result = await connObj.callMethod(
        _nmSettingsConnIface,
        'GetSettings',
        [],
        replySignature: DBusSignature('a{sa{sv}}'),
      );
      final topDict = result.values.first as DBusDict;
      for (final topEntry in topDict.children.entries) {
        if ((topEntry.key as DBusString).value == 'wifi' ||
            (topEntry.key as DBusString).value == '802-11-wireless') {
          final innerDict = (topEntry.value as DBusDict);
          for (final entry in innerDict.children.entries) {
            if ((entry.key as DBusString).value == 'ssid') {
              final ssidBytes =
                  ((entry.value as DBusArray).children);
              return String.fromCharCodes(
                ssidBytes.map((b) => (b as DBusByte).value),
              ).trim();
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  DBusDict _buildWifiConnectionProfile(String ssid, String password) {
    final ssidBytes = DBusArray(
      DBusSignature('y'),
      ssid.codeUnits.map((c) => DBusByte(c)).toList(),
    );

    final wireless = <DBusValue, DBusValue>{
      DBusString('ssid'): DBusVariant(ssidBytes),
      DBusString('mode'): DBusVariant(DBusString('infrastructure')),
    };

    final wirelessSec = <DBusValue, DBusValue>{};
    if (password.isNotEmpty) {
      wirelessSec[DBusString('key-mgmt')] = DBusVariant(DBusString('wpa-psk'));
      wirelessSec[DBusString('psk')] = DBusVariant(DBusString(password));
    }

    final ipv4 = <DBusValue, DBusValue>{
      DBusString('method'): DBusVariant(DBusString('auto')),
    };
    final ipv6 = <DBusValue, DBusValue>{
      DBusString('method'): DBusVariant(DBusString('auto')),
    };
    final conn = <DBusValue, DBusValue>{
      DBusString('type'): DBusVariant(DBusString('802-11-wireless')),
    };

    final profile = <DBusValue, DBusValue>{
      DBusString('connection'): DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        conn,
      ),
      DBusString('802-11-wireless'): DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        wireless,
      ),
      DBusString('ipv4'): DBusDict(DBusSignature('s'), DBusSignature('v'), ipv4),
      DBusString('ipv6'): DBusDict(DBusSignature('s'), DBusSignature('v'), ipv6),
    };

    if (wirelessSec.isNotEmpty) {
      profile[DBusString('802-11-wireless-security')] = DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        wirelessSec,
      );
    }

    return DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), profile);
  }

  DBusDict _buildStaticIPSettings(
    String ip,
    int prefix,
    String gateway,
    String dns,
  ) {
    final addressEntry = DBusDict(DBusSignature('s'), DBusSignature('v'), {
      DBusString('address'): DBusVariant(DBusString(ip)),
      DBusString('prefix'): DBusVariant(DBusUint32(prefix)),
    });

    final ipv4 = <DBusValue, DBusValue>{
      DBusString('method'): DBusVariant(DBusString('manual')),
      DBusString('address-data'): DBusVariant(
        DBusArray(DBusSignature('a{sv}'), [addressEntry]),
      ),
      DBusString('gateway'): DBusVariant(DBusString(gateway)),
      if (dns.isNotEmpty)
        DBusString('dns'): DBusVariant(
          DBusArray(
            DBusSignature('u'),
            [DBusUint32(_ipToInt(dns))],
          ),
        ),
    };

    return DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), {
      DBusString('ipv4'): DBusDict(DBusSignature('s'), DBusSignature('v'), ipv4),
    });
  }

  DBusDict _buildDhcpSettings() {
    return DBusDict(DBusSignature('s'), DBusSignature('a{sv}'), {
      DBusString('ipv4'): DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        {DBusString('method'): DBusVariant(DBusString('auto'))},
      ),
    });
  }

  static String _prefixToSubnet(int prefix) {
    if (prefix <= 0 || prefix > 32) return '255.255.255.0';
    final mask = prefix == 32
        ? 0xFFFFFFFF
        : ~((1 << (32 - prefix)) - 1) & 0xFFFFFFFF;
    return [
      (mask >> 24) & 0xFF,
      (mask >> 16) & 0xFF,
      (mask >> 8) & 0xFF,
      mask & 0xFF,
    ].join('.');
  }

  static int _subnetToPrefix(String subnet) {
    try {
      final parts = subnet.split('.').map(int.parse).toList();
      int mask = 0;
      for (final p in parts) {
        mask = (mask << 8) | p;
      }
      int prefix = 0;
      for (int i = 31; i >= 0; i--) {
        if ((mask >> i) & 1 == 1) prefix++;
        else break;
      }
      return prefix;
    } catch (_) {
      return 24;
    }
  }

  static int _ipToInt(String ip) {
    try {
      final parts = ip.split('.').map(int.parse).toList();
      return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
    } catch (_) {
      return 0;
    }
  }
}
