/// Fun, estimated "life stats" for a person born on a given date.
///
/// These are rough averages for entertainment (70 heartbeats/min,
/// 15 breaths/min, 8 hours of sleep a day) — not medical data.
class LifeStats {
  const LifeStats({
    required this.daysLived,
    required this.heartbeats,
    required this.breaths,
    required this.hoursSlept,
  });

  final int daysLived;
  final int heartbeats;
  final int breaths;
  final int hoursSlept;

  static const int heartbeatsPerMinute = 70;
  static const int breathsPerMinute = 15;
  static const int sleepHoursPerDay = 8;

  /// Stats for someone born on [dob], measured at moment [at].
  factory LifeStats.at(DateTime dob, DateTime at) {
    final raw = at.difference(dob).inDays;
    final days = raw < 0 ? 0 : raw;
    return LifeStats(
      daysLived: days,
      heartbeats: days * 24 * 60 * heartbeatsPerMinute,
      breaths: days * 24 * 60 * breathsPerMinute,
      hoursSlept: days * sleepHoursPerDay,
    );
  }

  /// Age in fractional years, e.g. 24.9.
  double get yearsLived => daysLived / 365.25;
}
