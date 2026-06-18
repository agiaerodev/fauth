import 'package:flutter/material.dart';

class TermsAndPrivacyNotice extends StatelessWidget {
  const TermsAndPrivacyNotice({ super.key });

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

  Widget _footerLink(String text, Color color) {
    return InkWell(
      onTap: () {
      },
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
}