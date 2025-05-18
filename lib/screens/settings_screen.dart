// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:miko/utils/colors.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the UserDataService for changes
    final userDataService = context.watch<UserDataService>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: AppColors.primaryText)),
        backgroundColor: const Color.fromARGB(255, 70, 58, 98),
      ),
      body: ListView(
        children: [
          // Appearance (Placeholder for now, could add theme/color pickers)
          ListTile(
            leading: const Icon(Icons.color_lens_outlined,
                color: AppColors.iconColor),
            title: const Text('Appearance',
                style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('Theme, colors',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Appearance settings not implemented')));
            },
          ),
          const Divider(color: AppColors.dividerColor),

          // Grid Layout Setting (Example using a Slider)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grid Layout',
                    style:
                        TextStyle(color: AppColors.primaryText, fontSize: 16)),
                const Text('Customize grid view for different pages',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 12)),
                Slider(
                  value: userDataService.gridSize?.toDouble() ?? 3.0,
                  min: 1.0,
                  max: 4.0, // Example: 1 to 4 columns
                  divisions: 3, // Creates steps at 1, 2, 3, 4
                  label: userDataService.gridSize.toString(),
                  onChanged: (double value) {
                    // Use read to call the setter without rebuilding the widget tree unnecessarily
                    context.read<UserDataService>().setGridSize(value.toDouble());
                  },
                  activeColor: AppColors.iconColor,
                  inactiveColor: AppColors.secondaryText,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Columns: ${userDataService.gridSize.round()}',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.dividerColor),

          // Playback Settings (Example using a Dropdown)
          ListTile(
            leading: const Icon(Icons.play_circle_outline,
                color: AppColors.iconColor),
            title: const Text('Decoder Preference',
                style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('Select preferred decoder',
                style: TextStyle(color: AppColors.secondaryText)),
            trailing: DropdownButton<String>(
              value: userDataService.decoderPreference,
              dropdownColor:
                  const Color.fromARGB(255, 70, 58, 98), // Match AppBar color
              style: const TextStyle(color: AppColors.primaryText),
              underline: Container(), // Remove default underline
              icon:
                  const Icon(Icons.arrow_drop_down, color: AppColors.iconColor),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context
                      .read<UserDataService>()
                      .setDecoderPreference(newValue);
                }
              },
              items: <String>['default', 'hardware', 'software']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value
                      .capitalize()), // Add a helper extension for capitalization
                );
              }).toList(),
            ),
          ),
          // Add other playback settings here if needed (e.g., secondary player switch)
          const Divider(color: AppColors.dividerColor),

          // External Apps Settings (Example using TextFields)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('External Apps',
                    style:
                        TextStyle(color: AppColors.primaryText, fontSize: 16)),
                const Text('Configure external player and download manager',
                    style: TextStyle(
                        color: AppColors.secondaryText, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(
                      text: userDataService.externalPlayer),
                  decoration: InputDecoration(
                    labelText: 'External Player Path/Name',
                    labelStyle: const TextStyle(color: AppColors.secondaryText),
                    hintStyle: const TextStyle(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColors.dividerColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.iconColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(
                        255, 30, 30, 30), // Darker background
                  ),
                  style: const TextStyle(color: AppColors.primaryText),
                  onChanged: (value) {
                    context.read<UserDataService>().setExternalPlayer(value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(
                      text: userDataService.downloadManager),
                  decoration: InputDecoration(
                    labelText: 'Download Manager Path/Name',
                    labelStyle: const TextStyle(color: AppColors.secondaryText),
                    hintStyle: const TextStyle(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColors.dividerColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.iconColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 30, 30, 30),
                  ),
                  style: const TextStyle(color: AppColors.primaryText),
                  onChanged: (value) {
                    context.read<UserDataService>().setDownloadManager(value);
                  },
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.dividerColor),

          // Storage (Placeholder)
          ListTile(
            leading:
                const Icon(Icons.storage_outlined, color: AppColors.iconColor),
            title: const Text('Storage',
                style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('Manage downloaded data',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Storage settings not implemented')));
            },
          ),
          const Divider(color: AppColors.dividerColor),

          // Clear Data (Existing functionality)
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: Colors.redAccent),
            title: const Text('Clear My Data',
                style: TextStyle(color: Colors.redAccent)),
            subtitle: const Text('Removes favorites and watchlist',
                style: TextStyle(color: AppColors.secondaryText)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Clear Data'),
                  content: const Text(
                      'Are you sure you want to remove all your favorites and watchlist items? This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear Data',
                            style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              );
              if (confirm == true) {
                // ignore: use_build_context_synchronously
                await Provider.of<UserDataService>(context, listen: false)
                    .clearAllUserData();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data cleared')));
              }
            },
          ),
          const Divider(color: AppColors.dividerColor),

          // About (Existing functionality)
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.iconColor),
            title: const Text('About',
                style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('App version, licenses',
                style: TextStyle(color: AppColors.secondaryText)),
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

// Helper extension to capitalize strings for dropdown items
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
