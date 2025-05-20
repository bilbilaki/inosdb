// --- СОЗДАЙТЕ НОВЫЙ ФАЙЛ: movies_by_keyword_screen.dart ---
// --- CREATE A NEW FILE: movies_by_keyword_screen.dart ---

import 'package:flutter/material.dart';
import 'movie_model.dart'; // Ваш MovieModel и KeywordMoviesResponse
import 'movie_service.dart'; // Ваш MovieService
import 'movie_detail_page.dart'; // Для перехода на страницу деталей фильма

class MoviesByKeywordScreen extends StatefulWidget {
  final int keywordId;
  final String keywordName;
  final MovieService movieService; // Принимаем сервис

  const MoviesByKeywordScreen({
    Key? key,
    required this.keywordId,
    required this.keywordName,
    required this.movieService,
  }) : super(key: key);

  @override
  State<MoviesByKeywordScreen> createState() => _MoviesByKeywordScreenState();
}

class _MoviesByKeywordScreenState extends State<MoviesByKeywordScreen> {
  late Future<KeywordMoviesResponse> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = widget.movieService.getMoviesByKeyword(keywordId: widget.keywordId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies for "${widget.keywordName}"'),
      ),
      body: FutureBuilder<KeywordMoviesResponse>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading movies: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.results.isNotEmpty) {
            final movies = snapshot.data!.results;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Количество столбцов
                childAspectRatio: 0.65, // Соотношение сторон карточки
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _buildMovieCard(context, movie);
              },
            );
          } else {
            return Center(
              child: Text('No movies found for "${widget.keywordName}".'),
            );
          }
        },
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias, // Для закругления изображения
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3, // Дает больше места изображению
              child: Hero(
                tag: 'movie-keyword-${movie.id}', // Уникальный тег
                child: Image.network(
                  movie.fullPosterPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.movie, color: Colors.white54)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (movie.releaseDate.isNotEmpty)
                    Text(
                      movie.releaseDate.length > 4 ? movie.releaseDate.substring(0, 4) : movie.releaseDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- КОНЕЦ ФАЙЛА movies_by_keyword_screen.dart ---