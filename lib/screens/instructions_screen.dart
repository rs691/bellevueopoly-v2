import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      _Step(
        title: 'Check in at businesses',
        body: 'Open the map, choose a spot, and scan their QR at the counter to log a visit.',
        icon: Icons.qr_code_scanner,
      ),
      _Step(
        title: 'Earn points automatically',
        body: 'Each successful check-in adds points. Points are tallied in your profile and on the leaderboard.',
        icon: Icons.stars,
      ),
      _Step(
        title: 'Track progress',
        body: 'See your visits, points, and streaks on Profile → Check-in History. Revisit favorites to climb the board.',
        icon: Icons.history_rounded,
      ),
      _Step(
        title: 'Redeem rewards',
        body: 'Watch the Rewards Nearby tab for offers. Some spots unlock perks after repeat visits.',
        icon: Icons.card_giftcard,
      ),
      _Step(
        title: 'Stay verified',
        body: 'Keep your email verified and location services on so scans record correctly.',
        icon: Icons.verified_user,
      ),
    ];

    const tips = [
      'If a scan fails, move closer to the QR and brighten your screen.',
      'Only one check-in per business counts per cooldown window (no rapid repeats).',
      'Bad connection? Your scan queues and syncs when you regain signal.',
      'You can always re-open past visits from Check-in History.',
    ];

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('How to Play'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(context),
              const SizedBox(height: 16),
              ...List.generate(steps.length, (i) => _StepCard(step: steps[i], index: i)),
              const SizedBox(height: 16),
              _tipsCard(tips),
              const SizedBox(height: 16),
              _ctaButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Welcome to Bellevueopoly',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Explore local businesses, check in, and climb the leaderboard. Here is the quick start guide.',
                    style: TextStyle(color: Colors.white70, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipsCard(List<String> tips) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pro tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white70, height: 1.4)),
                      Expanded(child: Text(tip, style: const TextStyle(color: Colors.white70, height: 1.4))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => context.go(AppRoutes.stopHub),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open Map'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => context.push(AppRoutes.checkinHistory),
            icon: const Icon(Icons.history, color: Colors.white70),
            label: const Text('Check-in History', style: TextStyle(color: Colors.white70)),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _Step step;
  final int index;

  const _StepCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      offset: const Offset(0, 0.05),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        opacity: 1,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.16),
              child: Icon(step.icon, color: Colors.white),
            ),
            title: Text(step.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(step.body, style: const TextStyle(color: Colors.white70, height: 1.35)),
            trailing: Text('#${index + 1}', style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String title;
  final String body;
  final IconData icon;

  const _Step({required this.title, required this.body, required this.icon});
}
