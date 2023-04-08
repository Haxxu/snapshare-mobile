// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:snapshare_mobile/features/post/post_card.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  List<Post> posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchHomePagePosts();
  }

  deletePost(String postId) async {
    bool isDeleted =
        await _postService.deletePost(context: context, postId: postId);
    if (isDeleted) {
      setState(() {
        posts.removeWhere((element) => element.id == postId);
      });
    } else {
      showSnackBar(context, 'Delete post failure');
    }
  }

  fetchHomePagePosts() async {
    setState(() {
      _isLoading = true;
    });

    posts = await _postService.getHomePagePosts(context: context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  onDeletePost: () => deletePost(posts[index].id),
                );
              },
            ),
    );

    // return Scaffold(
    //   body: FutureBuilder(
    //     future: _postService.getHomePagePosts(context: context),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return ListView.builder(
    //           itemCount: snapshot.data?.length ?? 0,
    //           itemBuilder: (context, index) {
    //             return PostCard(
    //               post: snapshot.data![index],
    //               key: UniqueKey(),
    //             );
    //           },
    //         );
    //       } else if (snapshot.hasError) {
    //         return Text('Error: ${snapshot.error}');
    //       } else {
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //     },
    //   ),
    // );
  }
}
