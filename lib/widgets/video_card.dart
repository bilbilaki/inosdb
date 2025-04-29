// lib/widgets/video_card.dart
import 'package:flutter/material.dart';
import 'package:miko/models/video.dart';
import 'package:miko/utils/colors.dart';

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({required this.video, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.network(
              video.thumbnailUrl,
              height: 200, // Adjust height as needed
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  height: 200, color: Colors.grey[800], child: const Icon(Icons.error)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: AppColors.secondaryBackground,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.accentColor,
                    ),
                  ),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                video.duration,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 12.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        // Video Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18.0,
                backgroundImage: NetworkImage(video.channelAvatarUrl),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${video.channelName} • ${video.viewCount} • ${video.uploadedDate}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.iconColor, size: 20.0),
                onPressed: () {
                  // TODO: Implement more options action
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Remove default padding
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0), // Space below each card
      ],
    );
  }
}