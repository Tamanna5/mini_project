import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_tracker/screens/home_screen.dart';
import 'package:book_tracker/providers/book_provider.dart';
import 'package:book_tracker/providers/reading_goal_provider.dart';
import 'package:book_tracker/providers/theme_provider.dart';
import 'package:book_tracker/providers/user_auth_provider.dart';
import 'package:book_tracker/themes/app_theme.dart';
import 'package:book_tracker/screens/welcome_screen.dart';
import 'package:book_tracker/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_tracker/services/db_initialization.dart';
import 'package:book_tracker/screens/auth/signup_screen.dart';
import 'package:book_tracker/screens/settings_screen.dart';
import 'package:book_tracker/screens/privacy_policy_screen.dart';
import 'package:book_tracker/screens/auth/login_screen.dart';
import 'package:book_tracker/screens/goals_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database configuration
  await initializeDatabaseConfig();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();
  
  // Create providers
  final themeProvider = ThemeProvider();
  final bookProvider = BookProvider();
  final readingGoalProvider = ReadingGoalProvider();
  
  // Initialize providers
  await bookProvider.init();
  await readingGoalProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => bookProvider),
        ChangeNotifierProvider(create: (_) => readingGoalProvider),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
      ],
      child: const BookTrackerApp(),
    ),
  );
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, UserAuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'Book Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/signup': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/privacy_policy': (context) => const PrivacyPolicyScreen(),
            '/goals': (context) => const GoalsScreen(),
          },
        );
      },
    );
  }
  
  Widget _handleCurrentScreen(UserAuthProvider authProvider) {
    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      case AuthStatus.uninitialized:
      default:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
