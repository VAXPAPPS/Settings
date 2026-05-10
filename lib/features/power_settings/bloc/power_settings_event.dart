import 'package:equatable/equatable.dart';

abstract class PowerSettingsEvent extends Equatable {
  const PowerSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل الإعدادات الأولية من جميع الخدمات
class LoadPowerSettings extends PowerSettingsEvent {
  const LoadPowerSettings();
}

/// تحديث معلومات البطارية من UPower
class RefreshPowerInfo extends PowerSettingsEvent {
  const RefreshPowerInfo();
}

/// تغيير بروفايل الأداء عبر power-profiles-daemon
class SetPowerProfile extends PowerSettingsEvent {
  final String profile;

  const SetPowerProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// استقبال تغيير البروفايل من مصدر خارجي (إشارة PropertiesChanged)
class ProfileChangedExternally extends PowerSettingsEvent {
  final String profile;

  const ProfileChangedExternally(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// تنفيذ أمر طاقة (shutdown/reboot/suspend/logout/lock)
class PerformPowerAction extends PowerSettingsEvent {
  final String action;

  const PerformPowerAction(this.action);

  @override
  List<Object?> get props => [action];
}

/// ضبط مهلات الخمول عبر aetheridle
class SetIdleTimeouts extends PowerSettingsEvent {
  final int dim;     // بالثواني
  final int blank;   // بالثواني
  final int suspend; // بالثواني

  const SetIdleTimeouts({
    required this.dim,
    required this.blank,
    required this.suspend,
  });

  @override
  List<Object?> get props => [dim, blank, suspend];
}
