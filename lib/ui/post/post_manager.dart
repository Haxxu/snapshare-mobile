import 'package:flutter/material.dart';

import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/services/post_service.dart';

class PostManager with ChangeNotifier {
  List<Post> feedPosts = [];

  PostService _postService = PostService();

  Future<void> createPost({
    required String title,
    required String image,
    String description = '',
  }) async {
    await _postService.createPost(
      title: title,
      image: image,
      description: description,
    );
  }
}
