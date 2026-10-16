import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Centralized success/error/info feedback (SnackBar + haptic) so every
/// screen shows confirmations the same way.
class FeedbackHelper {
  FeedbackHelper._();

  // Slightly deeper than AppColors.green so white text stays readable.
  static const Color _successColor = Color(0xFF139E5C);

  static void success(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(context, message,
        icon: Icons.check_circle_outline_rounded, color: _successColor);
  }

  static void error(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    _show(context, message,
        icon: Icons.error_outline_rounded, color: const Color(0xFFD93636));
  }

  static void info(BuildContext context, String message) {
    HapticFeedback.selectionClick();
    _show(context, message,
        icon: Icons.info_outline_rounded, color: AppColors.primary);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
