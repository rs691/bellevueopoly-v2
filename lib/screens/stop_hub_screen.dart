import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:myapp/widgets/navigation_box.dart'; // Import NavigationBox

class StopHubScreen extends StatelessWidget {
  const StopHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stop Hub Options'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            NavigationBox(
              icon: Icons.business,
              label: 'Boulevard Partners',
              onTap: () => context.go('/boulevard_partners'),
            ),
            NavigationBox(
              icon: Icons.location_on,
              label: 'Game Stops',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Game Stops tapped')));
              },
            ),
            NavigationBox(
              icon: Icons.event,
              label: 'Upcoming Events',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upcoming Events tapped')));
              },
            ),
            NavigationBox(
              icon: Icons.restaurant,
              label: 'Food & Drink',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Food & Drink tapped')));
              },
            ),
            NavigationBox(
              icon: Icons.info_outline,
              label: 'About This Game',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('About This Game tapped')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
