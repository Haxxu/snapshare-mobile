import 'dart:convert';

import 'package:snapshare_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  if (response.statusCode == 200) {
    onSuccess();
  } else if (response.statusCode >= 400 && response.statusCode < 500) {
    showSnackBar(context, jsonDecode(response.body)['message']);
  } else if (response.statusCode >= 500) {
    showSnackBar(context, jsonDecode(response.body)['message']);
  } else {
    showSnackBar(context, response.body);
  }
}
