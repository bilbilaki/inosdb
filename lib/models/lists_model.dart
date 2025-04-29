enum MediaType {
  image,
  video,
  audio, movie, series,
}



class Movie {
  final String id;
  final String title;
  final String? description;
  final String source;
  final MediaType type;
  final String? thumbnailUrl;
  final String? previewUrl; // Added for preview videos
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  
  Movie({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.type,
    this.thumbnailUrl,
    this.previewUrl,
    this.duration,
    this.metadata,
  });
}
class Series {
  final String id;
  final String title;
  final String? description;
  final String source;
  final MediaType type;
  final String? thumbnailUrl;
  final String? previewUrl; // Added for preview videos
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  
  Series({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.type,
    this.thumbnailUrl,
    this.previewUrl,
    this.duration,
    this.metadata,
  });
}

class Music {
  final String id;
  final String title;
  final String? description;
  final String source;
  final MediaType type;
  final String? thumbnailUrl;
  final String? previewUrl; // Added for preview videos 
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  
  Music({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.type,
    this.thumbnailUrl,
    this.previewUrl,
    this.duration,
    this.metadata,
  });
}     

class Photo {
  final String id;
  final String title;
  final String? description;
  final String source;
  final MediaType type;
  final String? thumbnailUrl;
  final String? previewUrl; // Added for preview videos
  final Duration? duration;
  final Map<String, dynamic>? metadata; 
  
  Photo({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.type,
    this.thumbnailUrl,
    this.previewUrl,
    this.duration,
    this.metadata,
  });
}       

class Document {
  final String id;
  final String title;
  final String? description;
  final String source;
  final MediaType type;
  final String? thumbnailUrl;
  final String? previewUrl; // Added for preview videos
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  
  Document({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.type, 
    this.thumbnailUrl,
    this.previewUrl,
    this.duration,
    this.metadata,
  });
}

class Lists {
  final List<Movie> movies_list;
  final List<Series> series_list;
  final List<Music> music_list;
  final List<Photo> photos_list;
  final List<Document> documents_list;

  Lists({required this.movies_list, required this.series_list, required this.music_list, required this.photos_list, required this.documents_list});
}







class movie_list {
  final List<Movie> movies;

  movie_list({required this.movies});
}

class series_list {
  final List<Series> series;

  series_list({required this.series});
}

class music_list {
  final List<Music> music;

  music_list({required this.music});
}

class photo_list {
  final List<Photo> photos;

  photo_list({required this.photos});
}

class document_list {
  final List<Document> documents;

  document_list({required this.documents});
}

  