// TODO Implement this library.
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBackground = Color(0xFF0F0F0F); // Very dark grey
  static const Color secondaryBackground =
      Color(0xFF212121); // Slightly lighter grey
  static const Color accentColor = Colors.red;
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.grey;
  static const Color iconColor = Colors.white;
  static const Color chipBackground = Color(0xFF373737);
  static const Color chipBackgroundSelected = Color(0xFFFFFFFF);
  static const Color chipText = Colors.white;
  static const Color chipTextSelected = Colors.black;
  static const Color dividerColor = Colors.grey;
}

// TODO Implement this library.

class AppColors2 {
  // Primary colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background colors
    static const Color blackbackground = Color(0xFF000000);

  static const Color whitebackground = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  // Error color
  static const Color error = Color(0xFFB00020);
    static const Color error2 = Color.fromARGB(255, 255, 123, 0);
  static const Color error3 = Color.fromARGB(255, 200, 210, 0);
  static const Color extracolor = Color.fromARGB(255, 35, 252, 2);
  static const Color extracolor2 = Color.fromARGB(255, 0, 21, 255);
  static const Color extracolor3 = Color.fromARGB(255, 111, 189, 1);
  static const Color extracolor4 = Color.fromARGB(255, 82, 3, 90);
  static const Color extracolor5 = Color.fromARGB(255, 128, 233, 243);
  static const Color extracolor6 = Color.fromARGB(255, 106, 2, 2);
  static const Color extracolor7 = Color.fromARGB(255, 31, 8, 133);
  static const Color extracolor8 = Color.fromARGB(255, 7, 227, 143);
  static const Color extracolor9 = Color.fromARGB(87, 184, 42, 158);
  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;
  static const Color tinytext = Color.fromARGB(221, 191, 188, 188);

  // Additional custom colors
  static const Color accentColor = Color(0xFFFF4081);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF6200EE),
    Color(0xFF9C27B0),
        Color.fromARGB(255, 14, 2, 255),

  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF03DAC6),
    Color(0xFF018786),
    Color.fromARGB(255, 14, 2, 255),
  ];
}

// Theme configuration for the app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors2.primaryColor,
      colorScheme: ColorScheme(
        primary: AppColors2.primaryColor,
        primaryContainer: AppColors2.primaryVariant,
        secondary: AppColors2.secondaryColor,
        secondaryContainer: AppColors2.secondaryVariant,
        surface: AppColors2.surface,
        background: AppColors2.whitebackground,
        error: AppColors2.error,
        onPrimary: AppColors2.onPrimary,
        onSecondary: AppColors2.onSecondary,
        onSurface: AppColors2.onSurface,
        onBackground: AppColors2.onBackground,
        onError: AppColors2.onError,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors2.whitebackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors2.primaryColor,
        foregroundColor: AppColors2.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors2.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors2.primaryColor,
          foregroundColor: AppColors2.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors2.primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors2.primaryColor,
          side: BorderSide(color: AppColors2.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors2.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppColors2.surface,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors2.dividerColor,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors2.onBackground,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors2.onBackground,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors2.onBackground,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors2.onBackground,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors2.onBackground,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors2.onBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors2.onBackground,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors2.primaryColor,
      colorScheme: ColorScheme(
        primary: AppColors2.primaryColor,
        primaryContainer: AppColors2.primaryVariant,
        secondary: AppColors2.secondaryColor,
        secondaryContainer: AppColors2.secondaryVariant,
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        error: AppColors2.error,
        onPrimary: AppColors2.onPrimary,
        onSecondary: AppColors2.onSecondary,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: AppColors2.onError,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF1F1F1F),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors2.primaryColor,
          foregroundColor: AppColors2.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors2.secondaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors2.secondaryColor,
          side: BorderSide(color: AppColors2.secondaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors2.secondaryColor, width: 2),
        ),
        filled: true,
        fillColor: Color(0xFF2C2C2C),
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFF3D3D3D),
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Example of how to use the MaterialApp with the theme
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      debugShowCheckedModeBanner: false,
      home: const HomePagetest(),
    );
  }
}

// Placeholder for HomePage
class HomePagetest extends StatelessWidget {
  const HomePagetest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Awesome App!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors2.secondaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
