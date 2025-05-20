class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Person {
  final bool adult;
  final List<String>? alsoKnownAs;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final int gender;
  final String? homepage;
  final int id;
  final String? imdbId;
  final String knownForDepartment;
  final String name;
  final String? placeOfBirth;
  final double popularity;
  final String? profilePath;

  Person({
    required this.adult,
    this.alsoKnownAs,
    this.biography,
    this.birthday,
    this.deathday,
    required this.gender,
    this.homepage,
    required this.id,
    this.imdbId,
    required this.knownForDepartment,
    required this.name,
    this.placeOfBirth,
    required this.popularity,
    this.profilePath,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      adult: json['adult'] ?? false,
      alsoKnownAs: json['also_known_as'] != null
          ? List<String>.from(json['also_known_as'])
          : null,
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      gender: json['gender'] ?? 0,
      homepage: json['homepage'],
      id: json['id'] ?? 0,
      imdbId: json['imdb_id'],
      knownForDepartment: json['known_for_department'] ?? '',
      name: json['name'] ?? '',
      placeOfBirth: json['place_of_birth'],
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      profilePath: json['profile_path'],
    );
  }

  String get fullProfilePath => profilePath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500$profilePath'
      : 'https://image.tmdb.org/t/p/w500$profilePath';

  String get genderText {
    switch (gender) {
      case 1:
        return 'Female';
      case 2:
        return 'Male';
      default:
        return 'Not specified';
    }
  }

  String get formattedBirthday {
    if (birthday == null) return 'Unknown';

    final parts = birthday!.split('-');
    if (parts.length != 3) return birthday!;

    final year = parts[0];
    final month = _getMonthName(int.parse(parts[1]));
    final day = int.parse(parts[2]);

    return '$month $day, $year';
  }

  String get age {
    if (birthday == null) return 'Unknown';

    final birthDate = DateTime.parse(birthday!);
    final today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    if (deathday != null) {
      final deathDate = DateTime.parse(deathday!);
      age = deathDate.year - birthDate.year;
      if (deathDate.month < birthDate.month ||
          (deathDate.month == birthDate.month &&
              deathDate.day < birthDate.day)) {
        age--;
      }
      return '$age (Deceased)';
    }

    return '$age years old';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class Cast {
  final bool adult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final int castId;
  final String character;
  final String creditId;
  final int order;

  Cast({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    required this.castId,
    required this.character,
    required this.creditId,
    required this.order,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      adult: json['adult'] ?? false,
      gender: json['gender'] ?? 0,
      id: json['id'] ?? 0,
      knownForDepartment: json['known_for_department'] ?? '',
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      profilePath: json['profile_path'],
      castId: json['cast_id'] ?? 0,
      character: json['character'] ?? '',
      creditId: json['credit_id'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  String get fullProfilePath => profilePath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500$profilePath'
      : 'https://image.tmdb.org/t/p/w500$profilePath';

  String get genderText {
    switch (gender) {
      case 1:
        return 'Female';
      case 2:
        return 'Male';
      default:
        return 'Not specified';
    }
  }
}

class Crew {
  final bool adult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final String creditId;
  final String department;
  final String job;

  Crew({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    required this.creditId,
    required this.department,
    required this.job,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      adult: json['adult'] ?? false,
      gender: json['gender'] ?? 0,
      id: json['id'] ?? 0,
      knownForDepartment: json['known_for_department'] ?? '',
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      profilePath: json['profile_path'],
      creditId: json['credit_id'] ?? '',
      department: json['department'] ?? '',
      job: json['job'] ?? '',
    );
  }

  String get fullProfilePath => profilePath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500$profilePath'
      : 'https://image.tmdb.org/t/p/w500$profilePath';
}

class MovieCredits {
  final int id;
  final List<Cast> cast;
  final List<Crew> crew;

  MovieCredits({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    return MovieCredits(
      id: json['id'] ?? 0,
      cast: (json['cast'] as List?)
              ?.map((castMember) => Cast.fromJson(castMember))
              .toList() ??
          [],
      crew: (json['crew'] as List?)
              ?.map((crewMember) => Crew.fromJson(crewMember))
              .toList() ??
          [],
    );
  }

  // Get directors from crew
  List<Crew> get directors {
    return crew.where((crewMember) => crewMember.job == 'Director').toList();
  }

  // Get writers from crew (Screenplay, Writer, etc.)
  List<Crew> get writers {
    return crew
        .where((crewMember) =>
            crewMember.department == 'Writing' ||
            crewMember.job == 'Screenplay' ||
            crewMember.job == 'Writer' ||
            crewMember.job == 'Story')
        .toList();
  }

  // Get producers from crew
  List<Crew> get producers {
    return crew
        .where((crewMember) =>
            crewMember.department == 'Production' &&
            (crewMember.job == 'Producer' ||
                crewMember.job == 'Executive Producer'))
        .toList();
  }
}

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }

  String get fullLogoPath => logoPath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500$logoPath'
      : 'https://image.tmdb.org/t/p/w500$logoPath';
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({
    required this.iso31661,
    required this.name,
  });

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'] ?? '',
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Movie {
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final List<Genre>? genres;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  // Additional fields from detailed response
  final String? belongsToCollection;
  final int? budget;
  final String? homepage;
  final String? imdbId;
  final List<String>? originCountry;
  final List<ProductionCompany>? productionCompanies;
  final List<ProductionCountry>? productionCountries;
  final int? revenue;
  final int? runtime;
  final List<SpokenLanguage>? spokenLanguages;
  final String? status;
  final String? tagline;
  final List<Keyword> keywords;
  // Flag to indicate if this is a detailed movie object
  final bool hasDetails;

  Movie({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    this.genres,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    this.belongsToCollection,
    this.budget,
    this.homepage,
    this.imdbId,
    this.originCountry,
    this.productionCompanies,
    this.productionCountries,
    this.revenue,
    this.runtime,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.hasDetails = false,
    this.keywords = const [],
  });
  
  

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Check if this is a detailed response
    final bool hasDetails =
        json.containsKey('runtime') || json.containsKey('genres');
    var parsedKeywords = <Keyword>[];
    if (json['keywords'] != null && json['keywords']['keywords'] != null) {
      parsedKeywords = (json['keywords']['keywords'] as List)
          .map((k) => Keyword.fromJson(k))
          .toList();
    } else if (json['keywords'] is List) {
      // На случай, если структура другая
      parsedKeywords =
          (json['keywords'] as List).map((k) => Keyword.fromJson(k)).toList();
    }
    return Movie(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      // Handle both list formats (genre_ids from list and genres from detailed)
      genreIds: json.containsKey('genre_ids')
          ? List<int>.from(json['genre_ids'] ?? [])
          : (json.containsKey('genres')
              ? (json['genres'] as List?)
                      ?.map((genre) => genre['id'] as int)
                      .toList() ??
                  []
              : []),
      genres: json.containsKey('genres')
          ? (json['genres'] as List?)
              ?.map((genre) => Genre.fromJson(genre))
              .toList()
          : null,

      id: json['id'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      posterPath: json['poster_path'],
      releaseDate: json['release_date'] ?? '',
      title: json['title'] ?? '',
      video: json['video'] ?? false,
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,

      // Additional fields from detailed response
      belongsToCollection: json['belongs_to_collection']?.toString(),
      budget: json['budget'],
      homepage: json['homepage'],
      imdbId: json['imdb_id'],
      originCountry: json.containsKey('origin_country')
          ? List<String>.from(json['origin_country'] ?? [])
          : null,
      productionCompanies: json.containsKey('production_companies')
          ? (json['production_companies'] as List?)
              ?.map((company) => ProductionCompany.fromJson(company))
              .toList()
          : null,
      productionCountries: json.containsKey('production_countries')
          ? (json['production_countries'] as List?)
              ?.map((country) => ProductionCountry.fromJson(country))
              .toList()
          : null,
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: json.containsKey('spoken_languages')
          ? (json['spoken_languages'] as List?)
              ?.map((language) => SpokenLanguage.fromJson(language))
              .toList()
          : null,
      status: json['status'],
      tagline: json['tagline'],
      hasDetails: hasDetails,
    );
  }

  String get fullPosterPath => posterPath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500$posterPath'
      : 'https://image.tmdb.org/t/p/w500$posterPath';

  String get fullBackdropPath => backdropPath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w780$backdropPath'
      : 'https://image.tmdb.org/t/p/w780$backdropPath';

  String get formattedRuntime {
    if (runtime == null || runtime == 0) return 'N/A';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get formattedBudget {
    if (budget == null || budget == 0) return 'N/A';
    return '\$${(budget! / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedRevenue {
    if (revenue == null || revenue == 0) return 'N/A';
    return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
  }

  String get genresText {
    if (genres == null || genres!.isEmpty) return 'N/A';
    return genres!.map((genre) => genre.name).join(', ');
  }
}

class MovieResponse {
  final int page;
  final List<Movie> results;
  final int totalPages;
  final int totalResults;

  MovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((movie) => Movie.fromJson(movie))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

class SearchResponse {
  final int page;
  final List<Movie> results;
  final int totalPages;
  final int totalResults;
  final String releaseDate;

  SearchResponse({
    required this.page,
    required this.results,
    this.totalPages = 0,
    this.totalResults = 0,
    this.releaseDate = "4:20",
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((movieJson) => Movie.fromJson(movieJson))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

enum MediaType { movie, tv, person }

abstract class MultiSearchResult {
  final int id;
  final String name;
  final String originalName;
  final MediaType mediaType;
  final bool adult;
  final double popularity;
  final String? profilePath;
  final String? posterPath;
  final String? backdropPath;

  MultiSearchResult({
    required this.id,
    required this.name,
    required this.originalName,
    required this.mediaType,
    required this.adult,
    required this.popularity,
    this.profilePath,
    this.posterPath,
    this.backdropPath,
  });
}

class MultiSearchMovie extends MultiSearchResult {
  final String title;
  final String originalTitle;
  final String? overview;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final int voteCount;
  final bool video;
  final String? originalLanguage;

  MultiSearchMovie({
    required super.id,
    required super.name,
    required super.originalName,
    required super.mediaType,
    required super.adult,
    required super.popularity,
    super.posterPath,
    super.backdropPath,
    required this.title,
    required this.originalTitle,
    this.overview,
    this.releaseDate,
    this.genreIds = const [],
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.video = false,
    this.originalLanguage,
  });

  factory MultiSearchMovie.fromJson(Map<String, dynamic> json) {
    return MultiSearchMovie(
      id: json['id'],
      name: json['title'] ?? json['name'] ?? '',
      originalName: json['original_title'] ?? json['original_name'] ?? '',
      mediaType: MediaType.movie,
      adult: json['adult'] ?? false,
      popularity: json['popularity']?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'],
      releaseDate: json['release_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      voteAverage: json['vote_average']?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      video: json['video'] ?? false,
      originalLanguage: json['original_language'],
    );
  }
}

class MultiSearchTV extends MultiSearchResult {
  final String? overview;
  final String? firstAirDate;
  final List<int> genreIds;
  final double voteAverage;
  final int voteCount;
  final List<String> originCountry;
  final String? originalLanguage;

  MultiSearchTV({
    required super.id,
    required super.name,
    required super.originalName,
    required super.mediaType,
    required super.adult,
    required super.popularity,
    super.posterPath,
    super.backdropPath,
    this.overview,
    this.firstAirDate,
    this.genreIds = const [],
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.originCountry = const [],
    this.originalLanguage,
  });

  factory MultiSearchTV.fromJson(Map<String, dynamic> json) {
    return MultiSearchTV(
      id: json['id'],
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      mediaType: MediaType.tv,
      adult: json['adult'] ?? false,
      popularity: json['popularity']?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      firstAirDate: json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      voteAverage: json['vote_average']?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'],
    );
  }
}

class MultiSearchPerson extends MultiSearchResult {
  final int? gender;
  final String? knownForDepartment;
  final List<dynamic> knownFor;

  MultiSearchPerson({
    required super.id,
    required super.name,
    required super.originalName,
    required super.mediaType,
    required super.adult,
    required super.popularity,
    super.profilePath,
    this.gender,
    this.knownForDepartment,
    this.knownFor = const [],
  });

  factory MultiSearchPerson.fromJson(Map<String, dynamic> json) {
    return MultiSearchPerson(
      id: json['id'],
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      mediaType: MediaType.person,
      adult: json['adult'] ?? false,
      popularity: json['popularity']?.toDouble() ?? 0.0,
      profilePath: json['profile_path'],
      gender: json['gender'],
      knownForDepartment: json['known_for_department'],
      knownFor: json['known_for'] ?? [],
    );
  }
}

class MultiSearchResponse {
  final int page;
  final List<MultiSearchResult> results;
  final int totalPages;
  final int totalResults;

  MultiSearchResponse({
    required this.page,
    required this.results,
    this.totalPages = 0,
    this.totalResults = 0,
  });

  factory MultiSearchResponse.fromJson(Map<String, dynamic> json) {
    return MultiSearchResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List?)?.map((result) {
            switch (result['media_type']) {
              case 'movie':
                return MultiSearchMovie.fromJson(result);
              case 'tv':
                return MultiSearchTV.fromJson(result);
              case 'person':
                return MultiSearchPerson.fromJson(result);
              default:
                throw Exception('Unknown media type');
            }
          }).toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

class Keyword {
  final int id;
  final String name;

  Keyword({
    required this.id,
    required this.name,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'],
      name: json['name'],
    );
  }
}

class KeywordSearchResponse {
  final int page;
  final List<Keyword> results;
  final int totalPages;
  final int totalResults;

  KeywordSearchResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory KeywordSearchResponse.fromJson(Map<String, dynamic> json) {
    return KeywordSearchResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((keywordJson) => Keyword.fromJson(keywordJson))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

class KeywordMoviesResponse {
  final int id;
  final int page;
  final List<Movie> results;
  final int totalPages;
  final int totalResults;

  KeywordMoviesResponse({
    required this.id,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory KeywordMoviesResponse.fromJson(Map<String, dynamic> json) {
    return KeywordMoviesResponse(
      id: json['id'],
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((movieJson) => Movie.fromJson(movieJson))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}
