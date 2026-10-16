import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/biometric_service.dart';
import '../../widgets/status_bar.dart';
import '../auth/auth_wrapper.dart';

/// Startup screen: shows the LifeTrack splash, then — if the user turned on
/// the biometric lock — requires a successful check before continuing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _needsRetry = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Short delay so the splash is visible instead of flashing by.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final locked = await BiometricService.isEnabled();
    if (!mounted) return;
    if (locked) {
      setState(() {
        _verifying = true;
        _needsRetry = false;
      });
      final ok = await BiometricService.authenticate();
      if (!mounted) return;
      if (!ok) {
        // Retry button instead of soft-locking the user out.
        setState(() {
          _verifying = false;
          _needsRetry = true;
        });
        return;
      }
    }
    _goToApp();
  }

  void _goToApp() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The splash is always light, matching the native launch screen.
    const dark = Color(0xFF18172E);
    const muted = Color(0xFF5F5D7E);
    return StatusBar(
      lightIcons: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFECE7FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/logo.png', width: 200, height: 200),
              const SizedBox(height: 16),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                AppStrings.tagline,
                style: TextStyle(fontSize: 14, color: muted),
              ),
              const SizedBox(height: 32),
              if (_needsRetry) ...[
                const Text(
                  'Authentication required',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _start,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ] else ...[
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: AppColors.primary,
                  ),
                ),
                if (_verifying) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Verifying identity...',
                    style: TextStyle(color: muted),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
