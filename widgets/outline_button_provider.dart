import 'package:flutter/material.dart';
import '/core/widgets/app_button.dart';

class OutlineButtonProvider extends StatelessWidget {
  const OutlineButtonProvider({ 
    super.key, 
    required this.label,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final dynamic icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext build) {
    return AppButton(
      label: label,
      leadingIcon: icon,
      onPressed: () {},
      variant: AppButtonVariant.outlined,
      borderRadius: 12,
      borderColor: const Color(0xFFE2E8F0),
      foregroundColor: iconColor ?? const Color(0xFF64748B),
      textStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}