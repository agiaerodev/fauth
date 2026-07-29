import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import './auth_input_field.dart';

/// Modal "Tell us about yourself" que solicita nombre y telefono
/// para completar el registro (authMode: register) antes de enviar el PIN.
class RegisterInfoModal extends StatefulWidget {
  const RegisterInfoModal({super.key, required this.email});

  final String email;

  static Future<bool?> show(BuildContext context, {required String email}) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => RegisterInfoModal(email: email),
    );
  }

  @override
  State<RegisterInfoModal> createState() => _RegisterInfoModalState();
}

class _RegisterInfoModalState extends State<RegisterInfoModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  static const Color titleColor = Color(0xFF1A2B47);
  static const Color subtitleBlue = Color(0xFF2255C4);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.sendOtp(
        widget.email,
        authMode: 'register',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // El error ya se maneja/muestra dentro del provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isOtpLoading;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const Text(
                'Tell us about yourself',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your name and phone number to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitleBlue.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                label: 'First Name',
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthInputField(
                label: 'Last Name',
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                },
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Continue',
                isLoading: isLoading,
                onPressed: _onContinue,
                variant: AppButtonVariant.gradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

