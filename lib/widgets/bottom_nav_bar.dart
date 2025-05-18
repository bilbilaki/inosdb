import 'package:flutter/material.dart';
import 'package:miko/utils/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Ensures all labels are visible
      backgroundColor: AppColors.primaryBackground,
      selectedItemColor: AppColors.accentColor,
      unselectedItemColor: AppColors.secondaryText,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedFontSize: 12.0,
      unselectedFontSize: 10.0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.live_tv_outlined),
          activeIcon: Icon(Icons.live_tv),
          label: 'TVSeries',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_outlined),
          activeIcon: Icon(Icons.movie),
          label: 'Anime',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Genres',
        ),
        // Center special button for Shorts
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, size: 32.0),
          activeIcon: Icon(Icons.add_circle, size: 32.0),
          label: 'WatchList',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          activeIcon: Icon(Icons.video_library),
          label: 'Favorites',
        ),
      ],
    );
  }
}