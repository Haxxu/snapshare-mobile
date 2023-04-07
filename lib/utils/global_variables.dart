import 'package:flutter/material.dart';
import 'package:snapshare_mobile/features/home/home_screen.dart';

import 'package:snapshare_mobile/features/user/profile_screen.dart';
import 'package:snapshare_mobile/screens/screens.dart';

List<Widget> mainScreenItems = [
  const HomeScreen(),
  const Text('Search Screen'),
  const AddPostScreen(),
  const ProfileScreen(),
];
