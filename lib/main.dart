import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/services/theme_services.dart';
import 'package:to_do_app/ui/theme.dart';

// Import Firebase packages
import 'package:firebase_core/firebase_core.dart';


import 'ui/login_screen.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ], child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkTheme = ref.watch(appThemeProvider).getTheme();
    print(isDarkTheme);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Todo',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
