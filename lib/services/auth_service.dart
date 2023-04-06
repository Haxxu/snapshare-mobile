import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:snapshare_mobile/models/auth_token.dart';
import 'package:snapshare_mobile/models/http_exception.dart';
import 'package:snapshare_mobile/screens/screens.dart';

class AuthService {
  static const _authTokenKey = 'authToken';
  static const _xAuthTokenKey = 'x-auth-token';
  late final String? apiUrl;

  AuthService() {
    apiUrl = dotenv.env['API_URL'];
  }

  String _buildAuthUrl(String method) {
    return '$apiUrl/auth/$method';
  }

  Future<String> _authenticate({
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

      _saveAuthToken(jsonDecode(response.body)['token']);

      return jsonDecode(response.body)['token'];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> register({
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

  Future<String> login({
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

  // Future<void> _saveAuthToken(AuthToken authToken) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString(_authTokenKey, json.encode(authToken.toJson()));
  //   prefs.setString(_xAuthTokenKey, json.encode(authToken.token));
  // }

  // Future<AuthToken?> loadSavedAuthToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey(_authTokenKey)) {
  //     return null;
  //   }

  //   final savedToken = prefs.getString(_authTokenKey);

  //   final authToken = AuthToken.fromJson(json.decode(savedToken!));
  //   if (!authToken.isValid) {
  //     return null;
  //   }
  //   return authToken;
  // }

  // Future<void> clearSavedAuthToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.remove(_authTokenKey);
  // }

  // Future<void> clearSavedAuthToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.remove(_authTokenKey);
  // }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_xAuthTokenKey, token);
  }

  Future<String?> loadSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_xAuthTokenKey)) {
      return null;
    }

    final savedToken = prefs.getString(_xAuthTokenKey);

    if (savedToken == null) {
      return null;
    }
    return savedToken;
  }

  Future<void> clearSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_xAuthTokenKey);
  }

  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_xAuthTokenKey);

      if (token == null) {
        prefs.setString(_xAuthTokenKey, '');
      }

      http.Response userRes = await http
          .get(Uri.parse('$apiUrl/me/info'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token!,
      });
      AuthManager authManager =
          // ignore: use_build_context_synchronously
          Provider.of<AuthManager>(context, listen: false);
      authManager.setUser(jsonEncode(jsonDecode(userRes.body)['data']));
    } catch (e) {
      print(e);
    }
  }
}
