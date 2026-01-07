import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loading placeholder for cards
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    BorderRadius? borderRadius,
  }) : borderRadius =
           borderRadius ??
           const BorderRadius.all(Radius.circular(AppSpacing.borderRadiusMD));

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.veryLightGrey,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// Complete skeleton for business list card
class BusinessCardSkeleton extends StatelessWidget {
  const BusinessCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        elevation: AppSpacing.elevationMedium,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(height: 20, width: 150),
              const SizedBox(height: AppSpacing.sm),
              SkeletonLoader(height: 14, width: double.infinity),
              const SizedBox(height: AppSpacing.sm),
              SkeletonLoader(height: 14, width: 200),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(height: 14, width: 100),
                  SkeletonLoader(height: 36, width: 80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
