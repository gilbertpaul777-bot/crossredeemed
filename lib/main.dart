import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:media_kit/media_kit.dart';

import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';
import 'providers/bible_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const CrossRedeemedApp());
}

class CrossRedeemedApp extends StatelessWidget {
  const CrossRedeemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BibleSettingsProvider(),
      child: MaterialApp(
        title: 'CrossRedeemed',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
