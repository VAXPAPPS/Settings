import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settings/core/services/network_manager_service.dart';
import 'wifi_settings_event.dart';
import 'wifi_settings_state.dart';

class WiFiSettingsBloc extends Bloc<WiFiSettingsEvent, WiFiSettingsState> {
  NetworkManagerService? _nm;

  WiFiSettingsBloc() : super(const WiFiSettingsState()) {
    on<InitializeWiFi>(_onInitializeWiFi);
    on<ToggleWiFi>(_onToggleWiFi);
    on<RefreshNetworks>(_onRefreshNetworks);
    on<ConnectToNetwork>(_onConnectToNetwork);
    on<DisconnectNetwork>(_onDisconnectNetwork);
    on<ForgetNetwork>(_onForgetNetwork);
    on<SetAutoConnect>(_onSetAutoConnect);
    on<SetStaticIP>(_onSetStaticIP);
    on<SetDHCP>(_onSetDHCP);
    on<SetDNS>(_onSetDNS);
    on<PasswordRequired>(_onPasswordRequired);
  }

  Future<void> _onInitializeWiFi(
    InitializeWiFi event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    emit(state.copyWith(status: WiFiSettingsStatus.loading));

    _nm = NetworkManagerService();
    final connected = await _nm!.connect().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (!connected) {
      emit(
        state.copyWith(
          status: WiFiSettingsStatus.error,
          errorMessage: 'Failed to connect to NetworkManager (System D-Bus)',
        ),
      );
      return;
    }

    try {
      // Request a fresh scan immediately
      await _nm!.requestScan();

      final wifiEnabled = await _nm!.isWifiEnabled();
      final wifiStatus = await _nm!.getWifiStatus();
      final networks = await _nm!.getWifiNetworks();
      final savedNetworks = await _nm!.getSavedNetworks();

      emit(
        state.copyWith(
          status: WiFiSettingsStatus.loaded,
          wifiEnabled: wifiEnabled,
          connectionStatus: wifiStatus,
          networks: networks,
          savedNetworks: savedNetworks,
        ),
      );
    } catch (e) {
      debugPrint('WiFi init error: $e');
      emit(
        state.copyWith(
          status: WiFiSettingsStatus.error,
          errorMessage: 'Failed to load WiFi settings: $e',
        ),
      );
    }
  }

  Future<void> _onToggleWiFi(
    ToggleWiFi event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;

    emit(state.copyWith(wifiEnabled: event.enabled));

    final success = await _nm!.setWifiEnabled(event.enabled);
    if (success) {
      await Future.delayed(const Duration(milliseconds: 800));
      add(const RefreshNetworks());
    } else {
      emit(state.copyWith(wifiEnabled: !event.enabled));
    }
  }

  Future<void> _onRefreshNetworks(
    RefreshNetworks event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;

    emit(state.copyWith(isScanning: true));

    // Request a new scan then wait briefly for results
    await _nm!.requestScan();
    await Future.delayed(const Duration(seconds: 2));

    final wifiStatus = await _nm!.getWifiStatus();
    final networks = await _nm!.getWifiNetworks();
    final savedNetworks = await _nm!.getSavedNetworks();
    final wifiEnabled = await _nm!.isWifiEnabled();

    emit(
      state.copyWith(
        isScanning: false,
        wifiEnabled: wifiEnabled,
        connectionStatus: wifiStatus,
        networks: networks,
        savedNetworks: savedNetworks,
      ),
    );
  }

  Future<void> _onConnectToNetwork(
    ConnectToNetwork event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;

    // If secured and no password provided, ask for it
    if (event.network.secured && event.password.isEmpty) {
      emit(state.copyWith(passwordRequiredFor: event.network));
      return;
    }

    emit(
      state.copyWith(
        status: WiFiSettingsStatus.connecting,
        connectingTo: event.network.ssid,
      ),
    );

    final success = await _nm!.wifiConnect(
      event.network.ssid,
      event.password,
    );

    if (success) {
      await Future.delayed(const Duration(seconds: 2));
      add(const RefreshNetworks());
      emit(state.copyWith(status: WiFiSettingsStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: WiFiSettingsStatus.error,
          errorMessage: 'Failed to connect to ${event.network.ssid}',
        ),
      );
    }
  }

  Future<void> _onDisconnectNetwork(
    DisconnectNetwork event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;

    final success = await _nm!.wifiDisconnect();
    if (success) {
      add(const RefreshNetworks());
    }
  }

  Future<void> _onForgetNetwork(
    ForgetNetwork event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;

    final success = await _nm!.forgetNetwork(event.ssid);
    if (success) {
      add(const RefreshNetworks());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to forget ${event.ssid}'));
    }
  }

  Future<void> _onSetAutoConnect(
    SetAutoConnect event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;
    await _nm!.setAutoConnect(event.ssid, event.autoConnect);
  }

  Future<void> _onSetStaticIP(
    SetStaticIP event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;
    await _nm!.setStaticIP(
      event.ssid,
      event.ip,
      event.gateway,
      event.subnet,
      event.dns,
    );
  }

  Future<void> _onSetDHCP(
    SetDHCP event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;
    await _nm!.setDHCP(event.ssid);
  }

  Future<void> _onSetDNS(
    SetDNS event,
    Emitter<WiFiSettingsState> emit,
  ) async {
    if (_nm == null) return;
    await _nm!.setDNS(event.ssid, event.dns1, event.dns2);
  }

  void _onPasswordRequired(
    PasswordRequired event,
    Emitter<WiFiSettingsState> emit,
  ) {
    emit(state.copyWith(passwordRequiredFor: event.network));
  }

  @override
  Future<void> close() {
    _nm?.disconnect();
    return super.close();
  }
}
