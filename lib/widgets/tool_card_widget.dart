import 'package:flutter/material.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/condition_badge_widget.dart';

class ToolCardWidget extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;

  const ToolCardWidget({
    super.key,
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = ResponsiveUtil.imageSize(context, 80);
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtil.padding(context, 16)),
      decoration: AppDecorations.glassCard(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tool.imageUrl != null && tool.imageUrl!.isNotEmpty)
                Container(
                  width: imageSize,
                  height: imageSize,
                  margin: EdgeInsets.only(
                    right: ResponsiveUtil.padding(context, 16),
                  ),
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
                  width: imageSize,
                  height: imageSize,
                  margin: EdgeInsets.only(
                    right: ResponsiveUtil.padding(context, 16),
                  ),
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
                            style: TextStyle(
                              fontSize: ResponsiveUtil.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ConditionBadge(condition: tool.condition),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: ResponsiveUtil.iconSize(context, 14),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tool.category,
                          style: TextStyle(
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
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.accent.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
