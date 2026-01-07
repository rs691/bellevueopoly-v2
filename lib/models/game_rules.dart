/// Data model for game rules and prizes
/// Generic structure that can be reused for any game type
class GameRules {
  final String gameName;
  final String gameDescription;
  final List<String> quickRules; // 2-3 bullet points for preview
  final List<RuleSection> fullRules; // Detailed sections
  final List<Prize> prizes; // Win conditions & rewards
  final List<FAQ> faqs; // Frequently asked questions
  final String? iconPath; // Optional game icon
  final String? bannerImageUrl; // Optional banner image

  const GameRules({
    required this.gameName,
    required this.gameDescription,
    required this.quickRules,
    required this.fullRules,
    required this.prizes,
    required this.faqs,
    this.iconPath,
    this.bannerImageUrl,
  });
}

/// A section in the full rules
class RuleSection {
  final String title;
  final String description;
  final List<String>? bulletPoints; // Optional detailed points
  final String? example; // Optional example

  RuleSection({
    required this.title,
    required this.description,
    this.bulletPoints,
    this.example,
  });
}

/// Prize/reward structure
class Prize {
  final String title; // e.g., "1st Place"
  final String description; // e.g., "Win the game"
  final int points; // Points awarded
  final String? icon; // Optional icon/emoji
  final String? details; // Optional additional details

  Prize({
    required this.title,
    required this.description,
    required this.points,
    this.icon,
    this.details,
  });
}

/// FAQ item
class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}

// ============================================================================
// EXAMPLE MONOPOLY GAME RULES (for reference)
// ============================================================================

final monopolyGameRules = GameRules(
  gameName: 'Bellevue Monopoly',
  gameDescription: 'Buy properties around Bellevue and become the richest player!',
  quickRules: [
    'Roll dice and move around the board to purchase properties',
    'Collect properties and earn rent from other players',
    'Be the last player standing when others go bankrupt',
  ],
  fullRules: [
    RuleSection(
      title: 'Setup',
      description: 'Each player starts with \$1,500 and a token. The banker controls all remaining money and properties.',
      bulletPoints: [
        'Shuffle property cards and place them on their corresponding spaces',
        'Choose starting order by rolling dice (highest goes first)',
        'All players start on "GO"',
      ],
    ),
    RuleSection(
      title: 'Taking a Turn',
      description: 'On your turn, roll the dice and move your token forward.',
      bulletPoints: [
        'Roll two dice and move that number of spaces',
        'If you roll doubles, roll again',
        'Follow the rules of the space you land on',
        'Pay any rent or fees owed',
      ],
      example: 'Roll a 7 and land on an unowned property. You can choose to buy it or auction it.',
    ),
    RuleSection(
      title: 'Properties & Ownership',
      description: 'You can buy, sell, and trade properties.',
      bulletPoints: [
        'Unowned properties can be purchased at the listed price',
        'Owned properties require rent payment',
        'Build houses and hotels to increase rent',
        'Mortgage properties for cash when needed',
      ],
    ),
    RuleSection(
      title: 'Winning',
      description: 'The game ends when all players but one are bankrupt.',
    ),
  ],
  prizes: [
    Prize(
      title: '🥇 1st Place',
      description: 'Win the game',
      points: 100,
      icon: '🏆',
      details: 'Highest points awarded for completing the game',
    ),
    Prize(
      title: '🥈 2nd Place',
      description: 'Runner-up',
      points: 50,
      icon: '🎖️',
    ),
    Prize(
      title: '🥉 3rd Place',
      description: 'Third place finish',
      points: 25,
      icon: '🎗️',
    ),
    Prize(
      title: '💰 Bonus Points',
      description: 'Collect all properties in one color',
      points: 10,
      icon: '⭐',
    ),
  ],
  faqs: [
    FAQ(
      question: 'What happens if I land on Free Parking?',
      answer: 'Nothing! Free Parking is just a rest stop. You don\'t earn or pay anything.',
    ),
    FAQ(
      question: 'Can I trade properties with other players?',
      answer: 'Yes! You can negotiate trades with other players during the game. Both players must agree.',
    ),
    FAQ(
      question: 'What if I can\'t afford rent?',
      answer: 'You can sell properties or mortgage properties to raise cash. If you still can\'t pay, you\'re bankrupt and out of the game.',
    ),
    FAQ(
      question: 'How long does a game take?',
      answer: 'A typical game takes 1-2 hours depending on the number of players.',
    ),
  ],
);

/// Placeholder class for routes without explicit game rules
class GameRulesPlaceholder extends GameRules {
  const GameRulesPlaceholder()
      : super(
          gameName: 'Game',
          gameDescription: 'Learn the rules before you play',
          quickRules: const [
            'Read the rules carefully',
            'Ask for help if needed',
            'Have fun!',
          ],
          fullRules: const [],
          prizes: const [],
          faqs: const [],
        );
}
