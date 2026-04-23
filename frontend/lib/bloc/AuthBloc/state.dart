import 'package:equatable/equatable.dart';

import '../../models/User.dart';

const Object _errorMessageUnchanged = Object();

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    required this.user,
    required this.status,
    this.isLoading = false,
    this.errorMessage,
    this.userChoice = false
  });

  factory AuthState.initial() => AuthState(
    user: User.empty(),
    status: AuthStatus.unknown,
  );

  final User user;
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final bool userChoice;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    bool? isLoading,
    Object? errorMessage = _errorMessageUnchanged,
    bool? userChoice
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _errorMessageUnchanged)
          ? this.errorMessage
          : errorMessage as String?,
      userChoice: userChoice ?? this.userChoice
    );
  }

  @override
  List<Object?> get props => <Object?>[user, status, isLoading, errorMessage, userChoice];
}