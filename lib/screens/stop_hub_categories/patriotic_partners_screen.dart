import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class PatrioticPartnersScreen extends StatelessWidget {
  const PatrioticPartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.flag,
      title: 'Patriotic Partners',
      description: 'Stops showcasing patriotic partners and experiences.',
    );
  }
}
