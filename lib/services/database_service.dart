import 'package:firebase_database/firebase_database.dart';
import '../models/birthday_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  DatabaseReference _birthdays(String uid) =>
      _db.child('users').child(uid).child('birthdays');

  // CREATE
  Future<void> addBirthday(String uid, BirthdayModel birthday) async {
    await _birthdays(uid).child(birthday.id).set(birthday.toMap());
  }

  // UPDATE
  Future<void> updateBirthday(String uid, BirthdayModel birthday) async {
    await _birthdays(uid).child(birthday.id).update(birthday.toMap());
  }

  // DELETE
  Future<void> deleteBirthday(String uid, String id) async {
    await _birthdays(uid).child(id).remove();
  }

  // ONE-TIME FETCH
  Future<List<BirthdayModel>> getBirthdays(String uid) async {
    final snapshot = await _birthdays(uid).get();
    if (!snapshot.exists || snapshot.value == null) return [];
    return _parse(snapshot.value);
  }

  // REAL-TIME STREAM
  Stream<List<BirthdayModel>> streamBirthdays(String uid) {
    return _birthdays(uid).onValue.map((event) => _parse(event.snapshot.value));
  }

  /// Parses the raw database value, skipping any malformed record instead
  /// of failing the whole list.
  List<BirthdayModel> _parse(Object? raw) {
    if (raw is! Map) return [];
    final result = <BirthdayModel>[];
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! Map) continue;
      try {
        result.add(BirthdayModel.fromMap(Map<dynamic, dynamic>.from(value)));
      } catch (_) {
        // Skip a corrupt record.
      }
    }
    return result;
  }
}
