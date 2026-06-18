import 'package:flutter/material.dart';
import '/core/widgets/navigation_app_bar.dart';
import '/core/widgets/app_button.dart';
import '../widgets/auth_input_field.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({ super.key });

  @override
  State<AccountRecovery> createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavigationAppBar(
        title: 'Forgot password',
        backgroundColor: Colors.transparent
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text('Find your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
                const Text('Enter your email or username. We\'ll send you a link to reset your password.'),
                const SizedBox(height: 31,),
                AuthInputField(
                  label: 'Email or username', 
                  controller: _emailController, 
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    // Contact support logic
                  },
                  child: const Text('Need help? Contact support', style: TextStyle(color: Color(0xff2292c7)),),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Send email',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Send recovery email logic
                    }
                  },
                  variant: AppButtonVariant.gradient,
                )
              ]
            ),
          ),
        ),
      )
    );
  }
}
