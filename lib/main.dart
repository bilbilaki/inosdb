import 'package:flutter/material.dart';
import 'package:media_cache_manager/media_cache_manager.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/services/user_data_service.dart'; // Import UserDataService
import 'package:miko/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:miko/app_shell.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await MediaCacheManager.instance.init();
  // Hive.registerAdapter(MovieAdapter()); // Remove or comment out if this was for the old model

  // Initialize Hive and register adapters

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DrawerState()),
        ChangeNotifierProvider(create: (context) => AnimeProvider()), // Initialize AnimeProvider directly
        ChangeNotifierProvider(create: (context) => MovieProvider()), // Initialize MovieProvider directly
        ChangeNotifierProvider(create: (context) => TvSeriesProvider()),
        ChangeNotifierProvider(
            create: (context) => UserDataService()), // Add UserDataService
      ],
      child: const MyApp(), // Use const if MyApp is stateless
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Make const

  @override
  Widget build(BuildContext context) {
    // Wrap with the DrawerState Provider
    return ChangeNotifierProvider(
        create: (context) => DrawerState(),
        child: MaterialApp.router(
          title: 'Miko',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Follows system theme
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ));
  }
}
