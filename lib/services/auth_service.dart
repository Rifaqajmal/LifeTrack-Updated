import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates the account. Firebase signs the new user in automatically, so
  /// the app moves straight to the home screen (see AuthWrapper).
  Future<User?> signup(String email, String password, {String? name}) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    final cleanName = name?.trim() ?? '';
    if (user != null && cleanName.isNotEmpty) {
      try {
        await user.updateDisplayName(cleanName);
        await user.reload();
      } catch (_) {
        // The account exists; a failed name update must not fail sign-up.
      }
    }
    return user;
  }

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Sends a password reset email via Firebase Auth. Firebase handles the
  /// actual email delivery and reset flow — the app just triggers it.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Updates the signed-in user's display name.
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
