import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      (
        'How do I earn points?',
        'Check in at participating locations, scan QR codes after purchases, and complete weekly challenges to stack bonus points.',
      ),
      (
        'What if a QR code will not scan?',
        'Try increasing screen brightness, clean the camera lens, and move 6-8 inches from the code. If it still fails, enter the receipt code manually from the cashier.',
      ),
      (
        'When are prizes released?',
        'Prizes refresh every Monday at 9 AM. Limited-quantity items appear first-come, first-served and restock mid-week when available.',
      ),
      (
        'Can I transfer points?',
        'Points are tied to your account and cannot be transferred, but family members can each earn points on their own devices.',
      ),
      (
        'How do I report an issue?',
        'Open Settings > Help & Support and tap “Report a Problem,” or email support@bellevueopoly.com with screenshots and your device model.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              Icon(Icons.help_outline, size: 36, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Quick answers for the most common app questions. Tap any question to expand the details.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          ...faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  faq.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      faq.$2,
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ],
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
              'Still need help? Reach us at support@bellevueopoly.com and we will respond within one business day.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
