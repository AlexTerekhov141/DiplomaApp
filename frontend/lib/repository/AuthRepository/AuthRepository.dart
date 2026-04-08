import '../../models/User.dart';

abstract class AuthRepository {
  Future<void> register(User user);

  Future<void> login({
    required String email,
    required String password,
  });

  Future<User> fetchProfile();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> logout();

  Future<String?> refreshAccessToken();

  Future<void> updateProfile(User updatedUser);
}