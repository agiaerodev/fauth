import 'dart:convert';
import 'dart:io';
import '../../../core/services/base_api_service.dart';
import 'package:flutter/material.dart';

class AuthService extends BaseApiService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    const route = '/profile/v1/auth/login';
    final body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await post(route, body);
      debugPrint('Login successful');
      return response;
    } catch (e) {
      debugPrint('Error during Login: $e');
      rethrow;
    }
  }

  Future<dynamic> sendPin({
    required String username,
    String? authMode
  }) async {
    const route = '/profile/v1/auth/send-pin';
    final body = {
      "attributes": {
        "username": username,
        "device": _detectDevice(),
        if (authMode != null) "authMode": authMode
      }
    };

    try {
      final response = await post(route, body);
      debugPrint('Send PIN successful');
      return response;
    } catch (e) {
      debugPrint('Error during Send PIN: $e');
      rethrow;
    }
  }

  Future<dynamic> confirmPin({
    required String username,
    required String pin,
  }) async {
    const route = '/profile/v1/auth/confirm-pin';
    final body = {
      "attributes": {
        "username": username,
        "pin": pin,
        "device": _detectDevice(),
      }
    };

    try {
      final response = await post(route, body);
      debugPrint('Confirm PIN successful');
      return response;
    } catch (e) {
      debugPrint('Error during Confirm PIN: $e');
      rethrow;
    }
  }

  Future<dynamic> loginSocial({
    required String type,
    required String? token,
    dynamic socialData,
  }) async {
    final route = '/profile/v1/auth/social/$type';
    final device = _detectDevice();

    final body = {
      'type': type,
      'attributes': {
        'token': token,
        'socialData': socialData ?? {},
        'device': device,
      },
    };

    try {
      final response = await post(route, body);
      debugPrint('Social Login successful for type: $type');
      return response;
    } catch (e) {
      debugPrint('Error during Social Login ($type): $e');
      rethrow;
    }
  }

  Future<dynamic> me() async {
    final route = '/profile/v1/auth/me';
    try {
      final config = {
        'refresh': true,
        'params': {
          'include': 'organizations'
        }
      };
      final response = await index(route, config: config);
      debugPrint('Social Login successful me');
      return response;
    } catch (e) {
      debugPrint('Error during me: $e');
      rethrow;
    }
  }

  Future<dynamic> getConcierge(int conciergeId) async {
    try {
      final route = '/reservations/v1/concierges';
      final config = {
        'refresh': true,
        'params': {
          'include': 'user,files',
          'filter': {
            'field': 'user_id',
          }
        }
      };
      final response = await show(route, conciergeId, config);
      
      // Si response es null o no tiene data, lanzar excepción
      if (response == null) {
        throw Exception('Concierge response is null');
      }
      
      final data = response['data'];
      if (data == null) {
        throw Exception('Concierge data is null');
      }
      
      return data;
    } catch(e) {
      print('❌ ERROR getConcierge: $e');
      rethrow;
    }
  }

  Future<dynamic> logout({appModule = 'agent-app'}) async {
    const route = '/profile/v1/auth/logout';
    try {
      final setting = jsonEncode({
        "timezone": DateTime.now().timeZoneName,
        "fromAdmin": true,
        "appMode": appModule,
        "authProvider": "local",
        "locale": "en",
      });

      final response = await get(route, params: {'setting': setting});
      debugPrint('Logout successful');
      return response;
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }


  String _detectDevice() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
