import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Description
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Badge in top right
              if (badge != null)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact game card for grid layouts
class CompactGameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const CompactGameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 36),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Badge in top right
              if (badge != null && badge! > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
