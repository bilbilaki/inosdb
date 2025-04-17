// lib/screens/tv_series_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/tv_series_provider.dart'; // Use TvSeriesProvider
import 'package:myapp/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/widgets/tv_series_card.dart'; // Use TvSeriesCard
import 'package:myapp/utils/dynamic_background.dart';

class TvSeriesGridScreen extends StatelessWidget {
 const TvSeriesGridScreen({super.key}); // Renamed

 @override
 Widget build(BuildContext context) {
 return Consumer<TvSeriesProvider>( // Consume TvSeriesProvider
 builder: (context, seriesProvider, child) {
 // Using DynamicBackground if you have it
 return DynamicBackground(
 child: _buildBody(context, seriesProvider),
 );
 // Or just Scaffold if not using DynamicBackground
 // return Scaffold(
 // backgroundColor: AppColors.primaryBackground,
 // body: _buildBody(context, seriesProvider),
 // );
 },
 );
 }

 Widget _buildBody(BuildContext context, TvSeriesProvider seriesProvider) {
 if (seriesProvider.isLoading) {
 return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
 }

 if (seriesProvider.hasError) {
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(20.0),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Icon(Icons.error_outline, color: Colors.red, size: 50),
 const SizedBox(height: 10),
 Text(
 'Error loading TV Series: ${seriesProvider.errorMessage ?? 'Unknown error'}',
 textAlign: TextAlign.center,
 style: const TextStyle(color: AppColors.secondaryText),
 ),
 const SizedBox(height: 20),
 ElevatedButton(
 onPressed: () => seriesProvider.loadAndProcessTvSeries(), // Retry loading
 style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor),
 child: const Text('Retry', style: TextStyle(color: AppColors.primaryText)),
 )
 ]
 ),
 )
 );
 }


 final seriesList = seriesProvider.searchResults; // Use searchResults getter

 if (seriesList.isEmpty && seriesProvider.searchQuery.isNotEmpty) {
 return Center(
 child: Text(
 'No results found for "${seriesProvider.searchQuery}"',
 style: const TextStyle(color: AppColors.secondaryText, fontSize: 16)
 )
 );
 }

 if (seriesList.isEmpty) {
 return const Center(child: Text('No TV Series found.', style: TextStyle(color: AppColors.secondaryText)));
 }


 // Display Series using MasonryGridView
 return MasonryGridView.count(
 padding: const EdgeInsets.all(8.0),
 crossAxisCount: 3, // Adjust Column Count as you want (2 or 3 is common)
 mainAxisSpacing: 8.0,
 crossAxisSpacing: 8.0,
 itemCount: seriesList.length,
 itemBuilder: (context, index) {
 final series = seriesList[index];
 return TvSeriesCard(series: series); // Use the TvSeriesCard
 },
 );
 }
}