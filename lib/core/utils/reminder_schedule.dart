import 'date_helper.dart';

/// A "days lived" milestone and the moment to notify about it.
class Milestone {
  const Milestone(this.days, this.when);

  final int days;
  final DateTime when;
}

/// Pure scheduling rules for local notifications (no plugin calls), kept
/// separate so they are easy to unit test.
class ReminderSchedule {
  ReminderSchedule._();

  /// Reminders fire at 9:00 local time.
  static const int reminderHour = 9;

  /// Birthday reminders: the day itself, 1 day before, 1 week before.
  static const List<int> daysBefore = [0, 1, 7];

  /// A milestone is every this-many days lived.
  static const int milestoneEveryDays = 1000;

  /// The next moment (strictly after [now]) to remind about [dob]'s
  /// birthday [daysBefore] days ahead, or null if none could be found.
  static DateTime? nextReminderTime(
    DateTime dob,
    int daysBefore,
    DateTime now,
  ) {
    var occurrence = DateHelper.nextOccurrence(dob, from: now);
    for (var i = 0; i < 2; i++) {
      final when = DateTime(
        occurrence.year,
        occurrence.month,
        occurrence.day - daysBefore,
        reminderHour,
      );
      if (when.isAfter(now)) return when;
      occurrence = DateTime(occurrence.year + 1, dob.month, dob.day);
    }
    return null;
  }

  /// The next "every 1,000 days" milestone for someone born on [dob].
  static Milestone nextMilestone(DateTime dob, DateTime now) {
    final lived = now.difference(dob).inDays;
    var days = ((lived < 0 ? 0 : lived) ~/ milestoneEveryDays + 1) *
        milestoneEveryDays;
    var when = DateTime(dob.year, dob.month, dob.day + days, reminderHour);
    if (!when.isAfter(now)) {
      days += milestoneEveryDays;
      when = DateTime(dob.year, dob.month, dob.day + days, reminderHour);
    }
    return Milestone(days, when);
  }
}
