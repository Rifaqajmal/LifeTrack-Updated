import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/status_bar.dart';

/// In-app copy of the privacy policy (kept in sync with
/// docs/PRIVACY_POLICY.md).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<(String, String)> _sections = [
    (
      'Who we are',
      'LifeTrack is developed by Rifaq Ajmal. This policy explains what the app stores, why, and the choices you have.'
    ),
    (
      'Account information',
      'You sign up with an email address, password and your name. These are handled by Firebase Authentication and used only to identify your account.'
    ),
    (
      'Birthdays you add',
      'Names, relations, dates of birth, avatar emoji and optional notes of the birthdays you add are stored in Firebase Realtime Database under your account, so they sync across devices and survive reinstalling the app.'
    ),
    (
      'Stored only on your device',
      'Your own date of birth and profile avatar are saved on your device only and never sent to a server. A cached copy of your birthday list is kept on the device so the app works offline.'
    ),
    (
      'Biometric lock',
      'If you turn on the optional app lock, your phone verifies your fingerprint, face or screen lock. LifeTrack never receives or stores biometric data.'
    ),
    (
      'Notifications',
      'Reminders are scheduled and shown entirely on your device. No notification content goes through a push service.'
    ),
    (
      'What we do not collect',
      'No analytics, advertising IDs, location, contacts or photos. We do not sell or share your data for advertising.'
    ),
    (
      'Third parties',
      'LifeTrack uses Firebase (Google) for sign-in and data storage. Firebase\'s privacy policy applies to that processing: firebase.google.com/support/privacy'
    ),
    (
      'Deleting your data',
      'Delete birthdays inside the app at any time. To delete your whole account and its data, contact the developer.'
    ),
    (
      'Children',
      'LifeTrack is not directed at children under 13 and does not knowingly collect their information.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
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
                      'Privacy Policy',
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final s in _sections) ...[
                    Text(
                      s.$1,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: lt.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.$2,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: lt.text2,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
