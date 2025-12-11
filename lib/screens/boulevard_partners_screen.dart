import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_model.dart'; // Corrected import
import '../providers/config_provider.dart'; // Import the provider

class BoulevardPartnersScreen extends ConsumerStatefulWidget {
  const BoulevardPartnersScreen({super.key});

  @override
  ConsumerState<BoulevardPartnersScreen> createState() => _BoulevardPartnersScreenState();
}

class _BoulevardPartnersScreenState extends ConsumerState<BoulevardPartnersScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // We'll use this to track if we've already animated the list so it doesn't replay on every rebuild
  bool _listAnimated = false;

  @override
  Widget build(BuildContext context) {
    // Watch the provider for business data
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boulevard Partners'),
        centerTitle: true,
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (businesses) {
          if (businesses.isEmpty) {
            return const Center(child: Text('No partners found.'));
          }

          // Trigger animation only once when data is first loaded
          if (!_listAnimated) {
            _listAnimated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              for (int i = 0; i < businesses.length; i++) {
                Future.delayed(Duration(milliseconds: i * 100), () {
                  if (_listKey.currentState != null) {
                    _listKey.currentState!.insertItem(i, duration: const Duration(milliseconds: 500));
                  }
                });
              }
            });
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: 0, // Start with 0 and insert them via the loop above
            itemBuilder: (context, index, animation) {
              // Safety check for index
              if (index >= businesses.length) return const SizedBox.shrink();

              final business = businesses[index];
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
          );
        },
      ),
    );
  }

  void _showBusinessDetails(Business business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
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
                        Expanded(
                          child: Text(
                            business.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
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
                        // Safe access to optional fields
                        Text(
                          business.address ?? "Address not available",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),

                        if (business.pitch != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              business.pitch!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),

                        if (business.website != null && business.website!.isNotEmpty)
                          _buildLinkTile(context, Icons.language, 'Website', business.website!),

                        if (business.phoneNumber != null && business.phoneNumber!.isNotEmpty)
                          _buildInfoTile(context, Icons.phone, 'Phone', business.phoneNumber!),

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
}

class _BusinessCard extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({
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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.01),
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
      position: _animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
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
                  widget.business.address ?? 'No address',
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
