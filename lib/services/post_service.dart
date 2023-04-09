// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/constants/api_urls.dart';
import 'package:snapshare_mobile/models/post.dart';
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

  Future<List<Post>> getSavedPosts({
    required BuildContext context,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    List<Post> postList = [];

    try {
      http.Response res = await http.get(
        Uri.parse(getSavedPostsUrl()),
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
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return postList;
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
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return postList;
  }

  Future<List<Post>> getHomePagePosts({
    required BuildContext context,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    final String userId =
        Provider.of<AuthManager>(context, listen: false).user!.id;
    List<Post> postList = [];

    try {
      final uri = Uri.parse(getRandomPostsUrl());
      final queryParams = {
        'tags': ["random"],
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
          // print(jsonEncode(jsonDecode(res.body)['data']));
          List<dynamic> data = jsonDecode(res.body)['data']['random'];
          for (int i = 0; i < data.length; ++i) {
            // print(jsonEncode(data[i]['owner']));
            Post p = Post.fromJson(jsonEncode(data[i]));
            postList.add(p);
          }
        },
      );

      final uri1 = Uri.parse(getFollowingUsersPostsByUserIdUrl(userId));
      final queryParams1 = {'limit': '5'};
      final uriWithQueryParams1 = uri1.replace(queryParameters: queryParams1);

      http.Response res1 = await http.get(
        uriWithQueryParams1,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      httpErrorHandle(
        response: res1,
        context: context,
        onSuccess: () {
          // print(jsonEncode(jsonDecode(res.body)['data']));
          List<dynamic> data = jsonDecode(res1.body)['data'];
          for (int i = 0; i < data.length; ++i) {
            // print(jsonEncode(data[i]['owner']));
            Post p = Post.fromJson(jsonEncode(data[i]));
            postList.add(p);
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    postList.shuffle();
    return postList;
  }

  Future<bool> checkLikedPost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isLiked = false;

    try {
      http.Response res = await http.get(
        Uri.parse(checkLikedPostUrl(postId)),
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

  void likePost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.put(
        Uri.parse(likePostUrl(postId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'post': postId,
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

  void unlikePost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.delete(
        Uri.parse(unlikePostUrl(postId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'post': postId,
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

  Future<bool> checkSavedPost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isLiked = false;

    try {
      http.Response res = await http.get(
        Uri.parse(checksavedPostUrl(postId)),
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

  void savePost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.put(
        Uri.parse(savePostUrl(postId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'post': postId,
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

  void unsavePost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.delete(
        Uri.parse(unsavePostUrl(postId)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'post': postId,
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

  Future<bool> deletePost({
    required BuildContext context,
    required String postId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isDeleted = false;

    try {
      http.Response res = await http.delete(
        Uri.parse(deletePostByIdUrl(postId)),
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
}
