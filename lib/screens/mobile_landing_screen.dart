import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_box.dart';
import '../widgets/stat_card.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../providers/user_data_provider.dart';

class MobileLandingScreen extends ConsumerWidget {
  const MobileLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section with daily challenge
            _buildHeroSection(context),

            // Quick stats section
            userDataAsync.when(
              data: (userDoc) {
                if (userDoc == null || !userDoc.exists) {
                  return const SizedBox.shrink();
                }
                final user = userDoc.data() as Map<String, dynamic>;
                return _buildQuickStats(context, user);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Navigation grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 1. Stop Hub (Business Categories)
                  NavigationBox(
                    icon: Icons.star,
                    label: 'Stop Hub',
                    onTap: () => context.go(AppRoutes.stopHub),
                  ),
                  // 2. Near Me (Map with nearby rewards)
                  NavigationBox(
                    icon: Icons.location_on,
                    label: 'Near Me',
                    onTap: () => context.go(AppRoutes.nearMe),
                  ),

                  // 3. Prizes
                  NavigationBox(
                    icon: Icons.emoji_events,
                    label: 'Prizes',
                    onTap: () => context.go(AppRoutes.prizes),
                  ),

                  // 4. FAQs (in Rules & Prizes screen)
                  NavigationBox(
                    icon: Icons.help,
                    label: 'FAQs',
                    onTap: () => context.go(AppRoutes.rulesAndPrizes),
                  ),

                  // 5. My Account / Profile
                  NavigationBox(
                    icon: Icons.person,
                    label: 'My Account',
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.9),
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.amber, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Challenge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Visit 5 different businesses today and earn 250 bonus points!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: LinearProgressIndicator(
              value: 0.4, // 2 out of 5 visited
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade300),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '2 of 5 visits completed',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> user) {
    final int points = (user['points'] as num?)?.toInt() ?? 0;
    final int visits = (user['visits'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: MiniStat(
              label: 'Points',
              value: points.toString(),
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: MiniStat(
              label: 'Visits',
              value: visits.toString(),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
