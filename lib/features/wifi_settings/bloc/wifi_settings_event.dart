import 'package:equatable/equatable.dart';
import 'package:settings/core/services/network_service.dart';

// Re-export WiFi models from network service
export 'package:settings/core/services/network_service.dart'
    show WiFiNetwork, WiFiStatus, ConnectionDetails;

abstract class WiFiSettingsEvent extends Equatable {
  const WiFiSettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeWiFi extends WiFiSettingsEvent {
  const InitializeWiFi();
}

class ToggleWiFi extends WiFiSettingsEvent {
  final bool enabled;
  const ToggleWiFi(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class RefreshNetworks extends WiFiSettingsEvent {
  const RefreshNetworks();
}

class ConnectToNetwork extends WiFiSettingsEvent {
  final WiFiNetwork network;
  final String password;
  const ConnectToNetwork(this.network, this.password);

  @override
  List<Object?> get props => [network, password];
}

class DisconnectNetwork extends WiFiSettingsEvent {
  const DisconnectNetwork();
}

class ForgetNetwork extends WiFiSettingsEvent {
  final String ssid;
  const ForgetNetwork(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class SetAutoConnect extends WiFiSettingsEvent {
  final String ssid;
  final bool autoConnect;
  const SetAutoConnect(this.ssid, this.autoConnect);

  @override
  List<Object?> get props => [ssid, autoConnect];
}

class SetStaticIP extends WiFiSettingsEvent {
  final String ssid;
  final String ip;
  final String gateway;
  final String subnet;
  final String dns;
  const SetStaticIP(this.ssid, this.ip, this.gateway, this.subnet, this.dns);

  @override
  List<Object?> get props => [ssid, ip, gateway, subnet, dns];
}

class SetDHCP extends WiFiSettingsEvent {
  final String ssid;
  const SetDHCP(this.ssid);

  @override
  List<Object?> get props => [ssid];
}

class SetDNS extends WiFiSettingsEvent {
  final String ssid;
  final String dns1;
  final String dns2;
  const SetDNS(this.ssid, this.dns1, this.dns2);

  @override
  List<Object?> get props => [ssid, dns1, dns2];
}

class PasswordRequired extends WiFiSettingsEvent {
  final WiFiNetwork network;
  const PasswordRequired(this.network);

  @override
  List<Object?> get props => [network];
}
