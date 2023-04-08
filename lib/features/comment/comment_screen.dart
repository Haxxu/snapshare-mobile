// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapshare_mobile/features/comment/comment_card.dart';
import 'package:snapshare_mobile/models/comment.dart';

import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/comment_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class CommentScreen extends StatefulWidget {
  static const String routeName = '/comments';

  const CommentScreen({
    super.key,
    required this.postId,
    required this.postOwnerId,
  });

  final String postId;
  final String postOwnerId;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();

    fetchComments(widget.postId);
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  fetchComments(String postId) async {
    comments = await _commentService.getCommentsByPostId(
        context: context, postId: postId);
    setState(() {});
  }

  createNewComment(String postId, String content) async {
    Comment? comment = await _commentService.createNewComment(
        context: context, postId: postId, content: content);
    if (comment != null) {
      setState(() {
        comments.insert(0, comment);
        _commentController.text = '';
      });
    } else {
      showSnackBar(context, 'Post comment failure');
    }
  }

  deleteComment(String commentId) async {
    bool isDeleted = await _commentService.deleteComment(
        context: context, commentId: commentId);
    if (isDeleted) {
      setState(() {
        comments.removeWhere((element) => element.id == commentId);
      });
    } else {
      showSnackBar(context, 'Delete comment failure');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<AuthManager>(context).user!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Comments (${comments.length})'),
      ),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return CommentCard(
            comment: comments[index],
            postOwnerId: widget.postOwnerId,
            onDeleteComment: () => deleteComment(comments[index].id),
            key: UniqueKey(),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.image),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.account}',
                      border: InputBorder.none,
                    ),
                    controller: _commentController,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (_commentController.text.trim() != '') {
                    createNewComment(
                        widget.postId, _commentController.text.trim());
                  }
                  setState(() {
                    _commentController.text = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
