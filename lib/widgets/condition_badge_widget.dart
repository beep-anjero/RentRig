import 'package:flutter/material.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({
    super.key,
    required this.condition,
  });

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getConditionColor(condition).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getConditionColor(condition),
        ),
      ),
      child: Text(
        condition.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getConditionColor(condition),
        ),
      ),
    );
  }
}
