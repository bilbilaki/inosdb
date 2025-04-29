

import 'package:flutter/material.dart';
import 'package:miko/screens/favorites_screen.dart'; // Import destinations
import 'package:miko/screens/settings_screen.dart';
import 'package:miko/screens/watchlist_screen.dart';
import 'package:miko/utils/colors.dart';
// Keep if you like it

class LibraryScreen extends StatelessWidget {
 const LibraryScreen({super.key});

 @override
 Widget build(BuildContext context) {
 return Scaffold(
   backgroundColor: AppColors.primaryBackground, // Keep background color
   body: SafeArea( // Use SafeArea
     child: ListView(
       padding: const EdgeInsets.symmetric(vertical: 8.0), // Overall padding
       children: [
         // User Lists Section
         _buildSectionHeader('Your Lists'),
         _buildLibraryItem(context, Icons.favorite_outline, 'Favorites', () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
         }),
         _buildLibraryItem(context, Icons.bookmark_outline, 'Watchlist', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchlistScreen()));
         }),
          _buildLibraryItem(context, Icons.history, 'History', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History not implemented')));
          }),

         _buildLibraryItem(context, Icons.download_outlined, 'Downloads', () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloads not implemented')));
         }),

        // Playlists Section (Optional, keep if useful)
       //   _buildSectionHeader('Playlists'),
       //   _buildPlaylistTile(context, Icons.add, 'New playlist', null, () {}),
       //   _buildPlaylistTile(context, Icons.thumb_up, 'Liked videos', '500 videos', () {}),


         // Other Actions
         _buildSectionHeader('More'),
         _buildLibraryItem(context, Icons.settings_outlined, 'Settings', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
         }),
         // Add other relevant items here if needed (Help, etc.)
       ],
     ),
   ),
 );
 }

 // Helper for section header
 Widget _buildSectionHeader(String title) {
   return Padding(
     padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
     child: Text(
       title.toUpperCase(),
       style: const TextStyle(
         color: AppColors.secondaryText,
         fontSize: 13.0,
         fontWeight: FontWeight.w500,
         letterSpacing: 0.5,
       ),
     ),
   );
 }


 // Updated helper for consistency
 Widget _buildLibraryItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
   return ListTile(
     leading: Icon(icon, color: AppColors.iconColor, size: 26),
     title: Text(
       title,
       style: const TextStyle(color: AppColors.primaryText, fontSize: 15)
     ),
     onTap: onTap,
     dense: false, // Slightly less dense for better spacing
     contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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