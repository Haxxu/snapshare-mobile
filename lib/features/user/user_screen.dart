// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapshare_mobile/features/post/post_card.dart';
import 'package:snapshare_mobile/features/user/followers_screen.dart';
import 'package:snapshare_mobile/features/user/following_screen.dart';
import 'package:snapshare_mobile/models/post.dart';

import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/utils/utils.dart';
import 'package:snapshare_mobile/widgets/follow_button.dart';

// ignore: must_be_immutable
class UserScreen extends StatefulWidget {
  String userId;
  UserScreen({super.key, required this.userId});

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  PostService postService = PostService();
  UserService userService = UserService();
  bool _isLoading = false;
  bool _isFollowing = false;
  List<Post> posts = [];
  int totalFollowers = 0;
  int totalFollowing = 0;
  User? user;

  @override
  void initState() {
    super.initState();

    fetchData();
    checkFollowUser();
  }

  fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      user = await userService.getUserById(
        context: context,
        userId: widget.userId,
      );

      posts = await postService.getPostsByUserId(
        context: context,
        userId: widget.userId,
      );

      totalFollowers = user?.followers?.length ?? 0;
      totalFollowing = user?.following?.length ?? 0;

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
      user = await userService.getUserById(
        context: context,
        userId: widget.userId,
      );

      totalFollowers = user?.followers?.length ?? 0;
      totalFollowing = user?.following?.length ?? 0;
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  checkFollowUser() async {
    _isFollowing = await userService.checkFollowUser(
      context: context,
      userId: widget.userId,
    );
    setState(() {});
  }

  followUser(String userId) async {
    await userService.followUser(context: context, userId: userId);

    setState(() {
      totalFollowers++;
      _isFollowing = true;
    });

    await checkFollowUser();
  }

  unfollowUser(String userId) async {
    await userService.unfollowUser(context: context, userId: userId);

    setState(() {
      totalFollowers--;
      _isFollowing = false;
    });

    await checkFollowUser();
  }

  @override
  Widget build(BuildContext context) {
    User? authUser = Provider.of<AuthManager>(context).user;
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  title: Text(user?.account ?? ''),
                ),
                body: Column(
                  children: [
                    buildInforSection(authUser),
                    const TabBar(
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Posts'),
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

  Widget buildInforSection(User? authUser) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user?.image ?? ''),
                radius: 50,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isFollowing
                            ? FollowButton(
                                text: 'Unfollow',
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.grey,
                                function: () async {
                                  unfollowUser(user!.id);
                                },
                              )
                            : FollowButton(
                                text: 'Follow',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                function: () async {
                                  followUser(user!.id);
                                },
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
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
                                        FollowersScreen(userId: widget.userId),
                                  ),
                                )
                                .then((value) => fetchUser());
                          },
                          child: buildStackColumn(
                            totalFollowers,
                            'followers',
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowingScreen(userId: widget.userId),
                                  ),
                                )
                                .then((value) => fetchUser());
                          },
                          child: buildStackColumn(
                            totalFollowing,
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
