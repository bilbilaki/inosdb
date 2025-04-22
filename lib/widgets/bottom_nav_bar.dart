import 'package:flutter/material.dart';
import 'package:myapp/utils/colors.dart';

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
      selectedItemColor: AppColors.primaryText,
      unselectedItemColor: AppColors.secondaryText,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedFontSize: 13.0,
      unselectedFontSize: 10.0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dvr_outlined),
          activeIcon: Icon(Icons.dvr),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_outlined),
          activeIcon: Icon(Icons.movie),
          label: 'Tvshows',
        ),
     //   BottomNavigationBarItem(
          // Using movie icon as placeholder for Shorts
       //   icon: Icon(Icons.movie_outlined),
      //    activeIcon: Icon(Icons.movie),
     //     label: 'Shorts',
       // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.tv_outlined),
          activeIcon: Icon(Icons.tv),
          label: 'Anime',
        ),
 //       BottomNavigationBarItem(
 // Central Add button - can navigate to Create Post or other actions
 //         icon: Icon(Icons.add_circle_outline, size: 34.0), // Larger icon
 //         activeIcon: Icon(Icons.add_circle, size: 34.0),
 //         label: 'Add', // No label typically for the center button
 //       ),
     //   BottomNavigationBarItem(
          // icon: Icon(Icons.tiktok_outlined),
          // activeIcon: Icon(Icons.tiktok),
          // label: 'Shorts',
        //),
    //    BottomNavigationBarItem(
      //    icon: Icon(Icons.subscriptions_outlined),
      //    activeIcon: Icon(Icons.subscriptions),
      //    label: 'Subscriptions',
      //  ),
      //  BottomNavigationBarItem(
      //    icon: Icon(Icons.video_library_outlined),
      //    activeIcon: Icon(Icons.video_library),
      //    label: 'Library',
      //  ),
      BottomNavigationBarItem(
       icon: Icon(Icons.movie_filter_outlined), // Changed Icon
       activeIcon: Icon(Icons.movie_filter),   // Changed Icon
       label: 'Genres',                     // Changed Label
     ),
     BottomNavigationBarItem( // Index 4 (Library) is now after the gap
       icon: Icon(Icons.video_library_outlined),
       activeIcon: Icon(Icons.video_library),
       label: 'Library',
     ),
      ],

    );
  }
}
