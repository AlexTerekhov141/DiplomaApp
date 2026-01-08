import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isConfirm = false,
    this.errorMessage,
    required this.imagePath
  });

  final String email;
  final String password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isConfirm;
  final String? errorMessage;
  final String imagePath;

  User copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? isConfirm,

  }) {
    return User(
        email: email ?? this.email,
        password: password ?? this.password,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage ?? this.errorMessage,
        isConfirm: isConfirm ?? this.isConfirm,
        imagePath: imagePath
    );
  }

  @override
  List<Object?> get props => <Object?>[
    email,
    password,
    isSubmitting,
    isSuccess,
    errorMessage,
    isConfirm,
  ];
}