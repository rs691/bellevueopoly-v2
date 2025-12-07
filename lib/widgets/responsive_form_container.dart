import 'package:flutter/material.dart';

class ResponsiveFormContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: child,
      ),
    );
  }
}
