import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/User.dart';
class AuthRepository {
  AuthRepository({required this.dio, required this.storage});
  final Dio dio;
  final FlutterSecureStorage storage;

  Future<void> register(User user) async {
    final Map<String, String> data = <String, String>{
      'email': user.email,
      'username': user.username,
      'password': user.password,
      'password_confirm': user.passwordConfirm,
      'first_name': user.firstName,
      'last_name': user.lastName,
    };

    try {
      final Response<dynamic> response = await dio.post(
        'http://192.168.1.97:8000/api/auth/register/',
        data: data,
        options: Options(
          headers: <String, dynamic>{'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final tokens = response.data['tokens'];
        await storage.write(key: 'access_token', value: tokens['access']);
        await storage.write(key: 'refresh_token', value: tokens['refresh']);
      } else {
        throw Exception('Registration error: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Registration error: ${e.response?.data}');
      } else {
        throw Exception('Registration error: ${e.message}');
      }
    }
  }
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final Map<String, String> data = <String, String>{
      'email': email,
      'password': password
    };

    try {
      final Response<dynamic> response = await dio.post(
        'http://192.168.1.97:8000/api/auth/login/',
        data: data,
        options: Options(headers: <String, dynamic>{'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await storage.write(key: 'access_token', value: response.data['access']);
        await storage.write(key: 'refresh_token', value: response.data['refresh']);
      } else {
        throw Exception('Login error: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Incorrect login or password');
      } else if (e.response != null) {
        throw Exception('Login error: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }


  Future<User> fetchProfile() async {
    final String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) throw Exception('No token');

    final Response<dynamic> response = await dio.get(
      'http://192.168.1.97:8000/api/auth/profile/',
      options: Options(headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return User(
        email: data['email'],
        username: data['username'],
        firstName: data['first_name'],
        lastName: data['last_name'],
        imagePath: data['avatar'] ?? '',
        password: '',
        passwordConfirm: '',
      );
    } else {
      throw Exception('Error retrieving profile');
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }
  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }
  Future<void> logout() async {
    final String? accessToken = await storage.read(key: 'access_token');

    await dio.post(
      'http://192.168.1.97:8000/api/auth/logout/',
      options: Options(headers: <String, dynamic>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }),
    );

    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<String?> refreshAccessToken() async {
    final String? refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

      final Response<dynamic> response = await dio.post(
        'http://192.168.1.97:8000/api/auth/refresh/',
        data: <String, String>{'refresh': refreshToken},
        options: Options(headers: <String, dynamic>{'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        await storage.write(key: 'access_token', value: newAccess);
        return newAccess;
      }

    return null;
  }


  Future<void> updateProfile(User updatedUser) async {
    final String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) throw Exception('No token');

    final Map<String, String> data = <String, String>{
      'email': updatedUser.email,
      'username': updatedUser.username,
      'first_name': updatedUser.firstName,
      'last_name': updatedUser.lastName,
    };

    try {
      final Response<dynamic> response = await dio.put(
        'http://192.168.1.97:8000/api/auth/profile/',
        data: data,
        options: Options(headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Profile update error: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Profile update error: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }


}