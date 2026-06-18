import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleLogin(BuildContext context, AuthMethod type) async {
    try {
      await context.read<AuthProvider>().loginSocial(type);
    } catch (e) {
      debugPrint('Error en login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    const Color titleColor = Color(0xFF1A2B47);
    const Color buttonTextColor = Color(0xFF64748B);
    const Color borderColor = Color(0xFFE2E8F0);
    const Color linkColor = Color(0xFF29ABE2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const Text(
                'Sign in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 48),

              // --- BOTÓN CON LOGICA Y ICONO ---
              OutlinedButton(
                // Deshabilitamos el botón si está cargando
                onPressed: isLoading
                    ? null
                    : () => _handleLogin(context, AuthMethod.microsoft),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: borderColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: buttonTextColor,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.microsoft,
                      color: Color(0xFF00A4EF),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continue with Microsoft',
                      style: TextStyle(
                        color: buttonTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Footer
              Column(
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
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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