// lib/widgets/status_bar.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/channel_status.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/utils/dummy_data.dart';

class StatusBar extends StatelessWidget {
  final List<ChannelStatus> statuses = generateDummyStatuses(
    25,
  ); // Generate some statuses

  StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0, // Adjust height for status items
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5), // Space for the ring
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        status.hasNewStory
                            ? Border.all(
                              color: AppColors.accentColor,
                              width: 2.0,
                            )
                            : null,
                  ),
                  child: CircleAvatar(
                    radius: 26.0,
                    backgroundImage: NetworkImage(status.avatarUrl),
                    backgroundColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 0.0),
                Text(
                  status.channelName,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
