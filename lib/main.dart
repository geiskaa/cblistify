import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cblistify/pages/login.dart';
import 'package:cblistify/tema/theme_notifier.dart';
import 'package:cblistify/database/utils/constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: ThemeData(
        scaffoldBackgroundColor: palette.lighter, // Warna latar dari tema
        appBarTheme: AppBarTheme(
          backgroundColor: palette.base,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.base,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
