// --- episode_detail_page.dart ---
import 'package:flutter/material.dart';
import 'tv_model.dart';
import 'movie_service.dart';
import 'person_detail_page.dart'; // For navigating to crew/guest star details

class EpisodeDetailPage extends StatefulWidget {
  final int tvShowId;
  final int seasonNumber;
  final int episodeNumber;
  final String episodeName; // For AppBar title
  final MovieService movieService;

  const EpisodeDetailPage({
    Key? key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.episodeName,
    required this.movieService,
  }) : super(key: key);

  @override
  State<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends State<EpisodeDetailPage> {
  late Future<EpisodeDetails> _episodeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _episodeDetailsFuture = widget.movieService.getTvShowEpisodeDetails(
      tvShowId: widget.tvShowId,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
    );
  }

  void _navigateToPersonDetail(int personId, String name, String? profilePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailPage(
          personId: personId,
          initialName: name,
          initialProfilePath: profilePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EpisodeDetails>(
        future: _episodeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final episode = snapshot.data!;
            final String fullStillPath = episode.stillPath != null
              ? 'https://image.tmdb.org/t/p/w780${episode.stillPath}' // Larger still
              : 'https://via.placeholder.com/780x439?text=No+Still+Image';

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'S${episode.seasonNumber} E${episode.episodeNumber}: ${episode.name}',
                      style: const TextStyle(fontSize: 16, shadows: [Shadow(blurRadius: 5, color: Colors.black)]),
                    ),
                    background: Image.network(
                      fullStillPath,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(color: Colors.grey[800], child: Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 50))),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Air Date: ${episode.airDate}', style: Theme.of(context).textTheme.titleSmall),
                            if (episode.runtime != null)
                                Text('Runtime: ${episode.runtime} min', style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                         if (episode.voteAverage > 0) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text('${episode.voteAverage.toStringAsFixed(1)} (${episode.voteCount} votes)', style: Theme.of(context).textTheme.titleSmall),
                            ]),
                         ],
                        const SizedBox(height: 16),
                        Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(episode.overview.isEmpty ? 'No overview available.' : episode.overview),
                        
                        if (episode.guestStars.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Guest Stars', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          _buildPersonList(context, episode.guestStars, true),
                        ],

                        if (episode.crew.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Crew', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          _buildPersonList(context, episode.crew, false),
                        ],
                        const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Episode details not found.'));
          }
        },
      ),
    );
  }

  Widget _buildPersonList(BuildContext context, List<dynamic> people, bool isGuestStar) {
    return SizedBox(
      height: 180, // Adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: people.length,
        itemBuilder: (context, index) {
          final person = people[index];
          String name = '';
          String? profilePath;
          String? role = ''; // Character for guest star, job for crew

          if (isGuestStar && person is GuestStar) {
            name = person.name;
            profilePath = person.profilePath;
            role = person.character;
          } else if (!isGuestStar && person is CrewMember) {
            name = person.name;
            profilePath = person.profilePath;
            role = person.job;
          }
          
          final String fullProfileUrl = profilePath != null
            ? 'https://inosdb.worker-inosuke.workers.dev/w500$profilePath'
            : 'https://via.placeholder.com/200x300?text=No+Image';
          return GestureDetector(
            onTap: () => _navigateToPersonDetail(person.id, name, profilePath),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullProfileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => Container(color: Colors.grey[700], child: const Center(child: Icon(Icons.person_outline))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  if (role.isNotEmpty)
                    Text(role, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// --- END OF EpisodeDetailPage.dart ---