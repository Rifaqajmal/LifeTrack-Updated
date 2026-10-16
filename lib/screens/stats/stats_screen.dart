import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/number_format.dart';
import '../../core/utils/page_transitions.dart';
import '../../providers/birthday_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/lt_card.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/status_bar.dart';
import '../profile/edit_profile_screen.dart';

/// Stats tab: your own live age and a summary of tracked birthdays.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final profile = context.watch<ProfileProvider>();
    final birthdays = context.watch<BirthdayProvider>();
    final topPad = MediaQuery.of(context).padding.top;

    final dob = profile.dob;
    final age = profile.age;
    final life = profile.lifeStats;

    final all = birthdays.birthdays;
    final now = DateTime.now();
    final today =
        all.where((b) => DateHelper.daysUntilBirthday(b.dob, from: now) == 0);
    final month = all.where((b) {
      final d = DateHelper.daysUntilBirthday(b.dob, from: now);
      return d > 0 && d <= 30;
    });
    final next = birthdays.nextUp;

    return StatusBar(
      lightIcons: true,
      child: Container(
        color: lt.bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dob == null
                        ? 'Add your date of birth to see your numbers'
                        : 'Born ${DateHelper.formatLong(dob)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13.5,
                    ),
                  ),
                  if (age != null) ...[
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${age.years}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'years · ${age.months} months · ${age.days} days',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dob == null)
                    LTCard(
                      onTap: () => Navigator.push(
                        context,
                        AppPageRoute<void>(page: const EditProfileScreen()),
                      ),
                      child: Row(
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Set your date of birth to unlock your live age and life stats.',
                              style: TextStyle(
                                  fontSize: 14, color: lt.text2, height: 1.4),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: lt.text3),
                        ],
                      ),
                    )
                  else ...[
                    _title(lt, 'Time Alive'),
                    _grid([
                      StatTile(
                        emoji: '📅',
                        value: NumberFormatter.grouped(age!.totalDays),
                        label: 'Days',
                        accent: AppColors.green,
                      ),
                      StatTile(
                        emoji: '⏰',
                        value: NumberFormatter.grouped(age.totalHours),
                        label: 'Hours',
                        accent: AppColors.amber,
                      ),
                      StatTile(
                        emoji: '⏱️',
                        value: NumberFormatter.compact(age.totalMinutes),
                        label: 'Minutes',
                        accent: AppColors.blue,
                      ),
                      StatTile(
                        emoji: '🗓️',
                        value: NumberFormatter.grouped(
                            (age.totalDays / 7).floor()),
                        label: 'Weeks',
                        accent: AppColors.primary,
                      ),
                    ]),
                    const SizedBox(height: 22),
                    _title(lt, 'Your Body So Far'),
                    _grid([
                      StatTile(
                        emoji: '❤️',
                        value: NumberFormatter.compact(life!.heartbeats),
                        label: 'Heartbeats',
                        accent: AppColors.pink,
                      ),
                      StatTile(
                        emoji: '🌬️',
                        value: NumberFormatter.compact(life.breaths),
                        label: 'Breaths',
                        accent: AppColors.blue,
                      ),
                      StatTile(
                        emoji: '😴',
                        value: NumberFormatter.grouped(life.hoursSlept),
                        label: 'Hours Slept',
                        accent: AppColors.primary,
                      ),
                      StatTile(
                        emoji: '🌍',
                        value: life.yearsLived.toStringAsFixed(1),
                        label: 'Orbits of the Sun',
                        accent: AppColors.green,
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Estimates: 70 heartbeats/min, 15 breaths/min, 8 h sleep/day.',
                        style: TextStyle(fontSize: 11.5, color: lt.text3),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _title(lt, 'Birthday Overview'),
                  _grid([
                    StatTile(
                      emoji: '🎂',
                      value: '${birthdays.count}',
                      label: 'Tracked',
                      accent: AppColors.primary,
                    ),
                    StatTile(
                      emoji: '🎉',
                      value: '${today.length}',
                      label: 'Today',
                      accent: AppColors.pink,
                    ),
                    StatTile(
                      emoji: '🔥',
                      value: '${month.length}',
                      label: 'Next 30 days',
                      accent: AppColors.amber,
                    ),
                    StatTile(
                      emoji: '⏳',
                      value: next == null
                          ? '—'
                          : '${DateHelper.daysUntilBirthday(next.dob, from: now)}d',
                      label: next == null ? 'Next birthday' : next.name,
                      accent: AppColors.green,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(LTColors lt, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: lt.text,
        ),
      ),
    );
  }

  Widget _grid(List<Widget> children) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.85,
      children: children,
    );
  }
}
