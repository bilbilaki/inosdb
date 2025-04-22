// lib/models/helpers.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../constants.dart'; // Import constants

// --- Base Image URL Helper ---
String _buildImageUrl(String? path, String size) {
  if (path == null || path.isEmpty || path == 'null') {
    // Return a placeholder or empty string if no path
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }
  // Ensure path doesn't start with '/'
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  return '${AppConstants.tmdbImageBaseUrl}/$size/$cleanPath';
}

// --- Cast Model ---
class CastMember {
  final String id;
  final String name;
  final String character;
  final String? profilePath; // Make nullable

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id']?.toString() ?? '', // Handle potential null or non-string
      name: json['name']?.toString() ?? 'Unknown Actor',
      character: json['character']?.toString() ?? 'Unknown Character',
      profilePath: json['profile_path']?.toString(),
    );
  }

  // Getters for profile picture URLs
  String getProfileUrlW500() => _buildImageUrl(profilePath, AppConstants.imageSizeW500);
  String getProfileUrlOriginal() => _buildImageUrl(profilePath, AppConstants.imageSizeOriginal);
}

// --- Crew Model ---
class CrewMember {
  final String id;
  final String name;
  final String job;
  final String department;
   final String? profilePath; // Make nullable

  CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Crew',
      job: json['job']?.toString() ?? 'Unknown Job',
      department: json['department']?.toString() ?? 'Unknown Department',
      profilePath: json['profile_path']?.toString(),
    );
  }

   // Getters for profile picture URLs
  String getProfileUrlW500() => _buildImageUrl(profilePath, AppConstants.imageSizeW500);
  String getProfileUrlOriginal() => _buildImageUrl(profilePath, AppConstants.imageSizeOriginal);
}

// --- Video Model ---
class Video {
  final String id; // TMDB Video ID
  final String key; // YouTube key
  final String name;
  final String site; // e.g., "YouTube"
  final String type; // e.g., "Trailer", "Teaser"

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Video',
      site: json['site']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  // Getter for the full YouTube watch URL
  String get youtubeWatchUrl {
    if (site.toLowerCase() == 'youtube' && key.isNotEmpty) {
      return '${AppConstants.youtubeBaseUrl}$key';
    }
    return ''; // Return empty if not a valid YouTube video
  }

   // Getter for a YouTube thumbnail URL
  String get youtubeThumbnailUrl {
     if (site.toLowerCase() == 'youtube' && key.isNotEmpty) {
      return '${AppConstants.youtubeThumbnailBaseUrl}$key/0.jpg'; // 0.jpg is standard quality thumbnail
    }
    return '';
  }
}

// --- Helper function to parse JSON safely ---
List<T> parseJsonList<T>(String? jsonString, T Function(Map<String, dynamic>) fromJson) {
  if (jsonString == null || jsonString.isEmpty || jsonString == 'null' || jsonString == '[]') {
    return [];
  }
  try {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    if (kDebugMode) {
      print("Error parsing JSON list: $e");
      print("Original string: $jsonString");
    }
    return []; // Return empty list on error
  }
}

// --- Helper function to parse delimited strings ---
List<String> parseDelimitedString(String? input, [String delimiter = '|']) {
  if (input == null || input.isEmpty || input == 'null') {
    return [];
  }
  return input.split(delimiter).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}