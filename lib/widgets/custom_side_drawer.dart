// lib/widgets/custom_side_drawer.dart
import 'package:flutter/material.dart';
import 'package:miko/utils/colors.dart';
import 'package:go_router/go_router.dart';

class CustomSideDrawer extends StatelessWidget {
  CustomSideDrawer({super.key});
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
              height: kToolbarHeight +
                  MediaQuery.of(context)
                      .padding
                      .top, // Match AppBar height + status bar
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                ),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                // Add Logo and Menu button like in AppBar
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/YouTube.png',
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(Icons.home_outlined, 'Home', () {
              context.go('/');
            }),
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));

            _buildDrawerItem(Icons.live_tv_rounded, 'TvSeries', () {
              context.push(
                  '/tv_series_grid_screen'); // or context.push('/favorites') if you want to maintain stack
            }),
            _buildDrawerItem(Icons.movie_outlined, 'Anime', () {
              context.push(
                  '/anime_grid_screen'); // or context.push('/favorites') if you want to maintain stack
            }),
            _buildDrawerItem(Icons.category_outlined, 'Genres', () {
              context.push('/genre_list_screen');
            }),
            const Divider(color: AppColors.dividerColor, height: 1),
            _buildDrawerItem(Icons.video_library_outlined, 'Library', () {
              context.push('/library_screen');
            }),
            _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
              context.push('/settings_screen');
            }),
            _buildDrawerItem(Icons.watch_later_outlined, 'Watchlist', () {
              context.push('/watchlist_screen');
            }),
            _buildDrawerItem(Icons.download_outlined, 'Downloads', () {}),
            _buildDrawerItem(Icons.favorite_border_sharp, 'Favorites', () {
              context.push('/favorites_screen');
            }),
            // TODO: Add list of subscribed channels here
            _buildDrawerItem(Icons.person_pin, 'Channel 1', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Channel 1 is not implemented yet')));
            }),
            _buildDrawerItem(Icons.person_pin, 'Channel 2', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Channel 2 is not implemented yet')));
            }),
            _buildDrawerItem(Icons.add, 'Browse channels', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Browse channels is not implemented yet')));
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
      title: Text(title,
          style: const TextStyle(color: AppColors.primaryText, fontSize: 14)),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
