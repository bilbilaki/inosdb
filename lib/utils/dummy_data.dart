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
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimages8.alphacoders.com%2F136%2Fthumb-1920-1368293.jpeg&f=1&nofb=1&ipt=cd9de08dc7a2f77b548a0e9504a8e47c0be35a1507f2e692ff8a0b3b8f12d140', // Evanescence
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.xtrafondos.com%2Fwallpapers%2Fresoluciones%2F22%2Fmakima-chainsaw-man-opening_1920x1080_10849.jpg&f=1&nofb=1&ipt=9be02f0b83c8d9f2b1e6ba37423fc4522f041a2037257605b64551197ac6df65', // Songs for ....
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.ultimate-manga.com%2Fwallpapers%2Fdesktop-wallpaper-4k-jujutsu-kaisen.jpg&f=1&nofb=1&ipt=eb8a43756e58bfaa75c87cfbe831b902999bdf50b518657ebd6fe50f585316af', // Big Bang Bloopers
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwallpapercave.com%2Fwp%2Fwp8430817.jpg&f=1&nofb=1&ipt=8e8875a2a8c703ce3dbb674ac3a2af4929b3ef0fb350f94d62a074a921d5a43f', // Sia
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.nichegamer.com%2Fwp-content%2Fuploads%2F2023%2F04%2Fpseudo-harem-04-10-2023-e1681164828660.jpg&f=1&nofb=1&ipt=7f06c05d032d19be60bbb575e4f854a63db9f840bfdb887c7c416e0a9ac5b1df', // Flutter placeholder
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.jbox.com.br%2Fwp%2Fwp-content%2Fuploads%2F2024%2F05%2Fsenpai-otokonoko-destacada-2.jpg&f=1&nofb=1&ipt=b5ea7097ecfd97be5ead46390a0bfdfe978cf9a357919739a24af70868dad21a', // Nature placeholder
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fadala-news.fr%2Fwp-content%2Fuploads%2F2024%2F03%2FSenpai-wa-Otokonoko.webp&f=1&nofb=1&ipt=6d19693d1db8e4d1e6cbc3f1f7d3b21294d67ac86909e505ad90d79a99c6e7af', // Goals placeholder
  'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.animecorner.me%2F2024%2F03%2F1711257157-86206.png&f=1&nofb=1&ipt=5c9d737546b9334c87c3149cd95a249467a00f5961e4a126bf64f6bc9e7cc2d2', // Steak placeholder
];

List<String> _dummyAvatars = List.generate(
  10,
  (index) => 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.animecorner.me%2F2024%2F03%2F1711257157-86206.png&f=1&nofb=1&ipt=5c9d737546b9334c87c3149cd95a249467a00f5961e4a126bf64f6bc9e7cc2d2',
);
List<String> _dummyPostImages = List.generate(
  5,
  (index) => 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.nichegamer.com%2Fwp-content%2Fuploads%2F2023%2F04%2Fpseudo-harem-04-10-2023-e1681164828660.jpg&f=1&nofb=1&ipt=7f06c05d032d19be60bbb575e4f854a63db9f840bfdb887c7c416e0a9ac5b1df',
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
