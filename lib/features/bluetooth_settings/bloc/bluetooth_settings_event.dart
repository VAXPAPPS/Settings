import 'package:equatable/equatable.dart';

// Re-export Bluetooth models from network service
export 'package:settings/core/services/network_service.dart'
    show BluetoothDevice, BluetoothStatus;

abstract class BluetoothSettingsEvent extends Equatable {
  const BluetoothSettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeBluetooth extends BluetoothSettingsEvent {
  const InitializeBluetooth();
}

class ToggleBluetooth extends BluetoothSettingsEvent {
  final bool enabled;
  const ToggleBluetooth(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class StartBluetoothScan extends BluetoothSettingsEvent {
  const StartBluetoothScan();
}

class StopBluetoothScan extends BluetoothSettingsEvent {
  const StopBluetoothScan();
}

class RefreshDevices extends BluetoothSettingsEvent {
  const RefreshDevices();
}

class PairDevice extends BluetoothSettingsEvent {
  final String address;
  const PairDevice(this.address);

  @override
  List<Object?> get props => [address];
}

class ConnectDevice extends BluetoothSettingsEvent {
  final String address;
  const ConnectDevice(this.address);

  @override
  List<Object?> get props => [address];
}

class DisconnectDevice extends BluetoothSettingsEvent {
  final String address;
  const DisconnectDevice(this.address);

  @override
  List<Object?> get props => [address];
}

class RemoveDevice extends BluetoothSettingsEvent {
  final String address;
  const RemoveDevice(this.address);

  @override
  List<Object?> get props => [address];
}
