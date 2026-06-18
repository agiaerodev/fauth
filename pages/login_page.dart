import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/outline_button_provider.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/terms_and_privacy_notice.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleLogin(BuildContext context, AuthMethod type) async {
    try {
      await context.read<AuthProvider>().loginSocial(type);
    } catch (e) {
      debugPrint('Error en login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    const Color titleColor = Color(0xFF1A2B47);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const Text(
                'Sign in or sing up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 40),
              Wrap(
                runSpacing: 10,
                children: [
                  OutlineButtonProvider(
                    label: 'Continue with Google',
                    icon: FontAwesomeIcons.google,
                  ),
                  OutlineButtonProvider(
                    label: 'Continue with Microsoft',
                    icon: FontAwesomeIcons.microsoft,
                    iconColor: Color(0xFF00A4EF),
                    onPressed: isLoading
                      ? null
                      : () => _handleLogin(context, AuthMethod.microsoft),
                  ),
                  OutlineButtonProvider(
                    label: 'Continue with Apple',
                    icon: FontAwesomeIcons.apple,
                    iconColor: Color(0xFF000000),
                  ),
                ]
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFFCBD5E1),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      child: Text('or', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xFFCBD5E1),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SignInForm(),
              SizedBox(height: 40),
              TermsAndPrivacyNotice(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}