import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Small rounded icon button. [glass] = translucent white (on gradients),
/// otherwise a soft surface button.
class LTIconButton extends StatelessWidget {
  const LTIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.glass = false,
    this.tooltip,
    this.color,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool glass;
  final String? tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final bg = glass ? Colors.white.withValues(alpha: 0.18) : lt.surface2;
    final fg = color ?? (glass ? Colors.white : lt.text);
    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(size * 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(size * 0.35),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: fg),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
