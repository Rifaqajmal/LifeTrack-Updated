import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_helper.dart';
import '../core/utils/relation_style.dart';
import '../core/utils/zodiac_helper.dart';
import '../models/birthday_model.dart';

/// The picture captured when sharing a birthday as an image. Self-contained
/// (fixed colours, no theme lookups) so it renders outside the widget tree.
class ShareableBirthdayCard extends StatelessWidget {
  const ShareableBirthdayCard({
    super.key,
    required this.birthday,
    required this.isToday,
  });

  final BirthdayModel birthday;
  final bool isToday;

  static const String logoAsset = 'assets/icon/logo.png';

  static TextStyle _t(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = Colors.white,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        fontFamily: 'PlusJakartaSans',
        decoration: TextDecoration.none,
      );

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final zodiac = ZodiacHelper.getZodiac(birthday.dob);
    final days = DateHelper.daysUntilBirthday(birthday.dob, from: now);
    final turning = DateHelper.turningAge(birthday.dob, from: now);

    final bigText = isToday ? '🎉' : (days == 1 ? 'Tomorrow' : '$days');
    final bigSize = isToday ? 46.0 : (days == 1 ? 34.0 : 58.0);
    final smallText = isToday
        ? 'Happy Birthday!'
        : (days == 1 ? 'is the big day' : 'days to go');

    return ClipRect(
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          gradient: isToday ? AppColors.pinkGradient : AppColors.heroGradient,
        ),
        child: Stack(
          children: [
            Positioned(top: -70, right: -60, child: _circle(220, 0.09)),
            Positioned(bottom: -90, left: -70, child: _circle(240, 0.08)),
            Positioned(top: 150, left: 22, child: _dot(AppColors.amber, 10)),
            Positioned(top: 110, right: 34, child: _dot(AppColors.pinkSoft, 12)),
            Positioned(
                top: 250, right: 24, child: _dot(AppColors.green, 9)),
            Positioned(
                bottom: 120, left: 30, child: _dot(AppColors.amber, 8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          logoAsset,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('LifeTrack',
                          style: _t(16, weight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Avatar
                  Container(
                    width: 108,
                    height: 108,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      RelationStyle.emojiFor(birthday),
                      style: const TextStyle(
                          fontSize: 54, decoration: TextDecoration.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    birthday.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(30, weight: FontWeight.w800, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isToday
                        ? 'Turns $turning today'
                        : 'Turning $turning · ${DateHelper.formatMonthDay(birthday.dob)}',
                    style: _t(15, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zodiac,
                    style: _t(13.5, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 26),
                  // Countdown panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          bigText,
                          style: _t(bigSize,
                              weight: FontWeight.w800, height: 1.05),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          smallText,
                          style: _t(15,
                              weight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Never miss a birthday · LifeTrack',
                    style: _t(11.5,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
