/// Date helpers for birthday countdowns, age math and display formatting.
///
/// Month names are built in (instead of using `intl`) so formatting never
/// depends on locale initialisation.
class DateHelper {
  DateHelper._();

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Returns the next occurrence of [dob]'s month/day, rolling to next year
  /// if this year's date has already passed. Today counts as "next".
  static DateTime nextOccurrence(DateTime dob, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime next = DateTime(now.year, dob.month, dob.day);
    if (next.isBefore(today)) {
      next = DateTime(now.year + 1, dob.month, dob.day);
    }
    return next;
  }

  /// Whole days remaining until the next birthday (0 = today).
  static int daysUntilBirthday(DateTime dob, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextOccurrence(dob, from: now);
    return next.difference(today).inDays;
  }

  /// Whole-years age as of [from] (defaults to now).
  static int calculateAge(DateTime dob, {DateTime? from}) {
    final now = from ?? DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// The age the person turns on their next birthday (today counts).
  static int turningAge(DateTime dob, {DateTime? from}) {
    return nextOccurrence(dob, from: from).year - dob.year;
  }

  /// "April 18, 2003"
  static String formatLong(DateTime d) =>
      '${monthNames[d.month - 1]} ${d.day}, ${d.year}';

  /// "April 18"
  static String formatMonthDay(DateTime d) =>
      '${monthNames[d.month - 1]} ${d.day}';

  /// "Apr 18"
  static String formatShort(DateTime d) =>
      '${monthShort[d.month - 1]} ${d.day}';

  /// "Good morning" / "Good afternoon" / "Good evening"
  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
