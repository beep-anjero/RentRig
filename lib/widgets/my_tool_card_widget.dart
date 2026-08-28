import 'package:flutter/material.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/widgets/availability_badge_widget.dart';
import 'package:rentrig/widgets/condition_badge_widget.dart';

class MyToolCard extends StatelessWidget {
  final Tool tool;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;

  const MyToolCard({
    super.key,
    required this.tool,
    required this.onToggleAvailability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.glassCard(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tool.imageUrl != null && tool.imageUrl!.isNotEmpty)
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    tool.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surface,
                        child: Icon(
                          Icons.build,
                          size: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: Icon(
                  Icons.build,
                  size: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tool.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ConditionBadge(condition: tool.condition),
                          const SizedBox(width: 8),
                          AvailabilityBadge(isAvailable: tool.isAvailable),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tool.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tool.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onToggleAvailability,
                          icon: Icon(
                            tool.isAvailable
                                ? Icons.cancel
                                : Icons.check_circle,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          label: Text(
                            tool.isAvailable
                                ? 'Mark Unavailable'
                                : 'Mark Available',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(
                              color: AppColors.accent.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
