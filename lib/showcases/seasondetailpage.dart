// --- season_detail_page.dart ---
import 'package:flutter/material.dart';
import 'tv_model.dart';
import 'movie_service.dart';
import 'episodedetailpage.dart'; // For navigation

class SeasonDetailPage extends StatefulWidget {
  final int tvShowId;
  final int seasonNumber;
  final String seasonName;
  final String? posterPath;
  final MovieService movieService;

  const SeasonDetailPage({
    Key? key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
    this.posterPath,
    required this.movieService,
  }) : super(key: key);

  @override
  State<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends State<SeasonDetailPage> {
  late Future<SeasonDetails> _seasonDetailsFuture;

  @override
  void initState() {
    super.initState();
    _seasonDetailsFuture = widget.movieService.getTvShowSeasonDetails(
      tvShowId: widget.tvShowId,
      seasonNumber: widget.seasonNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullPosterPath = widget.posterPath != null
        ? 'https://inosdb.worker-inosuke.workers.dev/w500${widget.posterPath}'
        : 'https://via.placeholder.com/500x750?text=No+Image';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.seasonName, style: const TextStyle(shadows: [Shadow(blurRadius: 5, color: Colors.black)])),
              background: widget.posterPath != null
                  ? Image.network(fullPosterPath, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(color: Colors.grey[800], child: Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 50))))
                  : Container(color: Colors.grey[800], child: Center(child: Icon(Icons.tv_outlined, color: Colors.white54, size: 80))),
            ),
          ),
          FutureBuilder<SeasonDetails>(
            future: _seasonDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text('Error: ${snapshot.error}')));
              } else if (snapshot.hasData && snapshot.data!.episodes.isNotEmpty) {
                final episodes = snapshot.data!.episodes..sort((a,b) => a.episodeNumber.compareTo(b.episodeNumber));
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final episode = episodes[index];
                      return _buildEpisodeListItem(context, episode);
                    },
                    childCount: episodes.length,
                  ),
                );
              } else {
                return const SliverFillRemaining(child: Center(child: Text('No episodes found for this season.')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeListItem(BuildContext context, Episode episode) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EpisodeDetailPage(
                tvShowId: widget.tvShowId, // or episode.showId if available and correct
                seasonNumber: episode.seasonNumber,
                episodeNumber: episode.episodeNumber,
                episodeName: episode.name,
                movieService: widget.movieService,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (episode.stillPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    episode.fullStillPath,
                    width: 120,
                    height: 67.5, // 16:9 aspect ratio
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(width: 120, height: 67.5, color: Colors.grey[700], child: const Center(child: Icon(Icons.hide_image_outlined))),
                  ),
                ),
              if (episode.stillPath != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E${episode.episodeNumber}: ${episode.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Air Date: ${episode.formattedAirDate}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    if (episode.voteAverage > 0) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                            const Icon(Icons.star_border, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(episode.voteAverage.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                        ]),
                    ],
                    const SizedBox(height: 6),
                    if (episode.overview.isNotEmpty)
                      Text(
                        episode.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- END OF SeasonDetailPage.dart ---