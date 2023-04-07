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

  Future<List<Post>> getPostsByUserId({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    List<Post> postList = [];

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
          // print(jsonEncode(jsonDecode(res.body)['data']));
          List<dynamic> data = jsonDecode(res.body)['data'];
          for (int i = 0; i < data.length; ++i) {
            // print(jsonEncode(data[i]['owner']));
            Post p = Post.fromJson(jsonEncode(data[i]));
            postList.add(p);
          }
        },
      );

      // Map<String, dynamic> jsonBody = jsonDecode(res.body);

      // List<dynamic> postList = jsonBody['data'];

      // List<Post> posts = postList.map((json) => Post.fromJson(json)).toList();
      // print(posts);

      // return postList;
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return postList;
  }
}
