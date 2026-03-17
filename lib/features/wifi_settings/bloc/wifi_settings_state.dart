import 'package:equatable/equatable.dart';
import 'package:settings/core/services/network_service.dart';

enum WiFiSettingsStatus { initial, loading, loaded, connecting, error }

class WiFiSettingsState extends Equatable {
  final WiFiSettingsStatus status;
  final bool wifiEnabled;
  final bool isScanning;
  final WiFiStatus? connectionStatus;
  final List<WiFiNetwork> networks;
  final List<String> savedNetworks;
  final String? connectingTo;
  final WiFiNetwork? passwordRequiredFor;
  final String? errorMessage;

  const WiFiSettingsState({
    this.status = WiFiSettingsStatus.initial,
    this.wifiEnabled = false,
    this.isScanning = false,
    this.connectionStatus,
    this.networks = const [],
    this.savedNetworks = const [],
    this.connectingTo,
    this.passwordRequiredFor,
    this.errorMessage,
  });

  WiFiNetwork? get connectedNetwork {
    try {
      return networks.firstWhere((n) => n.connected);
    } catch (_) {
      return null;
    }
  }

  WiFiSettingsState copyWith({
    WiFiSettingsStatus? status,
    bool? wifiEnabled,
    bool? isScanning,
    WiFiStatus? connectionStatus,
    List<WiFiNetwork>? networks,
    List<String>? savedNetworks,
    String? connectingTo,
    WiFiNetwork? passwordRequiredFor,
    String? errorMessage,
  }) {
    return WiFiSettingsState(
      status: status ?? this.status,
      wifiEnabled: wifiEnabled ?? this.wifiEnabled,
      isScanning: isScanning ?? this.isScanning,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      networks: networks ?? this.networks,
      savedNetworks: savedNetworks ?? this.savedNetworks,
      connectingTo: connectingTo,
      passwordRequiredFor: passwordRequiredFor,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    wifiEnabled,
    isScanning,
    connectionStatus,
    networks,
    savedNetworks,
    connectingTo,
    passwordRequiredFor,
    errorMessage,
  ];
}
