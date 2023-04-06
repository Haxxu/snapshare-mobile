import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'];

String createNewPostUrl() {
  return '$apiUrl/posts';
}

String getPostsByUserIdUrl(userId) {
  return '$apiUrl/users/$userId/posts';
}
