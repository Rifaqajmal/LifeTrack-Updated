import 'package:flutter/material.dart';

/// Rounded-square gradient avatar showing an emoji.
class EmojiAvatar extends StatelessWidget {
  const EmojiAvatar({
    super.key,
    required this.emoji,
    required this.colors,
    this.size = 48,
    this.radius,
    this.border,
  });

  final String emoji;
  final List<Color> colors;
  final double size;
  final double? radius;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius ?? size * 0.32),
        border: border,
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}
