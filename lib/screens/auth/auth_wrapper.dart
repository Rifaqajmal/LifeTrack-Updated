import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/loading_widget.dart';
import '../shell/main_shell.dart';
import 'login_screen.dart';

/// Shows the app when signed in, the login screen otherwise.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingWidget());
        }
        final user = snapshot.data;
        if (user != null) {
          // The key makes a different account get a completely fresh shell.
          return MainShell(key: ValueKey(user.uid), uid: user.uid);
        }
        return const LoginScreen();
      },
    );
  }
}
