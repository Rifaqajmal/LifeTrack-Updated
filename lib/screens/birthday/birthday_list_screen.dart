import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/confirm_dialog.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/feedback_helper.dart';
import '../../core/utils/navigation_helper.dart';
import '../../models/birthday_model.dart';
import '../../providers/birthday_provider.dart';
import '../../widgets/birthday_card.dart';
import '../../widgets/birthday_card_skeleton.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_bar.dart';

class BirthdayListScreen extends StatefulWidget {
  const BirthdayListScreen({super.key});

  @override
  State<BirthdayListScreen> createState() => _BirthdayListScreenState();
}

class _BirthdayListScreenState extends State<BirthdayListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh(BirthdayProvider provider) async {
    final ok = await provider.refresh();
    if (!ok && mounted) {
      FeedbackHelper.info(context, "Couldn't refresh — you may be offline");
    }
  }

  Future<void> _delete(BirthdayProvider provider, BirthdayModel b) async {
    try {
      await provider.delete(b);
      if (mounted) FeedbackHelper.success(context, 'Birthday deleted');
    } catch (_) {
      if (mounted) FeedbackHelper.error(context, 'Could not delete. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final provider = context.watch<BirthdayProvider>();
    final items = provider.filtered;
    final searching = provider.query.trim().isNotEmpty;

    Widget body;
    if (provider.loading) {
      body = ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: 5,
        itemBuilder: (_, __) => const BirthdayCardSkeleton(),
      );
    } else if (provider.error != null && provider.count == 0) {
      body = EmptyState(
        emoji: '📡',
        title: "Can't load birthdays",
        subtitle: provider.error!,
        action: OutlinedButton.icon(
          onPressed: () => _refresh(provider),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      );
    } else if (items.isEmpty) {
      body = searching
          ? const EmptyState(
              emoji: '🔍',
              title: 'No matches',
              subtitle: 'Try a different name or relation',
            )
          : const EmptyState(
              emoji: '🎂',
              title: AppStrings.emptyBirthdaysTitle,
              subtitle: AppStrings.emptyBirthdaysSubtitle,
            );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _refresh(provider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: _sections(context, provider, items),
        ),
      );
    }

    return StatusBar(
      lightIcons: true,
      child: Container(
        color: lt.bg,
        child: Column(
          children: [
            _header(context, provider),
            if (provider.fromCache)
              Container(
                width: double.infinity,
                color: lt.tint(AppColors.amber),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '📴 Showing saved birthdays — reconnecting…',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: lt.text),
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, BirthdayProvider provider) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Birthdays',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${provider.count} ${provider.count == 1 ? 'person' : 'people'} you care about',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _search,
            builder: (context, value, _) {
              return TextField(
                controller: _search,
                onChanged: provider.setQuery,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search by name or relation',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.8)),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () {
                            _search.clear();
                            provider.setQuery('');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Groups the (already soonest-first) list: Today, Upcoming (next 30
  /// days), then one section per month.
  List<Widget> _sections(BuildContext context, BirthdayProvider provider,
      List<BirthdayModel> items) {
    final now = DateTime.now();
    final widgets = <Widget>[];
    String? current;

    for (final b in items) {
      final days = DateHelper.daysUntilBirthday(b.dob, from: now);
      final String title;
      if (days == 0) {
        title = '🎉 Today';
      } else if (days <= 30) {
        title = '🔥 Upcoming';
      } else {
        final next = DateHelper.nextOccurrence(b.dob, from: now);
        final month = DateHelper.monthNames[next.month - 1];
        title = next.year == now.year ? month : '$month ${next.year}';
      }
      if (title != current) {
        current = title;
        widgets.add(_sectionHeader(context, title));
      }
      widgets.add(_dismissible(context, provider, b));
    }
    return widgets;
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: context.lt.text2,
        ),
      ),
    );
  }

  Widget _dismissible(
      BuildContext context, BirthdayProvider provider, BirthdayModel b) {
    return Dismissible(
      key: ValueKey(b.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => ConfirmDialog.show(
        context,
        title: 'Delete Birthday',
        message: "Delete ${b.name}'s birthday? This can't be undone.",
        confirmLabel: 'Delete',
        isDestructive: true,
      ),
      onDismissed: (_) => _delete(provider, b),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: BirthdayCard(
        birthday: b,
        margin: const EdgeInsets.only(bottom: 12),
        onTap: () => Nav.openDetail(context, b),
      ),
    );
  }
}
