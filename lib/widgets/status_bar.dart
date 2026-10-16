import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sets the status-bar icon colour for a screen.
/// [lightIcons] = white icons (use over dark/gradient headers).
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.lightIcons, required this.child});

  final bool lightIcons;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            lightIcons ? Brightness.light : Brightness.dark,
        statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      ),
      child: child,
    );
  }
}
