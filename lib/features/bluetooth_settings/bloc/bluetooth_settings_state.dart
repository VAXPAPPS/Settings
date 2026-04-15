import 'package:equatable/equatable.dart';
import 'package:settings/core/services/bluez_service.dart';

enum BluetoothSettingsStatus { initial, loading, ready, scanning, error }

class BluetoothSettingsState extends Equatable {
  final BluetoothSettingsStatus status;
  final bool bluetoothEnabled;
  final bool isScanning;
  final BluetoothStatus? adapterStatus;
  final List<BluetoothDevice> devices;
  final String? errorMessage;

  const BluetoothSettingsState({
    this.status = BluetoothSettingsStatus.initial,
    this.bluetoothEnabled = false,
    this.isScanning = false,
    this.adapterStatus,
    this.devices = const [],
    this.errorMessage,
  });

  List<BluetoothDevice> get pairedDevices =>
      devices.where((d) => d.paired).toList();

  List<BluetoothDevice> get availableDevices =>
      devices.where((d) => !d.paired).toList();

  BluetoothSettingsState copyWith({
    BluetoothSettingsStatus? status,
    bool? bluetoothEnabled,
    bool? isScanning,
    BluetoothStatus? adapterStatus,
    List<BluetoothDevice>? devices,
    String? errorMessage,
  }) {
    return BluetoothSettingsState(
      status: status ?? this.status,
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      isScanning: isScanning ?? this.isScanning,
      adapterStatus: adapterStatus ?? this.adapterStatus,
      devices: devices ?? this.devices,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bluetoothEnabled,
    isScanning,
    adapterStatus,
    devices,
    errorMessage,
  ];
}
