import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    this.email = '',
    this.username = '',
    this.password = '',
    this.passwordConfirm = '',
    this.firstName = '',
    this.lastName = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isConfirm = false,
    this.errorMessage,
    required this.imagePath,
  });
  factory User.empty() => const User(
    email: '',
    username: '',
    firstName: '',
    lastName: '',
    imagePath: '',
    password: '',
    isSubmitting: false,
    isSuccess: false,
    errorMessage: null,
  );

  final String email;
  final String username;
  final String password;
  final String passwordConfirm;
  final String firstName;
  final String lastName;

  final bool isSubmitting;
  final bool isSuccess;
  final bool isConfirm;
  final String? errorMessage;
  final String imagePath;

  User copyWith({
    String? email,
    String? username,
    String? password,
    String? passwordConfirm,
    String? firstName,
    String? lastName,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isConfirm,
    String? errorMessage,
    String? imagePath,
  }) {
    return User(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isConfirm: isConfirm ?? this.isConfirm,
      errorMessage: errorMessage ?? this.errorMessage,
      imagePath: imagePath ?? this.imagePath,
    );
  }
  @override
  List<Object?> get props => <Object?>[
    email,
    username,
    password,
    passwordConfirm,
    firstName,
    lastName,
    isSubmitting,
    isSuccess,
    isConfirm,
    errorMessage,
    imagePath,
  ];
}