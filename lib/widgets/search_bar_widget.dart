import 'package:flutter/material.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtil.padding(context, 16),
        ResponsiveUtil.padding(context, 12),
        ResponsiveUtil.padding(context, 16),
        ResponsiveUtil.padding(context, 8),
      ),
      child: Container(
        decoration: AppDecorations.glassCard(radius: 12),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtil.fontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: 'Search tools...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: ResponsiveUtil.fontSize(context, 16),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.6),
              size: ResponsiveUtil.iconSize(context, 24),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.6),
                      size: ResponsiveUtil.iconSize(context, 24),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
