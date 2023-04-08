import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapshare_mobile/features/comment/comment_card.dart';
import 'package:snapshare_mobile/models/comment.dart';

import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/providers/auth_manager.dart';
import 'package:snapshare_mobile/services/comment_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';

class CommentScreen extends StatefulWidget {
  static const String routeName = '/comments';

  const CommentScreen({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
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
        itemBuilder: (context, index) => CommentCard(comment: comments[index]),
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
                    print('post');
                    fetchComments(widget.postId);
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
