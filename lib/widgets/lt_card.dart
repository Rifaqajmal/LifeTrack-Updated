import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Rounded surface card with the soft brand shadow.
class LTCard extends StatelessWidget {
  const LTCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.radius = 20,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double radius;

  /// Optional coloured strip on the left edge.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final shape = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (accent != null) {
      // A coloured strip on the left edge (Stack, so no height is needed).
      content = Stack(
        children: [
          content,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: accent!),
          ),
        ],
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: lt.surface,
        borderRadius: shape,
        border: Border.all(color: lt.border),
        boxShadow: [
          BoxShadow(
            color: lt.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
