import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart'; // Assuming you might want to use this for the dialog

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeParticles();
  }

  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _Particle(
          color: _getRandomColor(),
          size: math.Random().nextDouble() * 15 + 5,
          offsetX: math.Random().nextDouble(),
          offsetY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.4 + 0.2,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.pinkAccent.withValues(alpha: 0.3),
      Colors.purpleAccent.withValues(alpha: 0.3),
      Colors.orangeAccent.withValues(alpha: 0.3),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Particle Animation
            ..._buildParticles(),
            // Main UI Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  _buildStaticDice(),
                  const SizedBox(height: 40),
                  _buildStaticTitle(),
                  const SizedBox(height: 12),
                  const Text(
                    'Roll the dice, explore your city',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildPlayNowButton(context),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/welcome'),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final animValue = (_particleController.value + particle.offsetY) % 1.0;
          return Positioned(
            left: MediaQuery.of(context).size.width * particle.offsetX,
            top: screenHeight * animValue - particle.size,
            child: Opacity(
              opacity: (math.sin(animValue * math.pi) * 0.5).clamp(0.0, 0.5),
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildStaticDice() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFe879f9), Color(0xFF9333ea)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFec4899).withValues(alpha: 0.6),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.casino, size: 80, color: Colors.white),
    );
  }

  Widget _buildStaticTitle() {
    return Column(
      children: [
        Text(
          'CHAMBER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 0.9,
            shadows: [
              Shadow(
                color: const Color(0xFFec4899).withValues(alpha: 0.8),
                blurRadius: 20,
              ),
              Shadow(
                color: const Color(0xFFa855f7).withValues(alpha: 0.6),
                blurRadius: 40,
              ),
              const Shadow(color: Colors.black38, offset: Offset(4, 4)),
            ],
          ),
        ),
        Text(
          'OPOLY',
          style: TextStyle(
            color: const Color(0xFFa855f7),
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 0.9,
            shadows: [
              Shadow(
                color: const Color(0xFFec4899).withValues(alpha: 0.8),
                blurRadius: 20,
              ),
              Shadow(
                color: const Color(0xFFa855f7).withValues(alpha: 0.6),
                blurRadius: 40,
              ),
              const Shadow(color: Colors.black38, offset: Offset(4, 4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayNowButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFa855f7), Color(0xFF7c3aed)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFa855f7).withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFa855f7).withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAuthPrompt(context),
          borderRadius: BorderRadius.circular(15),
          child: const Center(
            child: Text(
              'PLAY NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAuthPrompt(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Authentication',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<double>(begin: 0.8, end: 1.0);
        return ScaleTransition(
          scale: tween.animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join the Adventure!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please create an account or log in to start playing.',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/login');
                        },
                        child: const Text('Log In'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/register');
                        },
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final Color color;
  final double size;
  final double offsetX;
  final double offsetY;
  final double speed;

  _Particle({
    required this.color,
    required this.size,
    required this.offsetX,
    required this.offsetY,
    required this.speed,
  });
}

