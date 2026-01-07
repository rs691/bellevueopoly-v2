import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TERMS & CONDITIONS'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terms content
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: [Date]',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 1: Acceptance of Terms
            _buildSection(
              title: '1. Acceptance of Terms',
              content: 
                  'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement. '
                  'If you do not agree to abide by the above, please do not use this service.',
            ),
            
            // Section 2: Use License
            _buildSection(
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily use the application for personal, non-commercial use only. '
                  'This is the grant of a license, not a transfer of title.',
            ),
            
            // Section 3: Game Rules
            _buildSection(
              title: '3. Game Rules & Check-ins',
              content:
                  'Participation in the game requires adherence to all game rules. '
                  'Check-ins must be legitimate and performed at the physical location of participating businesses. '
                  'Fraudulent check-ins or any attempt to manipulate the system will result in immediate disqualification.',
            ),
            
            // Section 4: Prizes
            _buildSection(
              title: '4. Prizes & Rewards',
              content:
                  'Prize eligibility is determined by check-in completion and adherence to game rules. '
                  'Prizes are awarded at the discretion of the game organizers. '
                  'Prize values are approximate and subject to change without notice.',
            ),
            
            // Section 5: Privacy
            _buildSection(
              title: '5. Privacy',
              content:
                  'Your use of the application is also governed by our Privacy Policy. '
                  'We collect location data and check-in information as part of game functionality.',
            ),
            
            // Section 6: Account Termination
            _buildSection(
              title: '6. Account Termination',
              content:
                  'We reserve the right to terminate or suspend your account at any time for violations of these terms, '
                  'fraudulent activity, or any other reason deemed necessary by the game organizers.',
            ),
            
            // Section 7: Changes to Terms
            _buildSection(
              title: '7. Modifications',
              content:
                  'We reserve the right to modify these terms at any time. '
                  'Continued use of the application after changes constitutes acceptance of the updated terms.',
            ),
            
            // Section 8: Disclaimer
            _buildSection(
              title: '8. Disclaimer',
              content:
                  'The application is provided "as is" without warranty of any kind. '
                  'We do not guarantee uninterrupted or error-free service.',
            ),
            
            // Section 9: Limitation of Liability
            _buildSection(
              title: '9. Limitation of Liability',
              content:
                  'In no event shall the game organizers be liable for any damages arising from the use or inability to use the application.',
            ),
            
            // Section 10: Contact
            _buildSection(
              title: '10. Contact Information',
              content:
                  'For questions about these Terms & Conditions, please contact us at: [Contact Email]',
            ),
            
            const SizedBox(height: 32),
            
            // Back to Rules link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Go back to rules (or pop if came from rules)
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.rulesAndPrizes);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Rules'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
