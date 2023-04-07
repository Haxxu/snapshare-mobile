import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'];

// USER
String getPostsByUserIdUrl(userId) {
  return '$apiUrl/users/$userId/posts';
}

String getUserByIdUrl(userId) {
  return '$apiUrl/users/$userId';
}

String updateUserByUserIdUrl(userid) {
  return '$apiUrl/users/$userid';
}

// POST
String createNewPostUrl() {
  return '$apiUrl/posts';
}

String getRandomPostsUrl() {
  return '$apiUrl/posts';
}

String getFollowingUsersPostsByUserIdUrl(userId) {
  return '$apiUrl/users/$userId/following/posts';
}

String checkLikedPostUrl(postId) {
  return '$apiUrl/me/liked-posts/contains?postId=$postId';
}

String likePostUrl(postId) {
  return '$apiUrl/me/liked-posts';
}

String unlikePostUrl(postId) {
  return '$apiUrl/me/liked-posts';
}
