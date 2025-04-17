// lib/utils/dummy_data.dart
import 'package:myapp/models/video.dart';
import 'package:myapp/models/channel_status.dart';
import 'package:myapp/models/post.dart';
import 'dart:math';

// Basic random data generator
final Random _random = Random();

List<String> _dummyTitles = [
  'Evanescence - Afterlife (Official Lyric Video)',
  'Songs for when you\'re feeling good',
  'The big bang theory season 7 bloopers',
  'Sia - Bird Set free (Music Video Sora)',
  'Flutter Crash Course for Beginners 2024',
  'Amazing Nature Documentary HD',
  'Top 10 Goals of the Week',
  'How to Cook the Perfect Steak',
  'React Native vs Flutter - Deep Dive',
  'Lo-fi Hip Hop Radio - Beats to Relax/Study to',
];

List<String> _dummyChannels = [
  'Evanescence',
  'Shake Music',
  'AYNTK',
  'NeoCraft',
  'FlutterDev',
  'NaturePlus',
  'FootballHighlights',
  'Chef John',
  'Coding Explained',
  'Chillhop Music',
];

List<String> _dummyThumbnails = [
  'https://i.ytimg.com/vi/EDZn9rk6L4M/hq720.jpg', // Evanescence
  'https://i.ytimg.com/vi/Dx5qFachd3A/hq720.jpg', // Songs for ....
  'https://i.ytimg.com/vi/W7QZnwKqopo/hq720.jpg', // Big Bang Bloopers
  'https://i.ytimg.com/vi/KrPt4pXEUcQ/hq720.jpg', // Sia
  'https://i.ytimg.com/vi/5qap5aO4i9A/hq720.jpg', // Flutter placeholder
  'https://i.ytimg.com/vi/6lt2JfJdGSY/hqdefault.jpg', // Nature placeholder
  'https://i.ytimg.com/vi/RvVfgvUGSWE/hqdefault.jpg', // Goals placeholder
  'https://i.ytimg.com/vi/3zK3uNQTHdw/hqdefault.jpg', // Steak placeholder
  'https://i.ytimg.com/vi/22HxMVKg0IQ/hqdefault.jpg', // React Native vs Flutter placeholder
  'https://i.ytimg.com/vi/5qap5aO4i9A/hq720.jpg', // Lofi placeholder
];

List<String> _dummyAvatars = List.generate(
  10,
  (index) => 'https://i.pravatar.cc/40?img=${index + 1}',
);
List<String> _dummyPostImages = List.generate(
  5,
  (index) => 'https://picsum.photos/seed/${index + 50}/600/400',
);

String _randomDuration() {
  final mins = _random.nextInt(50) + 1; // 1 to 50 mins
  final secs = _random.nextInt(60);
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String _randomViewCount() {
  final count = _random.nextInt(5000) + 0.5; // 500 to 5.5M views
  if (count > 1000) {
    return '${(count / 1000).toStringAsFixed(1)}M views';
  } else {
    return '${count.toStringAsFixed(1)}K views';
  }
}

String _randomDate() {
  final days = _random.nextInt(365);
  if (days < 1) return 'few hours ago';
  if (days < 7) return '$days days ago';
  if (days < 30) return '${(days / 7).floor()} weeks ago';
  if (days < 365) return '${(days / 30).floor()} months ago';
  return '${(days / 365).floor()} years ago';
}

Video generateDummyVideo(int index) {
  final i = index % _dummyTitles.length;
  return Video(
    id: 'vid_$index',
    thumbnailUrl: _dummyThumbnails[i],
    duration: _randomDuration(),
    title: _dummyTitles[i] + (_random.nextBool() ? ' - Part ${index % 5}' : ''),
    channelName: _dummyChannels[i],
    channelAvatarUrl: _dummyAvatars[i],
    viewCount: _randomViewCount(),
    uploadedDate: _randomDate(),
  );
}

List<Video> generateDummyVideos(int count) {
  return List.generate(count, (index) => generateDummyVideo(index));
}

List<ChannelStatus> generateDummyStatuses(int count) {
  return List.generate(count, (index) {
    final i = index % _dummyChannels.length;
    return ChannelStatus(
      id: 'status_$index',
      channelName: _dummyChannels[i].split(' ').first, // Shorter name
      avatarUrl: _dummyAvatars[i],
      hasNewStory: _random.nextDouble() > 0.6, // 40% chance of new story
    );
  });
}

List<Post> generateDummyPosts(int count) {
  return List.generate(count, (index) {
    final i = index % _dummyChannels.length;
    return Post(
      id: 'post_$index',
      channelName: _dummyChannels[i],
      channelAvatarUrl: _dummyAvatars[i],
      timestamp: _randomDate(),
      content:
          'This is some post content generated for testing purposes. ${_dummyTitles[i]}. What do you think? #${_dummyChannels[i].replaceAll(' ', '')} #FlutterDev',
      imageUrl:
          _random.nextBool()
              ? _dummyPostImages[index % _dummyPostImages.length]
              : null,
      likeCount: _random.nextInt(1500),
      commentCount: _random.nextInt(200),
    );
  });
}

// Simulates fetching more data
Future<List<Video>> fetchMoreVideos(int currentLength, {int count = 10}) async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
  return List.generate(
    count,
    (index) => generateDummyVideo(currentLength + index),
  );
}

Future<List<Post>> fetchMorePosts(int currentLength, {int count = 5}) async {
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return generateDummyPosts(count);
}

List<String> getChipLabels() {
  return [
    'All',
    'Music',
    'How I Met Your Mother',
    'Melbourne shuffle',
    'Mixes',
    'Playlists',
    'Live',
    'Dramedy',
    'Sketch comedy',
    'Manga',
    'Gaming',
    'Recently uploaded',
    'Watched',
  ];
}
