// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapshare_mobile/features/post/post_card.dart';
import 'package:snapshare_mobile/features/user/edit_user_screen.dart';
import 'package:snapshare_mobile/features/user/followers_screen.dart';
import 'package:snapshare_mobile/features/user/following_screen.dart';
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
  AuthService authService = AuthService();
  PostService postService = PostService();
  User? user;
  List<Post> posts = [];
  List<Post> savedPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
    fetchUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  deletePost(String postId) async {
    bool isDeleted =
        await postService.deletePost(context: context, postId: postId);
    if (isDeleted) {
      setState(() {
        posts.removeWhere((element) => element.id == postId);
      });
    } else {
      showSnackBar(context, 'Delete post failure');
    }
  }

  getData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      user = await authService.getUserData(context);

      posts = await postService.getPostsByUserId(
          context: context, userId: user!.id);

      savedPosts = await postService.getSavedPosts(context: context);

      // print(posts![1].owner);
    } catch (e) {
      // print(e.toString());
      showSnackBar(context, e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  fetchUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      user = await authService.getUserData(context);

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
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  title: Text(user?.account ?? ''),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, EditUserScreen.routeName)
                            .then(
                          (_) {
                            fetchUser();
                            getData();
                          },
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
                body: Column(
                  children: [
                    buildInforSection(),
                    const TabBar(
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'My Posts'),
                        Tab(text: 'Saved Posts'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                post: posts[index],
                                key: UniqueKey(),
                                onDeletePost: () => deletePost(posts[index].id),
                              );
                            },
                          ),
                          ListView.builder(
                            itemCount: savedPosts.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                post: savedPosts[index],
                                key: UniqueKey(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildInforSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user!.image),
                radius: 50,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStackColumn(
                          posts.length,
                          'posts',
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowersScreen(userId: user?.id ?? ''),
                                  ),
                                )
                                .then((value) => fetchUser());
                          },
                          child: buildStackColumn(
                            user?.followers?.length ?? 0,
                            'followers',
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowingScreen(userId: user?.id ?? ''),
                                  ),
                                )
                                .then((value) => fetchUser());
                          },
                          child: buildStackColumn(
                            user?.following?.length ?? 0,
                            'followings',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              user?.name ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              user?.description ?? '',
            ),
          ),
          // const Divider(),
        ],
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
