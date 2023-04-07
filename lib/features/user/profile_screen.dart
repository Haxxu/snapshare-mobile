// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapshare_mobile/features/user/edit_user_screen.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/screens/screens.dart';
import 'package:snapshare_mobile/services/auth_service.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  List<Post>? posts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();
    PostService postService = PostService();

    try {
      user = await authService.getUserData(context);

      posts = await postService.getPostsByUserId(
          context: context, userId: user!.id);

      // print(posts![1].owner);
    } catch (e) {
      // print(e.toString());
      showSnackBar(context, e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  logout() async {
    await Provider.of<AuthManager>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                title: Text(user!.name),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, EditUserScreen.routeName)
                          .then(
                        (_) => getData(),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => logout(),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(user!.image),
                              radius: 40,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStackColumn(
                                        posts!.length,
                                        'posts',
                                      ),
                                      buildStackColumn(
                                        user!.followers!.length,
                                        'followers',
                                      ),
                                      buildStackColumn(
                                        user!.following!.length,
                                        'followings',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Column buildStackColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
