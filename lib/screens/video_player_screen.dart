// lib/screens/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';                  // Required.
import 'package:media_kit_video/media_kit_video.dart';      // Required.


class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({required this.videoUrl, super.key});

  @override
  State<VideoPlayerScreen> createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Create a [Player] instance from `package:media_kit`.
  late final Player player = Player();
  // Create a [VideoController] instance from `package:media_kit_video`.
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Open the video URL.
    player.open(Media(widget.videoUrl), play: true); // Start playing immediately
  }

  @override
  void dispose() {
    // Make sure to dispose the [Player] and [VideoController] instances.
     // IMPORTANT: Dispose the player and controller !!
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Player usually on black background
      appBar: AppBar(
         backgroundColor: Colors.transparent, // Transparent app bar overlay
         elevation: 0,
         iconTheme: const IconThemeData(color: Colors.white), // White back button
         // Optional: Add title if needed
         // title: Text(Uri.parse(widget.videoUrl).pathSegments.last, style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
       extendBodyBehindAppBar: true, // Allow video to go behind appbar
      body: Center( // Center the video player
        child: SizedBox(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.width * 9.0 / 16.0, // Assuming 16:9 aspect ratio
            // Use [Video] widget to display video output.
          child: Video(
             controller: controller,
             // Optional: Custom controls
             controls: AdaptiveVideoControls, // Use default controls
             // Optional: Configure appearance
//           width: ..., height: ..., 
             fit: BoxFit.fitWidth, 
             //fill: ..., alignment: ...,
             // Optional: Display subtitles
             subtitleViewConfiguration: const SubtitleViewConfiguration(visible: true),
          ),
        ),
      ),
    );
  }
}