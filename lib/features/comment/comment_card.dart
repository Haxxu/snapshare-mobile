import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/models/comment.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/comment_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/time.dart';
import 'package:snapshare_mobile/widgets/like_animation.dart';

// ignore: must_be_immutable
class CommentCard extends StatefulWidget {
  final Comment comment;
  CommentCard({
    super.key,
    required this.comment,
    required this.onDeleteComment,
    required this.postOwnerId,
  });

  Function() onDeleteComment;
  String postOwnerId;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final UserService _userService = UserService();
  final CommentService _commentService = CommentService();
  User? owner;
  bool isLiked = false;
  int totalLikes = 0;

  @override
  void initState() {
    super.initState();

    fetchOwnerData();
    totalLikes = widget.comment.likes?.length ?? 0;
    checkLikedComment(widget.comment.id);
  }

  fetchOwnerData() async {
    User? owner1 = await _userService.getUserById(
        context: context, userId: widget.comment.owner);

    setState(() {
      owner = owner1;
    });
  }

  checkLikedComment(String commentId) async {
    isLiked = await _commentService.checkLikedComment(
        context: context, commentId: commentId);
    setState(() {});
  }

  likeComment(String commentId) async {
    _commentService.likeComment(context: context, commentId: commentId);
    setState(() {
      totalLikes++;
      isLiked = true;
    });
  }

  unlikeComment(String commentId) async {
    _commentService.unlikeComment(context: context, commentId: commentId);
    setState(() {
      totalLikes--;
      isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? authUser = Provider.of<AuthManager>(context).user;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              owner?.image ?? '',
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: owner?.account ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.comment.content}',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        getTimeAgo(widget.comment.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shrinkWrap: true,
                                  children: [
                                    Visibility(
                                      visible: owner?.id == authUser?.id ||
                                          widget.postOwnerId == authUser?.id,
                                      child: SimpleDialogOption(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        child: const Text('Delete comment'),
                                        onPressed: () async {
                                          widget.onDeleteComment();
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
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LikeAnimation(
                isAnimating: isLiked,
                smallLike: true,
                child: SizedBox(
                  height: 35,
                  child: IconButton(
                    onPressed: () async {
                      if (!isLiked) {
                        likeComment(widget.comment.id);
                      } else {
                        unlikeComment(widget.comment.id);
                      }
                    },
                    icon: isLiked
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          )
                        : const Icon(
                            Icons.favorite_border_outlined,
                            size: 15,
                          ),
                  ),
                ),
              ),
              Visibility(
                visible: totalLikes > 0,
                child: Text(
                  '$totalLikes',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
