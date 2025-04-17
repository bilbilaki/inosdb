// lib/screens/subscriptions_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/models/video.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/dummy_data.dart';
import 'package:myapp/utils/dynamic_background.dart';
import 'package:myapp/widgets/post_card.dart';
import 'package:myapp/widgets/status_bar.dart';
import 'package:myapp/widgets/video_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<dynamic> _feedItems = []; // Can contain Videos or Posts
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptionFeed();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadSubscriptionFeed() async {
     if (_isLoading) return;
     setState(() { _isLoading = true; });

     // Simulate fetching a mix of videos and posts
     await Future.delayed(const Duration(milliseconds: 500));
     final videos = generateDummyVideos(5);
     final posts = generateDummyPosts(3);
     final combined = [...videos, ...posts]..shuffle(); // Mix them up

     setState(() {
       _feedItems = combined;
       _isLoading = false;
     });
  }

  Future<void> _loadMoreFeedItems() async {
    if (_isLoading) return;
     setState(() { _isLoading = true; });

     await Future.delayed(const Duration(seconds: 1));
     final moreVideos = generateDummyVideos(3);
     final morePosts = generateDummyPosts(2);
     final moreCombined = [...moreVideos, ...morePosts]..shuffle();

     setState(() {
       _feedItems.addAll(moreCombined);
       _isLoading = false;
     });
  }

   void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading) {
       _loadMoreFeedItems();
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      child: Column(
         children: [
           // Status bar showing subscribed channels
           StatusBar(), // Reuse status bar for subscribed channels
           const Divider(height: 1, color: AppColors.dividerColor),
           Expanded(
             child: _isLoading && _feedItems.isEmpty
                 ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor))
                 : RefreshIndicator(
                     onRefresh: _loadSubscriptionFeed,
                     color: AppColors.accentColor,
                     backgroundColor: AppColors.secondaryBackground,
                     child: ListView.builder(
                       controller: _scrollController,
                       itemCount: _feedItems.length + (_isLoading ? 1 : 0),
                       itemBuilder: (context, index) {
                         if (index >= _feedItems.length) {
                           return const Padding(
                               padding: EdgeInsets.symmetric(vertical: 20.0),
                               child: Center(child: CircularProgressIndicator(color: AppColors.accentColor)),
                             );
                         }

                         final item = _feedItems[index];
                         if (item is Video) {
                           return VideoCard(video: item);
                         } else if (item is Post) {
                           return PostCard(post: item);
                         }
                         return const SizedBox.shrink(); // Should not happen
                       },
                     ),
                 ),
           ),
         ],
      ),
    );
  }
}