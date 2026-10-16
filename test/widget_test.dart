import 'package:flutter_test/flutter_test.dart';
import 'package:life_track/core/utils/age_calculator.dart';
import 'package:life_track/core/utils/date_helper.dart';
import 'package:life_track/core/utils/life_stats.dart';
import 'package:life_track/core/utils/number_format.dart';
import 'package:life_track/core/utils/reminder_schedule.dart';
import 'package:life_track/core/utils/zodiac_helper.dart';

// Pure logic tests — no Firebase, no widgets.
void main() {
  group('DateHelper', () {
    final dob = DateTime(2000, 4, 18);

    test('days until birthday', () {
      expect(DateHelper.daysUntilBirthday(dob, from: DateTime(2026, 4, 10)), 8);
      expect(DateHelper.daysUntilBirthday(dob, from: DateTime(2026, 4, 18)), 0);
      expect(
          DateHelper.daysUntilBirthday(dob, from: DateTime(2026, 4, 19)), 364);
    });

    test('age and turning age', () {
      expect(DateHelper.calculateAge(dob, from: DateTime(2026, 4, 17)), 25);
      expect(DateHelper.calculateAge(dob, from: DateTime(2026, 4, 18)), 26);
      expect(DateHelper.turningAge(dob, from: DateTime(2026, 4, 18)), 26);
      expect(DateHelper.turningAge(dob, from: DateTime(2026, 4, 19)), 27);
    });

    test('formatting', () {
      expect(DateHelper.formatLong(DateTime(2003, 4, 18)), 'April 18, 2003');
      expect(DateHelper.formatShort(DateTime(2003, 4, 18)), 'Apr 18');
      expect(DateHelper.formatMonthDay(DateTime(2003, 4, 18)), 'April 18');
    });

    test('greeting', () {
      expect(DateHelper.greeting(now: DateTime(2026, 1, 1, 8)), 'Good morning');
      expect(DateHelper.greeting(now: DateTime(2026, 1, 1, 14)),
          'Good afternoon');
      expect(DateHelper.greeting(now: DateTime(2026, 1, 1, 20)),
          'Good evening');
    });
  });

  group('AgeCalculator', () {
    test('breaks age into years, months, days', () {
      final age = AgeCalculator.calculate(
        DateTime(2000, 1, 15),
        now: DateTime(2026, 3, 20),
      );
      expect(age.years, 26);
      expect(age.months, 2);
      expect(age.days, 5);
    });

    test('future birth date gives zeros', () {
      final age = AgeCalculator.calculate(
        DateTime(2030, 1, 1),
        now: DateTime(2026, 1, 1),
      );
      expect(age.years, 0);
      expect(age.totalDays, 0);
    });
  });

  group('ZodiacHelper', () {
    test('signs', () {
      expect(ZodiacHelper.getZodiac(DateTime(2000, 4, 18)), contains('Aries'));
      expect(ZodiacHelper.getZodiac(DateTime(2000, 4, 20)), contains('Taurus'));
      expect(ZodiacHelper.getZodiac(DateTime(2000, 1, 5)),
          contains('Capricorn'));
    });
  });

  group('NumberFormatter', () {
    test('grouped', () {
      expect(NumberFormatter.grouped(58003), '58,003');
      expect(NumberFormatter.grouped(999), '999');
      expect(NumberFormatter.grouped(1000000), '1,000,000');
    });

    test('compact', () {
      expect(NumberFormatter.compact(1243000000), '1.24B');
      expect(NumberFormatter.compact(318000000), '318M');
      expect(NumberFormatter.compact(24500000), '24.5M');
      expect(NumberFormatter.compact(58003), '58,003');
    });
  });

  group('LifeStats', () {
    test('counts from days lived', () {
      final s = LifeStats.at(DateTime(2000, 1, 1), DateTime(2000, 1, 11));
      expect(s.daysLived, 10);
      expect(s.heartbeats, 10 * 24 * 60 * 70);
      expect(s.breaths, 10 * 24 * 60 * 15);
      expect(s.hoursSlept, 80);
    });
  });

  group('ReminderSchedule', () {
    final dob = DateTime(2000, 4, 18);

    test('upcoming reminders at 9:00', () {
      final now = DateTime(2026, 4, 10, 8);
      expect(ReminderSchedule.nextReminderTime(dob, 0, now),
          DateTime(2026, 4, 18, 9));
      expect(ReminderSchedule.nextReminderTime(dob, 1, now),
          DateTime(2026, 4, 17, 9));
      expect(ReminderSchedule.nextReminderTime(dob, 7, now),
          DateTime(2026, 4, 11, 9));
    });

    test('passed reminder rolls to next year', () {
      final now = DateTime(2026, 4, 18, 10);
      expect(ReminderSchedule.nextReminderTime(dob, 0, now),
          DateTime(2027, 4, 18, 9));
    });

    test('next 1,000-day milestone', () {
      final now = DateTime(2000, 1, 11);
      final m = ReminderSchedule.nextMilestone(DateTime(2000, 1, 1), now);
      expect(m.days, 1000);
      expect(m.when.isAfter(now), isTrue);
    });
  });
}
