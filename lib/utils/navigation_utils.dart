import 'package:flutter/material.dart';
import 'package:myapp/screens/search_screen.dart';
import 'package:myapp/screens/search_screen_tv.dart' as tv;
import 'package:myapp/screens/search_screen_anime.dart';

class NavigationUtils {
  static void navigateToSearch(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'movie':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
        break;
      case 'tv':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const tv.SearchScreenTv()),
        );
        break;
      case 'anime':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreenAnime()),
        );
        break;
      default:
        // Default to movie search if type is not recognized
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
    }
  }
}
