import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () => context.go('/landing'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Show the splash image and scale it sensibly on all screens.
            final maxWidth = constraints.maxWidth;
            final targetWidth = maxWidth > 500 ? 400.0 : maxWidth * 0.7;
            return Image.asset(
              'assets/splash.png',
              width: targetWidth,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
