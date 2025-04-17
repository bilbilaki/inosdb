// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/post.dart';
import 'package:myapp/utils/colors.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBackground,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 0, // Flat design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // No rounding
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Timestamp, More Icon
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(post.channelAvatarUrl),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.channelName,
                        style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.timestamp,
                        style: const TextStyle(
                            color: AppColors.secondaryText, fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.iconColor, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Content Text
            Text(
              post.content,
              style: const TextStyle(color: AppColors.primaryText, fontSize: 14.0),
            ),
            const SizedBox(height: 10.0),

            // Optional Image
            if (post.imageUrl != null)
              ClipRRect(
                 borderRadius: BorderRadius.circular(8.0),
                 child: Image.network(
                   post.imageUrl!,
                   width: double.infinity,
                   fit: BoxFit.cover,
                   // Add loading/error builders similar to VideoCard if desired
                 ),
              ),
            if (post.imageUrl != null)
              const SizedBox(height: 12.0),

            // Actions: Likes, Comments, Share
            Row(
              children: [
                _buildActionIcon(Icons.thumb_up_outlined, post.likeCount.toString()),
                const SizedBox(width: 16.0),
                _buildActionIcon(Icons.thumb_down_outlined, null), // Dislike count often hidden
                const SizedBox(width: 16.0),
                 _buildActionIcon(Icons.comment_outlined, post.commentCount.toString()),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.iconColor, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String? count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.iconColor, size: 20),
        if (count != null) const SizedBox(width: 4.0),
        if (count != null)
          Text(
                count,
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 13.0),
              )
      ],
    );
  }
}