class TvShow {
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final List<Genre>? genres;
  final int id;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String? firstAirDate;
  final String? lastAirDate;
  final String name;
  final double voteAverage;
  final int voteCount;
  final List<Creator>? createdBy;
  final List<int>? episodeRunTime;
  final String? homepage;
  final bool? inProduction;
  final List<String>? languages;
  final Episode? lastEpisodeToAir;
  final Episode? nextEpisodeToAir;
  final List<Network>? networks;
  final int? numberOfEpisodes;
  final int? numberOfSeasons;
  final List<ProductionCompany>? productionCompanies;
  final List<ProductionCountry>? productionCountries;
  final List<Season>? seasons;
  final List<SpokenLanguage>? spokenLanguages;
  final String? status;
  final String? tagline;
  final String? type;

  TvShow({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    this.genres,
    required this.id,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    this.firstAirDate,
    this.lastAirDate,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
    this.createdBy,
    this.episodeRunTime,
    this.homepage,
    this.inProduction,
    this.languages,
    this.lastEpisodeToAir,
    this.nextEpisodeToAir,
    this.networks,
    this.numberOfEpisodes,
    this.numberOfSeasons,
    this.productionCompanies,
    this.productionCountries,
    this.seasons,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.type,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      genreIds: json['genre_ids'] != null 
          ? List<int>.from(json['genre_ids']) 
          : [],
      genres: json['genres'] != null 
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x))) 
          : null,
      id: json['id'] ?? 0,
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      posterPath: json['poster_path'],
      firstAirDate: json['first_air_date'],
      lastAirDate: json['last_air_date'],
      name: json['name'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      createdBy: json['created_by'] != null 
          ? List<Creator>.from(json['created_by'].map((x) => Creator.fromJson(x))) 
          : null,
      episodeRunTime: json['episode_run_time'] != null 
          ? List<int>.from(json['episode_run_time']) 
          : null,
      homepage: json['homepage'],
      inProduction: json['in_production'],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : null,
      lastEpisodeToAir: json['last_episode_to_air'] != null 
          ? Episode.fromJson(json['last_episode_to_air']) 
          : null,
      nextEpisodeToAir: json['next_episode_to_air'] != null 
          ? Episode.fromJson(json['next_episode_to_air']) 
          : null,
      networks: json['networks'] != null 
          ? List<Network>.from(json['networks'].map((x) => Network.fromJson(x))) 
          : null,
      numberOfEpisodes: json['number_of_episodes'],
      numberOfSeasons: json['number_of_seasons'],
      productionCompanies: json['production_companies'] != null 
          ? List<ProductionCompany>.from(json['production_companies'].map((x) => ProductionCompany.fromJson(x))) 
          : null,
      productionCountries: json['production_countries'] != null 
          ? List<ProductionCountry>.from(json['production_countries'].map((x) => ProductionCountry.fromJson(x))) 
          : null,
      seasons: json['seasons'] != null 
          ? List<Season>.from(json['seasons'].map((x) => Season.fromJson(x))) 
          : null,
      spokenLanguages: json['spoken_languages'] != null 
          ? List<SpokenLanguage>.from(json['spoken_languages'].map((x) => SpokenLanguage.fromJson(x))) 
          : null,
      status: json['status'],
      tagline: json['tagline'],
      type: json['type'],
    );
  }

  String get fullPosterPath => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
      : 'https://via.placeholder.com/500x750?text=No+Image';

  String get fullBackdropPath => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w500$backdropPath' 
      : 'https://via.placeholder.com/500x281?text=No+Image';
      
  String get year {
    if (firstAirDate == null || firstAirDate!.isEmpty) {
      return 'TBA';
    }
    return firstAirDate!.substring(0, 4);
  }
  
  String get formattedRating => voteAverage.toStringAsFixed(1);
  
  String get originCountryText => originCountry.isNotEmpty 
      ? originCountry.join(', ') 
      : 'Unknown';
      
  String get formattedRuntime {
    if (episodeRunTime == null || episodeRunTime!.isEmpty) {
      return 'Unknown';
    }
    
    final avgRuntime = episodeRunTime!.reduce((a, b) => a + b) / episodeRunTime!.length;
    final hours = avgRuntime ~/ 60;
    final minutes = avgRuntime.toInt() % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  String get formattedStatus {
    if (status == null) return 'Unknown';
    
    switch (status) {
      case 'Returning Series':
        return 'Currently Airing';
      case 'Ended':
        return 'Ended';
      case 'Canceled':
        return 'Canceled';
      case 'In Production':
        return 'In Production';
      default:
        return status!;
    }
  }
  
  String get airDateRange {
    if (firstAirDate == null) return 'TBA';
    
    final start = firstAirDate!;
    final end = inProduction == true ? 'Present' : (lastAirDate ?? 'Unknown');
    
    return '$start - $end';
  }
  
  List<String> get genreNames {
    if (genres != null && genres!.isNotEmpty) {
      return genres!.map((genre) => genre.name).toList();
    } else if (genreIds.isNotEmpty) {
      return genreIds.map((id) => _getGenreName(id)).toList();
    }
    return ['Unknown'];
  }
  
  String _getGenreName(int genreId) {
    final Map<int, String> genres = {
      10759: 'Action & Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      10762: 'Kids',
      9648: 'Mystery',
      10763: 'News',
      10764: 'Reality',
      10765: 'Sci-Fi & Fantasy',
      10766: 'Soap',
      10767: 'Talk',
      10768: 'War & Politics',
      37: 'Western',
    };
    
    return genres[genreId] ?? 'Unknown';
  }
}

