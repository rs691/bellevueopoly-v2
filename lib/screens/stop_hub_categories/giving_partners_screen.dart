import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class GivingPartnersScreen extends StatelessWidget {
  const GivingPartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.volunteer_activism,
      title: 'Giving Partners',
      description: 'Stops focused on community giving and philanthropy.',
    );
  }
}
