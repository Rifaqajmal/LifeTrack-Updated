import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';
import 'providers/birthday_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lets birthdays be added/edited offline; they sync when back online.
  try {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  } catch (e) {
    debugPrint('Could not enable database persistence: $e');
  }

  await HiveService.init();
  await NotificationService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.load();
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(MyApp(themeProvider: themeProvider, settings: settingsProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeProvider, required this.settings});

  final ThemeProvider themeProvider;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BirthdayProvider()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
