import 'package:flutter/material.dart';

import '../widgets/register_info_modal.dart';

class OtpRegistrationFlow {
  static Future<bool> open(
    BuildContext context, {
    required String email,
  }) async {
    final shouldRegister = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account not found'),
        content: const Text(
          'No account was found for this email address. '
          'Would you like to register in the app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );

    if (shouldRegister != true || !context.mounted) return false;

    return await RegisterInfoModal.show(context, email: email) == true;
  }
}
