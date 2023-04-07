import 'dart:convert';

import './user.dart';

class Comment {
  final String id;
  final String content;
  final String owner;
  final String post;
  final List<dynamic>? likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.content,
    required this.owner,
    required this.post,
    required this.createdAt,
    required this.updatedAt,
    this.likes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'owner': owner,
        'post': post,
        'likes': likes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['_id'] ?? '',
      content: map['content'] ?? '',
      post: map['post'] ?? '',
      // owner: map['owner'] != null ? User.fromMap(map['owner']) : null,
      owner: map['owner'] ?? '',
      likes: List<Map<String, dynamic>>.from(
        map['likes']?.map(
          (x) => Map<String, dynamic>.from(x),
        ),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) {
    return Comment.fromMap(json.decode(source));
  }
}
