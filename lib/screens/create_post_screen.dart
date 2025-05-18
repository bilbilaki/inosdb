import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miko/models/tvseries_details.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:miko/utils/colors.dart';
//import 'package:miko/utils/dynamic_background.dart';
//import 'package:miko/services/image_cache_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class EpisodeData {
  int episodeNumber;
  String? link1080p;
  String? link720p;
  String? link480p;
  String? subtitle;

  EpisodeData({
    required this.episodeNumber,
    this.link1080p,
    this.link720p,
    this.link480p,
    this.subtitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'episodeNumber': episodeNumber,
      '1080p': link1080p,
      '720p': link720p,
      '480p': link480p,
      'subtitle': subtitle,
    };
  }
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<EpisodeData> _episodes = [];
  bool _isMovie = false;
  String? _searchResult;
  Map<String, dynamic>? _searchData;
  TvSeriesProvider? _tvSeriesProvider;
  final String _apiKey = '607e40af5bb66576f6fd7252d5529e24';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/original';
  static const String _backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';
  String? _posterPath;
  String? _backdropPath;
  final String _baseUrl = 'https://api.themoviedb.org/3';

  @override
  void dispose() {
    _seasonController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _searchContent() async {
    if (_nameController.text.isEmpty) return;

    try {
      if (_isMovie) {
        // TODO: Implement movie search
        if (mounted) {
          setState(() {
            _searchResult = 'Movie search not implemented yet';
          });
        }
      } else {
        if (mounted) {
          final searchUri = Uri.parse(
              '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(_nameController.text)}');
          final searchResponse = await http.get(searchUri);

          if (searchResponse.statusCode == 200) {
            final searchData =
                json.decode(searchResponse.body) as Map<String, dynamic>;
            final results = searchData['results'] as List<dynamic>?;
            if (results != null && results.isNotEmpty) {
              final seriesId =
                  (results[0] as Map<String, dynamic>)['id'] as int?;
              if (seriesId != null) {
                final detailsUri = Uri.parse(
                    '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US');
                final detailsResponse = await http.get(detailsUri);
                if (detailsResponse.statusCode == 200) {
                  setState(() {
                    _searchData = json.decode(detailsResponse.body);
                    _searchResult = null;
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResult = 'Error searching: $e';
          _searchData = null;
        });
      }
    }
  }

  Future<void> _fetchSeasonEpisodes() async {
    if (_searchData == null || _seasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a series and enter season number')),
      );
      return;
    }

    try {
      final seriesId = _searchData!['id'];
      final seasonNumber = int.parse(_seasonController.text);

      final seasonUri = Uri.parse(
          '$_baseUrl/tv/$seriesId/season/$seasonNumber?api_key=$_apiKey&language=en-US');
      final response = await http.get(seasonUri);

      if (response.statusCode == 200) {
        final seasonData = json.decode(response.body);
        final episodes = seasonData['episodes'] as List<dynamic>?;

        if (episodes != null) {
          setState(() {
            _episodes.clear();
            for (var episode in episodes) {
              _episodes.add(EpisodeData(
                episodeNumber: episode['episode_number'] as int,
                link1080p: '',
                link720p: '',
                link480p: '',
                subtitle: '',
              ));
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch season episodes')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching episodes: $e')),
      );
    }
  }

  Future<TvSeriesDetails?> getTvSeriesDetails(seriesId) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY_HERE') {
      if (kDebugMode) {
        print(
            "ERROR: Please replace 'YOUR_TMDB_API_KEY_HERE' with your actual TMDB API key in tmdb_api_service.dart");
      }
      throw Exception(
          "TMDB API Key not set. Please replace 'YOUR_TMDB_API_KEY_HERE' in tmdb_api_service.dart");
    }

    final detailsUri = Uri.parse(
        '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US'); // Optional: Add language
    if (kDebugMode) {
      print("Fetching details from TMDB: $detailsUri");
    }

    try {
      final detailsResponse = await http.get(detailsUri);

      if (detailsResponse.statusCode == 200) {
        final detailsData = json.decode(detailsResponse.body);
        // Use the factory constructor from the model
        final details = TvSeriesDetails.fromJson(
            detailsData); // Pass the ID to the model constructor
        if (kDebugMode) {
          print("Successfully fetched and parsed details for ID $seriesId.");
        }
        return details; // Cast to the correct type
      } else if (detailsResponse.statusCode == 404) {
        if (kDebugMode) {
          print("TV series with ID $seriesId not found.");
        }
      } else {
        if (kDebugMode) {
          print(
              "Error fetching details from TMDB: ${detailsResponse.statusCode} - ${detailsResponse.body}");
        }
        // Handle details fetch error
        throw Exception(
            'Failed to load TV series details (Status code: ${detailsResponse.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching/parsing details for ID $seriesId: $e');
      }
      // Handle errors
      return null;
      // throw Exception('An error occurred fetching details: $e');
    }
    return null;
  }

  void _addNewEpisode() {
    setState(() {
      _episodes.add(EpisodeData(
        episodeNumber: _episodes.length + 1,
      ));
    });
  }

  Future<void> _importFromCsv() async {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.secondaryBackground,
                title: const Text('Add Season',
                    style: TextStyle(color: AppColors.primaryText)),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.iconColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  TextButton(
                    onPressed: _importFromCsv,
                    child: const Text(
                      'Import CSV',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Save season data
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie/Series Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Movie',
                              style: TextStyle(color: AppColors.primaryText)),
                          Switch(
                            value: _isMovie,
                            onChanged: (value) => setState(() {
                              _isMovie = value;
                              _searchData = null;
                              _searchResult = null;
                            }),
                          ),
                          const Text('Series',
                              style: TextStyle(color: AppColors.primaryText)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Field
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.primaryText),
                        decoration: const InputDecoration(
                          labelText: 'Search by name',
                          labelStyle: TextStyle(color: AppColors.secondaryText),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _searchContent,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                      if (_searchResult != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _searchResult!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      if (_searchData != null) ...[
                        const SizedBox(height: 20),
                        Card(
                          color: AppColors.secondaryBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_searchData!['poster_path'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 250,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '$_imageBaseUrl${_searchData!['poster_path']}',
                                        height: 250,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchData!['name'] ?? 'Unknown Title',
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchData!['overview'] ??
                                      'No overview available',
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(_searchData!['vote_average'] ?? 0.0).toStringAsFixed(1)}/10',
                                      style: const TextStyle(
                                        color: AppColors.primaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.calendar_today,
                                        color: AppColors.secondaryText,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _searchData!['first_air_date'] ??
                                          'Unknown',
                                      style: const TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_searchData!['number_of_seasons'] !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Seasons: ${_searchData!['number_of_seasons']}',
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (!_isMovie) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _seasonController,
                                  style: const TextStyle(
                                      color: AppColors.primaryText),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Season Number',
                                    labelStyle: TextStyle(
                                        color: AppColors.secondaryText),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchSeasonEpisodes,
                                icon: const Icon(Icons.download),
                                label: const Text('Fetch Episodes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Episodes',
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addNewEpisode,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Episode'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._episodes.map((episode) => Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: AppColors.secondaryBackground,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Episode ${episode.episodeNumber}',
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        onChanged: (value) =>
                                            episode.link1080p = value,
                                        style: const TextStyle(
                                            color: AppColors.primaryText),
                                        decoration: const InputDecoration(
                                          labelText: '1080p Link',
                                          labelStyle: TextStyle(
                                              color: AppColors.secondaryText),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        onChanged: (value) =>
                                            episode.link720p = value,
                                        style: const TextStyle(
                                            color: AppColors.primaryText),
                                        decoration: const InputDecoration(
                                          labelText: '720p Link',
                                          labelStyle: TextStyle(
                                              color: AppColors.secondaryText),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        onChanged: (value) =>
                                            episode.link480p = value,
                                        style: const TextStyle(
                                            color: AppColors.primaryText),
                                        decoration: const InputDecoration(
                                          labelText: '480p Link',
                                          labelStyle: TextStyle(
                                              color: AppColors.secondaryText),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        onChanged: (value) =>
                                            episode.subtitle = value,
                                        style: const TextStyle(
                                            color: AppColors.primaryText),
                                        decoration: const InputDecoration(
                                          labelText: 'Subtitle Link (Optional)',
                                          labelStyle: TextStyle(
                                              color: AppColors.secondaryText),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
