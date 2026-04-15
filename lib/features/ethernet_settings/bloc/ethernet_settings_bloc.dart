import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settings/core/services/network_manager_service.dart';
import 'ethernet_settings_event.dart';
import 'ethernet_settings_state.dart';

class EthernetSettingsBloc
    extends Bloc<EthernetSettingsEvent, EthernetSettingsState> {
  NetworkManagerService? _nm;

  EthernetSettingsBloc() : super(const EthernetSettingsState()) {
    on<InitializeEthernet>(_onInitializeEthernet);
    on<RefreshInterfaces>(_onRefreshInterfaces);
    on<EnableInterface>(_onEnableInterface);
    on<DisableInterface>(_onDisableInterface);
  }

  Future<void> _onInitializeEthernet(
    InitializeEthernet event,
    Emitter<EthernetSettingsState> emit,
  ) async {
    emit(state.copyWith(status: EthernetSettingsStatus.loading));

    _nm = NetworkManagerService();
    final connected = await _nm!.connect().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(
        state.copyWith(
          status: EthernetSettingsStatus.error,
          errorMessage: 'Failed to connect to NetworkManager (System D-Bus)',
        ),
      );
      return;
    }

    try {
      final interfaces = await _nm!.getEthernetInterfaces();
      emit(
        state.copyWith(
          status: EthernetSettingsStatus.loaded,
          interfaces: interfaces,
        ),
      );
    } catch (e) {
      debugPrint('Ethernet init error: $e');
      emit(
        state.copyWith(
          status: EthernetSettingsStatus.error,
          errorMessage: 'Failed to load Ethernet settings: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshInterfaces(
    RefreshInterfaces event,
    Emitter<EthernetSettingsState> emit,
  ) async {
    if (_nm == null) return;

    final interfaces = await _nm!.getEthernetInterfaces();
    emit(state.copyWith(interfaces: interfaces));
  }

  Future<void> _onEnableInterface(
    EnableInterface event,
    Emitter<EthernetSettingsState> emit,
  ) async {
    if (_nm == null) return;

    final success = await _nm!.enableEthernet(event.name);
    if (success) {
      // Wait briefly for NM to update connection state
      await Future.delayed(const Duration(milliseconds: 800));
      final interfaces = await _nm!.getEthernetInterfaces();
      emit(state.copyWith(interfaces: interfaces));
    } else {
      emit(state.copyWith(errorMessage: 'Failed to enable ${event.name}'));
    }
  }

  Future<void> _onDisableInterface(
    DisableInterface event,
    Emitter<EthernetSettingsState> emit,
  ) async {
    if (_nm == null) return;

    final success = await _nm!.disableEthernet(event.name);
    if (success) {
      await Future.delayed(const Duration(milliseconds: 200));
      final interfaces = await _nm!.getEthernetInterfaces();
      emit(state.copyWith(interfaces: interfaces));
    } else {
      emit(state.copyWith(errorMessage: 'Failed to disable ${event.name}'));
    }
  }

  @override
  Future<void> close() {
    _nm?.disconnect();
    return super.close();
  }
}
