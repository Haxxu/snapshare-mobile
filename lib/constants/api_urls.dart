import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'];

String createNewPostUrl() {
  return '$apiUrl/posts';
}
