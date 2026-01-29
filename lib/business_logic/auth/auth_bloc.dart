import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  /// Handle login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );
      
      final authResponse = await _authRepository.login(request);
      emit(Authenticated(user: authResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const Unauthenticated());
    }
  }

  /// Handle registration
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final request = RegisterRequest(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      
      final authResponse = await _authRepository.register(request);
      emit(Authenticated(user: authResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const Unauthenticated());
    }
  }

  /// Handle logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  /// Handle authentication check
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Handle profile update
  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    
    emit(const AuthLoading());
    
    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: event.fullName,
        phone: event.phone,
      );
      
      emit(Authenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Restore previous state
      if (state is Authenticated) {
        emit(state);
      }
    }
  }
}
