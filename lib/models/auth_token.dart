class AuthToken {
  final String _token;

  AuthToken({token}) : _token = token;

  bool get isValid {
    return token != null;
  }

  String? get token {
    return _token;
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': _token,
    };
  }

  static AuthToken fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['authToken'],
    );
  }
}
