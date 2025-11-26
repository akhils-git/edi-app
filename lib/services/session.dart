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

  static bool get isLoggedIn => token != null && currentUser != null;
}
