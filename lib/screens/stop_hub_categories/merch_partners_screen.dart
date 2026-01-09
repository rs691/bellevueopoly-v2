import 'package:flutter/material.dart';

import 'stop_hub_category_page.dart';

class MerchPartnersScreen extends StatelessWidget {
  const MerchPartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StopHubCategoryPage(
      icon: Icons.shopping_bag,
      title: 'Merch Partners',
      description: 'Find merchandise stops and partner swag locations.',
    );
  }
}
