import 'package:hive_flutter/hive_flutter.dart';
import '../models/birthday_model.dart';

/// Local offline cache for birthdays using a plain Hive box (no codegen).
///
/// Each user's birthdays are cached in a box named `birthdays_<uid>` so
/// switching accounts on the same device doesn't mix data. The cache is
/// refreshed every time the live Firebase stream emits, and read on
/// startup so the list has something to show before (or without) a
/// connection.
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static String _boxName(String uid) => 'birthdays_$uid';

  static Future<Box> _openBox(String uid) async {
    return Hive.isBoxOpen(_boxName(uid))
        ? Hive.box(_boxName(uid))
        : await Hive.openBox(_boxName(uid));
  }

  /// Overwrites the local cache with the latest list from Firebase.
  static Future<void> cacheBirthdays(
    String uid,
    List<BirthdayModel> birthdays,
  ) async {
    final box = await _openBox(uid);
    await box.clear();
    for (final b in birthdays) {
      await box.put(b.id, b.toMap());
    }
  }

  /// Reads whatever was last cached for this user (empty list if none).
  /// Unreadable entries are skipped.
  static Future<List<BirthdayModel>> getCachedBirthdays(String uid) async {
    final box = await _openBox(uid);
    final result = <BirthdayModel>[];
    for (final raw in box.values) {
      if (raw is! Map) continue;
      try {
        result.add(BirthdayModel.fromMap(Map<dynamic, dynamic>.from(raw)));
      } catch (_) {
        // Skip a corrupt cache entry.
      }
    }
    return result;
  }

  static Future<void> clearCache(String uid) async {
    final box = await _openBox(uid);
    await box.clear();
  }
}
