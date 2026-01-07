import 'package:flutter/material.dart';

/// A helper widget to add semantic accessibility labels to components
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final String? hint;
  final VoidCallback? onTap;

  const AccessibleCard({
    required this.child,
    required this.semanticLabel,
    this.hint,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      onTap: onTap,
      enabled: onTap != null,
      button: onTap != null,
      child: child,
    );
  }
}

/// A semantic button with accessible labeling
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final String? hint;

  const AccessibleButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.hint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      onTap: onPressed,
      enabled: true,
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: icon != null
            ? Tooltip(
                message: label,
                child: IconButton(
                  onPressed: onPressed,
                  icon: Icon(icon),
                  tooltip: label,
                ),
              )
            : ElevatedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}

/// A semantic heading widget for better screen reader support
class AccessibleHeading extends StatelessWidget {
  final String text;
  final int level; // 1 = h1, 2 = h2, 3 = h3, etc.
  final TextStyle? style;

  const AccessibleHeading({
    required this.text,
    this.level = 2,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: true,
      label: text,
      child: Text(
        text,
        style:
            style ??
            (level == 1
                ? Theme.of(context).textTheme.headlineMedium
                : level == 2
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

/// A semantic list item for better accessibility
class AccessibleListItem extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final int index;
  final int totalItems;

  const AccessibleListItem({
    required this.child,
    required this.semanticLabel,
    required this.index,
    required this.totalItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: true,
      label: semanticLabel,
      child: MergeSemantics(child: child),
    );
  }
}

/// A semantic icon with accessible labeling
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final double? size;

  const AccessibleIcon({
    required this.icon,
    required this.label,
    this.color,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: true,
      label: label,
      image: true,
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
