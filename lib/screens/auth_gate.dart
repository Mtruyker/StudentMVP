import 'package:flutter/material.dart';
import 'package:studentlk/models/user.dart';
import 'package:studentlk/screens/admin/admin_shell.dart';
import 'package:studentlk/screens/login_screen.dart';
import 'package:studentlk/screens/student/student_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppUser? _currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return LoginScreen(
        onLogin: (user) => setState(() => _currentUser = user),
      );
    }

    if (user.role == UserRole.admin) {
      return AdminShell(
        user: user,
        onLogout: () => setState(() => _currentUser = null),
      );
    }

    return StudentShell(
      user: user,
      onLogout: () => setState(() => _currentUser = null),
    );
  }
}
