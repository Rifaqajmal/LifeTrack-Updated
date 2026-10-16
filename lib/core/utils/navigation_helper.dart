import 'package:flutter/material.dart';
import '../../models/birthday_model.dart';
import '../../screens/birthday/add_edit_birthday_screen.dart';
import '../../screens/birthday/birthday_detail_screen.dart';
import 'feedback_helper.dart';
import 'page_transitions.dart';

/// Shared "open screen, then show the right confirmation" navigation.
class Nav {
  Nav._();

  static Future<void> openDetail(BuildContext context, BirthdayModel b) async {
    final result = await Navigator.push<String>(
      context,
      AppPageRoute<String>(page: BirthdayDetailScreen(birthday: b)),
    );
    if (!context.mounted) return;
    if (result == 'deleted') {
      FeedbackHelper.success(context, 'Birthday deleted');
    } else if (result == 'updated') {
      FeedbackHelper.success(context, 'Birthday updated ✓');
    }
  }

  static Future<void> openAdd(BuildContext context, String uid) async {
    final result = await Navigator.push<String>(
      context,
      AppPageRoute<String>(page: AddEditBirthdayScreen(uid: uid)),
    );
    if (!context.mounted) return;
    if (result == 'added') {
      FeedbackHelper.success(context, 'Birthday added 🎉');
    }
  }
}
