import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/features/comment/comment_screen.dart';
import 'package:snapshare_mobile/models/comment.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/comment_service.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/widgets/like_animation.dart';

class PostCard extends StatefulWidget {
  final Post post;
  PostCard({super.key, required this.post, this.onDeletePost});
  Function()? onDeletePost;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();
  User? authUser;
  User? owner;
  bool isLikeAnimting = false;
  bool isLiked = false;
  bool isSaved = false;
  int totalLikes = 0;
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();

    authUser = Provider.of<AuthManager>(context, listen: false).user;

    checkLikedPost(widget.post.id);
    checkSavedPost(widget.post.id);
    fetchOwnerData(widget.post.owner);
    fetchCommentsData(widget.post.id);
    fetchData();
  }

  fetchData() async {
    totalLikes = widget.post.likes?.length ?? 0;

    setState(() {});
  }

  fetchCommentsData(String postId) async {
    comments = await _commentService.getCommentsByPostId(
        context: context, postId: postId);

    setState(() {});
  }

  fetchOwnerData(String ownerId) async {
    owner = await _userService.getUserById(context: context, userId: ownerId);

    setState(() {});
  }

  checkLikedPost(String postId) async {
    isLiked =
        await _postService.checkLikedPost(context: context, postId: postId);

    setState(() {});
  }

  likePost(String postId) async {
    _postService.likePost(context: context, postId: postId);

    setState(() {
      totalLikes++;
      isLiked = true;
    });
  }

  unlikePost(String postId) async {
    _postService.unlikePost(context: context, postId: postId);
    setState(() {
      totalLikes--;
      isLiked = false;
    });
  }

  checkSavedPost(String postId) async {
    isSaved =
        await _postService.checkSavedPost(context: context, postId: postId);

    setState(() {});
  }

  savePost(String postId) async {
    _postService.savePost(context: context, postId: postId);
    setState(() {
      isSaved = true;
    });
  }

  unsavePost(String postId) async {
    _postService.unsavePost(context: context, postId: postId);
    setState(() {
      isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: mobileBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: mobileBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
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
                return _buildOwnerSection(context, snapshot.data!);
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
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => CommentScreen(
                              postId: widget.post.id,
                              postOwnerId: widget.post.owner),
                        ),
                      )
                      .then((_) => fetchCommentsData(widget.post.id));
                },
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: LikeAnimation(
                    isAnimating: isSaved,
                    child: IconButton(
                      icon: isSaved
                          ? const Icon(Icons.bookmark)
                          : const Icon(Icons.bookmark_border),
                      onPressed: () {
                        if (!isSaved) {
                          savePost(widget.post.id);
                        } else {
                          unsavePost(widget.post.id);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          // DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w400),
                      child: Text(
                        '$totalLikes likes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    DefaultTextStyle(
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w400),
                      child: Text(
                        '${comments.length} comments',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: owner?.account ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.post.title}',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(
                      widget.post.createdAt,
                    ),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection(BuildContext context, User owner) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(owner.image),
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
                      Visibility(
                        visible: owner.id == authUser?.id,
                        child: SimpleDialogOption(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: const Text('Delete'),
                          onPressed: () async {
                            if (widget.onDeletePost != null) {
                              widget.onDeletePost!();
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
