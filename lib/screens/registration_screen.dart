import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../widgets/glassmorphic_card.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  @override
  void initState() {
    super.initState();

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Initialize particles
    _initializeParticles();
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
    _particleController.dispose();
    super.dispose();
  }

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      _formKey.currentState?.save();
      // TODO: Implement Firebase registration
      print('Username: $_username, Email: $_email, Password: $_password');
      context.go('/');
    }
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

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Join the adventure!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Registration Form
                      GlassmorphicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _username = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || !value.contains('@')) {
                                      return 'Please enter a valid email.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _email = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _password = value ?? '';
                                  },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _trySubmit,
                                    child: const Text('Create Account'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Link to login
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(
                            color: Colors.cyanAccent.shade100,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(15, (index) {
      final particle = _particles[index];
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
    });
  }
}

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
