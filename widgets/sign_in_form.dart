import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';
import '../screens/account_recovery.dart';
import '../screens/create_account.dart';
import './auth_input_field.dart';
import '/modules/home/presentation/screen/home_screen.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({ super.key });

  @override
  Widget build(BuildContext context) {
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();

    return Form(
      child: Column(
        children: [
          AuthInputField(
            label: 'Email',
            controller: email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthInputField(
            label: 'Password',
            controller: password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 40),
          AppButton(
            label: 'Sign In',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            variant: AppButtonVariant.gradient,
          ),
          SizedBox(height: 12,),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountRecovery()));
            },
            child: Text(
              'I´ve forgotten my password',
              style: TextStyle(
                color: Colors.blue
              )
            ),
          ),
          SizedBox(height: 40,),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don’t have an account?', style: TextStyle(fontSize: 16),),
                SizedBox(width: 5,),
                Text('Sign Up', style: TextStyle(fontSize: 16, color: Color(0xff2292c7)),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}