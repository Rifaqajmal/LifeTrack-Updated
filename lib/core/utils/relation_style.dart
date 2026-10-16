import 'package:flutter/material.dart';
import '../../models/birthday_model.dart';
import '../constants/app_colors.dart';

/// Default avatar emoji + gradient for a relation (Sister, Mother, ...).
class RelationStyle {
  const RelationStyle(this.emoji, this.gradient);

  final String emoji;
  final List<Color> gradient;

  /// Choices offered in the Add/Edit form.
  static const List<String> choices = [
    'Sister',
    'Brother',
    'Mother',
    'Father',
    'Friend',
    'Other',
  ];

  static const RelationStyle _sister =
      RelationStyle('🌸', [AppColors.pinkSoft, AppColors.pink]);
  static const RelationStyle _brother =
      RelationStyle('👨', [Color(0xFFFBBF24), Color(0xFFF59E0B)]);
  static const RelationStyle _mother =
      RelationStyle('👩', [Color(0xFF6EE7B7), Color(0xFF10B981)]);
  static const RelationStyle _father =
      RelationStyle('🧔', [Color(0xFF60A5FA), AppColors.blue]);
  static const RelationStyle _friend =
      RelationStyle('🧑', [Color(0xFFA78BFA), AppColors.primary2]);
  static const RelationStyle _other =
      RelationStyle('🎂', [Color(0xFFA78BFA), AppColors.primary2]);

  static RelationStyle of(String relation) {
    switch (relation.trim().toLowerCase()) {
      case 'sister':
      case 'sis':
        return _sister;
      case 'brother':
      case 'bro':
      case 'bhai':
        return _brother;
      case 'mother':
      case 'mom':
      case 'mum':
      case 'mama':
        return _mother;
      case 'father':
      case 'dad':
      case 'papa':
        return _father;
      case 'friend':
        return _friend;
      default:
        return _other;
    }
  }

  /// The emoji shown for [b]: its chosen emoji, else the relation default.
  static String emojiFor(BirthdayModel b) {
    final custom = b.emoji;
    if (custom != null && custom.trim().isNotEmpty) return custom;
    return of(b.relation).emoji;
  }
}
