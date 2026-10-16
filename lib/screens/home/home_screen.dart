import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/utils/number_format.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/relation_style.dart';
import '../../models/birthday_model.dart';
import '../../providers/birthday_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/birthday_card.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/lt_card.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/reminders_sheet.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/status_bar.dart';
import '../profile/edit_profile_screen.dart';
import '../settings/settings_screen.dart';

/// Home tab: greeting, next birthday, quick actions, live age.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.uid, required this.onSelectTab});

  final String uid;
  final ValueChanged<int> onSelectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Keeps "days until" and the live age fresh while the app stays open.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const double _cardHeight = 108;
  static const double _overlap = 44;

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final birthdays = context.watch<BirthdayProvider>();
    final user = context.watch<UserProvider>();
    final profile = context.watch<ProfileProvider>();

    final next = birthdays.nextUp;
    final upcoming = birthdays.birthdays.skip(1).take(3).toList();
    final topPad = MediaQuery.of(context).padding.top;

    return StatusBar(
      lightIcons: true,
      child: Container(
        color: lt.bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    _header(context, user, birthdays, topPad),
                    const SizedBox(height: _cardHeight - _overlap),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  height: _cardHeight,
                  child: _nextUpCard(context, next),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _sectionTitle(context, 'Quick Actions'),
            _quickActions(context),
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 22),
              _sectionTitle(context, 'Coming Up'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final b in upcoming)
                      BirthdayCard(
                        birthday: b,
                        onTap: () => Nav.openDetail(context, b),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            _sectionTitle(context, 'Your Live Age'),
            _liveAge(context, profile),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, UserProvider user,
      BirthdayProvider birthdays, double topPad) {
    final name = user.firstName;
    final count = birthdays.count;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24 + _overlap),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateHelper.greeting()} 👋',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.isEmpty ? 'Welcome' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              LTIconButton(
                icon: Icons.notifications_rounded,
                glass: true,
                tooltip: 'Reminders',
                onPressed: () => RemindersSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎂 $count ${count == 1 ? 'birthday' : 'birthdays'} tracked',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextUpCard(BuildContext context, BirthdayModel? next) {
    final lt = context.lt;
    if (next == null) {
      return LTCard(
        onTap: () => Nav.openAdd(context, widget.uid),
        child: Row(
          children: [
            const Text('🎈', style: TextStyle(fontSize: 34)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No birthdays yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: lt.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to add your first one',
                    style: TextStyle(fontSize: 13, color: lt.text3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle_rounded,
                color: AppColors.primary, size: 30),
          ],
        ),
      );
    }

    final days = DateHelper.daysUntilBirthday(next.dob);
    final color = daysColor(days);
    final style = RelationStyle.of(next.relation);
    return LTCard(
      onTap: () => Nav.openDetail(context, next),
      child: Row(
        children: [
          EmojiAvatar(
            emoji: RelationStyle.emojiFor(next),
            colors: style.gradient,
            size: 60,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT UP',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: lt.text3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  next.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: lt.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Turning ${DateHelper.turningAge(next.dob)} · ${DateHelper.formatShort(next.dob)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: lt.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 64),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: lt.tint(color),
              borderRadius: BorderRadius.circular(16),
            ),
            child: days == 0
                ? Text(
                    '🎉\nToday',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$days',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        days == 1 ? 'day' : 'days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: context.lt.text,
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final items = <_Action>[
      _Action('Add', '➕', AppColors.primary,
          () => Nav.openAdd(context, widget.uid)),
      _Action('Birthdays', '🎂', AppColors.pink, () => widget.onSelectTab(1)),
      _Action('Stats', '📊', AppColors.green, () => widget.onSelectTab(2)),
      _Action(
        'Settings',
        '⚙️',
        AppColors.blue,
        () => Navigator.push(
          context,
          AppPageRoute<void>(page: const SettingsScreen()),
        ),
      ),
    ];
    final lt = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: LTCard(
                onTap: items[i].onTap,
                radius: 18,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: lt.tint(items[i].color),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(items[i].emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: lt.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _liveAge(BuildContext context, ProfileProvider profile) {
    final lt = context.lt;
    final stats = profile.lifeStats;
    if (stats == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LTCard(
          onTap: () => Navigator.push(
            context,
            AppPageRoute<void>(page: const EditProfileScreen()),
          ),
          child: Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your date of birth',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: lt.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'See your heartbeats, breaths and days lived',
                      style: TextStyle(fontSize: 13, color: lt.text3),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: lt.text3),
            ],
          ),
        ),
      );
    }
    final age = profile.age;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (age != null) ...[
            LTCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${age.years}',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'years old',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: lt.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${age.months} months · ${age.days} days',
                          style: TextStyle(fontSize: 13, color: lt.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.85,
        children: [
          StatTile(
            emoji: '❤️',
            value: NumberFormatter.compact(stats.heartbeats),
            label: 'Heartbeats',
            accent: AppColors.pink,
          ),
          StatTile(
            emoji: '🌬️',
            value: NumberFormatter.compact(stats.breaths),
            label: 'Breaths',
            accent: AppColors.blue,
          ),
          StatTile(
            emoji: '😴',
            value: NumberFormatter.grouped(stats.hoursSlept),
            label: 'Hours Slept',
            accent: AppColors.primary,
          ),
          StatTile(
            emoji: '📅',
            value: NumberFormatter.grouped(stats.daysLived),
            label: 'Days Lived',
            accent: AppColors.green,
          ),
        ],
          ),
        ],
      ),
    );
  }
}

class _Action {
  const _Action(this.label, this.emoji, this.color, this.onTap);
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
}
