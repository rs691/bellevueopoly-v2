import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/glassmorphic_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_form_container.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _initializeParticles();
  }

  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _Particle(
          color: _getRandomColor(),
          size: math.Random().nextDouble() * 20 + 10,
          offsetX: math.Random().nextDouble(),
          offsetY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.1 + 0.05,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.pinkAccent.withValues(alpha: 0.4),
      Colors.purpleAccent.withValues(alpha: 0.4),
      Colors.orangeAccent.withValues(alpha: 0.4),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;
    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      setState(() => _emailSent = true);
      _showSuccess('Password reset email sent! Check your inbox.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('No account found with this email.');
      } else if (e.code == 'invalid-email') {
        _showError('Invalid email address.');
      } else if (e.code == 'too-many-requests') {
        _showError('Too many requests. Try again later.');
      } else {
        _showError(e.message ?? 'Failed to send reset email.');
      }
    } catch (e) {
      _showError('An unexpected error occurred.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  List<Widget> _buildParticles() {
    return _particles.asMap().entries.map((entry) {
      final particle = entry.value;
      return Positioned(
        left: particle.offsetX * 400,
        top: particle.offsetY * 800,
        child: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final yOffset =
                (_particleController.value * particle.speed * 500) % 800;
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: particle.color,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ..._buildParticles(),
            SafeArea(
              child: ResponsiveFormContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter your email to receive a password reset link',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (!_emailSent)
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              GlassmorphicCard(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        const TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: Colors.white70),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your email';
                                    }
                                    if (!value!.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _email = value ?? '';
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _trySubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Send Reset Email',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Password reset email sent to $_email',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Check your email for a link to reset your password. If you don\'t see it, check your spam folder.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      if (!_emailSent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Remember your password? ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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
