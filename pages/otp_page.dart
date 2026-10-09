import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../routes/auth_route_names.dart';
import '../widgets/register_info_modal.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<String> _previousValues = List.filled(6, '');
  bool _hasError = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    final previous = _previousValues[index];
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 1) {
      // Strip the digit that was already in the field to get what was typed/pasted.
      String incoming = digits;
      if (previous.isNotEmpty) {
        if (digits.startsWith(previous)) {
          incoming = digits.substring(previous.length);
        } else if (digits.endsWith(previous)) {
          incoming = digits.substring(0, digits.length - previous.length);
        }
      }

      if (incoming.length <= 1) {
        _setField(index, incoming.isEmpty ? previous : incoming);
        if (index < 5) _focusNodes[index + 1].requestFocus();
      } else {
        _fillFrom(incoming.length >= 6 ? 0 : index, incoming);
      }
      setState(() {});
      return;
    }

    if (digits != value) {
      _setField(index, digits);
    }
    _previousValues[index] = digits;

    if (digits.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (digits.isEmpty && value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _setField(int index, String text) {
    _controllers[index].value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _previousValues[index] = text;
  }

  void _fillFrom(int start, String digits) {
    int i = start;
    for (final char in digits.split('')) {
      if (i > 5) break;
      _setField(i, char);
      i++;
    }
    if (i > 5) {
      _focusNodes[5].requestFocus();
      if (_pin.length == 6) FocusScope.of(context).unfocus();
    } else {
      _focusNodes[i].requestFocus();
    }
  }

  void _clearAll() {
    for (var i = 0; i < 6; i++) {
      _controllers[i].clear();
      _previousValues[i] = '';
    }
  }

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verifyOtp() async {
    try {
      if (_pin.length < 6) return;

      final authProvider = context.read<AuthProvider>();
      await authProvider.verifyOtp(_pin);
    } catch(e) {
      setState(() {
        _hasError = true;
      });
    }

  }

  Future<void> _resendCode() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.otpEmail != null) {
      await authProvider.sendOtp(authProvider.otpEmail!, authMode: 'login');
      // Clear fields and focus first field
      _clearAll();
      _focusNodes[0].requestFocus();
      setState(() {
        _hasError = false;
      });
    }
  }

  Future<void> _goToSignUp() async {
    final authProvider = context.read<AuthProvider>();
    final email = authProvider.otpEmail;
    if (email == null) return;

    final registered = await RegisterInfoModal.show(context, email: email);
    if (registered == true && mounted) {
      _clearAll();
      _focusNodes[0].requestFocus();
      setState(() {
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    const Color titleColor = Color(0xFF1A2B47);
    const Color linkBlue = Color(0xFF2255C4);
    const Color backgroundColor = Color(0xFFF9FAFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top modal dash
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: titleColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'We have sent a 6-digit code to your email address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      authProvider.otpEmail ?? 'user@example.com',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        bool isFocused = _focusNodes[index].hasFocus;
                        return Container(
                          width: 48,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _hasError 
                                ? Colors.red 
                                : (isFocused ? linkBlue : Colors.grey.withOpacity(0.2)),
                              width: isFocused ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
                              enableInteractiveSelection: true,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                              decoration: const InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) => _onOtpChanged(value, index),
                              onTap: () => setState(() {}),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_hasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Invalid code. Please try again.',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 50),
                    // Only this button rebuilds on each countdown tick.
                    ValueListenableBuilder<int>(
                      valueListenable: authProvider.resendSecondsListenable,
                      builder: (context, resendSeconds, _) {
                        final canResend = _pin.isNotEmpty || resendSeconds == 0;
                        return TextButton(
                          onPressed: canResend ? _resendCode : null,
                          child: Text(
                            canResend
                                ? 'RESEND CODE NOW'
                                : 'RESEND CODE IN ${_formatSeconds(resendSeconds)}',
                            style: TextStyle(
                              color: canResend ? linkBlue : Colors.grey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _goToSignUp,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: linkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AppButton(
                label: 'Verify',
                isLoading: authProvider.isOtpLoading,
                onPressed: _pin.length == 6 ? _verifyOtp : null,
                variant: AppButtonVariant.gradient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
