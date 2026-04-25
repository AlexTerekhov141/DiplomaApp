import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../models/Processing_mode.dart';
import '../../models/User.dart';
import '../../repository/AppSettingsRepository/AppSettingsRepository.dart';
import '../../repository/AuthRepository/AuthRepository.dart';
import 'event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authRepository, required this.appSettingsRepository,}) : super(AuthState.initial()) {
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthPasswordConfirmChanged>(_onPasswordConfirmChanged);
    on<AuthUsernameChanged>(_onUsernameChanged);
    on<AuthFirstNameChanged>(_onFirstNameChanged);
    on<AuthLastNameChanged>(_onLastNameChanged);

    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthFetchProfile>(_onFetchProfile);
    on<AuthLogout>(_onLogout);
    on<AuthStarted>(_onStarted);
    on<AuthProfileUpdate>(_onProfileUpdate);
    on<AuthProfileImageUpdate>(_onProfileImageUpdate);

    on<AuthProfileUserChoiceUpdate>(_onAuthProfileUserChoiceUpdate);
  }

  final AuthRepository authRepository;
  final AppSettingsRepository appSettingsRepository;

  Future<void> _onAuthProfileUserChoiceUpdate(AuthProfileUserChoiceUpdate event, Emitter<AuthState> emit,) async {
    try {
      await appSettingsRepository.setProcessingMode(event.processingMode);
      emit(state.copyWith(
        userChoice: true,
        processingMode: event.processingMode,
      ));
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(email: event.email),
    ));
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(password: event.password),
    ));
  }

  void _onPasswordConfirmChanged(AuthPasswordConfirmChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(passwordConfirm: event.passwordConfirm),
    ));
  }

  void _onUsernameChanged(AuthUsernameChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(username: event.username),
    ));
  }

  void _onFirstNameChanged(AuthFirstNameChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(firstName: event.firstName),
    ));
  }

  void _onLastNameChanged(AuthLastNameChanged event, Emitter<AuthState> emit,) {
    emit(state.copyWith(
      user: state.user.copyWith(lastName: event.lastName),
    ));
  }

  Future<void> _onLoginSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit,) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    try {
      await authRepository.login(
        email: state.user.email,
        password: state.user.password,
      );

      final User profile = await authRepository.fetchProfile();

      emit(state.copyWith(
        user: profile,
        isLoading: false,
        status: AuthStatus.authenticated,
        errorMessage: null,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onRegisterSubmitted(AuthRegisterSubmitted event, Emitter<AuthState> emit,) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    try {
      await authRepository.register(state.user);

      final User profile = await authRepository.fetchProfile();

      emit(state.copyWith(
        user: profile,
        isLoading: false,
        status: AuthStatus.authenticated,
        errorMessage: null,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onFetchProfile(AuthFetchProfile event, Emitter<AuthState> emit,) async {
    try {
      final User profile = await authRepository.fetchProfile();

      emit(state.copyWith(
        user: profile,
        status: AuthStatus.authenticated,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
      ));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit,) async {
    try {
      await authRepository.logout();
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
    }

    emit(AuthState.initial().copyWith(
      status: AuthStatus.unauthenticated,
      userChoice: state.userChoice,
      processingMode: state.processingMode,
    ));
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit,) async {
    final bool hasModeChoice =
        await appSettingsRepository.hasProcessingModeChoice();
    final ProcessingMode processingMode =
        await appSettingsRepository.getProcessingMode();

    emit(state.copyWith(
      status: AuthStatus.unknown,
      isLoading: true,
      errorMessage: null,
      userChoice: hasModeChoice,
      processingMode: processingMode,
    ));

    final String? token = await authRepository.getAccessToken();

    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        user: User.empty(),
        status: AuthStatus.unauthenticated,
        isLoading: false,
      ));
      return;
    }

    try {
      final User profile = await authRepository.fetchProfile();

      emit(state.copyWith(
        user: profile,
        status: AuthStatus.authenticated,
        isLoading: false,
      ));
    } catch (e, st) {
      try {
        final String? newToken = await authRepository.refreshAccessToken();

        if (newToken != null && newToken.isNotEmpty) {
          final User profile = await authRepository.fetchProfile();

          emit(state.copyWith(
            user: profile,
            status: AuthStatus.authenticated,
            isLoading: false,
          ));
          return;
        }

        emit(state.copyWith(
          user: User.empty(),
          status: AuthStatus.unauthenticated,
          isLoading: false,
        ));
      } catch (refreshError, refreshSt) {
        emit(state.copyWith(
          user: User.empty(),
          status: AuthStatus.unauthenticated,
          isLoading: false,
        ));
        GetIt.I<Talker>().handle(refreshError, refreshSt);
      }

      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onProfileUpdate(AuthProfileUpdate event, Emitter<AuthState> emit,) async {
    emit(state.copyWith(
      user: state.user.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    ));

    try {
      final User updatedUser = state.user.copyWith(
        firstName: event.firstName ?? state.user.firstName,
        lastName: event.lastName ?? state.user.lastName,
        username: event.username ?? state.user.username,
      );

      await authRepository.updateProfile(updatedUser);
      final User profile = await authRepository.fetchProfile();

      final String currentImagePath = state.user.imagePath;
      final bool hasLocalImagePath = currentImagePath.isNotEmpty &&
          !currentImagePath.startsWith('http://') &&
          !currentImagePath.startsWith('https://') &&
          !currentImagePath.startsWith('assets/') &&
          !currentImagePath.startsWith('/media/');

      final String imagePath =
      hasLocalImagePath ? currentImagePath : profile.imagePath;

      emit(state.copyWith(
        user: profile.copyWith(
          imagePath: imagePath,
          isSubmitting: false,
          isSuccess: true,
        ),
      ));
    } catch (e, st) {
      emit(state.copyWith(
        user: state.user.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      ));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onProfileImageUpdate(AuthProfileImageUpdate event, Emitter<AuthState> emit,) async {
    emit(state.copyWith(
      user: state.user.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    ));

    try {
      final User updatedUser = state.user.copyWith(
        imagePath: event.imagePath,
      );

      emit(state.copyWith(
        user: updatedUser.copyWith(
          isSubmitting: false,
          isSuccess: false,
        ),
      ));
    } catch (e, st) {
      emit(state.copyWith(
        user: state.user.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      ));
      GetIt.I<Talker>().handle(e, st);
    }
  }
}
