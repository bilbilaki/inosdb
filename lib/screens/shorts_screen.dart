// lib/screens/shorts_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/dynamic_background.dart';

class ShortsScreen extends StatelessWidget {
  const ShortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for Shorts UI - typically a PageView for vertical swiping
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 10, // Example count
        itemBuilder: (context, index) {
          return DynamicBackground(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Short Title $index', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
                             const SizedBox(width: 8),
                             const Text('Channel Name', style: TextStyle(color: Colors.white)),
                             const SizedBox(width: 8),
                             ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: const Text('Subscribe')),
                           ],
                         )
                       ],
                     ),
                   ),
                   const SizedBox(height: 80), // Space for actions on the right
                 ],
              ),
            ),
             // TODO: Add overlay with buttons (like, dislike, comment, share, channel info)
          );
        },
      ),
    );
  }
}