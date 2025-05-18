import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miko/router.dart';
import 'package:miko/screens/anime_grid_screen.dart';
import 'package:miko/screens/favorites_screen.dart';
import 'package:miko/screens/genre_list_screen.dart';
import 'package:miko/screens/home_screen.dart';
import 'package:miko/screens/settings_screen.dart';
import 'package:miko/screens/shorts_screen.dart';
import 'package:miko/screens/tv_series_grid_screen.dart';
import 'package:miko/screens/watchlist_screen.dart';
import 'package:miko/showcases/movie_page.dart';
import 'package:miko/showcases/tv_page.dart';
import 'package:miko/utils/colors.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryBackground,
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Image.asset(
                  'assets/YouTube.png',
                  height: 40,
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.movie_creation,
            title: 'Movies',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.live_tv_rounded,
            title: 'TV Series',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TvSeriesGridScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.movie_outlined,
            title: 'Anime',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeGridScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.category_outlined,
            title: 'Genres',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenreListScreen(), // Pass movie ID
                ));
          }),
          
          const Divider(color: AppColors.dividerColor, height: 1),
          _buildDrawerItem(
            context,
            icon: Icons.video_library_outlined,
            title: 'Subscription ',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionsPage(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.watch_later_outlined,
            title: 'Watchlist',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WatchlistScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.favorite_border_sharp,
            title: 'Favorites',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.download_outlined,
            title: 'Downloads',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloads not implemented yet')),
              );
              Navigator.pop(context); // Close drawer
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.playlist_play,
            title: 'Playlist Player',
            onTap: () => context.go(AppRoutes.shorts),
          ),
          const Divider(color: AppColors.dividerColor, height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Subscriptions',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildDrawerItem(context,
              icon: Icons.movie_outlined, title: 'Popular Movie', onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoviePage(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.tv_rounded,
            title: 'Popular TV Shows',
            onTap: (){Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TvShowPage(), // Pass movie ID
                ));
          }),
          _buildDrawerItem(
            context,
            icon: Icons.add,
            title: 'Browse channels',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Browse channels not implemented yet')),
              );
              Navigator.pop(context); // Close drawer
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.iconColor, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
