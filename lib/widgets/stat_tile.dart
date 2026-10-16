import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'lt_card.dart';

/// Compact stat: emoji, big value, small label.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    this.accent = AppColors.primary,
  });

  final String emoji;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    return LTCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lt.tint(accent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: lt.text,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: lt.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
