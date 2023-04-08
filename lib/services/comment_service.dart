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
  Future<Comment?> createNewComment({
    required BuildContext context,
    required String postId,
    required String content,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    Comment? comment;

    try {
      http.Response res = await http.post(Uri.parse(createNewCommentUrl()),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'post': postId,
            'content': content,
          }));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          comment = Comment.fromMap(jsonDecode(res.body)['data']);
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return comment;
  }

  Future<bool> deleteComment({
    required BuildContext context,
    required String commentId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isDeleted = false;

    try {
      http.Response res = await http.delete(
        Uri.parse(deleteCommentByIdUrl(commentId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          isDeleted = true;
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return isDeleted;
  }

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

  Future<bool> checkLikedComment({
    required BuildContext context,
    required String commentId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isLiked = false;

    try {
      http.Response res = await http.get(
        Uri.parse(checkLikedCommentUrl(commentId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // print(jsonEncode(jsonDecode(res.body)['data']));
          isLiked = jsonDecode(res.body)['data'];
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return isLiked;
  }

  void likeComment({
    required BuildContext context,
    required String commentId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.put(
        Uri.parse(likeCommentUrl(commentId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'comment': commentId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {},
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }

  void unlikeComment({
    required BuildContext context,
    required String commentId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.delete(
        Uri.parse(unlikeCommentUrl(commentId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'comment': commentId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {},
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }
}
