import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_helper.dart';
import '../core/utils/relation_style.dart';
import '../models/birthday_model.dart';
import 'emoji_avatar.dart';
import 'lt_card.dart';

/// Colour used for a "days until" chip.
Color daysColor(int days) {
  if (days == 0) return AppColors.pink;
  if (days <= 7) return AppColors.amber;
  if (days <= 30) return AppColors.primary;
  return AppColors.green;
}

/// Label such as "Today", "Tomorrow", "12d".
String daysLabel(int days) {
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '${days}d';
}

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({
    super.key,
    required this.birthday,
    required this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final BirthdayModel birthday;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final days = DateHelper.daysUntilBirthday(birthday.dob);
    final color = daysColor(days);
    final style = RelationStyle.of(birthday.relation);
    final relation = birthday.relation.trim();

    return LTCard(
      margin: margin,
      onTap: onTap,
      accent: days <= 7 ? color : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          EmojiAvatar(
            emoji: RelationStyle.emojiFor(birthday),
            colors: style.gradient,
            size: 50,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  birthday.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: lt.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  relation.isEmpty
                      ? DateHelper.formatShort(birthday.dob)
                      : '$relation · ${DateHelper.formatShort(birthday.dob)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: lt.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: lt.tint(color),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysLabel(days),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
