import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:airport_butler_agents_app/modules/auth/services/auth_service.dart';

class MicrosoftAuthService {
  static final MicrosoftAuthService instance = MicrosoftAuthService._internal();
  MicrosoftAuthService._internal();

  static const FlutterAppAuth _appAuth = FlutterAppAuth();

  Future<dynamic> login() async {
    final String? tenantId = dotenv.env['MICROSOFT_TENANT'];
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        dotenv.env['CLIENT_ID']!,
        dotenv.env['REDIRECT_URI']!,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint:
          '${dotenv.env['AUTHORITY']}/oauth2/v2.0/authorize',
          tokenEndpoint: '${dotenv.env['AUTHORITY']}/oauth2/v2.0/token',
        ),
        scopes: ['openid', 'profile', 'email', 'offline_access', 'User.Read'],
        promptValues: ['select_account'],
        additionalParameters: {
          'tenant': tenantId!,
        },
      ),
    );

    final accessToken = result.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token nulo en login de Microsoft');
    }

    final response = await AuthService().loginSocial(
      type: 'microsoft',
      token: accessToken,
      socialData: {
        'refreshToken': result.refreshToken,
      },
    );
    return response;
  }
}