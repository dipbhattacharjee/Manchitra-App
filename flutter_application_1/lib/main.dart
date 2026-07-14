import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/theme.dart';
import 'core/config/secrets.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/assistant/ai_assistant_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/weather/weather_screen.dart';
import 'features/profile/settings_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/privacy_policy_screen.dart';
import 'features/profile/about_manchitra_screen.dart';

/// ============================================================
/// MANCHITRA — Durga Puja 2026 Pandal Navigation App
/// ============================================================
/// App entry point and route configuration.
///
/// Screens:
///   /              → SplashScreen
///   /onboarding    → OnboardingScreen
///   /login         → LoginScreen
///   /home          → HomeScreen (with bottom nav)
///   /ai            → AIAssistantScreen
///   /notifications → NotificationsScreen
///   /weather       → WeatherScreen
/// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase using safe credentials
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(const ManchitraApp());
}

class ManchitraApp extends StatelessWidget {
  const ManchitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manchitra — Durga Puja 2026',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Initial route
      initialRoute: '/',

      // Route definitions
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/ai': (context) => const AIAssistantScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/about-manchitra': (context) => const AboutManchitraScreen(),
      },

      // Handle unknown routes
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),

      // Page transitions builder
      builder: (context, child) {
        return MediaQuery(
          // Prevent font scaling from accessibility settings breaking layout
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
