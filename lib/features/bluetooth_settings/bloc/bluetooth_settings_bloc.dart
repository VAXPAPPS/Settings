import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settings/core/services/bluez_service.dart';
import 'bluetooth_settings_event.dart';
import 'bluetooth_settings_state.dart';

class BluetoothSettingsBloc
    extends Bloc<BluetoothSettingsEvent, BluetoothSettingsState> {
  BlueZService? _bluez;
  Timer? _scanTimer;

  // Subscriptions to BlueZ real-time signals
  StreamSubscription<BluetoothDevice>? _deviceAddedSub;
  StreamSubscription? _deviceRemovedSub;

  BluetoothSettingsBloc() : super(const BluetoothSettingsState()) {
    on<InitializeBluetooth>(_onInitializeBluetooth);
    on<ToggleBluetooth>(_onToggleBluetooth);
    on<StartBluetoothScan>(_onStartBluetoothScan);
    on<StopBluetoothScan>(_onStopBluetoothScan);
    on<RefreshDevices>(_onRefreshDevices);
    on<PairDevice>(_onPairDevice);
    on<ConnectDevice>(_onConnectDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<RemoveDevice>(_onRemoveDevice);
    on<DeviceDiscovered>(_onDeviceDiscovered);
    on<DeviceRemoved>(_onDeviceRemoved);
  }

  Future<void> _onInitializeBluetooth(
    InitializeBluetooth event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    emit(state.copyWith(status: BluetoothSettingsStatus.loading));

    _bluez = BlueZService();
    final connected = await _bluez!.connect().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(
        state.copyWith(
          status: BluetoothSettingsStatus.error,
          errorMessage: 'Failed to connect to BlueZ (System D-Bus)',
        ),
      );
      return;
    }

    // Subscribe to real-time BlueZ signals
    _deviceAddedSub = _bluez!.onDeviceAdded.listen((device) {
      add(DeviceDiscovered(device));
    });
    _deviceRemovedSub = _bluez!.onDeviceRemoved.listen((path) {
      add(DeviceRemoved(path));
    });

    try {
      final btStatus = await _bluez!.getAdapterStatus();
      final devices = await _bluez!.getManagedDevices();

      emit(
        state.copyWith(
          status: BluetoothSettingsStatus.ready,
          bluetoothEnabled: btStatus.powered,
          adapterStatus: btStatus,
          devices: devices,
        ),
      );
    } catch (e) {
      debugPrint('Bluetooth init error: $e');
      emit(
        state.copyWith(
          status: BluetoothSettingsStatus.error,
          errorMessage: 'Failed to load Bluetooth settings: $e',
        ),
      );
    }
  }

  Future<void> _onToggleBluetooth(
    ToggleBluetooth event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    emit(state.copyWith(bluetoothEnabled: event.enabled));

    final success = await _bluez!.setAdapterPowered(event.enabled);
    if (success) {
      await Future.delayed(const Duration(milliseconds: 600));
      add(const RefreshDevices());
      if (event.enabled) {
        add(const StartBluetoothScan());
      }
    } else {
      emit(state.copyWith(bluetoothEnabled: !event.enabled));
    }
  }

  Future<void> _onStartBluetoothScan(
    StartBluetoothScan event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null || state.isScanning) return;

    emit(state.copyWith(isScanning: true));

    final success = await _bluez!.startDiscovery();
    if (success) {
      // Auto-stop discovery after 30 seconds (BlueZ best practice)
      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: 30), () {
        add(const StopBluetoothScan());
      });
    } else {
      emit(state.copyWith(isScanning: false));
    }
  }

  Future<void> _onStopBluetoothScan(
    StopBluetoothScan event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    _scanTimer?.cancel();
    _scanTimer = null;

    if (_bluez != null) {
      await _bluez!.stopDiscovery();
    }
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onRefreshDevices(
    RefreshDevices event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    final btStatus = await _bluez!.getAdapterStatus();
    final devices = await _bluez!.getManagedDevices();

    emit(
      state.copyWith(
        bluetoothEnabled: btStatus.powered,
        adapterStatus: btStatus,
        devices: devices,
      ),
    );
  }

  Future<void> _onPairDevice(
    PairDevice event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    final success = await _bluez!.pairDevice(event.devicePath);
    if (success) {
      add(const RefreshDevices());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to pair device'));
    }
  }

  Future<void> _onConnectDevice(
    ConnectDevice event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    final success = await _bluez!.connectDevice(event.devicePath);
    if (success) {
      add(const RefreshDevices());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to connect device'));
    }
  }

  Future<void> _onDisconnectDevice(
    DisconnectDevice event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    await _bluez!.disconnectDevice(event.devicePath);
    add(const RefreshDevices());
  }

  Future<void> _onRemoveDevice(
    RemoveDevice event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_bluez == null) return;

    final success = await _bluez!.removeDevice(event.devicePath);
    if (success) {
      add(const RefreshDevices());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to remove device'));
    }
  }

  // ─── Real-time signal handlers ──────────────────────────────────────────

  /// Called when BlueZ signals a new device was found during discovery
  Future<void> _onDeviceDiscovered(
    DeviceDiscovered event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    final existing = state.devices.any(
      (d) => d.devicePath == event.device.devicePath,
    );
    if (existing) {
      // Update the existing entry
      final updated = state.devices.map((d) {
        return d.devicePath == event.device.devicePath ? event.device : d;
      }).toList();
      emit(state.copyWith(devices: updated));
    } else {
      emit(state.copyWith(devices: [...state.devices, event.device]));
    }
  }

  /// Called when BlueZ signals a device object was removed
  Future<void> _onDeviceRemoved(
    DeviceRemoved event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    final updated = state.devices
        .where((d) => d.devicePath != event.devicePath)
        .toList();
    emit(state.copyWith(devices: updated));
  }

  @override
  Future<void> close() async {
    _scanTimer?.cancel();
    await _deviceAddedSub?.cancel();
    await _deviceRemovedSub?.cancel();
    await _bluez?.disconnect();
    return super.close();
  }
}
