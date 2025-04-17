// lib/widgets/custom_side_drawer.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/library_screen.dart';
import 'package:myapp/screens/subscriptions_screen.dart';
import 'package:myapp/screens/tv_series_grid_screen.dart';
import 'package:myapp/utils/colors.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a basic structure. Populate with actual YouTube drawer items.
    return Material(
      child: Container(
        width: 280, // Typical drawer width
        color: AppColors.secondaryBackground, // Slightly different background
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Header (optional, can be customized)
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top, // Match AppBar height + status bar
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                ),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                // Add Logo and Menu button like in AppBar
                 child: Row(
                   children: [
                     IconButton(
                       icon: const Icon(Icons.menu, color: AppColors.iconColor),
                       onPressed: () {
                         // Use Provider or callback to close the drawer
                         Navigator.of(context).pop(); // Simplest way if using standard Scaffold.drawer
                       },
                     ),
                     const SizedBox(width: 10),
                     Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/YouTube_Logo_2017.svg/100px-YouTube_Logo_2017.svg.png',
                         height: 20,
                       ),
                   ],
                 ),
              ),
            ),
            _buildDrawerItem(Icons.home_outlined, 'Home',() {
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            }),
            _buildDrawerItem(Icons.explore_outlined, 'Explore',() {
           //   Navigator.push(context, MaterialPageRoute(builder: (context) => const TvSeriesGridScreen()));
            }),
            _buildDrawerItem(Icons.movie_outlined, 'Shorts',() {
           //   Navigator.push(context, MaterialPageRoute(builder: (context) => const AnimeGridScreen()));
            }),
            _buildDrawerItem(Icons.subscriptions_outlined, 'Subscriptions',() {
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionsScreen()));
            }),
            const Divider(color: AppColors.dividerColor, height: 1),
             _buildDrawerItem(Icons.video_library_outlined, 'Library', () {
          //        Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryScreen()));
             }),
             _buildDrawerItem(Icons.history_outlined, 'History', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History is not implemented yet')));
             }),
             _buildDrawerItem(Icons.slideshow_outlined, 'Your videos', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your videos is not implemented yet')));
             }),
             _buildDrawerItem(Icons.download_outlined, 'Downloads', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloads is not implemented yet')));
             }),
             _buildDrawerItem(Icons.thumb_up_outlined, 'Liked videos', () {}),
            const Divider(color: AppColors.dividerColor, height: 1),
             const Padding(
               padding: EdgeInsets.all(16.0),
               child: Text('Subscriptions', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
             ),
            // TODO: Add list of subscribed channels here
             _buildDrawerItem(Icons.person_pin, 'Channel 1', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Channel 1 is not implemented yet')));
             }),
             _buildDrawerItem(Icons.person_pin, 'Channel 2', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Channel 2 is not implemented yet')));
             }),
             _buildDrawerItem(Icons.add, 'Browse channels', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Browse channels is not implemented yet')));
             }),


             // Add more sections and items as needed (Settings, Help, etc.)
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.iconColor, size: 24),
      title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontSize: 14)),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}