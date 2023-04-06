import 'package:flutter/foundation.dart';

import 'package:snapshare_mobile/models/auth_token.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/services/auth_service.dart';

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;
  String? _xAuthToken;
  User? _user;

  final AuthService _authService = AuthService();

  AuthToken? get authToken {
    return _authToken;
  }

  String? get xAuthToken {
    return _xAuthToken;
  }

  User? get user {
    return _user;
  }

  // bool get isAuth {
  //   return authToken != null && authToken!.isValid;
  // }

  bool get isAuth {
    return _xAuthToken != null;
  }

  // void _setAuthToken(AuthToken token) {
  //   _authToken = token;
  //   notifyListeners();
  // }

  void _setXAuthToken(String token) {
    _xAuthToken = token;
    notifyListeners();
  }

  void setUser(String user) {
    _user = User.fromJson(user);
  }

  Future<void> login({
    required String account,
    required String password,
  }) async {
    _setXAuthToken(
        await _authService.login(account: account, password: password));
  }

  Future<void> register({
    required String account,
    required String password,
    String description = '',
    String name = '',
  }) async {
    _setXAuthToken(await _authService.register(
      account: account,
      password: password,
      name: name,
      description: description,
    ));
  }

  Future<void> logout() async {
    _xAuthToken = null;
    _authService.clearSavedAuthToken();
    notifyListeners();
    print(_xAuthToken);
  }

  Future<bool> tryAutoLogin() async {
    final savedToken = await _authService.loadSavedAuthToken();
    if (savedToken == null) {
      return false;
    }
    _setXAuthToken(savedToken);
    return true;
  }
}
