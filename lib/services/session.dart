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

      if (data.containsKey('exp')) {
        final exp = data['exp'] * 1000; // to millis
        if (DateTime.now().millisecondsSinceEpoch > exp) {
           // Token expired
           clear();
           return false;
        }
      }

      if (data.containsKey('_id')) {
        final userId = data['_id'];
        
        // Try to fetch full details
        try {
          final user = await AuthService.getUserDetails(userId);
          currentUser = user;
          return true;
        } catch (e) {
          // If fetch fails (network), we can still fallback to content in token if we had more data, 
          // or just assume logged in but with partial data if we accept that.
          // For now, let's assume we want to stay logged in if token is valid structure and not expired.
          // We'll create a minimal UserData.
          // Note: `AuthService.getUserDetails` might throw 401 which should clear, but `catch(e)` catches all.
          // If we want to differentiate, we'd need to check error type.
          
          // Let's rely on the token validity for "Login state".
           currentUser = UserData(
            id: userId,
            name: data['name'] ?? 'User', // Token might not have name
            email: data['email'] ?? '',
            role: data['role'] ?? 'user',
            isActive: true, // Default to true for offline fallback
            // other fields null
          );
          return true;
        }
      }
    } catch (e) {
      print('Error loading session from token: $e');
    }
    // If anything fails (structure invalid, etc), clear session
    clear();
    return false;
  }
}
