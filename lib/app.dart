import 'package:flutter/material.dart';
import 'package:mobile_final/views/auth/login_screen.dart';
import 'package:mobile_final/views/auth/signup_screen.dart';
import 'package:mobile_final/views/auth/onboarding_screen.dart';
import 'package:mobile_final/views/flashcards/deck_list_screen.dart';
import 'package:mobile_final/views/home/home_screen.dart';
import 'package:mobile_final/views/settings/settings_screen.dart';
import 'package:mobile_final/views/notes/notes_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_final/providers/theme_provider.dart';
import 'package:mobile_final/views/home/explore_screen.dart';

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StudySync',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: themeProvider.fontSize),
          bodyMedium: TextStyle(fontSize: themeProvider.fontSize),
          bodyLarge: TextStyle(fontSize: themeProvider.fontSize),
          labelLarge: TextStyle(fontSize: themeProvider.fontSize),
          titleMedium: TextStyle(fontSize: themeProvider.fontSize),
          titleLarge: TextStyle(fontSize: themeProvider.fontSize),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: themeProvider.fontSize),
          bodyMedium: TextStyle(fontSize: themeProvider.fontSize),
          bodyLarge: TextStyle(fontSize: themeProvider.fontSize),
          labelLarge: TextStyle(fontSize: themeProvider.fontSize),
          titleMedium: TextStyle(fontSize: themeProvider.fontSize),
          titleLarge: TextStyle(fontSize: themeProvider.fontSize),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/flashcards': (context) => const DeckListScreen(),
        '/notes': (context) => const NotesListScreen(),
        '/explore': (context) => const ExploreScreen(),
      },
    );
  }
}
