import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/clipboard_config.dart';
import 'package:settings/features/vaxp_de/services/clipboard_service.dart';

abstract class ClipboardEvent extends Equatable {
  const ClipboardEvent();
  @override
  List<Object> get props => [];
}

class LoadClipboardConfig extends ClipboardEvent {}

class UpdateClipboardConfig extends ClipboardEvent {
  final ClipboardConfig config;
  const UpdateClipboardConfig(this.config);
  @override
  List<Object> get props => [config];
}

class RestoreDefaultClipboardConfig extends ClipboardEvent {}

abstract class ClipboardState extends Equatable {
  const ClipboardState();
  @override
  List<Object> get props => [];
}

class ClipboardInitial extends ClipboardState {}

class ClipboardLoading extends ClipboardState {}

class ClipboardLoaded extends ClipboardState {
  final ClipboardConfig config;
  const ClipboardLoaded({required this.config});
  @override
  List<Object> get props => [config];
}

class ClipboardError extends ClipboardState {
  final String message;
  const ClipboardError(this.message);
  @override
  List<Object> get props => [message];
}

class ClipboardBloc extends Bloc<ClipboardEvent, ClipboardState> {
  final ClipboardService _service;

  ClipboardBloc({ClipboardService? service}) 
      : _service = service ?? ClipboardService(),
        super(ClipboardInitial()) {
    on<LoadClipboardConfig>(_onLoad);
    on<UpdateClipboardConfig>(_onUpdate);
    on<RestoreDefaultClipboardConfig>(_onRestore);
  }

  Future<void> _onLoad(LoadClipboardConfig event, Emitter<ClipboardState> emit) async {
    emit(ClipboardLoading());
    try {
      final config = await _service.getConfig();
      emit(ClipboardLoaded(config: config));
    } catch (e) {
      emit(ClipboardError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateClipboardConfig event, Emitter<ClipboardState> emit) async {
    try {
      await _service.saveConfig(event.config);
      emit(ClipboardLoaded(config: event.config));
    } catch (e) {
      emit(ClipboardError(e.toString()));
    }
  }

  Future<void> _onRestore(RestoreDefaultClipboardConfig event, Emitter<ClipboardState> emit) async {
    try {
      const defaultConfig = ClipboardConfig();
      await _service.saveConfig(defaultConfig);
      emit(const ClipboardLoaded(config: defaultConfig));
    } catch (e) {
      emit(ClipboardError(e.toString()));
    }
  }
}
