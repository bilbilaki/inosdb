// lib/widgets/tv_series_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/screens/tv_series_details_screen.dart'; // Correct screen
import 'package:myapp/utils/colors.dart'; // Assuming AppColors exists

class TvSeriesCard extends StatelessWidget {
 final TvSeries series;

 const TvSeriesCard({required this.series, super.key});

 @override
 Widget build(BuildContext context) {
 final posterUrl = series.fullPosterUrl; // Use helper from TvSeries model
 final firstAirYear = series.firstAirDate != null && series.firstAirDate!.length >= 4
 ? series.firstAirDate!.substring(0, 4)
 : 'N/A';

 return InkWell(
 onTap: () {
 // Navigate to TvSeries Details Screen
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (_) => TvSeriesDetailsScreen(tvSeriesId: series.tmdbId), // Pass TMDB ID
 ),
 );
 },
 child: Card(
 // Style as needed, similar to MovieCard
 color: Colors.transparent,
 elevation: 0,
 margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 AspectRatio(
 aspectRatio: 2 / 3,
 child: ClipRRect(
 borderRadius: BorderRadius.circular(8.0),
 child: posterUrl != null
 ? CachedNetworkImage(
 imageUrl: posterUrl,
 fit: BoxFit.cover,
 placeholder: (context, url) => Container(
 color: AppColors.secondaryBackground.withOpacity(0.5),
 child: const Center(
 child: CircularProgressIndicator(
 strokeWidth: 2, color: AppColors.accentColor)),
 ),
 errorWidget: (context, url, error) => Container(
 color: AppColors.secondaryBackground.withOpacity(0.5),
 child: const Center(
 child: Icon(Icons.error_outline,
 color: AppColors.secondaryText))),
 )
 : Container(
 color: AppColors.secondaryBackground.withOpacity(0.5),
 child: const Center(
 child: Icon(Icons.tv_off_outlined,
 color: AppColors.secondaryText, size: 40))),
 ),
 ),
 const SizedBox(height: 8.0),
 Padding(
 padding: const EdgeInsets.symmetric(horizontal: 4.0),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisSize: MainAxisSize.min,
 children: [
 Text(
 series.name, // Use TMDB name
 style: const TextStyle(
 color: AppColors.primaryText,
 fontWeight: FontWeight.w500,
 fontSize: 14.0,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 2.0),
 Row(
 children: [
 const Icon(Icons.star, color: Colors.amber, size: 14),
 const SizedBox(width: 4),
 Text(
 '${series.voteAverage.toStringAsFixed(1)} • $firstAirYear',
 style: const TextStyle(
 color: AppColors.secondaryText,
 fontSize: 12.0,
 ),
 maxLines: 1,
 overflow: TextOverflow.ellipsis,
 ),
 ],
 ),
 ],
 ),
 ),
 const SizedBox(height: 8.0),
 ],
 ),
 ),
 );
 }
}