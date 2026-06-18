import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/terms_and_privacy_notice.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({ super.key });

  @override
  Widget build(BuildContext context) {

    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    final TextEditingController confirmPassword = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight(600)
              ),
            ),
            SizedBox(height: 40,),
            Wrap(
              runSpacing: 10,
              children: [
                AuthInputField(
                  label: 'Email', 
                  controller: email, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }

                    return null;
                  }
                ),
                AuthInputField(
                  label: 'Password',
                  controller:password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    return null;
                  }
                ),
                AuthInputField(
                  label: 'Confirm Password',
                  controller: confirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your confirm password';
                    }

                    return null;
                  }
                ),
              ],  
            ),
            SizedBox(height: 40,),
            AppButton(
              label: 'Sign Up',
              variant: AppButtonVariant.gradient,
            ),
            SizedBox(height: 12,),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: TextStyle(fontSize: 16),),
                  SizedBox(width: 5,),
                  Text('Sign in', style: TextStyle(color: Colors.blue, fontSize: 16),)
                ],
              ),
            ),
            SizedBox(height: 40),
            TermsAndPrivacyNotice()
          ],
        ),
      )
    );
  }
}