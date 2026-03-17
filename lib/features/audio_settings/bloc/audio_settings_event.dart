import 'package:equatable/equatable.dart';
import 'package:settings/core/services/audio_service.dart';

abstract class AudioSettingsEvent extends Equatable {
  const AudioSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAudioSettings extends AudioSettingsEvent {
  const LoadAudioSettings();
}

class RefreshAudioInfo extends AudioSettingsEvent {
  const RefreshAudioInfo();
}

// Output
class SetOutputDevice extends AudioSettingsEvent {
  final AudioDevice device;
  const SetOutputDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class SetOutputVolume extends AudioSettingsEvent {
  final int volume;
  const SetOutputVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ToggleOutputMute extends AudioSettingsEvent {
  const ToggleOutputMute();
}

// Input
class SetInputDevice extends AudioSettingsEvent {
  final AudioDevice device;
  const SetInputDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class SetInputVolume extends AudioSettingsEvent {
  final int volume;
  const SetInputVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ToggleInputMute extends AudioSettingsEvent {
  const ToggleInputMute();
}

// App Streams
class SetAppVolume extends AudioSettingsEvent {
  final int appIndex;
  final int volume;
  const SetAppVolume(this.appIndex, this.volume);

  @override
  List<Object?> get props => [appIndex, volume];
}

class ToggleAppMute extends AudioSettingsEvent {
  final int appIndex;
  const ToggleAppMute(this.appIndex);

  @override
  List<Object?> get props => [appIndex];
}

// Settings
class SetOveramplification extends AudioSettingsEvent {
  final bool enabled;
  const SetOveramplification(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

// Profiles
class SelectCard extends AudioSettingsEvent {
  final String cardName;
  const SelectCard(this.cardName);

  @override
  List<Object?> get props => [cardName];
}

class SetProfile extends AudioSettingsEvent {
  final String profileName;
  const SetProfile(this.profileName);

  @override
  List<Object?> get props => [profileName];
}
