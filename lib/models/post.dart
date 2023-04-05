import 'package:flutter/foundation.dart';

class Post {
  final String title;
  final String id;
  final String owner;
  final String image;
  final List likes;
  final String description;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.title,
    required this.id,
    required this.owner,
    required this.likes,
    required this.image,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'owner': owner,
        '_id': id,
        'image': image,
        'description': description,
        'likes': likes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['account'],
      owner: json['owner'],
      likes: json['likes'],
      id: json['_id'],
      image: json['image'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
