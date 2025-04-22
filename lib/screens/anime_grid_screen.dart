// lib/screens/tv_series_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/tv_series_anime.dart';
import 'package:myapp/widgets/anime_series_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/anime_provider.dart'; // Ensure correct provider import
import 'package:myapp/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/utils/dynamic_background.dart'; // Keep if using
import 'package:flutter_tilt/flutter_tilt.dart';


// Simplified StateLESS Widget as lazy loading is removed
class AnimeGridScreen extends StatelessWidget {
  const AnimeGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer directly
    return Consumer<AnimeProvider>(
      builder: (context, seriesProvider, child) {
        // Optional: Keep DynamicBackground if desired
        return DynamicBackground(
          child: _buildBody(context, seriesProvider),
        );
        // Or just return the body directly:
        // return _buildBody(context, seriesProvider);
      },
    );
  }

  Widget _buildBody(BuildContext context, AnimeProvider seriesProvider) {
    final status = seriesProvider.status;

    if (status == LoadingStatus.loading || status == LoadingStatus.idle) {
      // Show loading indicator initially or while loading
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accentColor));
    }

    if (seriesProvider.hasError) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            'Error loading TV Series: ${seriesProvider.errorMessage ?? 'Unknown error'}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            // Reload all data on retry
            onPressed: () => seriesProvider.loadAnimeData(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor),
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primaryText)),
          )
        ]),
      ));
    }

    // Get the list to display (handles search results automatically)
    final seriesList = seriesProvider.animeseriesForDisplay;

    if (seriesList.isEmpty && seriesProvider.searchQuery.isNotEmpty) {
      return Center(
          child: Text('No results found for "${seriesProvider.searchQuery}"',
              style: const TextStyle(
                  color: AppColors.secondaryText, fontSize: 16)));
    }

    if (seriesList.isEmpty) {
      return const Center(
          child: Text('No TV Series found in the database.',
              style: TextStyle(color: AppColors.secondaryText)));
    }
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 3,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: seriesList.length,
      itemBuilder: (context, index) {
        final series = seriesList[index];
        return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: AnimeSeriesCard(series: series),
        );
      },
    );
  }
}
