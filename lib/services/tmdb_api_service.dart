// tmdb_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:myapp/models/tvseries_details.dart';
// Import the model

class TmdbApiService {
  // --- IMPORTANT: REPLACE WITH YOUR ACTUAL TMDB API KEY ---
  final String _apiKey = '607e40af5bb66576f6fd7252d5529e24';
  // -------------------------------------------------------

  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<TvSeriesDetails?> findAndFetchTvSeriesDetails(
      String seriesName) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY_HERE') {
      if (kDebugMode) {
        print(
            "ERROR: Please replace 'YOUR_TMDB_API_KEY_HERE' with your actual TMDB API key in tmdb_api_service.dart");
      }
      throw Exception(
          "TMDB API Key not set. Please replace 'YOUR_TMDB_API_KEY_HERE' in tmdb_api_service.dart");
    }

    if (seriesName.trim().isEmpty) {
      if (kDebugMode) {
        print("ERROR: Series name cannot be empty.");
      }
      return null; // Or throw an exception
    }
    final String formatted =
        seriesName.replaceAll(RegExp(r' _\:;+'), '-').toLowerCase();

    try {
      // 1. Search for the TV series by name
      final searchUri = Uri.parse(
          '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(formatted)}');

      if (kDebugMode) {
        print("Searching TMDB: $searchUri");
      }

      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final results =
            searchData['results'] as List<dynamic>?; // Make it nullable

        if (results != null && results.isNotEmpty) {
          // 2. Get the ID of the first result (most relevant usually)
          final firstResult = results[0];
          final seriesId = firstResult['id'] as int?;

          if (seriesId != null) {
            if (kDebugMode) {
              print(
                  "Found series ID: $seriesId for '$seriesName'. Fetching details...");
            }
            // 3. Fetch detailed information using the ID
            return await getTvSeriesDetails(seriesId);
          } else {
            if (kDebugMode) {
              print(
                  "No valid ID found in the first search result for '$seriesName'.");
            }
            return null;
          }
        } else {
          if (kDebugMode) {
            print("No results found for series: '$seriesName'");
          }
          return null; // No results found
        }
      } else {
        if (kDebugMode) {
          print(
              "Error searching TMDB: ${searchResponse.statusCode} - ${searchResponse.body}");
        }
        // Handle search error (e.g., invalid API key, network issue)
        throw Exception(
            'Failed to search TV series (Status code: ${searchResponse.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during TMDB API call: $e');
      }
      // Handle other errors (network, parsing)
      // You might want to return null or re-throw a custom exception
      return null;
      // throw Exception('An error occurred: $e');
    }
  }

  Future<Map<String, dynamic>?> findAndFetchRawTvSeriesDetailsJson(
      String seriesName) async {
    // ... (API key check, etc.) ...
    try {
      final searchUri = Uri.parse(
          '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(seriesName)}');
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData =
            json.decode(searchResponse.body) as Map<String, dynamic>;
        final results = searchData['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final seriesId = (results[0] as Map<String, dynamic>)['id'] as int?;
          if (seriesId != null) {
            final detailsUri = Uri.parse(
                '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US');
            final detailsResponse = await http.get(detailsUri);
            if (detailsResponse.statusCode == 200) {
              return json.decode(detailsResponse.body) as Map<String, dynamic>;
            }
          }
        }
      }
      return null;
    } catch (e) {
      // ... (error handling) ...
      return null;
    }
  }

  Future<Map<String, dynamic>?> findAndFetchRawTvSeriesDetailsJsonpostscreen(
      String _nameController) async {
    // ... (API key check, etc.) ...
    try {
      final searchUri = Uri.parse(
          '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(_nameController)}');
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData =
            json.decode(searchResponse.body) as Map<String, dynamic>;
        final results = searchData['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final seriesId = (results[0] as Map<String, dynamic>)['id'] as int?;
          if (seriesId != null) {
            final detailsUri = Uri.parse(
                '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US');
            final detailsResponse = await http.get(detailsUri);
            if (detailsResponse.statusCode == 200) {
              return json.decode(detailsResponse.body) as Map<String, dynamic>;
            }
          }
        }
      }
      return null;
    } catch (e) {
      // ... (error handling) ...
      return null;
    }
  }

  // --- Optional: Direct fetch by ID if you already have it ---
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
}
