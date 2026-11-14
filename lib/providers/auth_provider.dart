import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Shared sign-in state used by S1, S5, S6 and the router.
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AppUser? user;
  String? email;
  bool isLoading = false;
  String? error;

  bool get isSignedIn => user != null;

  Future<void> signIn(String email, String password) async {
    await _run(email, () => _service.signIn(email, password));
  }

  Future<void> signUp(String name, String email, String password) async {
    await _run(email, () => _service.signUp(name, email, password));
  }

  Future<void> signOut() async {
    await _service.signOut();
    user = null;
    email = null;
    notifyListeners();
  }

  Future<void> _run(String email, Future<AppUser> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await action();
      this.email = email;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }
}
