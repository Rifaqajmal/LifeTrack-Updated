import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Bottom sheet to choose an emoji avatar.
/// Returns the chosen emoji, or '' for "Auto" (use the default), or null if
/// dismissed.
class EmojiPickerSheet {
  EmojiPickerSheet._();

  static const List<String> emojis = [
    '😀', '😎', '🥳', '😇', '🤓', '🥰', '😊', '🤩',
    '🌸', '🌻', '🌈', '⭐', '🔥', '💎', '🎈', '🎂',
    '👩', '👨', '🧔', '👧', '👦', '👵', '👴', '🧑',
    '🐱', '🐶', '🦋', '🦄', '🐼', '🦊', '🐯', '🐸',
  ];

  static Future<String?> show(
    BuildContext context, {
    String? selected,
    String autoLabel = 'Auto',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final lt = sheetContext.lt;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lt.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose an avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: lt.text,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final e in emojis)
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(sheetContext, e),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: e == selected
                                ? lt.primarySoft
                                : lt.surface2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: e == selected
                                  ? AppColors.primary
                                  : lt.border,
                              width: e == selected ? 2 : 1,
                            ),
                          ),
                          child:
                              Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, ''),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(autoLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
