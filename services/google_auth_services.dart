import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static final GoogleAuthService instance = GoogleAuthService._internal();
  GoogleAuthService._internal();

  static const FlutterAppAuth _appAuth = FlutterAppAuth();

  Future<dynamic> login() async {
    final String? googleClientId = dotenv.env['GOOGLE_CLIENT_ID'];
    final String? googleRedirectUri = dotenv.env['GOOGLE_REDIRECT_URI'];

    if (googleClientId == null || googleRedirectUri == null) {
      throw Exception('Google configuration missing in .env');
    }

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          googleClientId,
          googleRedirectUri,
          issuer: 'https://accounts.google.com',
          scopes: ['openid', 'profile', 'email'],
          promptValues: ['select_account'],
        ),
      );


      final accessToken = result.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token nulo en login de Google');
      }

      final response = await AuthService().loginSocial(
        type: 'google',
        token: accessToken,
        socialData: {
          'idToken': result.idToken,
          'refreshToken': result.refreshToken,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Google login error: ${e.toString()}');
    }
  }
}
