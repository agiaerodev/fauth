import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/widgets/app_web_view/app_web_view_screen.dart';
import '/core/widgets/app_snack_bar.dart';

/// Opens the web change password flow inside an in-app web view.
abstract final class ChangePasswordFlow {
  static const String _accountRecoveryPath = '/auth/account-recovery';
  static const String _loginRedirectUrl = 'abconcierges://login';

  /// Completes with `true` when the web flow redirects back to the app, or
  /// `null` if the user closed it or the page could not be opened.
  static Future<bool?> open(BuildContext context) async {
    final uri = _buildUri();
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const AppSnackBar(content: Text('Unable to open change password page')),
      );
      return null;
    }

    return AppWebViewScreen.navigateTo(
      context,
      url: uri.toString(),
      title: 'Change Password',
      redirectUrls: const [_loginRedirectUrl],
    );
  }

  static Uri? _buildUri() {
    final baseUri = Uri.tryParse(dotenv.env['API_ROUTE'] ?? '');
    if (baseUri == null || !baseUri.hasScheme) return null;

    final device = Platform.isIOS ? 'apple' : 'android';
    return baseUri.replace(
      path: '${baseUri.path}/',
      fragment: '$_accountRecoveryPath?device=$device',
    );
  }
}
