import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Full-width gradient primary button (or outlined when [outlined]).
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.outlined = false,
    this.height = 54,
    this.gradient = AppColors.buttonGradient,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final bool outlined;
  final double height;
  final VoidCallback? onPressed;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final enabled = onPressed != null && !loading;
    final fg = outlined ? AppColors.primary : Colors.white;

    final content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: outlined ? null : gradient,
          color: outlined ? lt.surface : null,
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onPressed : null,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
