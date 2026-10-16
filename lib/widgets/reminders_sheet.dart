import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/feedback_helper.dart';
import '../providers/settings_provider.dart';
import 'settings_widgets.dart';

/// Quick reminder toggles (opened from the bell on Home).
class RemindersSheet {
  RemindersSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final lt = sheetContext.lt;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: lt.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: lt.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (settings.notificationsBlocked) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lt.tint(AppColors.amber),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Notifications are blocked for LifeTrack. Turn them on in your phone settings to receive reminders.',
                          style: TextStyle(fontSize: 13, color: lt.text),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SettingsCard(
                      children: [
                        SettingsTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Birthday Reminders',
                          subtitle: 'On the day, 1 day and 1 week before',
                          trailing: LTSwitch(
                            value: settings.remindersEnabled,
                            onChanged: (v) async {
                              final ok = await settings.setReminders(v);
                              if (!ok && context.mounted) {
                                FeedbackHelper.info(context,
                                    'Allow notifications in phone settings');
                              }
                            },
                          ),
                        ),
                        SettingsTile(
                          icon: Icons.auto_graph_rounded,
                          color: AppColors.pink,
                          title: 'Live Age Notifications',
                          subtitle: 'Every 1,000 days you live',
                          trailing: LTSwitch(
                            value: settings.milestonesEnabled,
                            onChanged: (v) async {
                              final ok = await settings.setMilestones(v);
                              if (!ok && context.mounted) {
                                FeedbackHelper.info(context,
                                    'Allow notifications in phone settings');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
