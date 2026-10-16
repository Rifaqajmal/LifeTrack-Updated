import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in user's own profile details that live only on the device:
/// their date of birth (for "Live Age") and their emoji avatar.
///
/// Stored per account (`uid`) so two accounts on one phone don't share
/// each other's date of birth.
class LocalProfileService {
  LocalProfileService._();

  static const _legacyDobKey = 'dob'; // used by v1 (one value for everyone)

  static String _dobKey(String uid) => 'profile_dob_$uid';
  static String _avatarKey(String uid) => 'profile_avatar_$uid';

  static Future<DateTime?> loadDob(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString(_dobKey(uid));
    if (raw == null) {
      // One-time migration of the v1 global value to this account.
      final legacy = prefs.getString(_legacyDobKey);
      if (legacy != null) {
        await prefs.setString(_dobKey(uid), legacy);
        await prefs.remove(_legacyDobKey);
        raw = legacy;
      }
    }
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> saveDob(String uid, DateTime? dob) async {
    final prefs = await SharedPreferences.getInstance();
    if (dob == null) {
      await prefs.remove(_dobKey(uid));
    } else {
      await prefs.setString(_dobKey(uid), dob.toIso8601String());
    }
  }

  static Future<String?> loadAvatar(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey(uid));
  }

  static Future<void> saveAvatar(String uid, String? emoji) async {
    final prefs = await SharedPreferences.getInstance();
    if (emoji == null || emoji.isEmpty) {
      await prefs.remove(_avatarKey(uid));
    } else {
      await prefs.setString(_avatarKey(uid), emoji);
    }
  }
}
