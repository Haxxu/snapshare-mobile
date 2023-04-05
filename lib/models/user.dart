class User {
  final String account;
  final String name;
  final String id;
  final String image;
  final String description;
  final List followers;
  final List following;
  final List? savedPosts;
  final List? likedPosts;
  final String createdAt;
  final String updatedAt;
  // final String

  const User({
    required this.account,
    required this.name,
    required this.id,
    required this.image,
    required this.description,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
    this.likedPosts,
    this.savedPosts,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'account': account,
        '_id': id,
        'image': image,
        'description': description,
        'followers': followers,
        'following': following,
        'saved_posts': savedPosts,
        'liked_posts': likedPosts,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static User fromJson(Map<String, dynamic> json) {
    return User(
      account: json['account'],
      name: json['name'],
      id: json['_id'],
      image: json['image'],
      description: json['description'],
      followers: json['followers'],
      following: json['followings'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
