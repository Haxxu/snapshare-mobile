import 'dart:convert';
import './user.dart';

class Post {
  final String id;
  final String title;
  final String owner;
  final String image;
  final String description;
  final List<dynamic>? likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
    this.likes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'owner': owner,
        'image': image,
        'description': description,
        'likes': likes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      owner: map['owner'] ?? '',
      // owner:
      //     map['user'] == null ? null : User.fromJson(jsonEncode(map['owner'])),
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

  factory Post.fromJson(String source) {
    return Post.fromMap(json.decode(source));
  }
}
