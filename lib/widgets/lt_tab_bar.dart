import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Bottom navigation: Home, Birthdays, [+] , Stats, Profile.
class LTTabBar extends StatelessWidget {
  const LTTabBar({
    super.key,
    required this.index,
    required this.onSelect,
    required this.onAdd,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    return Container(
      decoration: BoxDecoration(
        color: lt.surface,
        border: Border(top: BorderSide(color: lt.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(context, 0, Icons.home_rounded, 'Home'),
              _item(context, 1, Icons.cake_rounded, 'Birthdays'),
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: 'Add birthday',
                    child: GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
              ),
              _item(context, 2, Icons.bar_chart_rounded, 'Stats'),
              _item(context, 3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon, String label) {
    final lt = context.lt;
    final active = index == i;
    final color = active ? AppColors.primary : lt.text3;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
