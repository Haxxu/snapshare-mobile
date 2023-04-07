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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _postService.getHomePagePosts(context: context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return PostCard(post: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
