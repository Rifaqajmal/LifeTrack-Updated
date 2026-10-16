import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/feedback_helper.dart';
import '../../core/utils/page_transitions.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/status_bar.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'Version ${info.version} (${info.buildNumber})');
      }
    } catch (_) {}
  }

  Future<void> _toggleReminders(SettingsProvider s, bool v) async {
    final ok = await s.setReminders(v);
    if (!ok && mounted) {
      FeedbackHelper.info(context, 'Allow notifications in phone settings');
    }
  }

  Future<void> _toggleMilestones(SettingsProvider s, bool v) async {
    final ok = await s.setMilestones(v);
    if (!ok && mounted) {
      FeedbackHelper.info(context, 'Allow notifications in phone settings');
    }
  }

  Future<void> _sendTest() async {
    final ok = await NotificationService.scheduleTest();
    if (!mounted) return;
    if (ok) {
      FeedbackHelper.success(
          context, 'Test sent! Close the app and wait a few minutes.');
    } else {
      FeedbackHelper.info(context, 'Allow notifications in phone settings');
    }
  }

  Future<void> _toggleBiometric(SettingsProvider s, bool v) async {
    final ok = await s.setBiometric(v);
    if (!ok && mounted) {
      FeedbackHelper.error(context, 'Verification failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final settings = context.watch<SettingsProvider>();
    final theme = context.watch<ThemeProvider>();
    final topPad = MediaQuery.of(context).padding.top;

    return StatusBar(
      lightIcons: true,
      child: Scaffold(
        backgroundColor: lt.bg,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 22),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Row(
                children: [
                  LTIconButton(
                    icon: Icons.arrow_back_rounded,
                    glass: true,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsLabel('Appearance'),
                  Row(
                    children: [
                      _themeOption(lt, theme, ThemeMode.light, '☀️', 'Light'),
                      const SizedBox(width: 10),
                      _themeOption(lt, theme, ThemeMode.dark, '🌙', 'Dark'),
                      const SizedBox(width: 10),
                      _themeOption(
                          lt, theme, ThemeMode.system, '📱', 'System'),
                    ],
                  ),
                  const SettingsLabel('Notifications'),
                  if (settings.notificationsBlocked) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lt.tint(AppColors.amber),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Notifications are blocked for LifeTrack. Turn them on in your phone settings to receive reminders.',
                        style: TextStyle(fontSize: 13, color: lt.text),
                      ),
                    ),
                  ],
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.pink,
                        title: 'Birthday Reminders',
                        subtitle: 'On the day, 1 day and 1 week before',
                        trailing: LTSwitch(
                          value: settings.remindersEnabled,
                          onChanged: (v) => _toggleReminders(settings, v),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.auto_graph_rounded,
                        color: AppColors.primary,
                        title: 'Live Age Notifications',
                        subtitle: 'Every 1,000 days you live',
                        trailing: LTSwitch(
                          value: settings.milestonesEnabled,
                          onChanged: (v) => _toggleMilestones(settings, v),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.send_rounded,
                        color: AppColors.green,
                        title: 'Send test notification',
                        subtitle: 'Arrives within a few minutes',
                        onTap: _sendTest,
                      ),
                    ],
                  ),
                  const SettingsLabel('Security'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        color: AppColors.green,
                        title: 'Biometric Lock',
                        subtitle: settings.biometricSupported
                            ? 'Ask for fingerprint or face when opening'
                            : 'Not available on this device',
                        trailing: LTSwitch(
                          value: settings.biometricEnabled,
                          onChanged: settings.biometricSupported
                              ? (v) => _toggleBiometric(settings, v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SettingsLabel('About'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.privacy_tip_rounded,
                        color: AppColors.blue,
                        title: 'Privacy Policy',
                        onTap: () => Navigator.push(
                          context,
                          AppPageRoute<void>(
                              page: const PrivacyPolicyScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Column(
                      children: [
                        const Text('🎂', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: lt.text2,
                          ),
                        ),
                        if (_version.isNotEmpty)
                          Text(
                            _version,
                            style: TextStyle(fontSize: 12, color: lt.text3),
                          ),
                        Text(
                          'Made by ${AppStrings.author}',
                          style: TextStyle(fontSize: 12, color: lt.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(LTColors lt, ThemeProvider theme, ThemeMode mode,
      String emoji, String label) {
    final selected = theme.mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => theme.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? lt.primarySoft : lt.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : lt.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : lt.text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
