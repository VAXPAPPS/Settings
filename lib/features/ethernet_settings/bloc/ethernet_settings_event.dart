import 'package:equatable/equatable.dart';

// Re-export Ethernet models from NetworkManager service
export 'package:settings/core/services/network_manager_service.dart'
    show EthernetInterface;

abstract class EthernetSettingsEvent extends Equatable {
  const EthernetSettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeEthernet extends EthernetSettingsEvent {
  const InitializeEthernet();
}

class RefreshInterfaces extends EthernetSettingsEvent {
  const RefreshInterfaces();
}

class EnableInterface extends EthernetSettingsEvent {
  final String name;
  const EnableInterface(this.name);

  @override
  List<Object?> get props => [name];
}

class DisableInterface extends EthernetSettingsEvent {
  final String name;
  const DisableInterface(this.name);

  @override
  List<Object?> get props => [name];
}
