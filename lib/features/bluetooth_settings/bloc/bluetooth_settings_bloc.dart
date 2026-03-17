import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settings/core/services/network_service.dart';
import 'bluetooth_settings_event.dart';
import 'bluetooth_settings_state.dart';

class BluetoothSettingsBloc
    extends Bloc<BluetoothSettingsEvent, BluetoothSettingsState> {
  NetworkService? _networkService;
  Timer? _scanTimer;

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
  }

  Future<void> _onInitializeBluetooth(
    InitializeBluetooth event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    emit(state.copyWith(status: BluetoothSettingsStatus.loading));

    _networkService = NetworkService();
    final connected = await _networkService!.connect().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(
        state.copyWith(
          status: BluetoothSettingsStatus.error,
          errorMessage: 'Failed to connect to Network Daemon',
        ),
      );
      return;
    }

    try {
      final btStatus = await _networkService!.getBluetoothStatus();
      final devices = await _networkService!.getBluetoothDevices();

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
    if (_networkService == null) return;

    emit(state.copyWith(bluetoothEnabled: event.enabled));

    final success = await _networkService!.setBluetoothPowered(event.enabled);
    if (success) {
      await Future.delayed(const Duration(milliseconds: 500));
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
    if (_networkService == null || state.isScanning) return;

    emit(state.copyWith(isScanning: true));

    final success = await _networkService!.startBluetoothScan();
    if (success) {
      // Auto-stop scan after 10 seconds
      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: 10), () {
        add(const StopBluetoothScan());
      });

      // Refresh devices periodically during scan
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!state.isScanning) {
          timer.cancel();
          return;
        }
        add(const RefreshDevices());
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

    if (_networkService != null) {
      await _networkService!.stopBluetoothScan();
    }
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onRefreshDevices(
    RefreshDevices event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_networkService == null) return;

    final btStatus = await _networkService!.getBluetoothStatus();
    final devices = await _networkService!.getBluetoothDevices();

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
    if (_networkService == null) return;

    final success = await _networkService!.pairDevice(event.address);
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
    if (_networkService == null) return;

    final success = await _networkService!.connectDevice(event.address);
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
    if (_networkService == null) return;

    await _networkService!.disconnectDevice(event.address);
    add(const RefreshDevices());
  }

  Future<void> _onRemoveDevice(
    RemoveDevice event,
    Emitter<BluetoothSettingsState> emit,
  ) async {
    if (_networkService == null) return;

    final success = await _networkService!.removeDevice(event.address);
    if (success) {
      add(const RefreshDevices());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to remove device'));
    }
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    _networkService?.disconnect();
    return super.close();
  }
}
