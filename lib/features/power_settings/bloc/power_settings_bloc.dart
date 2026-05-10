import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'power_settings_event.dart';
import 'power_settings_state.dart';
import '../services/power_service.dart';
import '../services/aetheridle_service.dart';

class PowerSettingsBloc extends Bloc<PowerSettingsEvent, PowerSettingsState> {
  final PowerService _powerService;
  final AetheridleService _aetheridleService;

  StreamSubscription<Map<String, dynamic>>? _batterySubscription;
  StreamSubscription<String>? _profileSubscription;

  PowerSettingsBloc({
    PowerService? powerService,
    AetheridleService? aetheridleService,
  })  : _powerService = powerService ?? PowerService(),
        _aetheridleService = aetheridleService ?? AetheridleService(),
        super(const PowerSettingsState()) {
    on<LoadPowerSettings>(_onLoadPowerSettings);
    on<RefreshPowerInfo>(_onRefreshPowerInfo);
    on<SetPowerProfile>(_onSetPowerProfile);
    on<ProfileChangedExternally>(_onProfileChangedExternally);
    on<PerformPowerAction>(_onPerformPowerAction);
    on<SetIdleTimeouts>(_onSetIdleTimeouts);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحميل الإعدادات الأولية
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onLoadPowerSettings(
    LoadPowerSettings event,
    Emitter<PowerSettingsState> emit,
  ) async {
    emit(state.copyWith(status: PowerSettingsStatus.loading));

    // الاتصال بـ PowerService (UPower + PowerProfiles + logind)
    final connected = await _powerService.connect();
    if (!connected) {
      emit(state.copyWith(
        status: PowerSettingsStatus.error,
        errorMessage: 'Failed to connect to UPower / logind',
      ));
      return;
    }

    // الاشتراك في تغييرات البطارية
    _batterySubscription?.cancel();
    _batterySubscription =
        _powerService.batteryChangedStream.listen((data) {
      add(const RefreshPowerInfo());
    });

    // الاشتراك في تغييرات بروفايل الأداء
    _profileSubscription?.cancel();
    _profileSubscription =
        _powerService.profileChangedStream.listen((profile) {
      add(ProfileChangedExternally(profile));
    });

    try {
      // بيانات البطارية من UPower
      final batteryInfo = await _powerService.getBatteryInfo();

      // بروفايل الأداء من power-profiles-daemon
      final activeProfile = await _powerService.getActiveProfile();
      final profilesAvailable = _powerService.isProfilesAvailable;

      // مهلات الخمول من ملف config الخاص بـ aetheridle
      final timeouts = await _aetheridleService.getCurrentTimeoutsSeconds();

      emit(state.copyWith(
        status: PowerSettingsStatus.loaded,
        batteryLevel: batteryInfo['percentage'] as double,
        isCharging: batteryInfo['charging'] as bool,
        activePowerProfile: activeProfile,
        isProfilesAvailable: profilesAvailable,
        dimTimeout: timeouts['dim'] ?? 0,
        blankTimeout: timeouts['blank'] ?? 0,
        suspendTimeout: timeouts['suspend'] ?? 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PowerSettingsStatus.error,
        errorMessage: 'Failed to load power settings: $e',
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحديث البطارية
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRefreshPowerInfo(
    RefreshPowerInfo event,
    Emitter<PowerSettingsState> emit,
  ) async {
    try {
      final batteryInfo = await _powerService.getBatteryInfo();
      emit(state.copyWith(
        batteryLevel: batteryInfo['percentage'] as double,
        isCharging: batteryInfo['charging'] as bool,
      ));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // بروفايلات الأداء
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSetPowerProfile(
    SetPowerProfile event,
    Emitter<PowerSettingsState> emit,
  ) async {
    // optimistic update
    emit(state.copyWith(activePowerProfile: event.profile));
    await _powerService.setActiveProfile(event.profile);
  }

  Future<void> _onProfileChangedExternally(
    ProfileChangedExternally event,
    Emitter<PowerSettingsState> emit,
  ) async {
    emit(state.copyWith(activePowerProfile: event.profile));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // أوامر الطاقة (logind)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onPerformPowerAction(
    PerformPowerAction event,
    Emitter<PowerSettingsState> emit,
  ) async {
    switch (event.action) {
      case 'shutdown':
        await _powerService.shutdown();
        break;
      case 'reboot':
        await _powerService.reboot();
        break;
      case 'suspend':
        await _powerService.suspend();
        break;
      case 'logout':
        await _powerService.logout();
        break;
      case 'lock':
        await _powerService.lockScreen();
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // مهلات الخمول (aetheridle)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSetIdleTimeouts(
    SetIdleTimeouts event,
    Emitter<PowerSettingsState> emit,
  ) async {
    // optimistic update في الـ UI
    emit(state.copyWith(
      dimTimeout: event.dim,
      blankTimeout: event.blank,
      suspendTimeout: event.suspend,
    ));

    // كتابة الـ config وإعادة تشغيل aetheridle
    await _aetheridleService.setAllTimeouts(
      dimSeconds: event.dim,
      blankSeconds: event.blank,
      suspendSeconds: event.suspend,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _batterySubscription?.cancel();
    _profileSubscription?.cancel();
    _powerService.disconnect();
    _aetheridleService.dispose();
    return super.close();
  }
}
