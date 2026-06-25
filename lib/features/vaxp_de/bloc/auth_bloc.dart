import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/models/auth_config.dart';
import 'package:settings/features/vaxp_de/services/auth_service.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoadAuthConfig extends AuthEvent {}

class UpdateAuthConfig extends AuthEvent {
  final AuthConfig config;
  const UpdateAuthConfig(this.config);
  @override
  List<Object> get props => [config];
}

class RestoreDefaultAuthConfig extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  final AuthConfig config;
  const AuthLoaded({required this.config});
  @override
  List<Object> get props => [config];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _service;

  AuthBloc({AuthService? service}) 
      : _service = service ?? AuthService(),
        super(AuthInitial()) {
    on<LoadAuthConfig>(_onLoad);
    on<UpdateAuthConfig>(_onUpdate);
    on<RestoreDefaultAuthConfig>(_onRestore);
  }

  Future<void> _onLoad(LoadAuthConfig event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final config = await _service.getConfig();
      emit(AuthLoaded(config: config));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateAuthConfig event, Emitter<AuthState> emit) async {
    try {
      await _service.saveConfig(event.config);
      emit(AuthLoaded(config: event.config));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRestore(RestoreDefaultAuthConfig event, Emitter<AuthState> emit) async {
    try {
      const defaultConfig = AuthConfig();
      await _service.saveConfig(defaultConfig);
      emit(const AuthLoaded(config: defaultConfig));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
