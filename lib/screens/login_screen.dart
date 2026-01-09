import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../widgets/glassmorphic_card.dart';

import '../widgets/responsive_form_container.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _controller;
  late final AnimationController _formAnimationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;
  String? _error;
  bool _showForm = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  // Re-usable FirestoreService instance
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );
    // Show form immediately
    _formAnimationController.forward();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/background.mp4');
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;
    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      if (userCredential.user != null) {
        // Check if email is verified
        if (!userCredential.user!.emailVerified) {
          if (mounted) {
            _showError(
              'Please verify your email before logging in.',
              Icons.email_outlined,
            );
            // Optionally redirect to verification screen
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              context.go('/email-verification', extra: _email);
            }
          }
        } else {
          if (mounted) context.go('/');
        }
      }
    } on FirebaseAuthException catch (e) {
      final authService = ref.read(authServiceProvider);
      if (e.code == 'network-request-failed') {
        _showError(
          'Network error. Please check your internet connection.',
          Icons.wifi_off,
          showRetry: true,
        );
      } else {
        _showError(authService.getErrorMessage(e), Icons.error_outline);
      }
    } catch (e) {
      _showError(
        'An unexpected error occurred. Please try again.',
        Icons.error_outline,
        showRetry: true,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);

    try {
      // Use the newly added method in AuthService (or direct auth for now if not available via provider here)
      // Since we are inside a widget, we can use FirebaseAuth directly or Ref if we convert to ConsumerWidget fully
      // But let's stick to the pattern used in _signInWithGoogle which uses FirebaseAuth.instance directly
      // EXCEPT I just added it to AuthService, so let's try to use that if possible, OR just duplicate the logic
      // to match the existing style of this file which overrides the service pattern a bit.
      // To be safe and consistent with _signInWithGoogle in this file:
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        // Always ensure anonymous users have admin privileges
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          // Create new user document
          await _firestoreService.addUser(
            user: user,
            username: 'Guest Player', // Default name for anonymous
          );
        } else {
          // Update existing anonymous user to ensure admin privileges
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
                {'isAdmin': true, 'isAnonymous': true},
                SetOptions(merge: true),
              ); // Merge to avoid overwriting other fields
        }
      }

      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      final authService = ref.read(authServiceProvider);
      if (e.code == 'network-request-failed') {
        _showError(
          'Network error. Cannot connect in guest mode.',
          Icons.wifi_off,
          showRetry: true,
        );
      } else {
        _showError(authService.getErrorMessage(e), Icons.error_outline);
      }
    } catch (e) {
      _showError(
        'An unexpected error occurred during bypass.',
        Icons.error_outline,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Helper to reduce code duplication for showing errors
  void _showError(String message, IconData icon, {bool showRetry = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: showRetry ? 4 : 3),
          action: showRetry
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _trySubmit,
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7C3AED);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isVideoInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const SizedBox.shrink(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ResponsiveFormContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Animated form appears first
                      if (_showForm)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _WhiteFormCard(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: InputDecorationTheme(
                                    labelStyle: TextStyle(
                                      color: purple,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: purple,
                                        width: 1.2,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: purple,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'EMAIL ADDRESS',
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) =>
                                            (value == null ||
                                                !value.contains('@'))
                                            ? 'Please enter a valid email.'
                                            : null,
                                        onSaved: (value) =>
                                            _email = value ?? '',
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'PASSWORD',
                                        ),
                                        obscureText: true,
                                        validator: (value) =>
                                            (value == null || value.length < 6)
                                            ? 'Password must be at least 6 characters long.'
                                            : null,
                                        onSaved: (value) =>
                                            _password = value ?? '',
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () =>
                                              context.go('/password-reset'),
                                          child: Text(
                                            'Forgot password?'.toUpperCase(),
                                            style: TextStyle(
                                              color: purple,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: TextButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _signInAnonymously,
                                          child: const Text(
                                            'Developer Bypass (Guest)',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_showForm) const SizedBox(height: 24),

                      // PLAY NOW button
                      AnimatedGlassmorphicCard(
                        onTap: _isLoading ? null : _trySubmit,
                        padding: EdgeInsets.zero,
                        child: SizedBox(
                          width: 320,
                          height: 90,
                          child: Center(
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'LOADING...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'PLAY NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_showForm)
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
          ),
          if (!_isVideoInitialized)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_error != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Video error: ' + _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WhiteFormCard extends StatelessWidget {
  final Widget child;
  const _WhiteFormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x804C1D95), // purple glow
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x334C1D95),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
