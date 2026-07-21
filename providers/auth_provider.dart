import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/microsoft_auth_service.dart';
import '../services/google_auth_services.dart';
import '../services/apple_auth_services.dart';
import '../../../core/http/api_client.dart';
import '../../../core/utils/avatar_url_helper.dart';
import '../../../core/utils/helpers.dart';
import '../services/auth_service.dart';
import '../../../core/services/preferences_service.dart';

enum AuthMethod { microsoft, google, apple, email }

class AuthProvider extends ChangeNotifier {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  dynamic _user;
  bool _isLoading = false;
  final Map<AuthMethod, bool> _loadingMethods = {};
  bool _isInitialLoading = true;
  bool _hasSeenWelcome = false;
  Timer? _statusCheckTimer;
  int _resendSeconds = 120;
  Timer? _resendTimer;
  bool _isOtpLoading = false;
  String? _otpEmail;

  dynamic get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool isMethodLoading(AuthMethod method) => _loadingMethods[method] ?? false;
  bool get isInitialLoading => _isInitialLoading;
  bool get hasSeenWelcome => _hasSeenWelcome;
  int get resendSeconds => _resendSeconds;
  bool get isOtpLoading => _isOtpLoading;
  String? get otpEmail => _otpEmail;
  bool get canResend => _resendSeconds == 0;

  final String appMode;
  final String permissionApp;
  final Future<Map<String, dynamic>?> Function(int userId, dynamic userData)? verifyUserStatusFn;

  AuthProvider({
    required this.appMode,
    required this.permissionApp,
    this.verifyUserStatusFn,
  }) {
    _initializeAuth();
  }

  String get userProfileImage {
    String nameForAvatar = "User";
    if (_user != null) {
      if (_user is Map) {
        nameForAvatar = _user['fullName'] ?? _user['name'] ?? "User";
      }
    }
    final String initialsUrl = resolveAvatarUrl(displayName: nameForAvatar);
    if (_user == null) return initialsUrl;

    if (_user is Map) {
      final backendPhoto = _user['mainimageUrl'] ?? _user['avatar'];
      if (backendPhoto != null && backendPhoto.toString().startsWith('http')) {
        return backendPhoto.toString();
      }
    }
    return initialsUrl;
  }

  Future<void> login(TextEditingController email, TextEditingController password) async {
    _isLoading = true;
    _loadingMethods[AuthMethod.email] = true;
    notifyListeners();
    try {
      final response = await AuthService().login(
        username: email.text.trim(),
        password: password.text.trim(),
      );
      await handleBackendResponse(response);
      if (_user != null) {
        showNativeSnackBar("Welcome back!", Colors.green);
      }
    } catch (e, stack) {
      _user = null;
      _logger.f("Login failed", error: e, stackTrace: stack);

      String errorMessage = "Login Failed";
      if (e.toString().contains("401")) {
        errorMessage = "Invalid email or password";
      } else if (e.toString().contains("timeout")) {
        errorMessage = "Login timeout - Please try again";
      } else {
        errorMessage = e.toString().replaceAll("Exception:", "").trim();
      }

      showNativeSnackBar(errorMessage, Colors.redAccent);
      rethrow;
    } finally {
      _isLoading = false;
      _loadingMethods[AuthMethod.email] = false;
      notifyListeners();
    }
  }

