import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:snapshare_mobile/models/auth_token.dart';
import 'package:snapshare_mobile/services/auth_service.dart';

class PostService {
  late final String? apiUrl;
  AuthToken? _authToken;
  AuthService _authService = AuthService();

  PostService() {
    apiUrl = dotenv.env['API_URL'];
  }

  Future<void> _loadAuthToken() async {
    _authToken = await _authService.loadSavedAuthToken();
  }

  Future<void> createPost({
    required String title,
    required String image,
    required String description,
  }) async {
    await _loadAuthToken();

    final url = Uri.parse('$apiUrl/posts');
    final body = {
      title: title,
      image: image,
      description: description,
    };

    final response = await http.post(url, body: body, headers: {
      "Content-Type": "application/json",
      'x-auth-token': _authToken!.token ?? ''
    });
  }
}
