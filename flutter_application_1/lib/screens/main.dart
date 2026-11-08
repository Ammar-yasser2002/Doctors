import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for intl (needed for Arabic date/time formatting).
  Intl.defaultLocale = 'ar';
  await initializeDateFormatting('ar');

  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please configure Firebase:');
    debugPrint('1. Make sure android/app/google-services.json exists');
    debugPrint('2. Make sure your Android package name matches the Firebase app');
    debugPrint('3. Add the SHA-1 fingerprint to your Firebase Android app');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Doctors App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              primary: const Color(0xFF1565C0),
              secondary: const Color(0xFF1A1A2E),
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1A1A2E),
              elevation: 0,
            ),
            useMaterial3: true,
            fontFamily: 'Cairo',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontWeight: FontWeight.w300),
              bodyMedium: TextStyle(fontWeight: FontWeight.w300),
              bodySmall: TextStyle(fontWeight: FontWeight.w300),
              titleLarge: TextStyle(fontWeight: FontWeight.w300),
              titleMedium: TextStyle(fontWeight: FontWeight.w300),
              titleSmall: TextStyle(fontWeight: FontWeight.w300),
              headlineLarge: TextStyle(fontWeight: FontWeight.w300),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300),
              headlineSmall: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
          
        );
      },
    );
  }
}