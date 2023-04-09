// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/constants/api_urls.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/utils/error_handling.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class UserService {
  Future<User?> updateUserByUserId({
    required BuildContext context,
    required String name,
    required String description,
    required String image,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    User? user;

    try {
      http.Response res =
          await http.patch(Uri.parse(updateUserByUserIdUrl(userId)),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': token,
              },
              body: jsonEncode({
                'name': name,
                'description': description,
                'image': image,
              }));

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          user = User.fromJson(jsonEncode(jsonDecode(res.body)['data']));
          Provider.of<AuthManager>(context, listen: false)
              .setUser(jsonEncode(jsonDecode(res.body)['data']));
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return user;
  }

  Future<User?> getUserById({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    User? user;

    try {
      http.Response res =
          await http.get(Uri.parse(getUserByIdUrl(userId)), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // user = User.fromJson(jsonEncode(jsonDecode(res.body)['data']));
          user = User.fromMap(jsonDecode(res.body)['data']['user']);
        },
      );
    } catch (e) {
      print(e);
      // showSnackBar(context, e.toString());
    }

    return user;
  }

  Future<bool> checkFollowUser({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    bool isFollowing = false;

    try {
      http.Response res = await http.get(
        Uri.parse(checkFollowUserUrl(userId)),
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
          isFollowing = jsonDecode(res.body)['data'];
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return isFollowing;
  }

  Future<void> followUser({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.put(
        Uri.parse(followUserUrl()),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'user': userId,
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

  Future<void> unfollowUser({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';

    try {
      http.Response res = await http.delete(
        Uri.parse(unfollowUserUrl()),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'user': userId,
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

  Future<List<User>> getFollowingByUserId({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    List<User> userList = [];

    try {
      http.Response res = await http.get(
        Uri.parse(getFollowingByUserIdUrl(userId)),
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
            User u = User.fromJson(jsonEncode(data[i]));
            userList.add(u);
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return userList;
  }

  Future<List<User>> getFollowersByUserId({
    required BuildContext context,
    required String userId,
  }) async {
    final String token =
        Provider.of<AuthManager>(context, listen: false).xAuthToken ?? '';
    List<User> userList = [];

    try {
      http.Response res = await http.get(
        Uri.parse(getFollowersByUserIdUrl(userId)),
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
            User u = User.fromJson(jsonEncode(data[i]));
            userList.add(u);
          }
        },
      );
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }

    return userList;
  }
}
