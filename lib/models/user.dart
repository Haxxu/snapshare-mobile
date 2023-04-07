import 'dart:convert';

class User {
  final String id;
  final String account;
  final String name;
  final String image;
  final String description;
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<dynamic>? savedPosts;
  final List<dynamic>? likedPosts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.account,
    required this.name,
    required this.image,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.followers,
    this.following,
    this.likedPosts,
    this.savedPosts,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'account': account,
        'name': name,
        'image': image,
        'description': description,
        'followers': followers,
        'following': following,
        'liked_posts': likedPosts,
        'saved_posts': savedPosts,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      account: map['account'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      followers: List<Map<String, dynamic>>.from(
        map['followers']?.map(
          (x) => Map<String, dynamic>.from(x),
        ),
      ),
      following: List<Map<String, dynamic>>.from(
        map['following']?.map(
          (x) => Map<String, dynamic>.from(x),
        ),
      ),
      likedPosts: map['liked_posts'] == null
          ? null
          : List<Map<String, dynamic>>.from(
              map['liked_posts']?.map(
                (x) => Map<String, dynamic>.from(x),
              ),
            ),
      savedPosts: map['saved_posts'] == null
          ? null
          : List<Map<String, dynamic>>.from(
              map['saved_posts']?.map(
                (x) => Map<String, dynamic>.from(x),
              ),
            ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? account,
    String? name,
    String? image,
    String? description,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<dynamic>? savedPosts,
    List<dynamic>? likedPosts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      account: account ?? this.account,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likedPosts: likedPosts ?? this.likedPosts,
      savedPosts: savedPosts ?? this.savedPosts,
      updatedAt: updatedAt ?? this.createdAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
