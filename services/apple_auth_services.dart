import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class AppleAuthService {
  static final AppleAuthService instance = AppleAuthService._internal();
  AppleAuthService._internal();

  static const FlutterAppAuth _appAuth = FlutterAppAuth();

  /// Apple exige un `client_secret` (JWT firmado con ES256) en el intercambio
  /// del código de autorización. Sin él, el token endpoint de Apple responde
  /// con `invalid_client` (código 2001).
  String _generateClientSecret({
    required String teamId,
    required String clientId,
    required String keyId,
    required String privateKey,
  }) {
    final jwt = JWT(
      {
        'iss': teamId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
        'aud': 'https://appleid.apple.com',
        'sub': clientId,
      },
      header: {'alg': 'ES256', 'kid': keyId},
    );

    return jwt.sign(
      ECPrivateKey(privateKey),
      algorithm: JWTAlgorithm.ES256,
    );
  }

  Future<dynamic> login() async {
    final String? appleClientId = dotenv.env['APPLE_CLIENT_ID'];
    final String? appleRedirectUri = dotenv.env['APPLE_REDIRECT_URI'];
    final String? appleTeamId = dotenv.env['APPLE_TEAM_ID'];
    final String? appleKeyId = dotenv.env['APPLE_KEY_ID'];
    final String? applePrivateKey = dotenv.env['APPLE_PRIVATE_KEY'];

    if (appleClientId == null || appleRedirectUri == null) {
      throw Exception('Apple configuration missing in .env');
    }

    if (appleTeamId == null || appleKeyId == null || applePrivateKey == null) {
      throw Exception(
        'Apple configuration missing in .env: APPLE_TEAM_ID, APPLE_KEY_ID and APPLE_PRIVATE_KEY are required to generate the client_secret',
      );
    }

    // Apple requiere un nonce para validar la identidad
    final rawNonce = const Uuid().v4();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final clientSecret = _generateClientSecret(
      teamId: appleTeamId,
      clientId: appleClientId,
      keyId: appleKeyId,
      privateKey: applePrivateKey.replaceAll(r'\n', '\n'),
    );

    try {
      // Android construye internamente el token request con
      // createTokenExchangeRequest() y no permite inyectar additionalParameters
      // ahí dentro de authorizeAndExchangeCode. Apple requiere client_secret
      // en el body. Por eso se hace en 2 pasos: authorize -> token.
      final authorizationResponse = await _appAuth.authorize(
        AuthorizationRequest(
          appleClientId,
          appleRedirectUri,
          issuer: 'https://appleid.apple.com',
          scopes: ['openid', 'email', 'name'],
          nonce: nonce,
          responseMode: 'form_post',
        ),
      );

      final authorizationCode = authorizationResponse.authorizationCode;
      if (authorizationCode == null) {
        throw Exception('No authorization code received from Apple');
      }

      final result = await _appAuth.token(
        TokenRequest(
          appleClientId,
          appleRedirectUri,
          issuer: 'https://appleid.apple.com',
          scopes: ['openid', 'email', 'name'],
          nonce: authorizationResponse.nonce,
          authorizationCode: authorizationCode,
          codeVerifier: authorizationResponse.codeVerifier,
          additionalParameters: {'client_secret': clientSecret},
        ),
      );

      final String? token = result.idToken ?? result.accessToken;

      if (token == null) {
        throw Exception('No identity token received from Apple');
      }

      // Apple solo envía el nombre (y a veces el email) en el `user`
      // (JSON string) del response de `authorize`, y únicamente la
      // PRIMERA vez que el usuario autoriza esta app. No viene en el id_token.
      final rawUser = authorizationResponse.authorizationAdditionalParameters?['user'];
      Map<String, dynamic>? appleUser;
      if (rawUser != null) {
        try {
          appleUser = jsonDecode(rawUser) as Map<String, dynamic>;
        } catch (_) {
          appleUser = null;
        }
      }

      final response = await AuthService().loginSocial(
        type: 'apple',
        token: token,
        socialData: {
          'idToken': result.idToken,
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
          'rawNonce': rawNonce, // Algunos backends necesitan el nonce original
          if (appleUser != null) 'user': appleUser,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Apple login error: ${e.toString()}');
    }
  }
}
