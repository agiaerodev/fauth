import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';
import '../pages/otp_page.dart';
import '../pages/create_account.dart';
import './auth_input_field.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SendCodeForm extends StatefulWidget {
  const SendCodeForm({super.key});

  @override
  State<SendCodeForm> createState() => _SendCodeFormState();
}

class _SendCodeFormState extends State<SendCodeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
              final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Send Code',
            isLoading: context.watch<AuthProvider>().isOtpLoading,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                try {
                  await authProvider.sendOtp(
                    _emailController.text.trim(),
                    authMode: 'login',
                  );
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OtpPage()),
                    );
                  }
                } catch (e) {
                  // Error handled in provider
                }
              }
            },
            variant: AppButtonVariant.gradient,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateAccount()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don’t have an account?', style: TextStyle(fontSize: 16)),
                SizedBox(width: 5),
                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, color: Color(0xff2292c7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


