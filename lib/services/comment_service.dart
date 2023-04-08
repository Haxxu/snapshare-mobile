// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:snapshare_mobile/constants/api_urls.dart';
import 'package:snapshare_mobile/models/comment.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/utils/error_handling.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class CommentService {
  Future<List<Comment>> getCommentsByPostId({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    List<Comment> comments = [];

    try {
      http.Response res = await http.get(
        Uri.parse(getCommentsByPostIdUrl(postId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          List<dynamic> data = jsonDecode(res.body)['data'];
          for (int i = 0; i < data.length; ++i) {
            Comment c = Comment.fromJson(jsonEncode(data[i]));
            comments.add(c);
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return comments;
  }
}
