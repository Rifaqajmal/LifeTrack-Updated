import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/confirm_dialog.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/feedback_helper.dart';
import '../../core/utils/page_transitions.dart';
import '../../providers/birthday_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/lt_card.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/status_bar.dart';
import '../settings/settings_screen.dart';
import 'edit_profile_screen.dart';

/// Account page: who you are, your numbers and account actions.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, AppPageRoute<void>(page: page));
  }

  Future<void> _changePassword(BuildContext context) async {
    final email = context.read<UserProvider>().email;
    if (email.isEmpty) return;
    final ok = await ConfirmDialog.show(
      context,
      title: 'Change password',
      message: "We'll email a password reset link to $email.",
      confirmLabel: 'Send Link',
    );
    if (!ok || !context.mounted) return;
    try {
      await AuthService().sendPasswordResetEmail(email);
      if (context.mounted) {
        FeedbackHelper.success(
            context, 'Reset link sent! Check your email (and spam).');
      }
    } catch (_) {
      if (context.mounted) {
        FeedbackHelper.error(context, "Couldn't send the link. Try again.");
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (!ok) return;
    try {
      await AuthService().logout();
    } catch (_) {
      if (context.mounted) {
        FeedbackHelper.error(context, "Couldn't log out. Try again.");
      }
    }
  }

  Future<void> _about(BuildContext context) async {
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = 'Version ${info.version} (${info.buildNumber})';
    } catch (_) {}
    if (!context.mounted) return;
    final lt = context.lt;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (version.isNotEmpty)
              Text(version, style: TextStyle(color: lt.text2)),
            const SizedBox(height: 8),
            Text(AppStrings.tagline, style: TextStyle(color: lt.text2)),
            const SizedBox(height: 8),
            Text('Made by ${AppStrings.author}',
                style: TextStyle(color: lt.text3)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final user = context.watch<UserProvider>();
    final profile = context.watch<ProfileProvider>();
    final settings = context.watch<SettingsProvider>();
    final birthdays = context.watch<BirthdayProvider>();
    final topPad = MediaQuery.of(context).padding.top;

    final name = user.displayName.isEmpty ? 'Your name' : user.displayName;
    final age = profile.age;
    final next = birthdays.nextUp;

    return StatusBar(
      lightIcons: true,
      child: Container(
        color: lt.bg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 28),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Text(
                          'My Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      LTIconButton(
                        icon: Icons.settings_rounded,
                        glass: true,
                        tooltip: 'Settings',
                        onPressed: () =>
                            _open(context, const SettingsScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _open(context, const EditProfileScreen()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        EmojiAvatar(
                          emoji: profile.avatarEmoji ?? '🎂',
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.2),
                          ],
                          size: 92,
                          radius: 30,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 3,
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                size: 16, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _mini(lt, '${birthdays.count}', 'Birthdays'),
                      const SizedBox(width: 10),
                      _mini(lt, age == null ? '—' : '${age.years}',
                          'Your Age'),
                      const SizedBox(width: 10),
                      _mini(
                        lt,
                        next == null
                            ? '—'
                            : '${DateHelper.daysUntilBirthday(next.dob)}',
                        'Days to Next',
                      ),
                    ],
                  ),
                  const SettingsLabel('Account'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.person_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Name, date of birth, avatar',
                        onTap: () =>
                            _open(context, const EditProfileScreen()),
                      ),
                      SettingsTile(
                        icon: Icons.lock_rounded,
                        color: AppColors.blue,
                        title: 'Change Password',
                        subtitle: 'Get a reset link by email',
                        onTap: () => _changePassword(context),
                      ),
                    ],
                  ),
                  const SettingsLabel('Preferences'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.pink,
                        title: 'Notifications',
                        subtitle: 'Birthday reminders',
                        trailing: LTSwitch(
                          value: settings.remindersEnabled,
                          onChanged: (v) async {
                            final ok = await settings.setReminders(v);
                            if (!ok && context.mounted) {
                              FeedbackHelper.info(context,
                                  'Allow notifications in phone settings');
                            }
                          },
                        ),
                      ),
                      if (settings.biometricSupported)
                        SettingsTile(
                          icon: Icons.fingerprint_rounded,
                          color: AppColors.green,
                          title: 'Biometric Lock',
                          subtitle: 'Ask for fingerprint or face on open',
                          trailing: LTSwitch(
                            value: settings.biometricEnabled,
                            onChanged: (v) async {
                              final ok = await settings.setBiometric(v);
                              if (!ok && context.mounted) {
                                FeedbackHelper.error(
                                    context, 'Verification failed');
                              }
                            },
                          ),
                        ),
                      SettingsTile(
                        icon: Icons.palette_rounded,
                        color: AppColors.amber,
                        title: 'Appearance',
                        subtitle: 'Light, dark or system',
                        onTap: () => _open(context, const SettingsScreen()),
                      ),
                    ],
                  ),
                  const SettingsLabel('More'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.info_rounded,
                        color: AppColors.blue,
                        title: 'About LifeTrack',
                        onTap: () => _about(context),
                      ),
                      SettingsTile(
                        icon: Icons.logout_rounded,
                        color: AppColors.red,
                        title: 'Log out',
                        titleColor: AppColors.red,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(LTColors lt, String value, String label) {
    return Expanded(
      child: LTCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: lt.text3),
            ),
          ],
        ),
      ),
    );
  }
}
