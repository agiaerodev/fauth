import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class AppleAuthService {
  static final AppleAuthService instance = AppleAuthService._internal();
  AppleAuthService._internal();

  static const FlutterAppAuth _appAuth = FlutterAppAuth();

  Future<dynamic> login() async {
    final String? appleClientId = dotenv.env['APPLE_CLIENT_ID'];
    final String? appleRedirectUri = dotenv.env['APPLE_REDIRECT_URI'];

    if (appleClientId == null || appleRedirectUri == null) {
      throw Exception('Apple configuration missing in .env');
    }

    // Apple requiere un nonce para validar la identidad
    final rawNonce = const Uuid().v4();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          appleClientId,
          appleRedirectUri,
          issuer: 'https://appleid.apple.com',
          scopes: ['openid'], // Eliminamos email y name
          nonce: nonce,
          // Eliminamos additionalParameters que forzaban form_post
        ),
      );

      if (result == null) {
        throw Exception('Apple login failed: result is null');
      }

      final String? token = result.idToken ?? result.accessToken;

      if (token == null) {
        throw Exception('No identity token received from Apple');
      }

      final response = await AuthService().loginSocial(
        type: 'apple',
        token: token,
        socialData: {
          'idToken': result.idToken,
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
          'rawNonce': rawNonce, // Algunos backends necesitan el nonce original
        },
      );
      return response;
    } catch (e) {
      throw Exception('Apple login error: ${e.toString()}');
    }
  }
}
