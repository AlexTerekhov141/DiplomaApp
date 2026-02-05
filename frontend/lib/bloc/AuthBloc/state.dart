import 'package:equatable/equatable.dart';
import '../../models/User.dart';

class AuthState extends Equatable {

  const AuthState({
    required this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(user: User.empty());
  final User user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[user, isLoading, isAuthenticated, errorMessage];
}
