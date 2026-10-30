import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/auth_status.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _user;
  AuthStatus _status;
  String? _errorMessage;

  /// Restores a saved session immediately (so the router knows the state on
  /// the first frame), then checks it with the server in the background.
  AuthProvider({required this.authRepository, bool verifySession = true})
    : _user = authRepository.getSavedUser(),
      _status = AuthStatus.unauthenticated {
    if (_user != null) {
      _status = AuthStatus.authenticated;
      if (verifySession) _verifySession();
    }
  }

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.login(
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _verifySession() async {
    final fresh = await authRepository.refreshSession();
    // The user may have signed out while we were waiting.
    if (_status != AuthStatus.authenticated) return;
    if (fresh == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = fresh;
    }
    notifyListeners();
  }
}
