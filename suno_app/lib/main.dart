// flutter_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suno_app/data/repositories/settings_repository.dart';
import 'package:suno_app/screens/home/home_screen.dart';
import 'package:suno_app/screens/onboarding/onboarding_screen.dart';
import 'package:suno_app/screens/settings/settings_screen.dart';
import 'package:suno_app/screens/translation/translation_screen.dart';
import 'package:suno_app/services/audio_service.dart';
import 'package:suno_app/services/model_management_service.dart';
import 'package:suno_app/services/permissions_service.dart';
import 'package:suno_app/services/translation_service.dart';
import 'package:suno_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For initial check

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // You might want to pre-load some services or check initial states here
  // For instance, check if onboarding is needed
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide core services as singletons throughout the app
        Provider<PermissionsService>(create: (_) => PermissionsService()),
        Provider<AudioService>(
          create: (_) => AudioService(),
          dispose: (_, service) =>
              service.dispose(), // Dispose audio service when no longer needed
        ),
        Provider<TranslationService>(
          create: (_) => TranslationService(),
          dispose: (_, service) =>
              service.dispose(), // Dispose translation service
        ),
        Provider<ModelManagementService>(
          create: (_) => ModelManagementService(),
        ),
        // Provide repositories
        Provider<SettingsRepository>(create: (_) => SettingsRepository()),
      ],
      child: MaterialApp(
        title: 'Suno',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Use your defined light theme
        // Define routes
        initialRoute: onboardingComplete ? '/' : '/onboarding',
        routes: {
          '/': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/translation': (context) => const TranslationScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        // A simple way to handle navigation after onboarding
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (context) {
                // Mark onboarding as complete after navigating to home for the first time
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('onboardingComplete', true);
                });
                return const HomeScreen();
              },
            );
          }
          return null; // Let the regular routes handle other paths
        },
      ),
    );
  }
}
