// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/constants/api_urls.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/utils/error_handling.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class PostService {
  Future<void> createNewPost({
    required BuildContext context,
    required String title,
    required String description,
    required String image,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.post(Uri.parse(createNewPostUrl()),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'title': title,
            'description': description,
            'image': image,
          }));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, jsonDecode(res.body)['message']);
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Post>?> getPostsByUserId({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.get(
        Uri.parse(getPostsByUserIdUrl(userId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, jsonDecode(res.body)['message']);
        },
      );

      Map<String, dynamic> jsonBody = jsonDecode(res.body);

      List<dynamic> postList = jsonBody['data'];

      // return postList.length;

      // List<Post> posts = postList.map((json) => Post.fromJson(json)).toList();
      // print(posts);
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }

  Future<int?> getNumbersOfPostsByUserId({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.get(
        Uri.parse(getPostsByUserIdUrl(userId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, jsonDecode(res.body)['message']);
        },
      );

      Map<String, dynamic> jsonBody = jsonDecode(res.body);

      List<dynamic> postList = jsonBody['data'];

      return postList.length;

      // List<Post> posts = postList.map((json) => Post.fromJson(json)).toList();
      // print(posts);
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }
}
