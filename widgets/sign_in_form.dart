import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';
import '../pages/account_recovery.dart';
import '../pages/create_account.dart';
import '../pages/otp_page.dart';
import 'package:go_router/go_router.dart';
import '../routes/auth_route_names.dart';
import './auth_input_field.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({ super.key });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            },
          ),
          const SizedBox(height: 12),
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
            },
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'Sign In',
            isLoading: context.watch<AuthProvider>().isMethodLoading(AuthMethod.email),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                try {
                  // El método login ahora valida credenciales y envía el OTP
                  await authProvider.login(_emailController, _passwordController);
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OtpPage()),
                    );
                  }
                } catch (e) {
                  // Error manejado en el provider
                }
              }
            },
            variant: AppButtonVariant.gradient,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountRecovery()));
            },
            child: const Text(
              'I´ve forgotten my password',
              style: TextStyle(
                color: Colors.blue
              )
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccount()));
            },
            child: const Row(
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
