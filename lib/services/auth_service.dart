import '../models/app_user.dart';

/// TEMPORARY in-memory auth service for Phase 3.
/// Phase 4 replaces the method bodies with Firebase Authentication;
/// the method signatures stay the same so the providers do not change.
class AuthService {
  // email -> password, and email -> user. Starts with one test account.
  final Map<String, String> _passwords = {'test@sufrah.app': 'test1234'};
  final Map<String, AppUser> _users = {
    'test@sufrah.app': AppUser(
      id: 'u1',
      name: 'Test User',
      createdAt: DateTime(2026, 11, 1),
    ),
  };

  Future<AppUser> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_passwords[email] != password) {
      throw Exception('Wrong email or password.');
    }
    return _users[email]!;
  }

  Future<AppUser> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_passwords.containsKey(email)) {
      throw Exception('An account with this email already exists.');
    }
    final user = AppUser(
      id: 'u${_users.length + 1}',
      name: name,
      createdAt: DateTime.now(),
    );
    _passwords[email] = password;
    _users[email] = user;
    return user;
  }

  Future<void> signOut() async {}
}
