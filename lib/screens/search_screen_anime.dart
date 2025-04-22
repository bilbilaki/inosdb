// lib/screens/search_screen_tv.dart
import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:myapp/models/tv_series_anime.dart';
import 'package:myapp/utils/dynamic_background.dart'; // Optional background
import 'package:provider/provider.dart';
import 'package:myapp/providers/anime_provider.dart'; // Use AnimeProvider
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/anime_series_card.dart'; // Use AnimeSeriesCard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/router.dart';
import 'package:go_router/go_router.dart';

class SearchScreenAnime extends StatefulWidget {
  final String? query;
 const SearchScreenAnime({ this.query, super.key});

 @override
 State<SearchScreenAnime> createState() => _SearchScreenAnimeState();
}

class _SearchScreenAnimeState extends State<SearchScreenAnime> {
 final TextEditingController _searchController = TextEditingController();
 final FocusNode _searchFocusNode = FocusNode();

 @override
 void initState() {
 super.initState();
 WidgetsBinding.instance.addPostFrameCallback((_) {
 Provider.of<AnimeProvider>(context, listen: false).searchAnime(''); // Clear search
 _searchFocusNode.requestFocus();
 });
 }

 @override
 void dispose() {
 _searchController.dispose();
 _searchFocusNode.dispose();
 WidgetsBinding.instance.addPostFrameCallback((_) {
 if (mounted) {
 Provider.of<AnimeProvider>(context, listen: false).searchAnime('');
 }
 });
 super.dispose();
 }

 void _performSearch(String query) {
 Provider.of<AnimeProvider>(context, listen: false).searchAnime(query);
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 body: DynamicBackground( // Optional background
 theme: ParticlesTheme.dark,
 child: SafeArea(
 child: Column(
 children: [
 // --- Search AppBar ---
 Container(
 color: AppColors.secondaryBackground.withOpacity(0.9),
 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
 child: Row(
 children: [
 IconButton(
 icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
 onPressed: () {
 _performSearch(''); // Clear search on back
 _searchController.clear();
 _searchFocusNode.unfocus();
 context.go(AppRoutes.home);
 },
 ),
 Expanded(
 child: TextField(
 controller: _searchController,
 focusNode: _searchFocusNode,
 autofocus: true,
 style: const TextStyle(color: AppColors.primaryText, fontSize: 18),
 cursorColor: AppColors.accentColor,
 decoration: InputDecoration(
 hintText: 'Search Anime Series...', // Updated hint
 hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7)),
 border: InputBorder.none,
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear, color: AppColors.secondaryText),
 onPressed: () {
 _searchController.clear();
 _performSearch('');
 _searchFocusNode.requestFocus();
 },
 )
 : null,
 ),
 onChanged: _performSearch,
 onSubmitted: _performSearch,
 ),
 ),
 ],
 ),
 ),

 // --- Search Results ---
 Expanded(
 child: Consumer<AnimeProvider>( // Use AnimeProvider
 builder: (context, seriesProvider, child) {
 final results = seriesProvider.animeseriesForDisplay;
 final query = seriesProvider.searchQuery;

 if (query.isEmpty) {
 return const Center(
 child: Text(
 'Start typing to search for Anime Series...', // Updated message
 style: TextStyle(color: AppColors.secondaryText)
 )
 );
 }

 if (seriesProvider.status == LoadingStatus.loading) {
 // Show loading only if the main load is still happening
 return const Center(child: CircularProgressIndicator());
 }

 if (results.isEmpty) {
 return Center(
 child: Text(
 'No results found for "$query"',
 style: const TextStyle(color: AppColors.secondaryText)
 )
 );
 }

 // Display results using MasonryGridView
 return MasonryGridView.count(
 padding: const EdgeInsets.all(8.0),
 crossAxisCount: 3, // Adjust columns
 mainAxisSpacing: 8.0,
 crossAxisSpacing: 8.0,
 itemCount: results.length,
 itemBuilder: (context, index) {
 final series = results[index];
 return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: AnimeSeriesCard(series: series)); // Use AnimeSeriesCard
 },
 );
 },
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }
}