abstract class AuthEvent {}

class AuthEmailChanged extends AuthEvent {
  AuthEmailChanged(this.email);
  final String email;
}

class AuthPasswordChanged extends AuthEvent {
  AuthPasswordChanged(this.password);
  final String password;
}
class AuthPasswordConfirmChanged extends AuthEvent {
  AuthPasswordConfirmChanged(this.passwordConfirm);
  final String passwordConfirm;
}
class AuthUsernameChanged extends AuthEvent {
  AuthUsernameChanged(this.username);
  final String username;
}

class AuthFirstNameChanged extends AuthEvent {
  AuthFirstNameChanged(this.firstName);
  final String firstName;
}

class AuthLastNameChanged extends AuthEvent {
  AuthLastNameChanged(this.lastName);
  final String lastName;
}

class AuthRegisterSubmitted extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {}

class AuthFetchProfile extends AuthEvent {}

class AuthLogout extends AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthProfileUpdate extends AuthEvent {

  AuthProfileUpdate({this.firstName, this.lastName, this.username});
  final String? firstName;
  final String? lastName;
  final String? username;
}

class AuthProfileImageUpdate extends AuthEvent {

  AuthProfileImageUpdate({required this.imagePath});
  final String imagePath;
}