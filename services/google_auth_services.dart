import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static final GoogleAuthService instance = GoogleAuthService._internal();
  GoogleAuthService._internal();

  static const List<String> _scopes = ['openid', 'profile', 'email'];

  bool _initialized = false;

  Future<GoogleSignIn> _buildGoogleSignIn() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_initialized) {
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
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

      final firebaseTokenId = await FirebaseMessaging.instance.getToken();
      final response = await AuthService().loginSocial(
        type: 'google',
        token: idToken,
        firebaseTokenId: firebaseTokenId,
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