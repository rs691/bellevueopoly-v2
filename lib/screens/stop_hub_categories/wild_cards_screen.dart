import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class WildCardsScreen extends StatelessWidget {
  const WildCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.casino,
      title: 'Wild Cards',
      description: 'Unpredictable stops with unique challenges and rewards.',
    );
  }
}
