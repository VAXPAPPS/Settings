import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:antidote/core/services/audio_service.dart';
import 'audio_settings_event.dart';
import 'audio_settings_state.dart';

class AudioSettingsBloc extends Bloc<AudioSettingsEvent, AudioSettingsState> {
  AudioService? _audioService;

  // Cache
  List<AudioDevice> _sinksCache = [];
  List<AudioDevice> _sourcesCache = [];
  List<AudioCard> _cardsCache = [];

  AudioSettingsBloc() : super(const AudioSettingsState()) {
    on<LoadAudioSettings>(_onLoadAudioSettings);
    on<RefreshAudioInfo>(_onRefreshAudioInfo);
    on<SetOutputDevice>(_onSetOutputDevice);
    on<SetOutputVolume>(_onSetOutputVolume);
    on<ToggleOutputMute>(_onToggleOutputMute);
    on<SetInputDevice>(_onSetInputDevice);
    on<SetInputVolume>(_onSetInputVolume);
    on<ToggleInputMute>(_onToggleInputMute);
    on<SetAppVolume>(_onSetAppVolume);
    on<ToggleAppMute>(_onToggleAppMute);
    on<SetOveramplification>(_onSetOveramplification);
    on<SelectCard>(_onSelectCard);
    on<SetProfile>(_onSetProfile);
  }

  Future<void> _onLoadAudioSettings(
    LoadAudioSettings event,
    Emitter<AudioSettingsState> emit,
  ) async {
    emit(state.copyWith(status: AudioSettingsStatus.loading));

    _audioService = AudioService();
    try {
      await _audioService!.connect();
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioSettingsStatus.error,
          errorMessage: 'Failed to connect to Audio Daemon',
        ),
      );
      return;
    }

    try {
      final volume = await _audioService!.getVolume();
      final muted = await _audioService!.getMuted();
      final micVolume = await _audioService!.getMicVolume();
      final micMuted = await _audioService!.getMicMuted();
      final overamp = await _audioService!.getOveramplification();
      final maxVolume = await _audioService!.getMaxVolume();

      _sinksCache = await _audioService!.getSinks();
      _sourcesCache = await _audioService!.getSources();
      _cardsCache = await _audioService!.getCards();

      final appStreams = await _audioService!.getAppStreams();

      AudioDevice? selectedSink;
      AudioDevice? selectedSource;

      if (_sinksCache.isNotEmpty) {
        selectedSink = _sinksCache.firstWhere(
          (d) => d.isDefault,
          orElse: () => _sinksCache.first,
        );
      }

      if (_sourcesCache.isNotEmpty) {
        selectedSource = _sourcesCache.firstWhere(
          (d) => d.isDefault,
          orElse: () => _sourcesCache.first,
        );
      }

      emit(
        state.copyWith(
          status: AudioSettingsStatus.loaded,
          outputDevices: _sinksCache,
          selectedOutputDevice: selectedSink,
          outputVolume: volume,
          outputMuted: muted,
          inputDevices: _sourcesCache,
          selectedInputDevice: selectedSource,
          inputVolume: micVolume,
          inputMuted: micMuted,
          appStreams: appStreams,
          overamplification: overamp,
          maxVolume: maxVolume,
          cards: _cardsCache,
        ),
      );
    } catch (e) {
      debugPrint('Audio init error: $e');
      emit(
        state.copyWith(
          status: AudioSettingsStatus.error,
          errorMessage: 'Failed to load audio settings: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAudioInfo(
    RefreshAudioInfo event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    try {
      final volume = await _audioService!.getVolume();
      final muted = await _audioService!.getMuted();
      final micVolume = await _audioService!.getMicVolume();
      final micMuted = await _audioService!.getMicMuted();
      final appStreams = await _audioService!.getAppStreams();

      emit(
        state.copyWith(
          outputVolume: volume,
          outputMuted: muted,
          inputVolume: micVolume,
          inputMuted: micMuted,
          appStreams: appStreams,
        ),
      );
    } catch (e) {
      debugPrint('Audio refresh error: $e');
    }
  }

  Future<void> _onSetOutputDevice(
    SetOutputDevice event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(selectedOutputDevice: event.device));
    await _audioService!.setDefaultSink(event.device.name);
  }

  Future<void> _onSetOutputVolume(
    SetOutputVolume event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(outputVolume: event.volume));
    await _audioService!.setVolume(event.volume);
  }

  Future<void> _onToggleOutputMute(
    ToggleOutputMute event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    final newMuted = !state.outputMuted;
    emit(state.copyWith(outputMuted: newMuted));
    await _audioService!.setMuted(newMuted);
  }

  Future<void> _onSetInputDevice(
    SetInputDevice event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(selectedInputDevice: event.device));
    await _audioService!.setDefaultSource(event.device.name);
  }

  Future<void> _onSetInputVolume(
    SetInputVolume event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(inputVolume: event.volume));
    await _audioService!.setMicVolume(event.volume);
  }

  Future<void> _onToggleInputMute(
    ToggleInputMute event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    final newMuted = !state.inputMuted;
    emit(state.copyWith(inputMuted: newMuted));
    await _audioService!.setMicMuted(newMuted);
  }

  Future<void> _onSetAppVolume(
    SetAppVolume event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    await _audioService!.setAppVolume(event.appIndex, event.volume);
    add(const RefreshAudioInfo());
  }

  Future<void> _onToggleAppMute(
    ToggleAppMute event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    final app = state.appStreams.firstWhere((a) => a.index == event.appIndex);
    await _audioService!.setAppMuted(event.appIndex, !app.muted);
    add(const RefreshAudioInfo());
  }

  Future<void> _onSetOveramplification(
    SetOveramplification event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(overamplification: event.enabled));
    await _audioService!.setOveramplification(event.enabled);

    final maxVolume = await _audioService!.getMaxVolume();
    
    // Clamp the volume to the new max volume if we disabled overamplification
    // and the volume happens to be higher than the new max.
    int newVolume = state.outputVolume;
    if (!event.enabled && state.outputVolume > maxVolume) {
      newVolume = maxVolume;
      await _audioService!.setVolume(maxVolume);
    }
    
    emit(state.copyWith(
      maxVolume: maxVolume,
      outputVolume: newVolume,
    ));
  }

  Future<void> _onSelectCard(
    SelectCard event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null) return;

    emit(state.copyWith(selectedCardName: event.cardName));

    final profiles = await _audioService!.getProfiles(event.cardName);
    emit(state.copyWith(profiles: profiles));
  }

  Future<void> _onSetProfile(
    SetProfile event,
    Emitter<AudioSettingsState> emit,
  ) async {
    if (_audioService == null || state.selectedCardName == null) return;

    await _audioService!.setProfile(state.selectedCardName!, event.profileName);
  }

  @override
  Future<void> close() {
    _audioService?.dispose();
    return super.close();
  }
}
