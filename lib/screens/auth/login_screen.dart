import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/feedback_helper.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/status_bar.dart';

/// Sign in / create account (toggled with [_isLogin]).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final AuthService _auth = AuthService();

  bool _loading = false;
  bool _isLogin = true;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String email) {
    final at = email.indexOf('@');
    return at > 0 && email.indexOf('.', at) > at + 1 && !email.endsWith('.');
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_isLogin && _nameController.text.trim().isEmpty) {
      return AppStrings.errorEnterName;
    }
    if (email.isEmpty) return AppStrings.errorEnterEmail;
    if (!_looksLikeEmail(email)) return AppStrings.errorValidEmail;
    if (password.isEmpty) return AppStrings.errorEnterPassword;
    if (password.length < 6) return AppStrings.errorPasswordLength;
    return null;
  }

  /// Plain-language version of Firebase Auth errors.
  String _friendlyAuthError(Object e) {
    final m = e.toString();
    if (m.contains('invalid-credential') ||
        m.contains('wrong-password') ||
        m.contains('user-not-found')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (m.contains('invalid-email')) {
      return "That email address doesn't look right.";
    }
    if (m.contains('user-disabled')) return 'This account has been disabled.';
    if (m.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (m.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    if (m.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (m.contains('weak-password')) {
      return 'Password should be at least 6 characters.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    final error = _validate();
    if (error != null) {
      FeedbackHelper.error(context, error);
      return;
    }
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isLogin) {
        await _auth.login(email, password);
      } else {
        await _auth.signup(email, password, name: _nameController.text.trim());
      }
      // On success the auth listener swaps this screen out by itself.
    } catch (e) {
      if (mounted) FeedbackHelper.error(context, _friendlyAuthError(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _forgotPassword() async {
    final initialEmail = _emailController.text.trim();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _ResetDialog(
        initialEmail: initialEmail,
        auth: _auth,
        validate: _looksLikeEmail,
        friendly: _friendlyAuthError,
      ),
    );
    if (sent == true && mounted) {
      FeedbackHelper.success(
          context, 'Reset link sent! Check your email (and spam).');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lt = context.lt;
    return StatusBar(
      lightIcons: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 250),
                            decoration: const BoxDecoration(
                              gradient: AppColors.heroGradient,
                            ),
                            child: SafeArea(
                              bottom: false,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                        'assets/icon/logo.png'),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    AppStrings.appName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.tagline,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          decoration: BoxDecoration(
                            color: lt.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: _form(lt),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _form(LTColors lt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isLogin ? 'Welcome back' : 'Create your account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: lt.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isLogin
              ? 'Sign in to see your birthdays'
              : 'Start tracking the birthdays you love',
          style: TextStyle(fontSize: 14, color: lt.text3),
        ),
        const SizedBox(height: 22),
        if (!_isLogin) ...[
          CustomTextField(
            controller: _nameController,
            label: 'Full name',
            hintText: 'e.g. Ali Khan',
            prefixIcon: Icons.person_rounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icons.mail_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: 'Password',
          hintText: 'At least 6 characters',
          prefixIcon: Icons.lock_rounded,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          suffixIcon: IconButton(
            tooltip: _obscure ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: lt.text3,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        if (_isLogin)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          )
        else
          const SizedBox(height: 12),
        const SizedBox(height: 4),
        CustomButton(
          label: _isLogin ? 'Sign In' : 'Create Account',
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: _loading
                ? null
                : () => setState(() => _isLogin = !_isLogin),
            child: Text.rich(
              TextSpan(
                text: _isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
                style: TextStyle(color: lt.text2, fontSize: 14),
                children: [
                  TextSpan(
                    text: _isLogin ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Forgot password" dialog with inline errors.
class _ResetDialog extends StatefulWidget {
  const _ResetDialog({
    required this.initialEmail,
    required this.auth,
    required this.validate,
    required this.friendly,
  });

  final String initialEmail;
  final AuthService auth;
  final bool Function(String) validate;
  final String Function(Object) friendly;

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialEmail);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _controller.text.trim();
    if (!widget.validate(email)) {
      setState(() => _error = AppStrings.errorValidEmail);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.auth.sendPasswordResetEmail(email);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = widget.friendly(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: TextStyle(color: context.lt.text2, fontSize: 14),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _controller,
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            errorText: _error,
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Link'),
        ),
      ],
    );
  }
}
