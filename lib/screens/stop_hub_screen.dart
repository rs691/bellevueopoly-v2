import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';

class StopHubScreen extends ConsumerStatefulWidget {
  const StopHubScreen({super.key});

  @override
  ConsumerState<StopHubScreen> createState() => _StopHubScreenState();
}

class _StopHubScreenState extends ConsumerState<StopHubScreen> {
  @override
  Widget build(BuildContext context) {
    // Helper function to build positioned pentagon (n-gon)
    Positioned buildPositionedPentagon({
      required int index,
      required int count,
      required double centerX,
      required double centerY,
      required double radius,
      required double tileSize,
      required Widget child,
    }) {
      final double angleDeg = -90 + (360 / count) * index;
      final double angleRad = angleDeg * math.pi / 180.0;
      final double x = centerX + radius * math.cos(angleRad) - tileSize / 2;
      final double y = centerY + radius * math.sin(angleRad) - tileSize / 2;
      return Positioned(left: x, top: y, child: child);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Stop Hub',
          style: GoogleFonts.baloo2(
            fontSize: 38,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, 
        toolbarHeight: 80,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final minSide = width < height ? width : height;
          // Tile size optimized for mobile touch targets
          // slightly smaller than home screen (0.26) to accommodate 7 items
          final tileSize = (minSide * 0.22).clamp(100.0, 180.0); 
          final radius = (minSide * 0.34);
          final centerX = width / 2;
          // Account for bottom navbar by centering in available space
          final navbarHeight = 72 + 32; // navbar height + margins
          final availableHeight = height - navbarHeight;
          final centerY = availableHeight / 2;

          List<_PentagonItem> items = [
            _PentagonItem(
              Icons.business,
              'Boulevard Partners',
              () => context.go(AppRoutes.boulevardPartners),
            ),
            _PentagonItem(
              Icons.flag,
              'Patriotic Partners',
              () => context.go(AppRoutes.patrioticPartners),
            ),
            _PentagonItem(
              Icons.shopping_bag,
              'Merch Partners',
              () => context.go(AppRoutes.merchPartners),
            ),
            _PentagonItem(
              Icons.volunteer_activism,
              'Giving Partners',
              () => context.go(AppRoutes.givingPartners),
            ),
            _PentagonItem(
              Icons.card_giftcard,
              'Community Chest',
              () => context.go(AppRoutes.communityChest),
            ),
            _PentagonItem(
              Icons.casino,
              'Wild Cards',
              () => context.go(AppRoutes.wildCards),
            ),
            _PentagonItem(
              Icons.celebration,
              'Fun House',
              () => context.go(AppRoutes.funHouse),
            ),
          ];

          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // Nav boxes in center
                  for (int i = 0; i < items.length; i++) ...[
                    buildPositionedPentagon(
                      index: i,
                      count: items.length,
                      centerX: centerX,
                      centerY: centerY,
                      radius: radius,
                      tileSize: tileSize,
                      child: _buildTile(items[i], tileSize),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(_PentagonItem item, double tileSize) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.15),
                child: Center(
                  child: _buildTileContent(item, tileSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileContent(_PentagonItem item, double tileSize) {
    final words = item.label.split(' ');
    
    if (words.length > 1) {
      // Multi-word: text above, icon center, text below
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              words[0],
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
               maxLines: 1,
               overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(height: tileSize * 0.04),
          Icon(
            item.icon,
            size: 28,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          SizedBox(height: tileSize * 0.04),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              words.sublist(1).join(' '),
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              maxLines: 2,
            ),
          ),
        ],
      );
    } else {
      // Single word: text on top, icon on bottom
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: tileSize * 0.06),
          Icon(
            item.icon,
            size: 32,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ],
      );
    }
  }
}

class _PentagonItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _PentagonItem(this.icon, this.label, this.onTap);
}