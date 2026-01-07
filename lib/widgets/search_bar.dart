import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable search bar widget
class SearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;

  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.textInputAction = TextInputAction.search,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.mediumGrey),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.mediumGrey),
                onPressed: () {
                  _controller.clear();
                  widget.onClear?.call();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: const BorderSide(color: AppColors.veryLightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusMD,
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }
}
