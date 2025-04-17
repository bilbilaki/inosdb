// lib/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/dynamic_background.dart'; // Import the dynamic background

class LibraryScreen extends StatelessWidget {
 const LibraryScreen({super.key});

 @override
 Widget build(BuildContext context) {
   // Use DynamicBackground instead of directly setting background color
   return Scaffold(
     // Remove backgroundColor property as DynamicBackground will handle it
     body: DynamicBackground(
       // Choose a theme that fits your library screen
       theme: ParticlesTheme.purple, // You can select: blue, dark, colorful, purple
       child: SafeArea(
         child: ListView(
           children: [
             // Could add recent videos horizontally scrollable here
             _buildLibraryItem(Icons.history, 'History', () {}),
             _buildLibraryItem(Icons.download_outlined, 'Downloads', () {}),
             _buildLibraryItem(Icons.slideshow_outlined, 'Your videos', () {}),
             _buildLibraryItem(Icons.schedule_outlined, 'Watch later', () {}),
             _buildLibraryItem(Icons.thumb_up_outlined, 'Liked videos', () {}),
             Divider(color: AppColors.dividerColor.withOpacity(0.5)), // Slightly transparent divider
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
               child: Text(
                 'Playlists',
                 style: TextStyle(
                   color: AppColors.primaryText,
                   fontSize: 16.0,
                   fontWeight: FontWeight.bold,
                   // Optional shadow for better visibility against particle background
                   shadows: [
                     Shadow(
                       color: Colors.black.withOpacity(0.3),
                       blurRadius: 2,
                     ),
                   ],
                 ),
               ),
             ),
             _buildPlaylistTile(Icons.add, 'New playlist', null, () {}),
             _buildPlaylistTile(Icons.thumb_up, 'Liked videos', '500 videos', () {}),
             _buildPlaylistTile(Icons.watch_later, 'Watch Later', '12 videos', () {}),
             // Add more playlists...
           ],
         ),
       ),
     ),
   );
 }

 Widget _buildLibraryItem(IconData icon, String title, VoidCallback onTap) {
   return ListTile(
     leading: Icon(icon, color: AppColors.iconColor),
     title: Text(
       title, 
       style: const TextStyle(
         color: AppColors.primaryText,
         // Optional: Adding shadow for better readability against particles
         shadows: [
           Shadow(
             color: Colors.black26,
             blurRadius: 2,
           ),
         ],
       )
     ),
     onTap: onTap,
     dense: true,
   );
 }

 Widget _buildPlaylistTile(IconData icon, String title, String? subtitle, VoidCallback onTap) {
   return ListTile(
     leading: Container(
       padding: const EdgeInsets.all(8),
       decoration: BoxDecoration(
         color: Colors.black26, // Semi-transparent background for icons
         borderRadius: BorderRadius.circular(4),
       ),
       child: Icon(icon, color: AppColors.iconColor, size: 30),
     ),
     title: Text(
       title, 
       style: const TextStyle(
         color: AppColors.primaryText,
         fontWeight: FontWeight.w500,
       )
     ),
     subtitle: subtitle != null
       ? Text(
           subtitle, 
           style: const TextStyle(color: AppColors.secondaryText)
         )
       : null,
     onTap: onTap,
     dense: true,
   );
 }
}