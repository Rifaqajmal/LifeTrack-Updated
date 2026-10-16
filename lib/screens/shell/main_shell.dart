import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/navigation_helper.dart';
import '../../providers/birthday_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/lt_tab_bar.dart';
import '../birthday/birthday_list_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';

/// The signed-in app: four tabs plus the centre "add" button.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.uid});

  final String uid;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  late final BirthdayProvider _birthdays;
  late final ProfileProvider _profile;
  late final SettingsProvider _settings;

  int _index = 0;
  Timer? _syncTimer;
  String? _lastSignature;

  @override
  void initState() {
    super.initState();
    _birthdays = context.read<BirthdayProvider>();
    _profile = context.read<ProfileProvider>();
    _settings = context.read<SettingsProvider>();

    WidgetsBinding.instance.addObserver(this);
    _birthdays.addListener(_scheduleSync);
    _profile.addListener(_scheduleSync);
    _settings.addListener(_scheduleSync);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _birthdays.start(widget.uid);
      _profile.load(widget.uid);
      NotificationService.requestPermission()
          .then((_) => _settings.refreshNotificationStatus());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    _birthdays.removeListener(_scheduleSync);
    _profile.removeListener(_scheduleSync);
    _settings.removeListener(_scheduleSync);
    // Signed out (or switched account): drop this user's data silently.
    _birthdays.stop();
    _profile.reset();
    NotificationService.cancelAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check the OS permission after the user returns from phone settings,
    // and re-plan reminders so they always look ahead from "now".
    if (state == AppLifecycleState.resumed) {
      _settings.refreshNotificationStatus();
      _lastSignature = null;
      _scheduleSync();
    }
  }

  /// Re-plans reminders shortly after anything relevant changes.
  void _scheduleSync() {
    if (_birthdays.loading && _birthdays.count == 0) return;
    if (!_profile.loaded) return;
    final signature = [
      for (final b in _birthdays.birthdays)
        '${b.id}|${b.name}|${b.dob.toIso8601String()}',
      _profile.dob?.toIso8601String() ?? '-',
      _settings.remindersEnabled,
      _settings.milestonesEnabled,
    ].join(';');
    if (signature == _lastSignature) return;

    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 1), () async {
      _lastSignature = signature;
      try {
        await NotificationService.sync(
          birthdays: _birthdays.birthdays,
          ownDob: _profile.dob,
          reminders: _settings.remindersEnabled,
          milestones: _settings.milestonesEnabled,
        );
      } catch (_) {
        _lastSignature = null;
      }
    });
  }

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(uid: widget.uid, onSelectTab: _select),
            const BirthdayListScreen(),
            const StatsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: LTTabBar(
          index: _index,
          onSelect: _select,
          onAdd: () => Nav.openAdd(context, widget.uid),
        ),
      ),
    );
  }
}
