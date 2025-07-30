class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() {
    return _instance;
  }
  UserSession._internal();
  String? userId;
  void clear() {
    userId = null;
  }
}
