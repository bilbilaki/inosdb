// lib/widgets/episode_tile.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/episode.dart';
import 'package:myapp/screens/video_player_screen.dart'; // Your player screen
import 'package:myapp/utils/colors.dart';

class EpisodeTile extends StatelessWidget {
 final Episode episode;

 const EpisodeTile({required this.episode, super.key});

 void _playVideo(BuildContext context, String url) {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (_) => VideoPlayerScreen(videoUrl: url),
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 final availableQualities = episode.getAvailableQualityUrls();

 return Card(
 color: AppColors.secondaryBackground.withOpacity(0.6),
 margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
 child: Padding(
 padding: const EdgeInsets.all(12.0),
 child: Row(
 children: [
 // Episode Number/Identifier
 Expanded(
 flex: 2, // Give more space to title/identifier
 child: Text(
 // Prioritize TMDB title if available in future, else use identifier
 episode.tmdbTitle ?? episode.episodeIdentifier,
 style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
 overflow: TextOverflow.ellipsis,
 ),
 ),
 const SizedBox(width: 10),

 // Quality Buttons
 Expanded(
 flex: 3, // Give space for buttons
 child: Wrap(
 alignment: WrapAlignment.end, // Align buttons to the right
 spacing: 6.0, // Horizontal space between buttons
 runSpacing: 4.0, // Vertical space if wraps
 children: availableQualities.entries.map((entry) {
 final quality = entry.key;
 final url = entry.value;
 return ElevatedButton(
 onPressed: () => _playVideo(context, url),
 style: ElevatedButton.styleFrom(
 backgroundColor: AppColors.accentColor.withOpacity(0.8),
 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
 minimumSize: const Size(40, 30), // Smaller buttons
 textStyle: const TextStyle(fontSize: 12),
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(6),
 ),
 ),
 child: Text(quality, style: const TextStyle(color: AppColors.primaryText)),
 );
 }).toList(),
 ),
 ),
 ],
 ),
 ),
 );
 }
}