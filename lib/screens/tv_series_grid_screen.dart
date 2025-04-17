// lib/screens/tv_series_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:myapp/utils/dynamic_background.dart';

class TvSeriesGridScreen extends StatefulWidget {
  const TvSeriesGridScreen({super.key});

  @override
  State<TvSeriesGridScreen> createState() => _TvSeriesGridScreenState();
}

class _TvSeriesGridScreenState extends State<TvSeriesGridScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<TvSeriesProvider>(context, listen: false);
      if (provider.hasMoreData && !provider.isLoading) {
        provider.loadNextBatch();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TvSeriesProvider>(
      builder: (context, seriesProvider, child) {
        return DynamicBackground(
          child: _buildBody(context, seriesProvider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TvSeriesProvider seriesProvider) {
    if (seriesProvider.status == LoadingStatus.idle) {
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
            onPressed: () => seriesProvider.loadNextBatch(),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor),
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primaryText)),
          )
        ]),
      ));
    }

    final seriesList = seriesProvider.searchResults;

    if (seriesList.isEmpty && seriesProvider.searchQuery.isNotEmpty) {
      return Center(
          child: Text('No results found for "${seriesProvider.searchQuery}"',
              style: const TextStyle(
                  color: AppColors.secondaryText, fontSize: 16)));
    }

    if (seriesList.isEmpty) {
      return const Center(
          child: Text('No TV Series found.',
              style: TextStyle(color: AppColors.secondaryText)));
    }

    return MasonryGridView.count(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 3,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: seriesList.length + (seriesProvider.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == seriesList.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.accentColor),
            ),
          );
        }
        final series = seriesList[index];
        return TvSeriesCard(series: series);
      },
    );
  }
}
