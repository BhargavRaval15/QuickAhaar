import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/providers/auth_provider.dart';
import 'package:quick_ahaar/screens/login_screen.dart';
import 'package:quick_ahaar/screens/main_screen.dart';
import 'package:quick_ahaar/screens/verification_screen.dart';
import 'package:quick_ahaar/theme/app_theme.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(authProvider),
        );
      },
    );
  }

  Widget _buildScreen(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (!authProvider.isEmailVerified) {
      return VerificationScreen(
        email: authProvider.user?.email ?? '',
        onResendVerification: () => authProvider.resendEmailVerification(),
      );
    }

    return const MainScreen();
  }
} 