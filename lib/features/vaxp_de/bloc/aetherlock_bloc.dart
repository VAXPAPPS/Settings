import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/aetherlock_config.dart';
import 'package:settings/features/vaxp_de/services/aetherlock_service.dart';

// Events
abstract class AetherLockEvent extends Equatable {
  const AetherLockEvent();

  @override
  List<Object> get props => [];
}

class LoadAetherLockConfig extends AetherLockEvent {}

class UpdateAetherLockConfig extends AetherLockEvent {
  final AetherLockConfig config;

  const UpdateAetherLockConfig(this.config);

  @override
  List<Object> get props => [config];
}

class RestoreDefaultAetherLockConfig extends AetherLockEvent {}

// States
abstract class AetherLockState extends Equatable {
  const AetherLockState();

  @override
  List<Object> get props => [];
}

class AetherLockInitial extends AetherLockState {}

class AetherLockLoading extends AetherLockState {}

class AetherLockLoaded extends AetherLockState {
  final AetherLockConfig config;

  const AetherLockLoaded({required this.config});

  @override
  List<Object> get props => [config];
}

class AetherLockError extends AetherLockState {
  final String message;

  const AetherLockError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AetherLockBloc extends Bloc<AetherLockEvent, AetherLockState> {
  final AetherLockService _service;

  AetherLockBloc({AetherLockService? service}) 
      : _service = service ?? AetherLockService(),
        super(AetherLockInitial()) {
    on<LoadAetherLockConfig>(_onLoad);
    on<UpdateAetherLockConfig>(_onUpdate);
    on<RestoreDefaultAetherLockConfig>(_onRestore);
  }

  Future<void> _onLoad(LoadAetherLockConfig event, Emitter<AetherLockState> emit) async {
    emit(AetherLockLoading());
    try {
      final config = await _service.getConfig();
      emit(AetherLockLoaded(config: config));
    } catch (e) {
      emit(AetherLockError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateAetherLockConfig event, Emitter<AetherLockState> emit) async {
    try {
      await _service.saveConfig(event.config);
      emit(AetherLockLoaded(config: event.config));
    } catch (e) {
      emit(AetherLockError(e.toString()));
    }
  }

  Future<void> _onRestore(RestoreDefaultAetherLockConfig event, Emitter<AetherLockState> emit) async {
    try {
      const defaultConfig = AetherLockConfig();
      await _service.saveConfig(defaultConfig);
      emit(const AetherLockLoaded(config: defaultConfig));
    } catch (e) {
      emit(AetherLockError(e.toString()));
    }
  }
}
