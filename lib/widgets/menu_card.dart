import 'package:flutter/material.dart';

class AnimatedMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const AnimatedMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  State<AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<AnimatedMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? const LinearGradient(
              colors: [Color(0xFFa855f7), Color(0xFF7c3aed)],
            )
                : const LinearGradient(
              colors: [Color(0xFF3b2a5a), Color(0xFF2a1d4a)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: const Color(0xFFa855f7).withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: Colors.white, size: 32),
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                widget.subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback onFilterTap;

  const StyledSearchBar({super.key, required this.hintText, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white70),
          onPressed: onFilterTap,
        ),
      ),
    );
  }
}

