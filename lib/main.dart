// lib/main.dart
import 'package:flutter/material.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/services/user_data_service.dart'; // Import UserDataService
import 'package:provider/provider.dart';
import 'package:myapp/app_shell.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:media_kit/media_kit.dart';
import 'router.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();
 MediaKit.ensureInitialized();

 runApp(
 MultiProvider(
 providers: [
   ChangeNotifierProvider(create: (context) => DrawerState()),
   ChangeNotifierProvider(create: (context) => MovieProvider()),
   ChangeNotifierProvider(create: (context) => TvSeriesProvider()),
   ChangeNotifierProvider(create: (context) => AnimeProvider()),
   ChangeNotifierProvider(create: (context) => UserDataService()), // Add UserDataService
 ],
 child: const MyApp(),
 ),
 );
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with the DrawerState Provider
    return ChangeNotifierProvider(
      create: (context) => DrawerState(),
      child: MaterialApp.router(
        title: 'My App',
        theme: ThemeData(
          // Define your app's theme
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Use routerConfig instead of home/routes
        routerConfig: router, // Pass the router instance here
      ),
    );
  }
}