import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/utils/firebase_messaging_helper.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static final GoogleAuthService instance = GoogleAuthService._internal();
  GoogleAuthService._internal();

  static const List<String> _scopes = ['openid', 'profile', 'email'];

  bool _initialized = false;

  Future<GoogleSignIn> _buildGoogleSignIn() async {
    final googleSignIn = GoogleSignIn.instance;
    final iosClientId =
        dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

    if (!_initialized) {
      await googleSignIn.initialize(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: Platform.isAndroid ? webClientId : null,
      );
      _initialized = true;
    }
    return googleSignIn;
  }

  Future<dynamic> login() async {
    try {
      final googleSignIn = await _buildGoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount account = await googleSignIn.authenticate(
        scopeHint: _scopes,
      );

      final GoogleSignInAuthentication auth = account.authentication;

      final String? idToken = auth.idToken;
      final GoogleSignInClientAuthorization? authorization = await account
          .authorizationClient
          .authorizationForScopes(_scopes);
      final String? accessToken = authorization?.accessToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Null ID token in Google login');
      }

      final firebaseToken = await FirebaseMessagingHelper.getTokenSafely();
      final response = await AuthService().loginSocial(
        type: 'google',
        token: idToken,
        firebaseToken: firebaseToken,
        appContext: "passenger-app",
        socialData: {
          'idToken': idToken,
          'accessToken': accessToken,
          'email': account.email,
          'displayName': account.displayName,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Google login error: ${e.toString()}');
    }
  }
}