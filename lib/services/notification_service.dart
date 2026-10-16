import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/number_format.dart';
import '../core/utils/reminder_schedule.dart';
import '../models/birthday_model.dart';

/// Local birthday reminders and "days lived" milestone notifications.
///
/// Everything is scheduled with *inexact* alarms: a birthday reminder does
/// not need to fire at the exact second, and this avoids the
/// SCHEDULE_EXACT_ALARM permission (denied by default on Android 14+, which
/// made exact scheduling fail).
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'birthday_channel';
  static const String _channelName = 'Birthday Notifications';

  /// Reserved id for the milestone notification (birthday ids stay below it).
  static const int _milestoneId = 2100000000;

  /// Reserved id for the "send test notification" button.
  static const int _testId = 2100000001;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFF5533FF),
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
  }

  /// Asks for the notification permission (Android 13+ shows a system
  /// prompt only the first time). Returns whether notifications are allowed.
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return (await android.requestNotificationsPermission()) ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return (await ios.requestPermissions(
                alert: true, badge: true, sound: true)) ??
            false;
      }
      return true;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  /// Whether the OS currently lets this app show notifications
  /// (null when it can't be determined on this platform).
  static Future<bool?> areEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled();
    } catch (_) {
      return null;
    }
  }

  /// Brings the OS-level schedule in line with the current data: every
  /// pending notification is cleared and the upcoming ones re-created, so
  /// deleted/renamed birthdays and changed settings are always reflected.
  static Future<void> sync({
    required List<BirthdayModel> birthdays,
    required DateTime? ownDob,
    required bool reminders,
    required bool milestones,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        await _plugin.cancel(request.id);
      }
    } catch (e) {
      debugPrint('Could not clear pending notifications: $e');
    }

    if (reminders) {
      for (final b in birthdays) {
        await _scheduleBirthday(b, current);
      }
    }
    if (milestones && ownDob != null) {
      await _scheduleMilestone(ownDob, current);
    }
  }

  /// Schedules a one-off test notification through the same path as real
  /// reminders, so the user can confirm delivery works on their phone.
  /// Returns false if notifications are not allowed or scheduling failed.
  static Future<bool> scheduleTest({
    Duration delay = const Duration(minutes: 1),
  }) async {
    final allowed = await requestPermission();
    if (!allowed) return false;
    try {
      await _plugin.zonedSchedule(
        _testId,
        'LifeTrack test 🎂',
        'Notifications work! Your birthday reminders will arrive like this.',
        tz.TZDateTime.now(tz.local).add(delay),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (e) {
      debugPrint('Could not schedule test notification: $e');
      return false;
    }
  }

  /// Removes every scheduled notification (used on logout).
  static Future<void> cancelAll() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        await _plugin.cancel(request.id);
      }
    } catch (e) {
      debugPrint('Could not cancel notifications: $e');
    }
  }

  static int _baseId(String birthdayId) {
    // < 500,000,000 * 4 = 2,000,000,000, safely below the 32-bit limit.
    return (birthdayId.hashCode.abs() % 500000000) * 4;
  }

  static Future<void> _scheduleBirthday(BirthdayModel b, DateTime now) async {
    final base = _baseId(b.id);
    for (var i = 0; i < ReminderSchedule.daysBefore.length; i++) {
      final daysBefore = ReminderSchedule.daysBefore[i];
      final when = ReminderSchedule.nextReminderTime(b.dob, daysBefore, now);
      if (when == null) continue;

      final String title;
      final String body;
      if (daysBefore == 0) {
        title = 'Birthday today 🎉';
        body = 'Wish ${b.name} a happy birthday!';
      } else if (daysBefore == 1) {
        title = 'Birthday tomorrow 🎂';
        body = "${b.name}'s birthday is tomorrow.";
      } else {
        title = 'Birthday next week 🎁';
        body = "${b.name}'s birthday is in $daysBefore days.";
      }

      try {
        await _plugin.zonedSchedule(
          base + i,
          title,
          body,
          tz.TZDateTime.from(when, tz.local),
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('Could not schedule reminder for ${b.name}: $e');
      }
    }
  }

  static Future<void> _scheduleMilestone(DateTime dob, DateTime now) async {
    final milestone = ReminderSchedule.nextMilestone(dob, now);
    try {
      await _plugin.zonedSchedule(
        _milestoneId,
        '🎉 ${NumberFormatter.grouped(milestone.days)} days alive!',
        'Today is day ${NumberFormatter.grouped(milestone.days)} of your life. '
            'What a milestone!',
        tz.TZDateTime.from(milestone.when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Could not schedule milestone notification: $e');
    }
  }
}
