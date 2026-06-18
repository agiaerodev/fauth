import 'package:flutter/material.dart';
import 'package:project_airport_butler_passenger_app/core/widgets/navigation_app_bar.dart';
import '/core/widgets/app_button.dart';
import '../widgets/auth_input_field.dart';

class AccountRecovery extends StatelessWidget {
  const AccountRecovery({ super.key });

  @override
  Widget build(BuildContext context) {
    final TextEditingController email = TextEditingController();

    return Scaffold(
      appBar: NavigationAppBar(
        title: 'Forgot pasword',
        backgroundColor: Colors.transparent
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            Text('Find your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight(600)),),
            Text('Enter your email or username. We-ll send you a link to reset your password.'),
            SizedBox(height: 31,),
            AuthInputField(
              label: 'Email or username', 
              controller: email, 
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }

                return null;
              }
            ),
            SizedBox(height: 14),
            GestureDetector(
              child: Text('Need help? Contact support', style: TextStyle(color: Color(0xff2292c7)),),
            ),
            SizedBox(height: 32),
            AppButton(
              label: 'Send email',
              variant: AppButtonVariant.gradient,
            )
          ]
        ),
      )
    );
  }
}