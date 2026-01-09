import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class CommunityChestScreen extends StatelessWidget {
  const CommunityChestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.card_giftcard,
      title: 'Community Chest',
      description: 'Rewards, surprises, and special community chest stops.',
    );
  }
}
