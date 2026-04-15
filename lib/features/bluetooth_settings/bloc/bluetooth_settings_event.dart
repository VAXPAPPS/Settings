import 'package:dbus/dbus.dart';
import 'package:equatable/equatable.dart';
import 'package:settings/core/services/bluez_service.dart';

// Re-export Bluetooth models from BlueZ service
export 'package:settings/core/services/bluez_service.dart'
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

/// Pair a device identified by its BlueZ D-Bus object path
class PairDevice extends BluetoothSettingsEvent {
  final DBusObjectPath devicePath;
  const PairDevice(this.devicePath);

  @override
  List<Object?> get props => [devicePath];
}

/// Connect to a paired device identified by its BlueZ D-Bus object path
class ConnectDevice extends BluetoothSettingsEvent {
  final DBusObjectPath devicePath;
  const ConnectDevice(this.devicePath);

  @override
  List<Object?> get props => [devicePath];
}

/// Disconnect from a connected device
class DisconnectDevice extends BluetoothSettingsEvent {
  final DBusObjectPath devicePath;
  const DisconnectDevice(this.devicePath);

  @override
  List<Object?> get props => [devicePath];
}

/// Remove / unpair a device
class RemoveDevice extends BluetoothSettingsEvent {
  final DBusObjectPath devicePath;
  const RemoveDevice(this.devicePath);

  @override
  List<Object?> get props => [devicePath];
}

/// Emitted internally when BlueZ signals a new device during discovery
class DeviceDiscovered extends BluetoothSettingsEvent {
  final BluetoothDevice device;
  const DeviceDiscovered(this.device);

  @override
  List<Object?> get props => [device.devicePath];
}

/// Emitted internally when BlueZ signals a device was removed
class DeviceRemoved extends BluetoothSettingsEvent {
  final DBusObjectPath devicePath;
  const DeviceRemoved(this.devicePath);

  @override
  List<Object?> get props => [devicePath];
}
