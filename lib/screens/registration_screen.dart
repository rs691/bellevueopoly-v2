import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/firestore_provider.dart';
import '../widgets/responsive_form_container.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/chamber_opoly_wordmark.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  bool _isLoading = false;
  bool _showForm = false;

  late AnimationController _formAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeOut),
    );
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/background.mp4');
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) setState(() => _isVideoInitialized = true);
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
    if (isValid != true) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      if (userCredential.user != null) {
        // Add user to Firestore
        await ref
            .read(firestoreServiceProvider)
            .addUser(user: userCredential.user!, username: _username);

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        if (mounted) {
          // Navigate to email verification screen
          context.go('/email-verification', extra: _email);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final authService = ref.read(authServiceProvider);
        IconData icon = Icons.error_outline;
        String message;
        bool showRetry = false;

        if (e.code == 'network-request-failed') {
          icon = Icons.wifi_off;
          message = 'Network error. Please check your internet connection.';
          showRetry = true;
        } else {
          message = authService.getErrorMessage(e);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.red,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'An unexpected error occurred. Please try again.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _trySubmit,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
            ),
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
                      const ChamberOpolyWordmark(width: 260, hero: true),
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
                                          labelText: 'USERNAME',
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
                                          labelText: 'EMAIL ADDRESS',
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null ||
                                              !value.contains('@')) {
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
                                          labelText: 'PASSWORD',
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null ||
                                              value.length < 6) {
                                            return 'Password must be at least 6 characters long.';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _password = value ?? '';
                                        },
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
                        onTap: _isLoading
                            ? null
                            : () {
                                if (!_showForm) {
                                  setState(() => _showForm = true);
                                  _formAnimationController.forward();
                                } else {
                                  _trySubmit();
                                }
                              },
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
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            "Already have an account? Log in",
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
            color: Color(0x804C1D95),
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
