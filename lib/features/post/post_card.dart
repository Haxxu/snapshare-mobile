import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/widgets/like_animation.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  User? authUser;
  bool isLikeAnimting = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    authUser = Provider.of<AuthManager>(context, listen: false).user!;

    checkLikedPost(widget.post.id);
  }

  checkLikedPost(String postId) async {
    isLiked =
        await _postService.checkLikedPost(context: context, postId: postId);

    setState(() {});
  }

  likePost(String postId) async {
    _postService.likePost(context: context, postId: postId);
    setState(() {
      isLiked = true;
    });
  }

  unlikePost(String postId) async {
    _postService.unlikePost(context: context, postId: postId);
    setState(() {
      isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Column(
        children: [
          // HEADER SECTION
          FutureBuilder(
            future: _userService.getUserById(
              context: context,
              userId: widget.post.owner,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildOwnerSection(context, snapshot.data);
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),

          // IMAGE SECTION
          GestureDetector(
            onDoubleTap: () async {
              likePost(widget.post.id);
              setState(() {
                isLikeAnimting = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.post.image,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimting ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimting,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimting = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIKE COMMENT SECTION
          Row(
            children: [
              LikeAnimation(
                isAnimating: isLiked,
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    if (!isLiked) {
                      likePost(widget.post.id);
                    } else {
                      unlikePost(widget.post.id);
                    }
                  },
                  icon: isLiked
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(Icons.favorite_border_outlined),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection(BuildContext context, User? owner) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(owner!.image),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shrinkWrap: true,
                      children: [
                        SimpleDialogOption(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: const Text('Delete'),
                          onPressed: () async {
                            print('Delete post');
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: const Text('Delete'),
                          onPressed: () async {
                            print('Delete post');
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                );
              },
            );
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
