import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'lt_card.dart';

/// Placeholder shown while birthdays load.
class BirthdayCardSkeleton extends StatelessWidget {
  const BirthdayCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: lt.surface2,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    return LTCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: lt.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [bar(130, 14), const SizedBox(height: 8), bar(90, 11)],
            ),
          ),
          bar(54, 26),
        ],
      ),
    );
  }
}
