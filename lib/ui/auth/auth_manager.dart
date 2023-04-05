import 'package:flutter/foundation.dart';

import 'package:snapshare_mobile/models/auth_token.dart';
import 'package:snapshare_mobile/services/auth_service.dart';

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;

  final AuthService _authService = AuthService();

  AuthToken? get authToken {
    return _authToken;
  }

  bool get isAuth {
    return authToken != null && authToken!.isValid;
  }

  void _setAuthToken(AuthToken token) {
    _authToken = token;
    notifyListeners();
  }

  Future<void> login({
    required String account,
    required String password,
  }) async {
    _setAuthToken(
        await _authService.login(account: account, password: password));
  }

  Future<void> register({
    required String account,
    required String password,
    String description = '',
    String name = '',
  }) async {
    _setAuthToken(await _authService.register(
      account: account,
      password: password,
      name: name,
      description: description,
    ));
  }

  Future<void> logout() async {
    _authToken = null;
    notifyListeners();
    _authService.clearSavedAuthToken();
  }

  Future<bool> tryAutoLogin() async {
    final savedToken = await _authService.loadSavedAuthToken();
    if (savedToken == null) {
      return false;
    }
    _setAuthToken(savedToken);
    return true;
  }
}
