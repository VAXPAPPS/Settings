import 'package:equatable/equatable.dart';
import 'package:settings/core/services/audio_service.dart';

enum AudioSettingsStatus { initial, loading, loaded, error }

class AudioSettingsState extends Equatable {
  final AudioSettingsStatus status;

  // Output
  final List<AudioDevice> outputDevices;
  final AudioDevice? selectedOutputDevice;
  final int outputVolume;
  final bool outputMuted;

  // Input
  final List<AudioDevice> inputDevices;
  final AudioDevice? selectedInputDevice;
  final int inputVolume;
  final bool inputMuted;

  // App Streams
  final List<AppStream> appStreams;

  // Settings
  final bool overamplification;
  final int maxVolume;

  // Cards & Profiles
  final List<AudioCard> cards;
  final String? selectedCardName;
  final List<AudioProfile> profiles;

  final String? errorMessage;

  const AudioSettingsState({
    this.status = AudioSettingsStatus.initial,
    this.outputDevices = const [],
    this.selectedOutputDevice,
    this.outputVolume = 100,
    this.outputMuted = false,
    this.inputDevices = const [],
    this.selectedInputDevice,
    this.inputVolume = 100,
    this.inputMuted = false,
    this.appStreams = const [],
    this.overamplification = false,
    this.maxVolume = 100,
    this.cards = const [],
    this.selectedCardName,
    this.profiles = const [],
    this.errorMessage,
  });

  AudioSettingsState copyWith({
    AudioSettingsStatus? status,
    List<AudioDevice>? outputDevices,
    AudioDevice? selectedOutputDevice,
    int? outputVolume,
    bool? outputMuted,
    List<AudioDevice>? inputDevices,
    AudioDevice? selectedInputDevice,
    int? inputVolume,
    bool? inputMuted,
    List<AppStream>? appStreams,
    bool? overamplification,
    int? maxVolume,
    List<AudioCard>? cards,
    String? selectedCardName,
    List<AudioProfile>? profiles,
    String? errorMessage,
  }) {
    return AudioSettingsState(
      status: status ?? this.status,
      outputDevices: outputDevices ?? this.outputDevices,
      selectedOutputDevice: selectedOutputDevice ?? this.selectedOutputDevice,
      outputVolume: outputVolume ?? this.outputVolume,
      outputMuted: outputMuted ?? this.outputMuted,
      inputDevices: inputDevices ?? this.inputDevices,
      selectedInputDevice: selectedInputDevice ?? this.selectedInputDevice,
      inputVolume: inputVolume ?? this.inputVolume,
      inputMuted: inputMuted ?? this.inputMuted,
      appStreams: appStreams ?? this.appStreams,
      overamplification: overamplification ?? this.overamplification,
      maxVolume: maxVolume ?? this.maxVolume,
      cards: cards ?? this.cards,
      selectedCardName: selectedCardName ?? this.selectedCardName,
      profiles: profiles ?? this.profiles,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    outputDevices,
    selectedOutputDevice,
    outputVolume,
    outputMuted,
    inputDevices,
    selectedInputDevice,
    inputVolume,
    inputMuted,
    appStreams,
    overamplification,
    maxVolume,
    cards,
    selectedCardName,
    profiles,
    errorMessage,
  ];
}
