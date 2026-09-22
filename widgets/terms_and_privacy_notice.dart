import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPrivacyNotice extends StatelessWidget {
  const TermsAndPrivacyNotice({ super.key });

  static const String _accountDeletionPath = '/auth/account-deletion';

  @override
  Widget build(BuildContext context) {
    const Color linkColor = Color(0xFF29ABE2);

    return Column(
      children: [
        const Text(
          'By continuing you agree to our',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Terms of Service', linkColor),
            const Text(' and ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            _footerLink('Privacy Policy', linkColor),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String text, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _openAccountDeletionPage() async {
    final baseRoute = dotenv.env['API_ROUTE'] ?? '';
    final baseUri = Uri.tryParse(baseRoute);
    if (baseUri == null || !baseUri.hasScheme) {
      throw StateError('API_ROUTE is not a valid URL');
    }

    final uri = baseUri.replace(
      path: _normalizedBasePath(baseUri.path),
      fragment: _normalizedFragment(_accountDeletionPath),
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError('Could not launch account deletion URL');
    }
  }

  String _normalizedBasePath(String basePath) {
    if (basePath.isEmpty || basePath == '/') {
      return '/';
    }

    return basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
  }

  String _normalizedFragment(String routePath) {
    return routePath.startsWith('/') ? routePath : '/$routePath';
  }
}