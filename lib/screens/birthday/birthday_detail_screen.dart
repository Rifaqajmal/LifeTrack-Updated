import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/confirm_dialog.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/feedback_helper.dart';
import '../../core/utils/life_stats.dart';
import '../../core/utils/number_format.dart';
import '../../core/utils/page_transitions.dart';
import '../../core/utils/relation_style.dart';
import '../../core/utils/zodiac_helper.dart';
import '../../models/birthday_model.dart';
import '../../providers/birthday_provider.dart';
import '../../services/share_service.dart';
import '../../services/wish_generator_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/lt_card.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/shareable_birthday_card.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/status_bar.dart';
import 'add_edit_birthday_screen.dart';

class BirthdayDetailScreen extends StatefulWidget {
  const BirthdayDetailScreen({super.key, required this.birthday});

  final BirthdayModel birthday;

  @override
  State<BirthdayDetailScreen> createState() => _BirthdayDetailScreenState();
}

class _BirthdayDetailScreenState extends State<BirthdayDetailScreen> {
  final ScreenshotController _screenshot = ScreenshotController();
  late String _wish;
  bool _capturing = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _wish = WishGeneratorService.generate(widget.birthday.name);
  }

  /// The freshest copy of this birthday (it may have been edited).
  BirthdayModel _current(BirthdayProvider provider) {
    for (final b in provider.birthdays) {
      if (b.id == widget.birthday.id) return b;
    }
    return widget.birthday;
  }

  void _newWish(BirthdayModel b) {
    setState(() {
      _wish = WishGeneratorService.generate(b.name, previous: _wish);
    });
  }

  Future<void> _edit(BirthdayModel b) async {
    final uid = context.read<BirthdayProvider>().uid;
    if (uid == null) return;
    final result = await Navigator.push<String>(
      context,
      AppPageRoute<String>(
        page: AddEditBirthdayScreen(uid: uid, existing: b),
      ),
    );
    if (!mounted) return;
    if (result == 'updated') {
      FeedbackHelper.success(context, 'Birthday updated ✓');
      // New name → fresh wish text.
      setState(() {});
    }
  }

  Future<void> _delete(BirthdayModel b) async {
    final provider = context.read<BirthdayProvider>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete Birthday',
      message: "Delete ${b.name}'s birthday? This can't be undone.",
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _deleting = true);
    try {
      await provider.delete(b);
      if (mounted) Navigator.pop(context, 'deleted');
    } catch (_) {
      if (mounted) {
        setState(() => _deleting = false);
        FeedbackHelper.error(context, 'Could not delete. Try again.');
      }
    }
  }

  Future<void> _shareText(BirthdayModel b) async {
    try {
      await ShareService.shareMessage(_wish);
    } catch (_) {
      if (mounted) FeedbackHelper.error(context, 'Could not open share');
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _wish));
    if (mounted) FeedbackHelper.success(context, 'Wish copied');
  }

  Future<void> _shareImage(BirthdayModel b, bool isToday) async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      // Load the logo first so it is ready when the card is drawn offscreen.
      await precacheImage(
          const AssetImage(ShareableBirthdayCard.logoAsset), context);
      if (!mounted) return;
      final bytes = await _screenshot.captureFromWidget(
        MediaQuery(
          data: MediaQueryData.fromView(View.of(context)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ShareableBirthdayCard(birthday: b, isToday: isToday),
          ),
        ),
        pixelRatio: 2.5,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/lifetrack_${b.id}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await ShareService.shareImage(file.path, text: _wish);
    } catch (_) {
      if (mounted) FeedbackHelper.error(context, 'Could not create image');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final provider = context.watch<BirthdayProvider>();
    final b = _current(provider);

    final now = DateTime.now();
    final days = DateHelper.daysUntilBirthday(b.dob, from: now);
    final isToday = days == 0;
    final turning = DateHelper.turningAge(b.dob, from: now);
    final age = DateHelper.calculateAge(b.dob, from: now);
    final stats = LifeStats.at(b.dob, DateHelper.nextOccurrence(b.dob, from: now));
    final style = RelationStyle.of(b.relation);
    final relation = b.relation.trim();
    final note = (b.note ?? '').trim();
    final topPad = MediaQuery.of(context).padding.top;

    final rows = <List<String>>[
      ['📅', 'Date of birth', DateHelper.formatLong(b.dob)],
      ['🎈', 'Current age', '$age years'],
      ['✨', 'Zodiac', ZodiacHelper.getZodiac(b.dob)],
      if (relation.isNotEmpty) [style.emoji, 'Relation', relation],
      if (note.isNotEmpty) ['📝', 'Note', note],
    ];

    final headline = isToday
        ? 'Turning $turning today 🎉'
        : days == 1
            ? 'Turning $turning tomorrow 🎉'
            : 'Turning $turning in $days days 🎉';

    return StatusBar(
      lightIcons: true,
      child: Scaffold(
        backgroundColor: lt.bg,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 28),
              decoration: BoxDecoration(
                gradient: isToday
                    ? AppColors.pinkGradient
                    : AppColors.headerGradient,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      LTIconButton(
                        icon: Icons.arrow_back_rounded,
                        glass: true,
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      LTIconButton(
                        icon: Icons.edit_rounded,
                        glass: true,
                        tooltip: 'Edit',
                        onPressed: _deleting ? null : () => _edit(b),
                      ),
                      const SizedBox(width: 8),
                      LTIconButton(
                        icon: Icons.delete_rounded,
                        glass: true,
                        tooltip: 'Delete',
                        onPressed: _deleting ? null : () => _delete(b),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EmojiAvatar(
                    emoji: RelationStyle.emojiFor(b),
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                    size: 88,
                    radius: 30,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    b.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (relation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        relation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(lt, 'Birthday Info'),
                  LTCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < rows.length; i++)
                          _infoRow(lt, rows[i][0], rows[i][1], rows[i][2],
                              last: i == rows.length - 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _title(lt, 'Life Stats at Turning $turning'),
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
                        value: '~${NumberFormatter.compact(stats.heartbeats)}',
                        label: 'Heartbeats',
                        accent: AppColors.pink,
                      ),
                      StatTile(
                        emoji: '🌬️',
                        value: '~${NumberFormatter.compact(stats.breaths)}',
                        label: 'Breaths',
                        accent: AppColors.blue,
                      ),
                      StatTile(
                        emoji: '😴',
                        value:
                            '~${NumberFormatter.grouped(stats.hoursSlept)}',
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
                  const SizedBox(height: 22),
                  _title(lt, 'Birthday Wish'),
                  LTCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _wish,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: lt.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _newWish(b),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('New wish'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: '🎉 Send Birthday Wish',
                    onPressed: () => _shareText(b),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Share Image',
                          icon: Icons.image_rounded,
                          outlined: true,
                          height: 50,
                          loading: _capturing,
                          onPressed: () => _shareImage(b, isToday),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          label: 'Copy',
                          icon: Icons.copy_rounded,
                          outlined: true,
                          height: 50,
                          onPressed: _copy,
                        ),
                      ),
                    ],
                  ),
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

  Widget _infoRow(LTColors lt, String emoji, String label, String value,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: lt.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: lt.text3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: lt.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