class Season {
  final String? airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final int seasonNumber;
  final double voteAverage;

  Season({
    this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      airDate: json['air_date'],
      episodeCount: json['episode_count'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'] ?? 0,
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  String get fullPosterPath => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w300$posterPath' 
      : 'https://via.placeholder.com/300x450?text=No+Image';
      
  String get formattedAirDate {
    if (airDate == null || airDate!.isEmpty) return 'TBA';
    return airDate!;
  }
  
  String get year {
    if (airDate == null || airDate!.isEmpty) return 'TBA';
    if (airDate!.length < 4) return airDate!;
    return airDate!.substring(0, 4);
  }
}

class Episode {
  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String? airDate;
  final int episodeNumber;
  final String episodeType;
  final String? productionCode;
  final int? runtime;
  final int seasonNumber;
  final int showId;
  final String? stillPath;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    this.airDate,
    required this.episodeNumber,
    required this.episodeType,
    this.productionCode,
    this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      airDate: json['air_date'],
      episodeNumber: json['episode_number'] ?? 0,
      episodeType: json['episode_type'] ?? 'standard',
      productionCode: json['production_code'],
      runtime: json['runtime'],
      seasonNumber: json['season_number'] ?? 0,
      showId: json['show_id'] ?? 0,
      stillPath: json['still_path'],
    );
  }

  String get fullStillPath => stillPath != null 
      ? 'https://image.tmdb.org/t/p/w300$stillPath' 
      : 'https://via.placeholder.com/300x169?text=No+Image';
      
  String get formattedAirDate {
    if (airDate == null || airDate!.isEmpty) return 'TBA';
    return airDate!;
  }
  
  String get formattedEpisodeType {
    switch (episodeType) {
      case 'finale':
        return 'Season Finale';
      case 'mid_season':
        return 'Mid-Season';
      case 'premiere':
        return 'Season Premiere';
      case 'special':
        return 'Special';
      default:
        return 'Standard';
    }
  }
  
  String get formattedRuntime {
    if (runtime == null) return 'Unknown';
    
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class Creator {
  final int id;
  final String creditId;
  final String name;
  final String originalName;
  final int gender;
  final String? profilePath;

  Creator({
    required this.id,
    required this.creditId,
    required this.name,
    required this.originalName,
    required this.gender,
    this.profilePath,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? 0,
      creditId: json['credit_id'] ?? '',
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      gender: json['gender'] ?? 0,
      profilePath: json['profile_path'],
    );
  }

  String get fullProfilePath => profilePath != null 
      ? 'https://image.tmdb.org/t/p/w200$profilePath' 
      : 'https://via.placeholder.com/200x300?text=No+Image';
      
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

class Network {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  Network({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }

  String get fullLogoPath => logoPath != null 
      ? 'https://image.tmdb.org/t/p/w200$logoPath' 
      : 'https://via.placeholder.com/200x100?text=No+Logo';
}

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
      ? 'https://image.tmdb.org/t/p/w200$logoPath' 
      : 'https://via.placeholder.com/200x100?text=No+Logo';
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

class TvShowResponse {
  final int page;
  final List<TvShow> results;
  final int totalPages;
  final int totalResults;

  TvShowResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TvShowResponse.fromJson(Map<String, dynamic> json) {
    return TvShowResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List?)
              ?.map((show) => TvShow.fromJson(show))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}