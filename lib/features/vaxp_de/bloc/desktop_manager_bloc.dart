import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/desktop_manager_config.dart';
import 'package:settings/features/vaxp_de/services/desktop_manager_service.dart';

// Events
abstract class DesktopManagerEvent extends Equatable {
  const DesktopManagerEvent();

  @override
  List<Object> get props => [];
}

class LoadDesktopManagerConfig extends DesktopManagerEvent {}

class UpdateDesktopManagerConfig extends DesktopManagerEvent {
  final DesktopManagerConfig config;

  const UpdateDesktopManagerConfig(this.config);

  @override
  List<Object> get props => [config];
}

class RestoreDefaultDesktopManagerConfig extends DesktopManagerEvent {}

// States
abstract class DesktopManagerState extends Equatable {
  const DesktopManagerState();

  @override
  List<Object> get props => [];
}

class DesktopManagerInitial extends DesktopManagerState {}

class DesktopManagerLoading extends DesktopManagerState {}

class DesktopManagerLoaded extends DesktopManagerState {
  final DesktopManagerConfig config;

  const DesktopManagerLoaded({required this.config});

  @override
  List<Object> get props => [config];
}

class DesktopManagerError extends DesktopManagerState {
  final String message;

  const DesktopManagerError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class DesktopManagerBloc extends Bloc<DesktopManagerEvent, DesktopManagerState> {
  final DesktopManagerService _service;

  DesktopManagerBloc({DesktopManagerService? service}) 
      : _service = service ?? DesktopManagerService(),
        super(DesktopManagerInitial()) {
    on<LoadDesktopManagerConfig>(_onLoad);
    on<UpdateDesktopManagerConfig>(_onUpdate);
    on<RestoreDefaultDesktopManagerConfig>(_onRestore);
  }

  Future<void> _onLoad(LoadDesktopManagerConfig event, Emitter<DesktopManagerState> emit) async {
    emit(DesktopManagerLoading());
    try {
      final config = await _service.getConfig();
      emit(DesktopManagerLoaded(config: config));
    } catch (e) {
      emit(DesktopManagerError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateDesktopManagerConfig event, Emitter<DesktopManagerState> emit) async {
    try {
      await _service.saveConfig(event.config);
      emit(DesktopManagerLoaded(config: event.config));
    } catch (e) {
      emit(DesktopManagerError(e.toString()));
    }
  }

  Future<void> _onRestore(RestoreDefaultDesktopManagerConfig event, Emitter<DesktopManagerState> emit) async {
    try {
      final currentState = state;
      List<String> availableWidgets = [];
      if (currentState is DesktopManagerLoaded) {
        availableWidgets = currentState.config.availableWidgets;
      }
      
      final defaultConfig = DesktopManagerConfig(availableWidgets: availableWidgets);
      await _service.saveConfig(defaultConfig);
      emit(DesktopManagerLoaded(config: defaultConfig));
    } catch (e) {
      emit(DesktopManagerError(e.toString()));
    }
  }
}
