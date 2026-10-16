import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/confirm_dialog.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/date_input_dialog.dart';
import '../../core/utils/feedback_helper.dart';
import '../../core/utils/relation_style.dart';
import '../../models/birthday_model.dart';
import '../../providers/birthday_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/emoji_avatar.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/lt_icon_button.dart';
import '../../widgets/status_bar.dart';

/// Add a birthday, or edit one when [existing] is given.
/// Pops with 'added' / 'updated' on success.
class AddEditBirthdayScreen extends StatefulWidget {
  const AddEditBirthdayScreen({super.key, required this.uid, this.existing});

  final String uid;
  final BirthdayModel? existing;

  @override
  State<AddEditBirthdayScreen> createState() => _AddEditBirthdayScreenState();
}

class _AddEditBirthdayScreenState extends State<AddEditBirthdayScreen> {
  static const String _other = 'Other';

  late final TextEditingController _name;
  late final TextEditingController _customRelation;
  late final TextEditingController _note;

  DateTime? _date;
  String? _emoji; // null = automatic (from relation)
  String _relation = ''; // one of RelationStyle.choices or ''
  bool _saving = false;
  bool _saved = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _date = e?.dob;
    _emoji = (e?.emoji ?? '').trim().isEmpty ? null : e!.emoji;

    final rel = (e?.relation ?? '').trim();
    String? match;
    for (final c in RelationStyle.choices) {
      if (c != _other && c.toLowerCase() == rel.toLowerCase()) match = c;
    }
    if (match != null) {
      _relation = match;
      _customRelation = TextEditingController();
    } else if (rel.isNotEmpty) {
      _relation = _other;
      _customRelation = TextEditingController(text: rel);
    } else {
      _customRelation = TextEditingController();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _customRelation.dispose();
    _note.dispose();
    super.dispose();
  }

  String get _relationValue =>
      _relation == _other ? _customRelation.text.trim() : _relation;

  String? get _noteValue {
    final n = _note.text.trim();
    return n.isEmpty ? null : n;
  }

  bool get _hasUnsavedChanges {
    final e = widget.existing;
    if (e == null) {
      return _name.text.trim().isNotEmpty ||
          _date != null ||
          _relation.isNotEmpty ||
          _emoji != null ||
          _note.text.trim().isNotEmpty;
    }
    final oldEmoji = (e.emoji ?? '').trim().isEmpty ? null : e.emoji;
    return _name.text.trim() != e.name ||
        _date != e.dob ||
        _relationValue != e.relation.trim() ||
        _emoji != oldEmoji ||
        _noteValue != ((e.note ?? '').trim().isEmpty ? null : e.note!.trim());
  }

  Future<void> _pickEmoji() async {
    FocusScope.of(context).unfocus();
    final result = await EmojiPickerSheet.show(
      context,
      selected: _emoji,
      autoLabel: 'Auto (based on relation)',
    );
    if (result == null || !mounted) return;
    setState(() => _emoji = result.isEmpty ? null : result);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final date = await pickDate(
      context,
      initial: _date,
      title: 'Birthday',
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    final name = _name.text.trim();
    if (name.isEmpty) {
      FeedbackHelper.error(context, AppStrings.errorEnterName);
      return;
    }
    if (_date == null) {
      FeedbackHelper.error(context, AppStrings.errorSelectDob);
      return;
    }

    final provider = context.read<BirthdayProvider>();
    final existing = widget.existing;
    final birthday = BirthdayModel(
      id: existing?.id ?? const Uuid().v4(),
      name: name,
      dob: _date!,
      relation: _relationValue,
      photoUrl: existing?.photoUrl,
      emoji: _emoji,
      note: _noteValue,
    );

    setState(() => _saving = true);
    try {
      await provider.save(birthday, isNew: !_isEditing);
      if (!mounted) return;
      _saved = true;
      Navigator.pop(context, _isEditing ? 'updated' : 'added');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      FeedbackHelper.error(context, 'Could not save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    final topPad = MediaQuery.of(context).padding.top;
    final previewEmoji = _emoji ??
        RelationStyle.of(_relationValue).emoji;
    final style = RelationStyle.of(_relationValue);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_saved || !_hasUnsavedChanges) {
          Navigator.pop(context);
          return;
        }
        final discard = await ConfirmDialog.show(
          context,
          title: 'Discard changes?',
          message: 'You have unsaved changes. Leave anyway?',
          confirmLabel: 'Discard',
          isDestructive: true,
        );
        if (discard && context.mounted) Navigator.pop(context);
      },
      child: StatusBar(
        lightIcons: true,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            backgroundColor: lt.bg,
            body: ListView(
              padding: EdgeInsets.zero,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
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
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          Expanded(
                            child: Text(
                              _isEditing ? 'Edit Birthday' : 'Add Birthday',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                        onTap: _pickEmoji,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            EmojiAvatar(
                              emoji: previewEmoji,
                              colors: style.gradient,
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.18),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    size: 16, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to change avatar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
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
                        hintText: 'e.g. Ali Khan',
                        prefixIcon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 40,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      _label(lt, 'Date of birth'),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _pickDate,
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
                                  _date == null
                                      ? 'Select date'
                                      : DateHelper.formatLong(_date!),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _date == null
                                        ? lt.text3
                                        : lt.text,
                                  ),
                                ),
                              ),
                              Icon(Icons.calendar_month_rounded,
                                  size: 20, color: lt.text3),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _label(lt, 'Relation'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in RelationStyle.choices)
                            _chip(lt, c),
                        ],
                      ),
                      if (_relation == _other) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _customRelation,
                          hintText: 'e.g. Cousin, Colleague',
                          prefixIcon: Icons.people_rounded,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 24,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _note,
                        label: 'Note (optional)',
                        hintText: 'Gift ideas, favourite cake…',
                        prefixIcon: Icons.edit_note_rounded,
                        maxLines: 3,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 26),
                      CustomButton(
                        label:
                            _isEditing ? 'Save Changes' : 'Save Birthday',
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
      ),
    );
  }

  Widget _label(LTColors lt, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: lt.text3,
        ),
      ),
    );
  }

  Widget _chip(LTColors lt, String label) {
    final selected = _relation == label;
    final emoji = RelationStyle.of(label).emoji;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _relation = selected ? '' : label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : lt.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : lt.border,
            width: 1.5,
          ),
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : lt.text2,
          ),
        ),
      ),
    );
  }
}
