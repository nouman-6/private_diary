import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _progress = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRect(
          clipper: _TextRevealClipper(_progress),
          child: const Text(
            'Welcome to your Diary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _TextRevealClipper extends CustomClipper<Rect> {
  final double progress;
  _TextRevealClipper(this.progress);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width * progress, size.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}