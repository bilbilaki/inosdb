import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const YouTubeCloneApp());
}

class YouTubeCloneApp extends StatelessWidget {
  const YouTubeCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Clone',
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const SubscriptionsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final List<ChannelStory> stories = [
    ChannelStory(name: 'Vevo', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/6w8mKcd4p04QaQO0FlGpmhWbSAm.jpg'),
    ChannelStory(name: 'BeatLove', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/2ZWHz2jNaxWhM3JXr56QR4hPUJl.jpg'),
    ChannelStory(name: 'Stake Music', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/uzHMp5heVLR68kbbUEXFPsmxYsM.jpg'),
    ChannelStory(name: 'Big Bang', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/6w8mKcd4p04QaQO0FlGpmhWbSAm.jpg'),
    ChannelStory(name: 'Kouman', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/2ZWHz2jNaxWhM3JXr56QR4hPUJl.jpg'),
    ChannelStory(name: 'Gaming', imageUrl: 'https://inosdb.worker-inosuke.workers.dev/w500/uzHMp5heVLR68kbbUEXFPsmxYsM.jpg'),
  ];

  final List<VideoPost> posts = [
    VideoPost(
      channelName: 'BeatLove',
      title: 'Eminem, 2Pac, Jelly Roll, NF, Halsey, Rihanna, Ed Sheeran, Taylor Swift, Skylar Grey | XL MIX',
      views: '748K views',
      timeAgo: '5 months ago',
      thumbnail: 'https://inosdb.worker-inosuke.workers.dev/w1280/2ZWHz2jNaxWhM3JXr56QR4hPUJl.jpg',
      isShort: false,
      likes: '45K',
    ),
    VideoPost(
      channelName: 'Stake Music',
      title: 'Songs and theatre video',
      views: '120K views',
      timeAgo: '3 weeks ago',
      thumbnail: 'https://inosdb.worker-inosuke.workers.dev/w1280/uzHMp5heVLR68kbbUEXFPsmxYsM.jpg',
      isShort: true,
      likes: '8.2K',
    ),
    VideoPost(
      channelName: 'Big Bang Theory',
      title: 'Thankable materials from Seasons +9 (Y\'all 4)',
      views: '2.1M views',
      timeAgo: '6 months ago',
      thumbnail: 'https://inosdb.worker-inosuke.workers.dev/w1280/6w8mKcd4p04QaQO0FlGpmhWbSAm.jpg',
      isShort: false,
      likes: '150K',
    ),
    VideoPost(
      channelName: 'Vevo',
      title: 'Mix - Mikey Cyrus - Slide Away (Official Video)',
      views: 'Updated today',
      timeAgo: '',
      thumbnail: 'https://inosdb.worker-inosuke.workers.dev/w1280/2ZWHz2jNaxWhM3JXr56QR4hPUJl.jpg',
      isShort: false,
      likes: '12K',
    ),
    VideoPost(
      channelName: 'Kouman',
      title: 'Ilihybiri: a lot are you lucky to have a job!',
      views: '402K views',
      timeAgo: '12 hours ago',
      thumbnail: 'https://inosdb.worker-inosuke.workers.dev/w1280/uzHMp5heVLR68kbbUEXFPsmxYsM.jpg',
      isShort: true,
      likes: '32K',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stories section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(stories[index].imageUrl),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stories[index].name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Videos section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= posts.length) {
                  // Simulate loading more items
                  return const Center(child: CircularProgressIndicator());
                }
                return VideoPostCard(post: posts[index]);
              },
              childCount: posts.length + 1, // +1 for loading indicator
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.play_circle), label: 'Shorts'),
          BottomNavigationBarItem(icon: Icon(Iconsax.video), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: Icon(Iconsax.music), label: 'Music'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'You'),
        ],
      ),
    );
  }
}

class ChannelStory {
  final String name;
  final String imageUrl;

  ChannelStory({required this.name, required this.imageUrl});
}

class VideoPost {
  final String channelName;
  final String title;
  final String views;
  final String timeAgo;
  final String thumbnail;
  final bool isShort;
  final String likes;

  VideoPost({
    required this.channelName,
    required this.title,
    required this.views,
    required this.timeAgo,
    required this.thumbnail,
    required this.isShort,
    required this.likes,
  });
}

class VideoPostCard extends StatelessWidget {
  final VideoPost post;

  const VideoPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail with duration/type indicator
        Stack(
          children: [
            post.isShort
                ? SizedBox(
                    height: 500,
                    width: double.infinity,
                    child: Image.network(
                      post.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      post.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  post.isShort ? 'SHORT' : '12:34',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Channel icon
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/backdrop_127532.jpg'),
              ),
              const SizedBox(width: 12),
              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.channelName} • ${post.views}${post.timeAgo.isNotEmpty ? ' • ${post.timeAgo}' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Iconsax.like_1),
                onPressed: () {},
              ),
              Text(post.likes),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Iconsax.dislike),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Iconsax.message),
                onPressed: () {},
              ),
              const Text('Comments'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Iconsax.share),
                onPressed: () {},
              ),
              const Text('Share'),
            ],
          ),
        ),
        
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}