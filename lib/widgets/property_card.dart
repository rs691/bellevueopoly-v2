import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_model.dart';

class PropertyCard extends StatelessWidget {
  final Business business;
  final int currentCheckIns;
  final VoidCallback? onDismiss;

  const PropertyCard({
    super.key,
    required this.business,
    this.currentCheckIns = 0,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (business.category != null && business.category!.isNotEmpty)
                          Text(
                            business.category!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white70,
                    onPressed: onDismiss ?? () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Hero Image
            if (business.heroImageUrl != null && business.heroImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: business.heroImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The Pitch
                  if (business.pitch != null && business.pitch!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Pitch',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          business.pitch!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Active Promotions
                  if (business.promotion != null) _buildPromotionCard(context),

                  // Loyalty Program
                  if (business.loyaltyProgram != null)
                    _buildLoyaltyCard(context, business.loyaltyProgram!, currentCheckIns),

                  // Contact Info
                  _buildContactInfo(context),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      if (business.website != null && business.website!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.language),
                            label: const Text('Visit'),
                            onPressed: () {
                              // TODO: Implement URL launch
                            },
                          ),
                        ),
                      if (business.phoneNumber != null &&
                          business.phoneNumber!.isNotEmpty)
                        if (business.website != null && business.website!.isNotEmpty)
                          const SizedBox(width: 8),
                      if (business.phoneNumber != null &&
                          business.phoneNumber!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.phone),
                            label: const Text('Call'),
                            onPressed: () {
                              // TODO: Implement phone call
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context) {
    final promotion = business.promotion!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[700]!, Colors.amber[900]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'ACTIVE PROMOTION',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            promotion.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            promotion.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              promotion.code,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(
    BuildContext context,
    LoyaltyProgram loyalty,
    int currentCheckIns,
  ) {
    final progressPercent = (currentCheckIns / loyalty.totalCheckInsRequired).clamp(0, 1);
    final isOwned = currentCheckIns >= loyalty.totalCheckInsRequired;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwned ? Colors.green[900] : Colors.blue[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwned ? Colors.green[300]! : Colors.blue[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOwned ? Icons.star : Icons.card_membership,
                color: isOwned ? Colors.amber : Colors.lightBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwned ? 'PROPERTY OWNED! 👑' : 'LOYALTY PROGRAM',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isOwned)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Check-ins: $currentCheckIns / ${loyalty.totalCheckInsRequired}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent.toDouble(),
                    minHeight: 8,
                    backgroundColor: Colors.black26,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.lightBlue[300]!,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visit ${loyalty.totalCheckInsRequired - currentCheckIns} more times to own this property!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else
            Text(
              'Congratulations! You own this property!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final items = <Widget>[];

    if (business.address != null && business.address!.isNotEmpty) {
      items.add(
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                business.address!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (business.hours != null && business.hours!.isNotEmpty) {
      items.add(const SizedBox(height: 8));
      items.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Hours',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...business.hours!.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 8),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }
}
