import 'package:flutter/material.dart';
import 'package:rentrig/utils/app_colors.dart';

class OwnerInfo extends StatelessWidget {
  final String ownerEmail;
  final Color avatarColor;

  const OwnerInfo({
    super.key,
    required this.ownerEmail,
    this.avatarColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            ownerEmail[0].toUpperCase(),
            style: const TextStyle(color: AppColors.background),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          ownerEmail,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
