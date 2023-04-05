import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:snapshare_mobile/models/auth_token.dart';
import 'package:snapshare_mobile/models/http_exception.dart';

class AuthService {
  static const _authTokenKey = 'authToken';
  late final String? apiUrl;

  AuthService() {
    apiUrl = dotenv.env['API_URL'];
  }

  String _buildAuthUrl(String method) {
    return '$apiUrl/auth/$method';
  }

  Future<AuthToken> _authenticate({
    required String account,
    required String password,
    String name = '',
    String description = '',
    String method = 'login',
  }) async {
    try {
      final url = Uri.parse(_buildAuthUrl(method));
      final body = method == 'login'
          ? json.encode({
              'account': account,
              'password': password,
            })
          : json.encode({
              'account': account,
              'password': password,
              'name': name,
              'description': description,
            });
      final response = await http
          .post(url, body: body, headers: {"Content-Type": "application/json"});
      final responseJson = json.decode(response.body);
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw HttpException(responseJson['message']);
      }

      final authToken = _fromJson(responseJson);
      _saveAuthToken(authToken);

      return authToken;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<AuthToken> register({
    required String account,
    required String password,
    String name = '',
    String description = '',
  }) async {
    return await _authenticate(
      account: account,
      password: password,
      name: name,
      description: description,
      method: 'register',
    );
  }

  Future<AuthToken> login({
    required String account,
    required String password,
  }) async {
    return await _authenticate(
      account: account,
      password: password,
      method: 'login',
    );
  }

  AuthToken _fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'],
    );
  }

  Future<void> _saveAuthToken(AuthToken authToken) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_authTokenKey, json.encode(authToken.toJson()));
  }

  Future<AuthToken?> loadSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_authTokenKey)) {
      return null;
    }

    final savedToken = prefs.getString(_authTokenKey);

    final authToken = AuthToken.fromJson(json.decode(savedToken!));
    if (!authToken.isValid) {
      return null;
    }
    return authToken;
  }

  Future<void> clearSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_authTokenKey);
  }
}
