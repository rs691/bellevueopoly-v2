import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class BoulevardPartnersScreen extends StatelessWidget {
  const BoulevardPartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.business,
      title: 'Boulevard Partners',
      description: 'Featured businesses and partners along the boulevard.',
    );
  }
}
