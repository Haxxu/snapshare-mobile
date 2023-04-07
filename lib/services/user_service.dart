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
}
