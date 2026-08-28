import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';

class CategoryBarWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryBarWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtil.padding(context, 48),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.padding(context, 16),
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.padding(context, 4),
            ),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent.withOpacity(0.18),
              checkmarkColor: AppColors.accent,
              side: BorderSide(
                color: isSelected
                    ? AppColors.accent
                    : AppColors.titanium.withOpacity(0.3),
                width: isSelected ? 1.5 : 1.0,
              ),
              labelStyle: GoogleFonts.spaceGrotesk(
                color: isSelected ? AppColors.accent : AppColors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: ResponsiveUtil.fontSize(context, 13),
              ),
            ),
          );
        },
      ),
    );
  }
}

