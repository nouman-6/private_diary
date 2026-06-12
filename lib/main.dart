import 'package:flutter/material.dart';
import 'package:private_diary/view/home_screen.dart';
import 'package:private_diary/view/lock_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Diary',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LockScreen(child: const HomeScreen()),
    );
  }
}
