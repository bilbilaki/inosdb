import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';
import 'tv_model.dart';

class MovieService {
  static const String _baseUrl = 'https://odd-cloud-55fe.worker-inosuke.workers.dev';
  static const String _apiKey = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2MDdlNDBhZjViYjY2NTc2ZjZmZDcyNTJkNTUyOWUyNCIsIm5iZiI6MTcyNTMxNjQ1OC4yNCwic3ViIjoiNjZkNjNkNmEzZTFhYjQ1Y2U1YjFiN2NmIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.N701knycQaKNMmYbdRnF3ag0dl9i28cL4oZBC-c42OY';

  final http.Client _client;

  MovieService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Accept': 'application/json',
  };

  Future<MovieResponse> getPopularMovies({int page = 1, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/movie/popular?language=$language&page=$page');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MovieResponse.fromJson(data);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<Movie> getMovieDetails({required int movieId, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/movie/$movieId?language=$language');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }
  
  Future<MovieCredits> getMovieCredits({required int movieId, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/movie/$movieId/credits?language=$language');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MovieCredits.fromJson(data);
      } else {
        throw Exception('Failed to load movie credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie credits: $e');
    }
  }
  
  Future<Person> getPersonDetails({required int personId, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/person/$personId?language=$language');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Person.fromJson(data);
      } else {
        throw Exception('Failed to load person details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching person details: $e');
    }
  }
  
  // Helper method to get both movie details and credits in parallel
  Future<MovieResponse> getMovieRecommendations({required int movieId, int page = 1, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/movie/$movieId/recommendations?language=$language&page=$page');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MovieResponse.fromJson(data);
      } else {
        throw Exception('Failed to load movie recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetailsWithCredits({required int movieId, String language = 'en-US'}) async {
    try {
      final detailsFuture = getMovieDetails(movieId: movieId, language: language);
      final creditsFuture = getMovieCredits(movieId: movieId, language: language);
      final recommendationsFuture = getMovieRecommendations(movieId: movieId, language: language);
      
      final results = await Future.wait([detailsFuture, creditsFuture, recommendationsFuture]);
      
      return {
        'details': results[0] as Movie,
        'credits': results[1] as MovieCredits,
        'recommendations': results[2] as MovieResponse,
      };
    } catch (e) {
      throw Exception('Error fetching movie data: $e');
    }
  }

  Future<TvShowResponse> getPopularTvShows({int page = 1, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/tv/popular?language=$language&page=$page');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TvShowResponse.fromJson(data);
      } else {
        throw Exception('Failed to load TV shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV shows: $e');
    }
  }
  
  Future<TvShowResponse> getTvShowRecommendations({required int tvShowId, int page = 1, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/tv/$tvShowId/recommendations?language=$language&page=$page');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TvShowResponse.fromJson(data);
      } else {
        throw Exception('Failed to load TV show recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV show recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> getTvShowDetailsWithRecommendations({required int tvShowId, String language = 'en-US'}) async {
    try {
      final detailsFuture = getTvShowDetails(tvShowId: tvShowId, language: language);
      final recommendationsFuture = getTvShowRecommendations(tvShowId: tvShowId, language: language);
      
      final results = await Future.wait([detailsFuture, recommendationsFuture]);
      
      return {
        'details': results[0] as TvShow,
        'recommendations': results[1] as TvShowResponse,
      };
    } catch (e) {
      throw Exception('Error fetching TV show data: $e');
    }
  }

  Future<TvShow> getTvShowDetails({required int tvShowId, String language = 'en-US'}) async {
    try {
      final url = Uri.parse('$_baseUrl/tv/$tvShowId?language=$language');
      
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TvShow.fromJson(data);
      } else {
        throw Exception('Failed to load TV show details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV show details: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}