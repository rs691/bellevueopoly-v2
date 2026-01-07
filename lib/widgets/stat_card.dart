import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable stat card for displaying key metrics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primaryBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMD,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMD,
            gradient: LinearGradient(
              colors: [
                cardColor.withValues(alpha: 0.1),
                cardColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: cardColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.2),
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: Icon(icon, color: cardColor, size: 24),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: cardColor.withValues(alpha: 0.5),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini stat display for appbar or headers
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primaryBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.mediumGrey),
        ),
      ],
    );
  }
}
