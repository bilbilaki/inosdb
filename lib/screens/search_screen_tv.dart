// lib/screens/search_screen_tv.dart
import 'package:flutter/material.dart';
import 'package:miko/models/tv_series.dart';
//import 'package:miko/utils/dynamic_background.dart'; // Optional background
import 'package:provider/provider.dart';
import 'package:miko/providers/tv_series_provider.dart'; // Use TvSeriesProvider
import 'package:miko/utils/colors.dart';
import 'package:miko/widgets/tv_series_card.dart'; // Use TvSeriesCard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/router.dart';
import 'package:go_router/go_router.dart';

class SearchScreenTv extends StatefulWidget {
  final String? query;
 const SearchScreenTv({ this.query, super.key});

 @override
 State<SearchScreenTv> createState() => _SearchScreenTvState();
}

class _SearchScreenTvState extends State<SearchScreenTv> {
 final TextEditingController _searchController = TextEditingController();
 final FocusNode _searchFocusNode = FocusNode();

 @override
 void initState() {
 super.initState();
 WidgetsBinding.instance.addPostFrameCallback((_) {
 Provider.of<TvSeriesProvider>(context, listen: false).searchTvSeries(''); // Clear search
 _searchFocusNode.requestFocus();
 });
 }

 @override
 void dispose() {
 _searchController.dispose();
 _searchFocusNode.dispose();
 WidgetsBinding.instance.addPostFrameCallback((_) {
 if (mounted) {
 Provider.of<TvSeriesProvider>(context, listen: false).searchTvSeries('');
 }
 });
 super.dispose();
 }

 void _performSearch(String query) {
 Provider.of<TvSeriesProvider>(context, listen: false).searchTvSeries(query);
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 body: SafeArea(
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
 Navigator.pop(context);
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
 hintText: 'Search TV series...', // Updated hint
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
 child: Consumer<TvSeriesProvider>( // Use TvSeriesProvider
 builder: (context, seriesProvider, child) {
 final results = seriesProvider.seriesForDisplay;
 final query = seriesProvider.searchQuery;

 if (query.isEmpty) {
 return const Center(
 child: Text(
 'Start typing to search for TV series...', // Updated message
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
 return TvSeriesCard(series: series); // Use TvSeriesCard
 },
 );
 },
 ),
 ),
 ],
 ),
 ),
 );
 }
}