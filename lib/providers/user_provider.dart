import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// The signed-in Firebase user, kept up to date (including profile edits
/// such as a new display name).
class UserProvider extends ChangeNotifier {
  UserProvider() {
    _user = FirebaseAuth.instance.currentUser;
    _subscription = FirebaseAuth.instance.userChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  StreamSubscription<User?>? _subscription;

  User? get user => _user;
  String? get uid => _user?.uid;
  String get email => _user?.email ?? '';
  bool get emailVerified => _user?.emailVerified ?? false;

  /// The full name the user entered, or '' if none was set.
  String get displayName => (_user?.displayName ?? '').trim();

  /// First word of the display name, or '' if none was set.
  String get firstName {
    final name = displayName;
    if (name.isEmpty) return '';
    return name.split(RegExp(r'\s+')).first;
  }

  /// Re-reads the user from Firebase (after a profile update).
  void refresh() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
