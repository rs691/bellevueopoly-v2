import 'package:flutter/material.dart';
import '../models/game_rules.dart';

/// Full screen for displaying game rules and prizes
/// Generic and reusable for any game type
class RulesAndPrizesScreen extends StatefulWidget {
  final GameRules gameRules;
  final VoidCallback? onClose;

  const RulesAndPrizesScreen({
    super.key,
    required this.gameRules,
    this.onClose,
  });

  @override
  State<RulesAndPrizesScreen> createState() => _RulesAndPrizesScreenState();
}

class _RulesAndPrizesScreenState extends State<RulesAndPrizesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with game info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.gameRules.gameName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.gameRules.iconPath != null)
                        Image.asset(
                          widget.gameRules.iconPath!,
                          height: 80,
                          width: 80,
                        )
                      else
                        Icon(
                          Icons.sports_esports,
                          size: 80,
                          color: Colors.white,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        widget.gameRules.gameDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Quick Rules', icon: Icon(Icons.speed)),
                  Tab(text: 'Full Rules', icon: Icon(Icons.book)),
                  Tab(text: 'Prizes', icon: Icon(Icons.emoji_events)),
                  Tab(text: 'FAQs', icon: Icon(Icons.help)),
                ],
              ),
            ),
          ),
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuickRulesTab(),
                _buildFullRulesTab(),
                _buildPrizesTab(),
                _buildFAQsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRulesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Quick Rules',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...widget.gameRules.quickRules.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRulePoint(entry.key + 1, entry.value),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('View Full Rules'),
          ),
        ],
      ),
    );
  }

  Widget _buildRulePoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildFullRulesTab() {
    final fullRules = widget.gameRules.fullRules.isNotEmpty
        ? widget.gameRules.fullRules
        : _fallbackFullRules;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Full Rules',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...fullRules.map((section) => _buildRuleSection(section)),
        ],
      ),
    );
  }

  Widget _buildRuleSection(RuleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.description,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              if (section.bulletPoints != null) ...[
                const SizedBox(height: 12),
                ...section.bulletPoints!.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (section.example != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border(
                      left: BorderSide(color: Colors.amber.shade400, width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.example!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrizesTab() {
    final prizes = widget.gameRules.prizes.isNotEmpty
        ? widget.gameRules.prizes
        : _fallbackPrizes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Prizes & Rewards',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...prizes.map((prize) => _buildPrizeCard(prize)),
        ],
      ),
    );
  }

  Widget _buildPrizeCard(Prize prize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(prize.icon ?? '🎁', style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prize.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prize.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (prize.details != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        prize.details!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${prize.points} pts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQsTab() {
    final faqs = widget.gameRules.faqs.isNotEmpty
        ? widget.gameRules.faqs
        : _fallbackFaqs;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Delegate for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Placeholder content to keep tabs feeling full when no data is provided
final List<RuleSection> _fallbackFullRules = [
  RuleSection(
    title: 'Overview',
    description:
        'Complete challenges around town, scan proof of completion, and earn points toward weekly prizes.',
    bulletPoints: [
      'Check in at participating locations during business hours',
      'Scan posted QR codes after eligible actions to lock in points',
      'Track progress in the Game Hub and redeem prizes in the Prizes tab',
    ],
  ),
  RuleSection(
    title: 'Earning Points',
    description:
        'Every visit, scan, and challenge completion adds to your weekly total. Bonus multipliers appear on weekends.',
    bulletPoints: [
      'Daily streaks add +25% to earned points for that day',
      'Featured partners may award double points during promos',
      'Receipts must be scanned within 24 hours to qualify',
    ],
    example:
        'Example: Complete a cafe challenge (150 pts) on Saturday with a streak active (+25%) for a total of 188 pts.',
  ),
  RuleSection(
    title: 'Fair Play',
    description:
        'One account per player. Duplicate scans, tampered QR codes, or scripted submissions may be voided.',
    bulletPoints: [
      'Keep location services on during scans for validation',
      'Report damaged QR codes to support@bellevueopoly.com',
      'Staff may ask to verify your account name with an ID',
    ],
  ),
];

final List<Prize> _fallbackPrizes = [
  Prize(
    title: 'Weekly Champion',
    description: 'Top scorer wins a feature reward plus bonus points.',
    points: 500,
    icon: '🏆',
    details: 'Awarded every Monday at 9 AM.',
  ),
  Prize(
    title: 'Local Hero Bundle',
    description: 'Gift cards to neighborhood favorites and limited merch.',
    points: 350,
    icon: '🎁',
  ),
  Prize(
    title: 'Flash Drop',
    description: 'Surprise reward that appears for the first 50 redemptions.',
    points: 150,
    icon: '⚡',
  ),
];

final List<FAQ> _fallbackFaqs = [
  FAQ(
    question: 'How do I join a challenge?',
    answer:
        'Open the Game Hub, pick a challenge card, and follow the steps. You will see a scanner prompt when proof is needed.',
  ),
  FAQ(
    question: 'Why was my scan rejected?',
    answer:
        'Most rejections are due to glare or expired codes. Clean your lens, increase brightness, and rescan within the 24-hour window.',
  ),
  FAQ(
    question: 'When do points reset?',
    answer:
        'Points reset Sunday at 11:59 PM. Use them before they expire or redeem for prizes ahead of time.',
  ),
];
