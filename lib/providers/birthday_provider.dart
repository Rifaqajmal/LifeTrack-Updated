import 'dart:async';
import 'package:flutter/foundation.dart';

import '../core/utils/date_helper.dart';
import '../models/birthday_model.dart';
import '../services/database_service.dart';
import '../services/hive_service.dart';

/// Holds the signed-in user's birthdays and keeps them in sync with
/// Firebase Realtime Database (live stream), with a Hive cache so the list
/// still appears offline.
///
/// One subscription lives here (started by the main shell after login), so
/// Home, Birthdays and Stats all read the same data and nothing leaks.
class BirthdayProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  static const Duration _connectTimeout = Duration(seconds: 8);
  static const Duration _writeTimeout = Duration(seconds: 4);

  StreamSubscription<List<BirthdayModel>>? _subscription;
  Timer? _connectTimer;
  int _session = 0;

  String? _uid;
  List<BirthdayModel> _items = [];
  String _query = '';
  bool _loading = true;
  bool _fromCache = false;
  String? _error;

  String? get uid => _uid;
  bool get loading => _loading;

  /// True while showing the offline cache before the live data arrives.
  bool get fromCache => _fromCache;
  String? get error => _error;
  String get query => _query;
  int get count => _items.length;

  /// All birthdays, soonest upcoming first.
  List<BirthdayModel> get birthdays => _sorted(_items);

  /// Birthdays matching the search text (name or relation), soonest first.
  List<BirthdayModel> get filtered {
    final q = _query.trim().toLowerCase();
    final all = birthdays;
    if (q.isEmpty) return all;
    return all
        .where((b) =>
            b.name.toLowerCase().contains(q) ||
            b.relation.toLowerCase().contains(q))
        .toList();
  }

  /// The soonest upcoming birthday (today counts), or null if none.
  BirthdayModel? get nextUp {
    final all = birthdays;
    return all.isEmpty ? null : all.first;
  }

  List<BirthdayModel> _sorted(List<BirthdayModel> source) {
    final now = DateTime.now();
    final list = [...source];
    list.sort((a, b) {
      final byDays = DateHelper.daysUntilBirthday(a.dob, from: now)
          .compareTo(DateHelper.daysUntilBirthday(b.dob, from: now));
      if (byDays != 0) return byDays;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  /// Starts listening for [uid]'s birthdays (safe to call repeatedly).
  Future<void> start(String uid) async {
    if (_uid == uid && _subscription != null) return;

    final session = ++_session;
    await _subscription?.cancel();
    _subscription = null;
    _connectTimer?.cancel();

    _uid = uid;
    _items = [];
    _query = '';
    _loading = true;
    _fromCache = false;
    _error = null;
    notifyListeners();

    // 1) Show whatever we cached last time right away.
    try {
      final cached = await HiveService.getCachedBirthdays(uid);
      if (session != _session) return;
      if (cached.isNotEmpty) {
        _items = cached;
        _fromCache = true;
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Could not read birthday cache: $e');
    }
    if (session != _session) return;

    // 2) Live data from Firebase takes over.
    _subscription = _db.streamBirthdays(uid).listen(
      (data) {
        if (session != _session) return;
        _connectTimer?.cancel();
        _items = data;
        _loading = false;
        _fromCache = false;
        _error = null;
        notifyListeners();
        unawaited(
          HiveService.cacheBirthdays(uid, data).catchError((Object e) {
            debugPrint('Could not cache birthdays: $e');
          }),
        );
      },
      onError: (Object e) {
        if (session != _session) return;
        _connectTimer?.cancel();
        _loading = false;
        if (_items.isEmpty) {
          _error = 'Could not load your birthdays. Check your connection.';
        }
        notifyListeners();
      },
    );

    // Offline with nothing cached: don't show a skeleton forever.
    _connectTimer = Timer(_connectTimeout, () {
      if (session != _session || !_loading) return;
      _loading = false;
      if (_items.isEmpty) {
        _error = 'Could not connect. Check your internet connection.';
      }
      notifyListeners();
    });
  }

  /// Stops listening and forgets everything *without* notifying — used when
  /// the signed-in screens are being torn down.
  void stop() {
    _session++;
    _subscription?.cancel();
    _subscription = null;
    _connectTimer?.cancel();
    _uid = null;
    _items = [];
    _query = '';
    _loading = true;
    _fromCache = false;
    _error = null;
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  /// Pull-to-refresh: re-reads from the server once. Returns false if it
  /// could not (offline) so the UI can say so.
  Future<bool> refresh() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final data = await _db.getBirthdays(uid).timeout(_connectTimeout);
      if (_uid != uid) return false;
      _items = data;
      _loading = false;
      _fromCache = false;
      _error = null;
      notifyListeners();
      unawaited(
        HiveService.cacheBirthdays(uid, data).catchError((Object e) {
          debugPrint('Could not cache birthdays: $e');
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Creates or updates a birthday. The live stream delivers the change
  /// (Firebase reports local writes immediately, even offline), so no
  /// manual list update is needed here.
  Future<void> save(BirthdayModel birthday, {required bool isNew}) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');
    final write = isNew
        ? _db.addBirthday(uid, birthday)
        : _db.updateBirthday(uid, birthday);
    try {
      await write.timeout(_writeTimeout);
    } on TimeoutException {
      // Offline: Firebase keeps the write queued and syncs it later.
    }
  }

  /// Deletes a birthday. It disappears from the list immediately (needed
  /// for swipe-to-dismiss), and comes back if the server rejects it.
  Future<void> delete(BirthdayModel birthday) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');
    final backup = _items;
    _items = _items.where((b) => b.id != birthday.id).toList();
    notifyListeners();
    try {
      await _db.deleteBirthday(uid, birthday.id).timeout(_writeTimeout);
    } on TimeoutException {
      // Offline: the delete stays queued and syncs later.
    } catch (_) {
      _items = backup;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectTimer?.cancel();
    super.dispose();
  }
}
