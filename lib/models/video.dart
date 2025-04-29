// lib/models/video.dart
class Video {
  final String id;
  final String thumbnailUrl;
  final String duration;
  final String title;
  final String channelName;
  final String channelAvatarUrl;
  final String viewCount;
  final String uploadedDate;

  Video({
    required this.id,
    required this.thumbnailUrl,
    required this.duration,
    required this.title,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.viewCount,
    required this.uploadedDate,
  });
}