// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:myapp/services/user_data_service.dart';
import 'package:myapp/utils/colors.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.secondaryBackground,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined, color: AppColors.iconColor),
            title: const Text('Appearance', style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('Theme options', style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appearance settings not implemented')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline, color: AppColors.iconColor),
            title: const Text('Playback', style: TextStyle(color: AppColors.primaryText)),
             subtitle: const Text('Video quality, subtitles', style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playback settings not implemented')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined, color: AppColors.iconColor),
            title: const Text('Storage', style: TextStyle(color: AppColors.primaryText)),
             subtitle: const Text('Manage downloaded data', style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage settings not implemented')));
            },
          ),
           const Divider(color: AppColors.dividerColor),
           ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            title: const Text('Clear My Data', style: TextStyle(color: Colors.redAccent)),
            subtitle: const Text('Removes favorites and watchlist', style: TextStyle(color: AppColors.secondaryText)),
            onTap: () async {
               final confirm = await showDialog<bool>(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: const Text('Confirm Clear Data'),
                   content: const Text('Are you sure you want to remove all your favorites and watchlist items? This cannot be undone.'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                     TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear Data', style: TextStyle(color: Colors.redAccent))),
                   ],
                 ),
               );
               if (confirm == true) {
                 // ignore: use_build_context_synchronously
                 await Provider.of<UserDataService>(context, listen: false).clearAllUserData();
                 // ignore: use_build_context_synchronously
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User data cleared')));
               }
            },
          ),
           ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.iconColor),
            title: const Text('About', style: TextStyle(color: AppColors.primaryText)),
             subtitle: const Text('App version, licenses', style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              // Consider using showAboutDialog for standard licenses
               showAboutDialog(
                 context: context,
                 applicationName: 'My Media App',
                 applicationVersion: '1.0.0', // Get from pubspec later
                 applicationLegalese: '© Inosuke/Company',
                 // applicationIcon: Image.asset('assets/icon.png', width: 40,), // Your app icon
               );
            },
          ),
        ],
      ),
    );
  }
}