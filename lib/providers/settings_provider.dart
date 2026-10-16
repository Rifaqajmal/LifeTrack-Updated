import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/biometric_service.dart';
import '../services/notification_service.dart';

/// App settings that are shared between the Profile and Settings screens:
/// reminder toggles, biometric lock, and the OS notification permission.
class SettingsProvider extends ChangeNotifier {
  static const _remindersKey = 'reminders_enabled';
  static const _milestonesKey = 'milestones_enabled';

  bool _reminders = true;
  bool _milestones = false;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool? _notificationsAllowed;

  /// Birthday reminders (day of, 1 day before, 1 week before).
  bool get remindersEnabled => _reminders;

  /// "Every 1,000 days lived" notifications.
  bool get milestonesEnabled => _milestones;

  bool get biometricSupported => _biometricSupported;
  bool get biometricEnabled => _biometricEnabled;

  /// Whether the OS lets the app show notifications (null = unknown).
  bool? get notificationsAllowed => _notificationsAllowed;

  /// True when a reminder toggle is on but the OS is blocking notifications.
  bool get notificationsBlocked =>
      (_reminders || _milestones) && _notificationsAllowed == false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _reminders = prefs.getBool(_remindersKey) ?? true;
    _milestones = prefs.getBool(_milestonesKey) ?? false;
    _biometricSupported = await BiometricService.isDeviceSupported();
    _biometricEnabled =
        _biometricSupported && await BiometricService.isEnabled();
    _notificationsAllowed = await NotificationService.areEnabled();
    notifyListeners();
  }

  Future<void> refreshNotificationStatus() async {
    _notificationsAllowed = await NotificationService.areEnabled();
    notifyListeners();
  }

  /// Turns birthday reminders on/off. Returns false if turning on but the
  /// OS is blocking notifications (so the UI can explain).
  Future<bool> setReminders(bool value) async {
    _reminders = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
    return value ? await _ensurePermission() : true;
  }

  /// Turns "days lived" milestone notifications on/off.
  Future<bool> setMilestones(bool value) async {
    _milestones = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_milestonesKey, value);
    return value ? await _ensurePermission() : true;
  }

  Future<bool> _ensurePermission() async {
    await NotificationService.requestPermission();
    await refreshNotificationStatus();
    return _notificationsAllowed != false;
  }

  /// Turns the biometric app lock on/off. Both directions require a
  /// successful check first: turning it on so the user can't lock themselves
  /// out, turning it off so someone holding an unlocked phone can't remove it.
  /// Returns whether the new state was applied.
  Future<bool> setBiometric(bool value) async {
    final ok = await BiometricService.authenticate();
    if (!ok) return false;
    await BiometricService.setEnabled(value);
    _biometricEnabled = value;
    notifyListeners();
    return true;
  }
}
