import 'dart:convert';
import 'auth_service.dart';

/// Simple in-memory session for storing the logged-in user and token.
class UserSession {
  UserSession._();

  static String? token;
  static UserData? currentUser;

  static void setFromAuthResponse(AuthResponse resp) {
    token = resp.token;
    currentUser = resp.data;
  }

  static void clear() {
    token = null;
    currentUser = null;
  }

  static bool get isLoggedIn => token != null;

  static Future<bool> loadFromToken(String storedToken) async {
    try {
      token = storedToken;
      final parts = storedToken.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);

      if (data.containsKey('_id')) {
        final userId = data['_id'];
        // Fetch full user details
        final user = await AuthService.getUserDetails(userId);
        currentUser = user;
        return true;
      }
    } catch (e) {
      print('Error loading session from token: $e');
    }
    // If anything fails, clear session
    clear();
    return false;
  }
}
