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

  Future<SeasonDetails> getTvShowSeasonDetails({
  required int tvShowId,
  required int seasonNumber,
  String language = 'en-US',
}) async {
  try {
    final url = Uri.parse('$_baseUrl/tv/$tvShowId/season/$seasonNumber?language=$language');
    
    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SeasonDetails.fromJson(data);
    } else {
      throw Exception('Failed to load TV show season details: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching TV show season details: $e');
  }
}



Future<YoutubeVideoForSeries> getTvShowVideos({
  required int tvShowId,
  String language = 'en-US',
}) async {
  try {
    final url = Uri.parse('$_baseUrl/tv/$tvShowId/videos?language=$language');
    
    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return YoutubeVideoForSeries.fromJson(data);
    } else {
      throw Exception('Failed to load TV show videos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching TV show videos: $e');
  }
}


Future<EpisodeDetails> getTvShowEpisodeDetails({
 required int tvShowId,
 required int seasonNumber,
 required int episodeNumber,
 String language = 'en-US',
}) async {
 try {
 final url = Uri.parse(
 '$_baseUrl/tv/$tvShowId/season/$seasonNumber/episode/$episodeNumber?language=$language'
 );
 
 final response = await _client.get(url, headers: _headers);

 if (response.statusCode == 200) {
 final Map<String, dynamic> data = json.decode(response.body);
 return EpisodeDetails.fromJson(data);
 } else {
 throw Exception('Failed to load TV show episode details: ${response.statusCode}');
 }
 } catch (e) {
 throw Exception('Error fetching TV show episode details: $e');
 }
}




Future<SearchResponse> searchMovies({
  required String query,
  bool includeAdult = true,
  String language = 'en-US',
  int page = 1,
  String? region,
  int? year,
}) async {
  try {
    // Prepare query parameters
    final Map<String, dynamic> queryParams = {
      'query': query,
      'include_adult': includeAdult.toString(),
      'language': language,
      'page': page.toString(),
    };

    // Add optional parameters if provided
    if (region != null) queryParams['region'] = region;
    if (year != null) queryParams['year'] = year.toString();

    // Construct the URL
    final url = Uri.parse('$_baseUrl/search/movie').replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );

    // Make the API call
    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SearchResponse.fromJson(data);
    } else {
      throw Exception('Failed to search movies: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error searching movies: $e');
  }
}

Future<MultiSearchResponse> multiSearch({
  required String query,
  bool includeAdult = false,
  String language = 'en-US',
  int page = 1,
}) async {
  try {
    final queryParams = {
      'query': query,
      'include_adult': includeAdult.toString(),
      'language': language,
      'page': page.toString(),
    };

    final url = Uri.parse('$_baseUrl/search/multi').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return MultiSearchResponse.fromJson(data);
    } else {
      throw Exception('Failed to perform multi-search: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error performing multi-search: $e');
  }
}



  // Keyword Search Method
  Future<KeywordSearchResponse> searchKeywords({
    required String query,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'query': query,
        'page': page.toString(),
      };

      final url = Uri.parse('$_baseUrl/search/keyword').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return KeywordSearchResponse.fromJson(data);
      } else {
        throw Exception('Failed to search keywords: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching keywords: $e');
    }
  }

  // Keyword Movies Method
  Future<KeywordMoviesResponse> getMoviesByKeyword({
    required int keywordId,
    bool includeAdult = false,
    String language = 'en-US',
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'include_adult': includeAdult.toString(),
        'language': language,
        'page': page.toString(),
      };

      final url = Uri.parse('$_baseUrl/keyword/$keywordId/movies').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return KeywordMoviesResponse.fromJson(data);
      } else {
        throw Exception('Failed to get movies by keyword: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting movies by keyword: $e');
    }
  }


  // TV Search Method
  Future<TVSearchResponse> searchTV({
    required String query,
    bool includeAdult = false,
    String language = 'en-US',
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'query': query,
        'include_adult': includeAdult.toString(),
        'language': language,
        'page': page.toString(),
      };

      final url = Uri.parse('$_baseUrl/search/tv').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TVSearchResponse.fromJson(data);
      } else {
        throw Exception('Failed to search TV shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching TV shows: $e');
    }
  }


  // TV Credits Method
  Future<TVCredits> getTVCredits({
    required int tvId,
    String language = 'en-US',
  }) async {
    try {
      final queryParams = {
        'language': language,
      };

      final url = Uri.parse('$_baseUrl/tv/$tvId/credits').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TVCredits.fromJson(data);
      } else {
        throw Exception('Failed to get TV credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting TV credits: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}