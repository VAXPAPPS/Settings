import 'package:equatable/equatable.dart';
import 'package:settings/core/services/network_service.dart';

enum EthernetSettingsStatus { initial, loading, loaded, error }

class EthernetSettingsState extends Equatable {
  final EthernetSettingsStatus status;
  final List<EthernetInterface> interfaces;
  final String? errorMessage;

  const EthernetSettingsState({
    this.status = EthernetSettingsStatus.initial,
    this.interfaces = const [],
    this.errorMessage,
  });

  EthernetSettingsState copyWith({
    EthernetSettingsStatus? status,
    List<EthernetInterface>? interfaces,
    String? errorMessage,
  }) {
    return EthernetSettingsState(
      status: status ?? this.status,
      interfaces: interfaces ?? this.interfaces,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, interfaces, errorMessage];
}
