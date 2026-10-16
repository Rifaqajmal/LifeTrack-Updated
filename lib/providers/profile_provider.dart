import 'package:flutter/foundation.dart';

import '../core/utils/age_calculator.dart';
import '../core/utils/life_stats.dart';
import '../services/local_profile_service.dart';

/// The signed-in user's own details stored on the device: date of birth
/// (drives "Live Age") and emoji avatar.
class ProfileProvider extends ChangeNotifier {
  String? _uid;
  DateTime? _dob;
  String? _avatarEmoji;
  bool _loaded = false;

  DateTime? get dob => _dob;
  String? get avatarEmoji => _avatarEmoji;
  bool get loaded => _loaded;

  /// Exact age breakdown right now, or null if no date of birth is set.
  AgeBreakdown? get age {
    final dob = _dob;
    return dob == null ? null : AgeCalculator.calculate(dob);
  }

  /// Life stats right now, or null if no date of birth is set.
  LifeStats? get lifeStats {
    final dob = _dob;
    return dob == null ? null : LifeStats.at(dob, DateTime.now());
  }

  Future<void> load(String uid) async {
    _uid = uid;
    _loaded = false;
    notifyListeners();
    final dob = await LocalProfileService.loadDob(uid);
    final avatar = await LocalProfileService.loadAvatar(uid);
    if (_uid != uid) return;
    _dob = dob;
    _avatarEmoji = avatar;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDob(DateTime? dob) async {
    final uid = _uid;
    if (uid == null) return;
    _dob = dob;
    notifyListeners();
    await LocalProfileService.saveDob(uid, dob);
  }

  Future<void> setAvatar(String? emoji) async {
    final uid = _uid;
    if (uid == null) return;
    _avatarEmoji = emoji;
    notifyListeners();
    await LocalProfileService.saveAvatar(uid, emoji);
  }

  /// Forgets the loaded profile *without* notifying — used when the
  /// signed-in screens are torn down.
  void reset() {
    _uid = null;
    _dob = null;
    _avatarEmoji = null;
    _loaded = false;
  }
}
