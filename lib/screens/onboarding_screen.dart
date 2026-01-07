import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await OnboardingScreen.markOnboardingComplete();
    if (mounted) {
      context.go('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildOnboardingPage(
            title: 'Welcome to BellEvueOPOLY',
            description:
                'Discover the best rewards and experiences around Bellevue!',
            icon: Icons.location_on,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.8),
                AppColors.primaryPurple.withOpacity(0.6),
              ],
            ),
          ),
          _buildOnboardingPage(
            title: 'Earn Points',
            description:
                'Visit businesses, complete daily challenges, and earn points. Redeem them for amazing prizes!',
            icon: Icons.emoji_events,
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.8),
                Colors.orange.withOpacity(0.6),
              ],
            ),
          ),
          _buildOnboardingPage(
            title: 'Check In & Compete',
            description:
                'Scan QR codes at participating businesses and climb the leaderboard!',
            icon: Icons.qr_code_2,
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.8),
                Colors.teal.withOpacity(0.6),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNextPage,
        backgroundColor: _getButtonColor(),
        child: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
      ),
      persistentFooterButtons: [
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        // Skip button (but not on last page)
        if (_currentPage < 2)
          TextButton(onPressed: _completeOnboarding, child: const Text('Skip')),
      ],
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (_currentPage) {
      case 0:
        return AppColors.primaryBlue;
      case 1:
        return Colors.amber;
      case 2:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
