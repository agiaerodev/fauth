import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/firebase_messaging_helper.dart';
import 'auth_service.dart';

/// Servicio de autenticación con Apple usando el SDK **nativo**
/// (`ASAuthorizationController` en iOS). A diferencia del flujo web OAuth
/// (flutter_appauth), este no depende de un `redirect_uri` http(s), por lo que
/// no sufre el problema de `ASWebAuthenticationSession` que nunca retorna el
/// control a la app (Apple exige que el `callbackURLScheme` NO sea http/https,
/// pero nuestro backend solo puede registrar un `redirect_uri` https ante
/// Apple). El resultado (identityToken) se envía igual al backend mediante
/// `AuthService().loginSocial(type: 'apple', ...)`.
class AppleAuthService {
  static final AppleAuthService instance = AppleAuthService._internal();
  AppleAuthService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  String _mapAppleAuthError(Object error) {
    if (error is SignInWithAppleAuthorizationException) {
      switch (error.code) {
        case AuthorizationErrorCode.canceled:
          return 'Login was cancelled';
        case AuthorizationErrorCode.failed:
          return 'Apple authorization failed: ${error.message}';
        case AuthorizationErrorCode.invalidResponse:
          return 'Apple returned an invalid response: ${error.message}';
        case AuthorizationErrorCode.notHandled:
          return 'Apple authorization was not handled: ${error.message}';
        case AuthorizationErrorCode.notInteractive:
          return 'Apple authorization requires user interaction';
        case AuthorizationErrorCode.credentialExport:
          return 'Apple credential export failed: ${error.message}';
        case AuthorizationErrorCode.credentialImport:
          return 'Apple credential import failed: ${error.message}';
        case AuthorizationErrorCode.matchedExcludedCredential:
          return 'Apple credential matched an excluded credential: ${error.message}';
        case AuthorizationErrorCode.unknown:
          return 'Unknown Apple authorization error: ${error.message}';
      }
    }
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Future<dynamic> login() async {
    // Apple requiere un nonce para validar la identidad del `identityToken`.
    final rawNonce = const Uuid().v4();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception(
          'Sign in with Apple is not available on this device/OS version',
        );
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final String? identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('No identity token received from Apple');
      }

      // Apple solo envía el nombre (y a veces el email) la PRIMERA vez que el
      // usuario autoriza esta app. No viene en identityToken en logins
      // posteriores.
      final appleUser = <String, dynamic>{
        if (credential.email != null) 'email': credential.email,
        if (credential.givenName != null || credential.familyName != null)
          'name': {
            if (credential.givenName != null) 'firstName': credential.givenName,
            if (credential.familyName != null) 'lastName': credential.familyName,
          },
      };

      final firebaseToken = await FirebaseMessagingHelper.getTokenSafely();
      final response = await AuthService().loginSocial(
        type: 'apple',
        token: identityToken,
        firebaseToken: firebaseToken,
        socialData: {
          'idToken': identityToken,
          'authorizationCode': credential.authorizationCode,
          'rawNonce': rawNonce, // Algunos backends necesitan el nonce original
          if (appleUser.isNotEmpty) 'user': appleUser,
        },
      );
      return response;
    } catch (e, stack) {
      final message = _mapAppleAuthError(e);
      _logger.e('Apple login error', error: e, stackTrace: stack);
      Error.throwWithStackTrace(Exception(message), stack);
    }
  }
}
