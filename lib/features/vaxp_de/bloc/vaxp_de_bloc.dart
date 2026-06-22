import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/dock_config.dart';
import 'package:settings/features/vaxp_de/services/dock_service.dart';

// Events
abstract class VaxpDeEvent extends Equatable {
  const VaxpDeEvent();

  @override
  List<Object> get props => [];
}

class LoadDockConfig extends VaxpDeEvent {}

class UpdateDockConfig extends VaxpDeEvent {
  final DockConfig config;

  const UpdateDockConfig(this.config);

  @override
  List<Object> get props => [config];
}

class RestoreDefaultDockConfig extends VaxpDeEvent {}

// States
abstract class VaxpDeState extends Equatable {
  const VaxpDeState();

  @override
  List<Object> get props => [];
}

class VaxpDeInitial extends VaxpDeState {}

class VaxpDeLoading extends VaxpDeState {}

class VaxpDeLoaded extends VaxpDeState {
  final DockConfig dockConfig;

  const VaxpDeLoaded({required this.dockConfig});

  @override
  List<Object> get props => [dockConfig];
}

class VaxpDeError extends VaxpDeState {
  final String message;

  const VaxpDeError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class VaxpDeBloc extends Bloc<VaxpDeEvent, VaxpDeState> {
  final DockService _dockService;

  VaxpDeBloc({DockService? dockService}) 
      : _dockService = dockService ?? DockService(),
        super(VaxpDeInitial()) {
    on<LoadDockConfig>(_onLoadDockConfig);
    on<UpdateDockConfig>(_onUpdateDockConfig);
    on<RestoreDefaultDockConfig>(_onRestoreDefaultDockConfig);
  }

  Future<void> _onLoadDockConfig(LoadDockConfig event, Emitter<VaxpDeState> emit) async {
    emit(VaxpDeLoading());
    try {
      final config = await _dockService.getDockConfig();
      emit(VaxpDeLoaded(dockConfig: config));
    } catch (e) {
      emit(VaxpDeError(e.toString()));
    }
  }

  Future<void> _onUpdateDockConfig(UpdateDockConfig event, Emitter<VaxpDeState> emit) async {
    try {
      await _dockService.saveDockConfig(event.config);
      emit(VaxpDeLoaded(dockConfig: event.config));
    } catch (e) {
      emit(VaxpDeError(e.toString()));
    }
  }

  Future<void> _onRestoreDefaultDockConfig(RestoreDefaultDockConfig event, Emitter<VaxpDeState> emit) async {
    try {
      const defaultConfig = DockConfig();
      await _dockService.saveDockConfig(defaultConfig);
      emit(const VaxpDeLoaded(dockConfig: defaultConfig));
    } catch (e) {
      emit(VaxpDeError(e.toString()));
    }
  }
}
