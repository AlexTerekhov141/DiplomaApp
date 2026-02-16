import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_config.dart';
import '../models/User.dart';
class AuthRepository {
  AuthRepository({required this.dio, required this.storage});
  final Dio dio;
  final FlutterSecureStorage storage;
  String get _baseUrl => AppConfig.apiBaseUrl.endsWith('/')
      ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
      : AppConfig.apiBaseUrl;

  String get _registerUrl => '$_baseUrl/api/auth/register/';
  String get _loginUrl => '$_baseUrl/api/auth/login/';
  String get _profileUrl => '$_baseUrl/api/auth/profile/';
  String get _logoutUrl => '$_baseUrl/api/auth/logout/';
  String get _refreshUrl => '$_baseUrl/api/auth/refresh/';

  String _normalizeAvatarUrl(dynamic avatarValue) {
    if (avatarValue == null) {
      return '';
    }
    final String avatar = avatarValue.toString().trim();
    if (avatar.isEmpty) {
      return '';
    }
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }
    if (avatar.startsWith('/')) {
      return '$_baseUrl$avatar';
    }
    if (avatar.startsWith('media/')) {
      return '$_baseUrl/$avatar';
    }
    return '$_baseUrl/media/$avatar';
  }

  String _toUserMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Please check your internet connection and try again.';
    }

    final int? statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Incorrect email or password.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server is temporarily unavailable. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }

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
        _registerUrl,
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
        throw Exception(_toUserMessage(e));
      } else {
        throw Exception(_toUserMessage(e));
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
        _loginUrl,
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
      throw Exception(_toUserMessage(e));
    }
  }


  Future<User> fetchProfile() async {
    final String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) throw Exception('No token');

    final Response<dynamic> response = await dio.get(
      _profileUrl,
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
        imagePath: _normalizeAvatarUrl(data['avatar']),
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

    try {
      await dio.post(
        _logoutUrl,
        options: Options(headers: <String, dynamic>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        }),
      );
    } finally {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
    }
  }

  Future<String?> refreshAccessToken() async {
    final String? refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

      final Response<dynamic> response = await dio.post(
        _refreshUrl,
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

    final FormData data = FormData.fromMap(<String, dynamic>{
      'email': updatedUser.email,
      'username': updatedUser.username,
      'first_name': updatedUser.firstName,
      'last_name': updatedUser.lastName,
    });

    final File avatarFile = File(updatedUser.imagePath);
    if (updatedUser.imagePath.isNotEmpty && avatarFile.existsSync()) {
      data.files.add(
        MapEntry<String, MultipartFile>(
          'avatar',
          MultipartFile.fromFileSync(
            updatedUser.imagePath,
            filename: updatedUser.imagePath.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    try {
      final Response<dynamic> response = await dio.put(
        _profileUrl,
        data: data,
        options: Options(headers: <String, dynamic>{
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Profile update error: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(_toUserMessage(e));
    }
  }


}
