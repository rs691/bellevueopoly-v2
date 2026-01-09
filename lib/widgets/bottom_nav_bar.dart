import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive margins: smaller on narrow screens, larger on wide screens
    final horizontalMargin = screenWidth < 360 ? 12.0 : 16.0;
    
    return Container(
      margin: EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: 16, // Floating effect - lifted from bottom
      ),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Rounded corners
        boxShadow: [
          // Layered shadows for depth
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // Match container radius
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Enhanced blur
          child: Container(
            decoration: BoxDecoration(
              // Enhanced glass effect with gradient
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
            ),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Remove hover effects
              showSelectedLabels: true,
              showUnselectedLabels: true,
              enableFeedback: false,
              // Explicit icon size for consistent touch targets
              iconSize: 24,
              // White colors for better visibility
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.8), // Improved from 0.7
              selectedFontSize: 12,
              unselectedFontSize: 10.5,
              selectedLabelStyle: GoogleFonts.baloo2(
                fontWeight: FontWeight.w700,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              unselectedLabelStyle: GoogleFonts.baloo2(
                fontWeight: FontWeight.w600,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.home_outlined, widget.currentIndex == 0, 0),
                  label: 'HOME',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.star_outline, widget.currentIndex == 1, 1),
                  label: 'STOPS',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.emoji_events_outlined, widget.currentIndex == 2, 2),
                  label: 'PRIZES',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.location_on_outlined, widget.currentIndex == 3, 3),
                  label: 'NEAR ME',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected, int index) {
    return ScaleTransition(
      scale: isSelected ? _iconAnimations[index] : AlwaysStoppedAnimation(1.0),
      child: Container(
        // Increased padding for better touch targets (minimum 48x48px)
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 24,
          shadows: const [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
