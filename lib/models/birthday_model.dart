/// A tracked birthday.
///
/// [emoji] (avatar) and [note] are optional and were added in v2; older
/// records saved without them still load fine (both come back `null`).
class BirthdayModel {
  final String id;
  final String name;
  final DateTime dob;
  final String relation;
  final String? photoUrl;
  final String? emoji;
  final String? note;

  const BirthdayModel({
    required this.id,
    required this.name,
    required this.dob,
    required this.relation,
    this.photoUrl,
    this.emoji,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob.toIso8601String(),
      'relation': relation,
      'photoUrl': photoUrl,
      'emoji': emoji,
      'note': note,
    };
  }

  /// Throws if [map] has no valid `dob`; callers that read lists from the
  /// network/cache catch this so one bad record can't hide all the others.
  factory BirthdayModel.fromMap(Map<dynamic, dynamic> map) {
    return BirthdayModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      dob: DateTime.parse(map['dob'].toString()),
      relation: (map['relation'] ?? '').toString(),
      photoUrl: map['photoUrl']?.toString(),
      emoji: map['emoji']?.toString(),
      note: map['note']?.toString(),
    );
  }

  /// First letter of the name (never throws on an empty name).
  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
