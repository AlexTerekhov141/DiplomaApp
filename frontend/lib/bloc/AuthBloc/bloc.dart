import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import '../../models/User.dart';
import '../../repository/AuthRepository.dart';
import 'event.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({required this.authRepository}) : super(AuthState.initial()) {

    on<AuthEmailChanged>((AuthEmailChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(email: e.email)));
    });

    on<AuthPasswordChanged>((AuthPasswordChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(password: e.password)));
    });
    on<AuthPasswordConfirmChanged>((AuthPasswordConfirmChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(passwordConfirm: e.passwordConfirm)));
    });

    on<AuthUsernameChanged>((AuthUsernameChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(username: e.username)));
    });

    on<AuthFirstNameChanged>((AuthFirstNameChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(firstName: e.firstName)));
    });

    on<AuthLastNameChanged>((AuthLastNameChanged e, Emitter<AuthState> emit) {
      emit(state.copyWith(user: state.user.copyWith(lastName: e.lastName)));
    });

    on<AuthLoginSubmitted>((AuthLoginSubmitted event, Emitter<AuthState> emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      try {
        await authRepository.login(
          email: state.user.email,
          password: state.user.password,
        );

        final User profile = await authRepository.fetchProfile();

        emit(state.copyWith(
          user: profile,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
        ));
      } catch (e,st) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
        GetIt.I<Talker>().handle(e, st);
      }
    });

    on<AuthRegisterSubmitted>((AuthRegisterSubmitted event, Emitter<AuthState> emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      try {
        await authRepository.register(state.user);

        final User profile = await authRepository.fetchProfile();

        emit(state.copyWith(
          user: profile,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    });

    on<AuthFetchProfile>((AuthFetchProfile event, Emitter<AuthState> emit) async {
      try {
        final User profile = await authRepository.fetchProfile();
        emit(state.copyWith(user: profile, isAuthenticated: true));
      } catch (_) {}
    });

    on<AuthLogout>((AuthLogout event, Emitter<AuthState> emit) async {
      try {
        await authRepository.logout();
      } catch (_) {}
      emit(AuthState.initial());
    });

    on<AuthStarted>((AuthStarted event, Emitter<AuthState> emit) async {
      final String? token = await authRepository.getAccessToken();
      if (token == null) {
        emit(state.copyWith(isAuthenticated: false, user: User.empty()));
        return;
      }

      try {
        final User profile = await authRepository.fetchProfile();
        emit(state.copyWith(
          user: profile,
          isAuthenticated: true,
        ));
      } catch (e) {
        final String? newToken = await authRepository.refreshAccessToken();

        if (newToken != null) {
          final User profile = await authRepository.fetchProfile();
          emit(state.copyWith(
            user: profile,
            isAuthenticated: true,
          ));
        }
      }
    });


    on<AuthProfileUpdate>((AuthProfileUpdate event, Emitter<AuthState> emit) async {
      emit(state.copyWith(user: state.user.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false)));

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
        final String imagePath = hasLocalImagePath ? currentImagePath : profile.imagePath;

        emit(state.copyWith(
          user: profile.copyWith(
            imagePath: imagePath,
            isSubmitting: false,
            isSuccess: true,
          ),
        ));
      } catch (e) {
        emit(state.copyWith(user: state.user.copyWith(isSubmitting: false, isSuccess: false, errorMessage: e.toString())));
      }
    });

    on<AuthProfileImageUpdate>((AuthProfileImageUpdate event, Emitter<AuthState> emit) async {
      emit(state.copyWith(
          user: state.user.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false)));

      try {
        final User updatedUser = state.user.copyWith(imagePath: event.imagePath);

        emit(state.copyWith(
            user: updatedUser.copyWith(isSubmitting: false, isSuccess: false)));
      } catch (e) {
        emit(state.copyWith(
            user: state.user.copyWith(
                isSubmitting: false, isSuccess: false, errorMessage: e.toString())));
      }
    });


  }
  final AuthRepository authRepository;
}
