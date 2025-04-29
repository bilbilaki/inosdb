// lib/screens/tv_series_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:miko/models/tv_series.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:miko/providers/tv_series_provider.dart'; // Ensure correct provider import
import 'package:miko/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/widgets/tv_series_card.dart';
//import 'package:myapp/utils/dynamic_background.dart'; // Keep if using

// Simplified StateLESS Widget as lazy loading is removed
class TvSeriesGridScreen extends StatelessWidget {
  const TvSeriesGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer directly
    return Consumer<TvSeriesProvider>(
      builder: (context, seriesProvider, child) {
        // Optional: Keep DynamicBackground if desired
        return _buildBody(context, seriesProvider);
        // Or just return the body directly:
        // return _buildBody(context, seriesProvider);
      },
    );
  }

  Widget _buildBody(BuildContext context, TvSeriesProvider seriesProvider) {
    final status = seriesProvider.status;
    final userData = Provider.of<UserDataService>(context);

    final gridSize = userData.gridSize.toInt();
    if (status == LoadingStatus.loading || status == LoadingStatus.idle) {
      // Show loading indicator initially or while loading
      return const Center(
          child: CircularProgressIndicator(color: AppColors2.accentColor));
    }

    if (seriesProvider.hasError) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: AppColors2.error, size: 50),
          const SizedBox(height: 10),
          Text(
            'Error loading TV Series: ${seriesProvider.errorMessage ?? 'Unknown error'}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors2.error),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            // Reload all data on retry
            onPressed: () => seriesProvider.loadTvSeriesData(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors2.accentColor),
            child: const Text('Retry',
                style: TextStyle(color: AppColors2.error2)),
          )
        ]),
      ));
    }

    // Get the list to display (handles search results automatically)
    final seriesList = seriesProvider.seriesForDisplay;

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

    // Display the grid using the loaded list
    return MasonryGridView.count(
       padding: const EdgeInsets.all(5.0),
      crossAxisCount: 1*gridSize, // Adjust number of 
      mainAxisSpacing: 1.5,
      controller: ScrollController(keepScrollOffset: true),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      crossAxisSpacing: 1.5,
      cacheExtent: 10,
      itemCount: seriesList.length, // Directly use the list length
      itemBuilder: (context, index) {
        final series = seriesList[index];
           return TvSeriesCard(series: series);
      },
    );
  }
}
