import 'package:flutter/foundation.dart'; // For kIsWeb check
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'dart:math' as math; // For random particle generation
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For state management (ConsumerStatefulWidget)

import '../widgets/glassmorphic_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_form_container.dart';

/// The LoginScreen handles user authentication via Email/Password and Google Sign-In.
/// It features an animated particle background and a glassmorphic UI design.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // --- ANIMATION STATE ---
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  // --- FORM STATE ---
  final _formKey =
      GlobalKey<FormState>(); // Key to validate and save form fields
  String _email = '';
  String _password = '';

  // --- LOADING STATE ---
  bool _isLoading = false; // For email/password loading state
  bool _isGoogleLoading = false; // For Google Sign-In loading state

  @override
  void initState() {
    super.initState();
    // Initialize the background particle animation
    // Duration controls the speed of the "breathing" or movement cycle
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slower, more ambient animation
    )..repeat();
    _initializeParticles();
  }

  /// populates the `_particles` list with random properties for the background effect
  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _Particle(
          color: _getRandomColor(),
          size: math.Random().nextDouble() * 20 + 10,
          offsetX: math.Random().nextDouble(),
          offsetY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.1 + 0.05, // Slower speed
        ),
      );
    }
  }

  /// Returns a random color from a predefined palette for the particles
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
    _particleController
        .dispose(); // Clean up controller to prevent memory leaks
    super.dispose();
  }

  // --- ERROR HANDLING HELPER ---
  /// Displays a floating SnackBar with error messages
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- EMAIL SIGN IN ---
  /// Validates the form and attempts to sign in via Firebase Email/Password Auth
  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return; // Stop if form is invalid
    _formKey.currentState?.save(); // Save form fields to variables

    setState(() => _isLoading = true);

    try {
      // Attempt Firebase Login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      // On success, navigation is handled by the AppRouter via auth state changes,
      // but we call context.go('/') here for explicit immediate feedback.
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed.');
    } catch (e) {
      _showError('An unexpected error occurred.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Handles the Google Sign-In flow, using signInWithPopup for Web and
  /// Firebase Auth provider-based sign-in for Mobile/Desktop.
  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final googleProvider = GoogleAuthProvider();
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: popup flow
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      } else {
        // Mobile/Desktop: provider-based flow (no google_sign_in package needed)
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          googleProvider,
        );
      }

      if (userCredential.user != null) {
        if (mounted) context.go('/');
      } else {
        throw Exception('Google Sign-In failed to return a user.');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google Sign-In failed via Firebase.');
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      _showError('Failed to sign in with Google. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }
  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Background Animation Layer
            ..._buildParticles(),

            // 2. Foreground Content Layer
            SafeArea(
              child: ResponsiveFormContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- HEADER TEXT ---
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Log in to continue your adventure',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 40),

                      // --- LOGIN FORM CARD ---
                      GlassmorphicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Email Field
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      (value == null || !value.contains('@'))
                                      ? 'Please enter a valid email.'
                                      : null,
                                  onSaved: (value) => _email = value ?? '',
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) =>
                                      (value == null || value.length < 6)
                                      ? 'Password must be at least 6 characters long.'
                                      : null,
                                  onSaved: (value) => _password = value ?? '',
                                ),
                                const SizedBox(height: 32),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading || _isGoogleLoading
                                        ? null
                                        : _trySubmit,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text('Login'),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                const _OrDivider(),
                                const SizedBox(height: 20),

                                // Google Sign-In Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: _isGoogleLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : OutlinedButton.icon(
                                          icon: Image.asset(
                                            'assets/images/google_logo.png',
                                            height: 24.0,
                                            // Fallback icon if image is missing
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.g_mobiledata,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                          ),
                                          label: const Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                          ),
                                          onPressed:
                                              _isLoading || _isGoogleLoading
                                              ? null
                                              : _signInWithGoogle,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- FOOTER LINKS ---
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(color: Colors.white70),
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

  /// Builds the list of animated particle widgets based on the `_particles` data
  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          // Use MediaQuery with a fallback for safety to determine screen bounds
          final size =
              MediaQuery.maybeOf(context)?.size ?? const Size(400, 800);
          final animValue =
              (_particleController.value * particle.speed + particle.offsetY) %
              1.0;
          return Positioned(
            left: size.width * particle.offsetX,
            top: size.height * animValue - particle.size,
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
}

/// Helper class to store properties for each background particle
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

/// A simple widget to render "------ OR ------" text with lines
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white30)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white30)),
      ],
    );
  }
}
