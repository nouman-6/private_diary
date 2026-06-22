import 'package:flutter/material.dart';
import 'package:private_diary/models/diary_entry.dart';
import 'package:private_diary/provider/diary_provider.dart';
import 'package:private_diary/provider/theme_provider.dart';
import 'package:private_diary/theme/app_theme.dart';
import 'package:private_diary/view/home_screen.dart';
import 'package:private_diary/view/lock_screen.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(DiaryEntryAdapter());
  await Hive.openBox<DiaryEntry>('diary_entries');

  FlutterNativeSplash.remove();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Private Diary',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LockScreen(child: const HomeScreen()),
    );
  }
}
