import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/date_input_dialog.dart';
import '../../core/utils/feedback_helper.dart';
import '../../providers/profile_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/status_bar.dart';

/// Edit your name, date of birth and avatar. Email is read-only.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  DateTime? _dob;
  String? _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    final profile = context.read<ProfileProvider>();
    _name = TextEditingController(text: user.displayName);
    _dob = profile.dob;
    _avatar = profile.avatarEmoji;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    FocusScope.of(context).unfocus();
    final result = await EmojiPickerSheet.show(
      context,
      selected: _avatar,
      autoLabel: 'Use default 🎂',
    );
    if (result == null || !mounted) return;
    setState(() => _avatar = result.isEmpty ? null : result);
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final date = await pickDate(
      context,
      initial: _dob,
      title: 'Date of birth',
    );
    if (date != null && mounted) setState(() => _dob = date);
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    final name = _name.text.trim();
    if (name.isEmpty) {
      FeedbackHelper.error(context, 'Please enter your name');
      return;
    }
    final user = context.read<UserProvider>();
    final profile = context.read<ProfileProvider>();

    setState(() => _saving = true);
    try {
      await profile.setDob(_dob);
      await profile.setAvatar(_avatar);
      if (name != user.displayName) {
        await AuthService().updateDisplayName(name);
        user.refresh();
      }
      if (!mounted) return;
      Navigator.pop(context);
      FeedbackHelper.success(context, 'Profile updated ✓');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      FeedbackHelper.error(
          context, "Couldn't update your name. Check your connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final user = context.watch<UserProvider>();
    final topPad = MediaQuery.of(context).padding.top;

    return StatusBar(
      lightIcons: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: lt.bg,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 26),
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        LTIconButton(
                          icon: Icons.arrow_back_rounded,
                          glass: true,
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Edit Profile',
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
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          EmojiAvatar(
                            emoji: _avatar ?? '🎂',
                            colors: const [
                              AppColors.primary2,
                              AppColors.pinkSoft,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _name,
                      label: 'Full name',
                      hintText: 'Your name',
                      prefixIcon: Icons.person_rounded,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 40,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'DATE OF BIRTH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: lt.text3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickDob,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: lt.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: lt.border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cake_rounded,
                                size: 20, color: lt.text3),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dob == null
                                    ? 'Select date'
                                    : DateHelper.formatLong(_dob!),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _dob == null ? lt.text3 : lt.text,
                                ),
                              ),
                            ),
                            if (_dob != null)
                              GestureDetector(
                                onTap: () => setState(() => _dob = null),
                                child: Icon(Icons.close_rounded,
                                    size: 20, color: lt.text3),
                              )
                            else
                              Icon(Icons.calendar_month_rounded,
                                  size: 20, color: lt.text3),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Stored only on this device. Used for your live age.',
                      style: TextStyle(fontSize: 12, color: lt.text3),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'EMAIL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: lt.text3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: lt.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: lt.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mail_rounded, size: 20, color: lt.text3),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: lt.text2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: lt.tint(user.emailVerified
                                  ? AppColors.green
                                  : AppColors.amber),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              user.emailVerified ? 'Verified' : 'Unverified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: user.emailVerified
                                    ? AppColors.green
                                    : AppColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: 'Save Changes',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
