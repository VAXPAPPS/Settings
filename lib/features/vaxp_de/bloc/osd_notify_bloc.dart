import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/osd_notify_config.dart';
import 'package:settings/features/vaxp_de/services/osd_notify_service.dart';

// Events
abstract class OsdNotifyEvent extends Equatable {
  const OsdNotifyEvent();

  @override
  List<Object> get props => [];
}

class LoadOsdNotifyConfig extends OsdNotifyEvent {}

class UpdateOsdNotifyConfig extends OsdNotifyEvent {
  final OsdNotifyConfig config;

  const UpdateOsdNotifyConfig(this.config);

  @override
  List<Object> get props => [config];
}

class RestoreDefaultOsdNotifyConfig extends OsdNotifyEvent {}

// States
abstract class OsdNotifyState extends Equatable {
  const OsdNotifyState();

  @override
  List<Object> get props => [];
}

class OsdNotifyInitial extends OsdNotifyState {}

class OsdNotifyLoading extends OsdNotifyState {}

class OsdNotifyLoaded extends OsdNotifyState {
  final OsdNotifyConfig config;

  const OsdNotifyLoaded({required this.config});

  @override
  List<Object> get props => [config];
}

class OsdNotifyError extends OsdNotifyState {
  final String message;

  const OsdNotifyError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class OsdNotifyBloc extends Bloc<OsdNotifyEvent, OsdNotifyState> {
  final OsdNotifyService _service;

  OsdNotifyBloc({OsdNotifyService? service}) 
      : _service = service ?? OsdNotifyService(),
        super(OsdNotifyInitial()) {
    on<LoadOsdNotifyConfig>(_onLoad);
    on<UpdateOsdNotifyConfig>(_onUpdate);
    on<RestoreDefaultOsdNotifyConfig>(_onRestore);
  }

  Future<void> _onLoad(LoadOsdNotifyConfig event, Emitter<OsdNotifyState> emit) async {
    emit(OsdNotifyLoading());
    try {
      final config = await _service.getConfig();
      emit(OsdNotifyLoaded(config: config));
    } catch (e) {
      emit(OsdNotifyError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateOsdNotifyConfig event, Emitter<OsdNotifyState> emit) async {
    try {
      await _service.saveConfig(event.config);
      emit(OsdNotifyLoaded(config: event.config));
    } catch (e) {
      emit(OsdNotifyError(e.toString()));
    }
  }

  Future<void> _onRestore(RestoreDefaultOsdNotifyConfig event, Emitter<OsdNotifyState> emit) async {
    try {
      const defaultConfig = OsdNotifyConfig();
      await _service.saveConfig(defaultConfig);
      emit(const OsdNotifyLoaded(config: defaultConfig));
    } catch (e) {
      emit(OsdNotifyError(e.toString()));
    }
  }
}
