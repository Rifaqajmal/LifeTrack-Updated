/// A date-of-birth broken down into calendar units and running totals.
class AgeBreakdown {
  const AgeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
  });

  /// Calendar age: e.g. 24 years, 9 months, 12 days.
  final int years;
  final int months;
  final int days;

  /// Running totals since birth.
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
}

class AgeCalculator {
  AgeCalculator._();

  static AgeBreakdown calculate(DateTime birthDate, {DateTime? now}) {
    final current = now ?? DateTime.now();

    int years = current.year - birthDate.year;
    int months = current.month - birthDate.month;
    int days = current.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      final daysInPrevMonth = DateTime(current.year, current.month, 0).day;
      days += daysInPrevMonth;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years < 0) {
      years = 0;
      months = 0;
      days = 0;
    }

    final diff = current.difference(birthDate);
    return AgeBreakdown(
      years: years,
      months: months,
      days: days,
      totalDays: diff.isNegative ? 0 : diff.inDays,
      totalHours: diff.isNegative ? 0 : diff.inHours,
      totalMinutes: diff.isNegative ? 0 : diff.inMinutes,
    );
  }
}
