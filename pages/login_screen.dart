import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/outline_button_provider.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/terms_and_privacy_notice.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 82, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sign in or sing up',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A2B47),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 40),
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
                  iconColor: Color(0xFF0078D4),
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
            TermsAndPrivacyNotice()
          ],
        ),
      ),
    );
  }
}