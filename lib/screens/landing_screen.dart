import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../widgets/glassmorphic_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/background.mp4');
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePlayTap() {
    context.go(AppRoutes.login);
  }

  void _handleCreateAccount() {
    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading video:\n$_error',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isVideoInitialized) _buildVideoBackground(),
          if (!_isVideoInitialized)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0f172a), Color(0xFF111827)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.72),
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          if (!_isVideoInitialized)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 32),
                  _buildGlassButton(),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _handleCreateAccount,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }

  Widget _buildGlassButton() {
    return AnimatedGlassmorphicCard(
      onTap: _handlePlayTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 320,
        height: 90,
        child: const Center(
          child: Text(
            'PLAY NOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Stack(
          children: [
            Text(
              'CHAMBER',
              style: GoogleFonts.luckiestGuy(
                fontSize: 85,
                letterSpacing: 2,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 10
                  ..color = Colors.black,
              ),
            ),
            Text(
              'CHAMBER',
              style: GoogleFonts.luckiestGuy(
                fontSize: 85,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -52),
          child: Stack(
            children: [
              Text(
                'OPOLY',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 85,
                  letterSpacing: 6,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10
                    ..color = Colors.black,
                ),
              ),
              Text(
                'OPOLY',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 85,
                  letterSpacing: 6,
                  color: const Color(0xFFa78bfa),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
