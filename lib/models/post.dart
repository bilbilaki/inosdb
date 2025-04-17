// lib/models/post.dart
class Post {
  final String id;
  final String channelName;
  final String channelAvatarUrl;
  final String timestamp;
  final String content;
  final String? imageUrl; // Optional image for the post
  final int likeCount;
  final int commentCount;

  Post({
    required this.id,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.timestamp,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
  });
}