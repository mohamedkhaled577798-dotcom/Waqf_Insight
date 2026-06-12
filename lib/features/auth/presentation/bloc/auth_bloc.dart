import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/core/usecases/usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/login_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/logout_usecase.dart';
import 'package:waqf_insight/features/auth/domain/usecases/register_usecase.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_event.dart';
import 'package:waqf_insight/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(Unauthenticated(errorMessage: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUseCase(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(Unauthenticated(errorMessage: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(Unauthenticated(errorMessage: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}
