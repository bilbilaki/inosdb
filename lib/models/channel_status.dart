// lib/models/channel_status.dart
class ChannelStatus {
  final String id;
  final String channelName;
  final String avatarUrl;
  final bool hasNewStory; // To show a ring indicator

  ChannelStatus({
    required this.id,
    required this.channelName,
    required this.avatarUrl,
    this.hasNewStory = false,
  });
}