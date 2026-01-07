import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrizesScreen extends ConsumerStatefulWidget {
  const PrizesScreen({super.key});

  @override
  ConsumerState<PrizesScreen> createState() => _PrizesScreenState();
}

class _PrizesScreenState extends ConsumerState<PrizesScreen> {
  Future<void> _refreshPrizes() async {
    // Since this is a static list, we'll just simulate a refresh
    // In a real app, you'd fetch from a provider or API
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final prizes = const [
      (
        'Grand Prize Trip',
        'Weekend getaway for two plus a \$250 dining credit.',
        '12,000 pts',
      ),
      (
        'Local Favorites Pack',
        'Gift cards to top Bellevue eateries and coffee shops.',
        '3,500 pts',
      ),
      (
        'Merch Bundle',
        'Limited-run hoodie, enamel pin set, and water bottle.',
        '1,800 pts',
      ),
      (
        'Instant Win Coupons',
        'Pop-up discounts for check-ins this week only.',
        '250 pts',
      ),
      (
        'Surprise Drop',
        'Flash reward that appears Fridays at noon—don’t miss it.',
        '??',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Prizes')),
      body: RefreshIndicator(
        onRefresh: _refreshPrizes,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_events, size: 36, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Prizes & Rewards',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Redeem points for the rewards below. Stock and availability change weekly, so check back often.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            ...prizes.map(
              (prize) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prize.$1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prize.$2,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            prize.$3,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: const Text(
                'Tip: Popular rewards sell out fast. Turn on notifications in Settings to get alerts when new prizes drop.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
