import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants.dart';

/// Small API client for auth endpoints.
///
/// Usage (example, do NOT call from UI automatically):
/// ```dart
/// final resp = await AuthService.login('stive@edu.com', '1234');
/// if (resp.success) {
///   print('token: ${resp.token}');
/// }
/// ```
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final bool isActive;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json['_id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        avatar: json['avatar'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
}

class AuthResponse {
  final bool success;
  final String token;
  final UserData data;

  AuthResponse({
    required this.success,
    required this.token,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json['success'] as bool? ?? false,
        token: json['token'] as String? ?? '',
        data: UserData.fromJson(json['data'] as Map<String, dynamic>),
      );
}

class AuthService {
  AuthService._();

  /// POST /api/v1/auth/login
  /// Sends JSON body: { "username": "...", "password": "..." }
  /// Returns [AuthResponse] on 200. Throws [ApiException] otherwise.
  static Future<AuthResponse> login(String username, String password) async {
    final uri = Uri.parse('${apiBaseUrl}api/v1/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username, 'password': password});

    http.Response resp;
    try {
      resp = await http.post(uri, headers: headers, body: body);
    } on SocketException catch (e) {
      throw ApiException(
        'Network error: $e. Ensure the backend at $apiBaseUrl is running and reachable from the device.',
        null,
      );
    } catch (e) {
      throw ApiException('Request failed: $e', null);
    }

    if (resp.statusCode == 200) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(resp.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(json);
      } catch (e) {
        throw ApiException('Invalid response format: $e', resp.statusCode);
      }
    }

    // Try to parse error message from body if present
    String message = 'Request failed with status ${resp.statusCode}';
    try {
      final parsed = jsonDecode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}

    throw ApiException(message, resp.statusCode);
  }
  /// POST /api/v1/users
  /// Sends multipart request with fields and optional 'avatar' file.
  /// Returns [RegistrationResponse] on 201. Throws [ApiException] otherwise.
  static Future<RegistrationResponse> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String role = 'student',
    File? avatarFile,
  }) async {
    final uri = Uri.parse('${apiBaseUrl}api/v1/users');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['phone_number'] = phoneNumber;
    request.fields['role'] = role;



    if (avatarFile != null) {
      final stream = http.ByteStream(avatarFile.openRead());
      final length = await avatarFile.length();
      
      final extension = avatarFile.path.split('.').last.toLowerCase();
      MediaType contentType;
      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else {
        // Default fallback or let it be inferred if unknown, but backend seems strict
        contentType = MediaType('image', 'jpeg'); 
      }

      final multipartFile = http.MultipartFile(
        'avatar',
        stream,
        length,
        filename: avatarFile.path.split('/').last,
        contentType: contentType,
      );
      request.files.add(multipartFile);
    }

    http.StreamedResponse streamedResp;
    try {
      streamedResp = await request.send();
    } on SocketException catch (e) {
      throw ApiException(
        'Network error: $e. Ensure the backend at $apiBaseUrl is running and reachable from the device.',
        null,
      );
    } catch (e) {
      throw ApiException('Request failed: $e', null);
    }

    final resp = await http.Response.fromStream(streamedResp);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(resp.body) as Map<String, dynamic>;
        return RegistrationResponse.fromJson(json);
      } catch (e) {
        throw ApiException('Invalid response format: $e', resp.statusCode);
      }
    }

    // Try to parse error message from body if present
    String message = 'Request failed with status ${resp.statusCode}';
    try {
      final parsed = jsonDecode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        message = parsed['message'].toString();
      }
    } catch (_) {}

    throw ApiException(message, resp.statusCode);
  }
}

class RegistrationResponse {
  final bool success;
  final UserData data;

  RegistrationResponse({
    required this.success,
    required this.data,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        success: json['success'] as bool? ?? false,
        data: UserData.fromJson(json['data'] as Map<String, dynamic>),
      );
}
