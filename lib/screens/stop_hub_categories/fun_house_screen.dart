import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class FunHouseScreen extends StatelessWidget {
  const FunHouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.celebration,
      title: 'Fun House',
      description: 'Mini-games, entertainment, and just-for-fun stops.',
    );
  }
}
