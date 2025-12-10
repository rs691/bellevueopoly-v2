import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading local JSON
import 'package:url_launcher/url_launcher.dart'; // For opening links

import 'package:myapp/models/business.dart';

class BoulevardPartnersScreen extends StatefulWidget {
  const BoulevardPartnersScreen({super.key});

  @override
  State<BoulevardPartnersScreen> createState() => _BoulevardPartnersScreenState();
}

class _BoulevardPartnersScreenState extends State<BoulevardPartnersScreen> {
  List<Business> _businesses = [];
  bool _isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final String response = await rootBundle.loadString('assets/data/boulevard_partners.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _businesses = data.map((json) => Business.fromJson(json)).toList();
        _isLoading = false;
        // Animate in items one by one
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int i = 0; i < _businesses.length; i++) {
            Future.delayed(Duration(milliseconds: i * 100), () {
              if (_listKey.currentState != null) {
                _listKey.currentState!.insertItem(i, duration: const Duration(milliseconds: 500));
              }
            });
          }
        });
      });
    } catch (e) {
      // Handle error: show a snackbar, log, or display an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading businesses: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBusinessDetails(Business business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Start at 60% of screen height
          minChildSize: 0.3, // Minimum height
          maxChildSize: 0.9, // Maximum height
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          business.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      children: [
                        Text(
                          '${business.streetAddress}, ${business.city}, ${business.state} ${business.zipCode}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        if (business.description != null && business.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              business.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        if (business.website != null && business.website!.isNotEmpty)
                          _buildLinkTile(context, Icons.language, 'Website', business.website!),
                        if (business.menuLink != null && business.menuLink!.isNotEmpty)
                          _buildLinkTile(context, Icons.restaurant_menu, 'Menu', business.menuLink!),
                        if (business.hoursOfOperation != null && business.hoursOfOperation!.isNotEmpty)
                          _buildInfoTile(context, Icons.access_time, 'Hours', business.hoursOfOperation!),
                        // Add more details here as needed
                        const SizedBox(height: 20),
                        Text(
                          '(This business will be part of the game feature on the map.)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLinkTile(BuildContext context, IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(url, style: const TextStyle(color: Colors.blueAccent)),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        }
      },
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String info) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(title),
      subtitle: Text(info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boulevard Partners'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_businesses.isEmpty
          ? const Center(child: Text('No partners found.'))
          : AnimatedList(
        key: _listKey,
        initialItemCount: _businesses.length,
        itemBuilder: (context, index, animation) {
          final business = _businesses[index];
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: _BusinessCard(
                business: business,
                onTap: () => _showBusinessDetails(business),
              ),
            ),
          );
        },
      )),
    );
  }
}

// Custom Widget for each business card entry (now Stateful for animation)
class _BusinessCard extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
  });

  @override
  State<_BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<_BusinessCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration for one full float cycle
    )..repeat(reverse: true); // Loop the animation back and forth

    _animation = Tween<Offset>(
      begin: const Offset(0, 0), // Start at no vertical offset
      end: const Offset(0, -0.01), // Float up slightly (e.g., 1% of card height)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation, // Apply the floating animation here
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 1.0), // Border for separation
        ),
        elevation: 2,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.business.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.business.streetAddress}, ${widget.business.city}, ${widget.business.state} ${widget.business.zipCode}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
