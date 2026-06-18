import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/terms_and_privacy_notice.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({ super.key });

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  const SizedBox(height: 40,),
                  AuthInputField(
                    label: 'Email', 
                    controller: _emailController, 
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 10),
                  AuthInputField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 10),
                  AuthInputField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 40,),
                  AppButton(
                    label: 'Sign Up',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Sign up logic
                      }
                    },
                    variant: AppButtonVariant.gradient,
                  ),
                  const SizedBox(height: 12,),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle(fontSize: 16),),
                        SizedBox(width: 5,),
                        Text('Sign in', style: TextStyle(color: Colors.blue, fontSize: 16),)
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const TermsAndPrivacyNotice(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
