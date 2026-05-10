import 'package:equatable/equatable.dart';

enum PowerSettingsStatus { initial, loading, loaded, error }

class PowerSettingsState extends Equatable {
  final PowerSettingsStatus status;

  // ── بيانات البطارية (من UPower)
  final double batteryLevel;
  final bool isCharging;

  // ── بروفايل الأداء (من power-profiles-daemon)
  final String activePowerProfile;
  final bool isProfilesAvailable;

  // ── مهلات الخمول (من aetheridle config)
  final int dimTimeout;     // بالثواني، 0 = معطّل
  final int blankTimeout;   // بالثواني، 0 = معطّل
  final int suspendTimeout; // بالثواني، 0 = معطّل

  final String? errorMessage;

  const PowerSettingsState({
    this.status = PowerSettingsStatus.initial,
    this.batteryLevel = 0.0,
    this.isCharging = false,
    this.activePowerProfile = 'balanced',
    this.isProfilesAvailable = false,
    this.dimTimeout = 0,
    this.blankTimeout = 0,
    this.suspendTimeout = 0,
    this.errorMessage,
  });

  PowerSettingsState copyWith({
    PowerSettingsStatus? status,
    double? batteryLevel,
    bool? isCharging,
    String? activePowerProfile,
    bool? isProfilesAvailable,
    int? dimTimeout,
    int? blankTimeout,
    int? suspendTimeout,
    String? errorMessage,
  }) {
    return PowerSettingsState(
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      activePowerProfile: activePowerProfile ?? this.activePowerProfile,
      isProfilesAvailable: isProfilesAvailable ?? this.isProfilesAvailable,
      dimTimeout: dimTimeout ?? this.dimTimeout,
      blankTimeout: blankTimeout ?? this.blankTimeout,
      suspendTimeout: suspendTimeout ?? this.suspendTimeout,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    batteryLevel,
    isCharging,
    activePowerProfile,
    isProfilesAvailable,
    dimTimeout,
    blankTimeout,
    suspendTimeout,
    errorMessage,
  ];
}
