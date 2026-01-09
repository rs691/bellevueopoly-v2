import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/business_provider.dart';
import '../providers/game_state_provider.dart';
import '../models/business_model.dart';
import 'qr_scanner_overlay.dart';

class MonopolyBoardScreen extends ConsumerStatefulWidget {
  const MonopolyBoardScreen({super.key});

  @override
  ConsumerState<MonopolyBoardScreen> createState() =>
      _MonopolyBoardScreenState();
}

class _MonopolyBoardScreenState extends ConsumerState<MonopolyBoardScreen> {
  // Monopoly board path: 20 tiles around the perimeter of a 6x6 grid
  // Clockwise starting from top-left
  static const List<int> boardPath = [
    0, 1, 2, 3, 4, 5, // Top row (left to right)
    11, 17, 23, 29, 35, // Right column (top to bottom)
    34, 33, 32, 31, 30, // Bottom row (right to left)
    24, 18, 12, 6, // Left column (bottom to top)
  ];

  late Set<String> visitedBusinessIds;
  late int totalPoints;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    visitedBusinessIds = {};
    totalPoints = 0;
    _loadPlayerProgress();
  }

  Future<void> _loadPlayerProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          visitedBusinessIds = Set<String>.from(
            data['visitedBusinesses'] ?? [],
          );
          totalPoints = data['totalPoints'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessListProvider);
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Life Board'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '$totalPoints pts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: businessAsync.when(
        data: (businesses) {
          // Initialize game state on first load only
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(gameStateProvider.notifier)
                  .initializeProperties(businesses);
              _isInitialized = true;
            });
          }
          return _buildBoardGrid(context, businesses, gameState);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBoardGrid(
    BuildContext context,
    List<Business> businesses,
    Map<String, Property> gameState,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: 36,
      itemBuilder: (context, index) {
        bool isEdge = _isEdgeTile(index, 6);
        if (!isEdge) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Center(
              child: Text(
                '🎲',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          );
        }

        final boardPathIndex = boardPath.indexOf(index);
        if (boardPathIndex == -1 || boardPathIndex >= businesses.length) {
          return _buildGenericTile('Coming Soon');
        }

        final business = businesses[boardPathIndex];
        final isVisited = visitedBusinessIds.contains(business.id);
        final property = gameState[business.id];

        return _buildBusinessTile(
          context,
          business,
          isVisited,
          property?.ownerId,
        );
      },
    );
  }

  bool _isEdgeTile(int index, int side) {
    int row = index ~/ side;
    int col = index % side;
    return row == 0 || row == side - 1 || col == 0 || col == side - 1;
  }

  Widget _buildBusinessTile(
    BuildContext context,
    Business business,
    bool isVisited,
    String? ownerId,
  ) {
    return InkWell(
      onTap: () => _showBusinessDetails(context, business, isVisited),
      child: Container(
        decoration: BoxDecoration(
          color: isVisited ? Colors.green[100] : Colors.white,
          border: Border.all(
            color: isVisited ? Colors.green : Colors.blueAccent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isVisited)
                  const Icon(Icons.check_circle, size: 20, color: Colors.green)
                else
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(height: 4),
                Text(
                  business.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${business.checkInPoints ?? 100}pt',
                  style: const TextStyle(fontSize: 8),
                ),
              ],
            ),
            if (ownerId != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 8)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericTile(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ),
    );
  }

  void _showBusinessDetails(
    BuildContext context,
    Business business,
    bool isVisited,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        business.category,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isVisited)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${business.checkInPoints ?? 100} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            if (business.pitch != null)
              Text(
                business.pitch!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text(
                'Scan the QR code at this location to earn ${business.checkInPoints ?? 100} points!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (business.promotion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Offer',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.promotion!.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isVisited
                    ? null
                    : () => _openQRScanner(context, business),
                icon: const Icon(Icons.qr_code_2),
                label: Text(isVisited ? 'Already Visited ✓' : 'Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isVisited ? Colors.grey : Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ),
            if (business.address != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      business.address!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openQRScanner(BuildContext context, Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerOverlay(
          businessId: business.id,
          correctSecret: business.secretCode,
          pointsToAward: business.checkInPoints ?? 100,
          onClose: () {
            _markBusinessVisited(business);
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Close the modal too
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🎉 Earned ${business.checkInPoints ?? 100} points at ${business.name}!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _markBusinessVisited(Business business) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final points = business.checkInPoints ?? 100;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userRef.update({
        'visitedBusinesses': FieldValue.arrayUnion([business.id]),
        'totalPoints': FieldValue.increment(points),
      });

      setState(() {
        visitedBusinessIds.add(business.id);
        totalPoints += points;
      });
    } catch (e) {
      debugPrint('Error marking business as visited: $e');
    }
  }
}
