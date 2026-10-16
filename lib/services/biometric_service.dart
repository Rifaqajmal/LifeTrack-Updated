import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Optional biometric app-lock, backed by [local_auth].
///
/// The lock is opt-in: [isEnabled] defaults to false until the user turns
/// it on from Settings, so the app works normally on devices/emulators
/// without biometric hardware.
class BiometricService {
  static const _prefsKey = 'biometric_lock_enabled';
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device can verify the user at all — biometrics *or* a
  /// PIN/pattern/password lock screen ([authenticate] falls back to those).
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }

  /// Prompts the user for biometric (or device PIN/pattern) verification.
  /// Returns false on any failure or cancellation instead of throwing, so
  /// callers can treat it as a simple pass/fail gate.
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock LifeTrack to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
