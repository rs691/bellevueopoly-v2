import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _diceController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final List<Coin> _coins = [];

  @override
  void initState() {
    super.initState();

    // Dice bounce animation
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Dice rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Glow animation for text
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Initialize particles
    _initializeParticles();
    _initializeCoins();
  }

  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        Particle(
          color: _getRandomColor(),
          size: math.Random().nextDouble() * 20 + 10,
          offsetX: math.Random().nextDouble(),
          offsetY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }

  void _initializeCoins() {
    for (int i = 0; i < 8; i++) {
      _coins.add(Coin(offsetX: math.Random().nextDouble(), delay: i * 0.5));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.pinkAccent.withOpacity(0.4),
      Colors.purpleAccent.withOpacity(0.4),
      Colors.orangeAccent.withOpacity(0.4),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _diceController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF2d1b4e), Color(0xFF1a0d33), Color(0xFF0a0015)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ..._buildParticles(),

            // Falling coins
            ..._buildCoins(),

            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // Animated Dice
                  _buildAnimatedDice(),

                  const SizedBox(height: 40),

                  // Title with glow effect
                  _buildGlowingTitle(),

                  const SizedBox(height: 12),

                  // Tagline
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

                  // Play Now button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildPlayNowButton(),
                  ),

                  const SizedBox(height: 20),

                  // Create Account link
                  GestureDetector(
                    onTap: () => context.go('/welcome'),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.cyanAccent.shade100,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildAnimatedDice() {
    return AnimatedBuilder(
      animation: Listenable.merge([_diceController, _rotationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_diceController.value * 0.15),
          child: Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: Container(
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
                    color: const Color(0xFFec4899).withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dice dots (showing 6)
                  ...List.generate(6, (index) {
                    final positions = [
                      const Alignment(-0.6, -0.6),
                      const Alignment(-0.6, 0.0),
                      const Alignment(-0.6, 0.6),
                      const Alignment(0.6, -0.6),
                      const Alignment(0.6, 0.0),
                      const Alignment(0.6, 0.6),
                    ];
                    return Align(
                      alignment: positions[index],
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a0d33),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowingTitle() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity1 = 0.8 + _glowController.value * 0.2;
        final glowOpacity2 = 0.6 + _glowController.value * 0.2;
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
                    color: const Color(0xFFec4899).withOpacity(glowOpacity1),
                    blurRadius: 20 + _glowController.value * 10,
                  ),
                  Shadow(
                    color: const Color(0xFFa855f7).withOpacity(glowOpacity2),
                    blurRadius: 40 + _glowController.value * 20,
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
                    color: const Color(0xFFec4899).withOpacity(glowOpacity1),
                    blurRadius: 20 + _glowController.value * 10,
                  ),
                  Shadow(
                    color: const Color(0xFFa855f7).withOpacity(glowOpacity2),
                    blurRadius: 40 + _glowController.value * 20,
                  ),
                  const Shadow(color: Colors.black38, offset: Offset(4, 4)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayNowButton() {
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
            color: const Color(0xFFa855f7).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFa855f7).withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/'),
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

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final animValue =
              (_particleController.value + particle.offsetY) % 1.0;

          return Positioned(
            left: MediaQuery.of(context).size.width * particle.offsetX,
            top: screenHeight * animValue - particle.size,
            child: Opacity(
              opacity: (math.sin(animValue * math.pi) * 0.6).clamp(0.0, 0.6),
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withOpacity(0.5),
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

  List<Widget> _buildCoins() {
    return _coins.map((coin) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final animValue =
              ((_particleController.value * coin.speed) + coin.delay) % 1.0;
          final rotation = animValue * 4 * math.pi;

          return Positioned(
            left: MediaQuery.of(context).size.width * coin.offsetX,
            top: screenHeight * animValue - 40,
            child: Opacity(
              opacity: animValue < 0.1 || animValue > 0.9 ? 0.0 : 1.0,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFfbbf24).withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

// Helper classes for particles and coins
class Particle {
  final Color color;
  final double size;
  final double offsetX;
  final double offsetY;
  final double speed;

  Particle({
    required this.color,
    required this.size,
    required this.offsetX,
    required this.offsetY,
    required this.speed,
  });
}

class Coin {
  final double offsetX;
  final double delay;
  final double speed;

  Coin({required this.offsetX, required this.delay, this.speed = 0.3});
}
