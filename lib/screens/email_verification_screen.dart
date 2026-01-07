import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/glassmorphic_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_form_container.dart';
import '../widgets/logout_confirmation_dialog.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  final List<_Particle> _particles = [];
  bool _isLoading = false;
  bool _isCheckingVerification = false;
  int _resendCooldown = 0;
  late DateTime _resendTime;

  @override
  void initState() {
    super.initState();
    _resendTime = DateTime.now().add(const Duration(seconds: 60));

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initializeParticles();
    _startResendTimer();

    // Auto-check email verification periodically
    _autoCheckEmailVerification();
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

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        final remaining = _resendTime.difference(now).inSeconds;
        if (remaining > 0) {
          setState(() => _resendCooldown = remaining);
          _startResendTimer();
        } else {
          setState(() => _resendCooldown = 0);
        }
      }
    });
  }

  Future<void> _autoCheckEmailVerification() async {
    // Check every 3 seconds if email is verified
    while (mounted && !FirebaseAuth.instance.currentUser!.emailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        await FirebaseAuth.instance.currentUser!.reload();
        if (mounted && FirebaseAuth.instance.currentUser!.emailVerified) {
          _showSuccessAndNavigate();
          break;
        }
      } catch (e) {
        debugPrint('Error checking email verification: $e');
      }
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Email verified! Welcome!'),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.go('/');
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        _showSuccess('Verification email resent!');
        setState(() {
          _resendTime = DateTime.now().add(const Duration(seconds: 60));
        });
        _startResendTimer();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send verification email.');
    } catch (e) {
      _showError('An unexpected error occurred.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isCheckingVerification = true);

    try {
      await FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        _showSuccessAndNavigate();
      } else {
        _showError('Email not verified yet. Please check your inbox.');
      }
    } catch (e) {
      _showError('Error checking verification status.');
    }

    if (mounted) setState(() => _isCheckingVerification = false);
  }

  Future<void> _logout() async {
    final success = await LogoutConfirmationDialog.show(context);
    // Dialog handles navigation, only redirect to login if successful
    if (success && mounted) {
      context.go('/login');
    }
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
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
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
                      // Animated email icon
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.1),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.mail_outline,
                                color: Colors.blue,
                                size: 64,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Verify Your Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We sent a verification link to:',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassmorphicCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            widget.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Click the verification link in your email to activate your account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Check your spam folder if you don\'t see the email.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCheckingVerification
                              ? null
                              : _checkEmailVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCheckingVerification
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'I\'ve Verified My Email',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resendCooldown > 0 || _isLoading
                              ? null
                              : _resendVerificationEmail,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _resendCooldown > 0
                                      ? 'Resend Email (${_resendCooldown}s)'
                                      : 'Resend Verification Email',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _logout,
                        child: const Text(
                          'Use a different email',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
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