  Future<void> _initializeAuth() async {
    // Temporizador de seguridad: si tarda más de 5 segundos, liberamos la pantalla
    Future.delayed(const Duration(seconds: 5), () {
      if (_isInitialLoading) {
        _logger.w("La inicialización está tardando demasiado. Forzando finalización de carga.");
        _isInitialLoading = false;
        notifyListeners();
      }
    });

    try {
      _hasSeenWelcome = await PreferencesService().hasSeenWelcome();
      
      ApiClient().onUnauthorized = () async {
        _logger.w("Unauthorized. Please sign in again...");
        showNativeSnackBar(
          "Unauthorized. Please sign in again.",
          Colors.redAccent,
        );
        await logout();
      };

      await initializeAuthenticatedUser();
    } catch (e) {
      _logger.e("Error en carga inicial: $e");
    } finally {
      if (_isInitialLoading) {
        _isInitialLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loginSocial(AuthMethod type) async {
    _isLoading = true;
    _loadingMethods[type] = true;
    notifyListeners();
    try {
      dynamic response;
      switch (type) {
        case AuthMethod.microsoft:
          response = await MicrosoftAuthService.instance.login();
          break;
        case AuthMethod.google:
          response = await GoogleAuthService.instance.login();
          break;
        case AuthMethod.apple:
          response = await AppleAuthService.instance.login();
          break;
        default:
          showNativeSnackBar(
            "Authentication method not available",
            Colors.orange,
          );
          break;
      }
      await handleBackendResponse(response);
      if (_user != null) {
        showNativeSnackBar("Welcome back!", Colors.green);
      }
    } catch (e, stack) {
      _user = null;
      _logger.f("Social login failed", error: e, stackTrace: stack);
      
      // Mejora de mensajes de error específicos
      String errorMessage = "Social Login Failed";
      if (e.toString().contains("localhost")) {
        errorMessage = "OAuth configuration error - Please verify redirect URI settings";
      } else if (e.toString().contains("timeout")) {
        errorMessage = "Login timeout - Please try again";
      } else if (e.toString().contains("cancelled")) {
        errorMessage = "Login was cancelled";
      } else if (e.toString().contains("access token")) {
        errorMessage = "Failed to obtain access token - Check your credentials";
      }
      
      showNativeSnackBar(errorMessage, Colors.redAccent);
      rethrow;
    } finally {
      _isLoading = false;
      _loadingMethods[type] = false;
      notifyListeners();
    }
  }

  Future<void> handleBackendResponse(dynamic response) async {
    try {
      // confirm-pin puede devolver el payload en `data` o en la raiz.
      final data = response['data'] is Map ? response['data'] : response;
      final String? token = data?['userToken'];
      final String? expiresIso = data?['expiresIn'];
      final dynamic userData = data?['userData'];
      if (token == null || token.isEmpty || expiresIso == null) {
        _logger.e("Error cargando datos del backend 163: $token");
        await logout();
        return;
      }

      final expirationDate = DateTime.parse(expiresIso).toUtc();
      final now = DateTime.now().toUtc().add(const Duration(seconds: 30));

      if (expirationDate.isBefore(now)) {
        _logger.e("Error cargando datos del backend 172: $expirationDate");
        await logout();
        throw Exception('Token expired');
      }

      if (!hasAccess(permissionApp, userData)) {
        showNativeSnackBar(
          "Access denied: $appMode access not permitted",
          Colors.redAccent,
        );
        _logger.e(
          "Error: Usuario sin permiso profile.access.agent-app para userId: ${userData?['id']}",
        );
        await logout();
        return;
      }

      if (userData != null) {
        ApiClient().setHandlingUnauthorized(false);
        await ApiClient().saveToken(token, expirationDate);
        await _validateAndSetUser(userData['id'], userData);
        _startStatusCheck();
        return;
      }
      return;
    } catch (e) {
      showNativeSnackBar("Error processing server response", Colors.redAccent);
      _logger.f("Error processing server response", error: e);
      await logout();
    }
  }

  Future<void> _validateAndSetUser(int userId, dynamic userData) async {
    if (verifyUserStatusFn != null) {
      final validatedUser = await verifyUserStatusFn!(userId, userData);
      if (validatedUser != null && hasAccess(permissionApp, userData)) {
        _user = validatedUser;
      } else {
        await logout();
      }
    } else {
      _user = userData;
    }
    notifyListeners();
  }

  void _startStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_user != null && _user is Map) {
        final userId = _user['id'];
        if (userId != null) {
          unawaited(initializeAuthenticatedUser());
        }
      }
    });
  }

  void _stopStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  Future<void> logout() async {
    try {
      _stopStatusCheck();
      await AuthService().logout();
      await ApiClient().deleteTokens();
      _user = null;
    } catch (e) {
      _logger.e("Error during logout", error: e);
    } finally {
      notifyListeners();
    }
  }

  bool hasAccess(String? can, [Map<String, dynamic>? user]) {
    if (can == null) return true;

    final targetUser = user ?? _user;

    if (targetUser == null) return false;

    final permissions = Map<String, dynamic>.from(
      targetUser['allPermissions'] ?? {},
    );

    return permissions[can] == true;
  }

  Future<void> markWelcomeSeen() async {
    await PreferencesService().markWelcomeSeen();
    _hasSeenWelcome = true;
    notifyListeners();
  }

  Future<void> initializeAuthenticatedUser() async {
    final token = await ApiClient().getToken();

    if (token == null || token.isEmpty) return;

    try {
      final response = await AuthService().me();
      _logger.i('api me $response');

      final userData = response['data']?['userData'];

      if (userData == null) {
        await logout();
        return;
      }

      if (!hasAccess(permissionApp, userData)) {
        showNativeSnackBar(
          "Access denied: agent-app access not permitted",
          Colors.redAccent,
        );

        _logger.e(
          "Error: Usuario sin permiso profile.access.agent-app para userId: ${userData['id']}",
        );

        await logout();
        return;
      }

      await _validateAndSetUser(userData['id'], userData);
      _startStatusCheck();
    } catch (e, stackTrace) {
      _logger.e(
        "Error validating session and access",
        error: e,
        stackTrace: stackTrace,
      );

      await logout();
    }
  }

  Future<void> sendOtp(
    String email, {
    String? authMode,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    _isOtpLoading = true;
    _otpEmail = email;
    notifyListeners();
    try {
      final response = await AuthService().sendPin(
        username: email,
        authMode: authMode,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      final data = response is Map && response['data'] is Map
          ? response['data']
          : response;

      final bool isSuccess = data?['is_success'] == true;
      final bool otpSent = data?['otp_sent'] == true;
      final String message = (data?['message'] as String?) ??
          (isSuccess ? "OTP sent successfully" : "Failed to send OTP");

      if (isSuccess && otpSent) {
        startResendTimer();
        showNativeSnackBar(message, Colors.green);
      } else {
        final int? retryAfter = data?['retry_after_seconds'] as int?;
        if (retryAfter != null && retryAfter > 0) {
          _resendSeconds = retryAfter;
          _resendTimer?.cancel();
          _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_resendSeconds > 0) {
              _resendSeconds--;
              notifyListeners();
            } else {
              _resendTimer?.cancel();
            }
          });
        }
        showNativeSnackBar(message, Colors.redAccent);
      }
    } catch (e) {
      _logger.e("Error sending OTP: $e");
      showNativeSnackBar(_extractErrorMessage(e), Colors.redAccent);
      rethrow;
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String pin) async {
    if (_otpEmail == null || _isOtpLoading || pin.length != 6) return;
    _isOtpLoading = true;
    notifyListeners();
    try {
      final response = await AuthService().confirmPin(
        username: _otpEmail!,
        pin: pin,
      );

      final data = response['data'] is Map ? response['data'] : response;

      if (data?['userToken'] != null && data?['expiresIn'] != null && data?['userData'] != null) {
        await handleBackendResponse(response);
      }
      showNativeSnackBar(
        data?['message'] ?? response['message'] ?? "OTP expired.",
        Colors.redAccent,
      );
    } catch (e) {
      _logger.e("Error verifying OTP: $e");
      showNativeSnackBar(_extractErrorMessage(e), Colors.redAccent);
      return;
    } finally {
      _isOtpLoading = false;
      notifyListeners();
    }
  }

  /// Extrae un mensaje legible desde una excepción lanzada por la capa de red.
  /// Los errores HTTP (4xx/5xx) llegan como `Exception('HTTP $status - $errorMsg')`,
  /// por lo que removemos ese prefijo para mostrar solo el mensaje real del backend.
  String _extractErrorMessage(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    final match = RegExp(r'^HTTP \d+ - (.*)$').firstMatch(raw);
    if (match != null) {
      return match.group(1) ?? raw;
    }
    return raw;
  }

  void startResendTimer() {
    _resendSeconds = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        _resendSeconds--;
        notifyListeners();
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _stopStatusCheck();
    _resendTimer?.cancel();
    super.dispose();
  }
}
