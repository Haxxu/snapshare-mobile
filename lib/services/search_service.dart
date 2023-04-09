// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/constants/api_urls.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/utils/error_handling.dart';

class SearchService {
  Future<List<dynamic>> search({
    required BuildContext context,
    required String search,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    List<User> users = [];
    List<Post> posts = [];

    try {
      final uri = Uri.parse(searchUrl());
      final queryParams = {
        'tags': ["posts"],
        'search': search.trim(),
        'limit': '5'
      };
      final uriWithQueryParams = uri.replace(queryParameters: queryParams);

      http.Response res = await http.get(
        uriWithQueryParams,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          List<dynamic> postsData = jsonDecode(res.body)['data']['posts'] ?? [];
          List<dynamic> usersData = jsonDecode(res.body)['data']['users'] ?? [];

          for (int i = 0; i < postsData.length; ++i) {
            Post p = Post.fromJson(jsonEncode(postsData[i]));
            posts.add(p);
          }

          for (int i = 0; i < usersData.length; ++i) {
            User u = User.fromJson(jsonEncode(usersData[i]));
            users.add(u);
          }
        },
      );
    } catch (e) {
      print(e);
    }

    return [users, posts];
  }
}
