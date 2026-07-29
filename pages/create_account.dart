import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_button.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/terms_and_privacy_notice.dart';
import '../providers/auth_provider.dart';
import 'otp_page.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({ super.key });

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.sendOtp(
        _emailController.text.trim(),
        authMode: 'register',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isOtpLoading;
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
                    label: 'First Name',
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 10),
                  AuthInputField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 10),
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
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{6,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 40,),
                  AppButton(
                    label: 'Sign Up',
                    isLoading: isLoading,
                    onPressed: _onSignUp,
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


