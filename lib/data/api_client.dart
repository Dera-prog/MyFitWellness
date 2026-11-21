import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);

  /// 0 means the request never reached the server.
  final int status;
  final String code;
  final String message;

  bool get isNetwork => status == 0;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl})
      : baseUrl = _resolveBase(baseUrl),
        _client = http.Client();

  static const String _defined = String.fromEnvironment('API_BASE_URL');
  static const String _tokenKey = 'mfw.token';
  static const Duration _timeout = Duration(seconds: 12);

  final String baseUrl;
  final http.Client _client;
  String? _token;

  bool get hasToken => _token != null;

  static String _resolveBase(String? override) {
    final raw = (override?.isNotEmpty == true)
        ? override!
        : (_defined.isNotEmpty
            ? _defined
            : (kIsWeb
                ? (Uri.base.host.endsWith('vercel.app')
                    ? 'https://myfitwellness-api.vercel.app/api'
                    : '${Uri.base.origin}/api')
                : 'http://localhost:8090/api'));
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    } catch (_) {
      _token = null;
    }
  }

  Future<void> saveToken(String? token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token == null) {
        await prefs.remove(_tokenKey);
      } else {
        await prefs.setString(_tokenKey, token);
      }
    } catch (_) {
      // A device without storage still works for this session.
    }
  }

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{'accept': 'application/json'};
    if (json) headers['content-type'] = 'application/json';
    if (_token != null) headers['authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _headers();
    try {
      late http.Response response;
      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          response = await _client.get(uri, headers: headers).timeout(_timeout);
      }
      if (response.statusCode == 204) return null;
      dynamic decoded;
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = null;
        }
      }
      if (response.statusCode >= 400) {
        final map = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
        throw ApiException(
          response.statusCode,
          (map['error'] as String?) ?? 'request_failed',
          (map['message'] as String?) ?? 'Something went wrong',
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(0, 'timeout', 'The server took too long to answer');
    } catch (error) {
      if (kDebugMode) debugPrint('[api] $method $path failed: $error');
      throw ApiException(0, 'network', 'Could not reach MyFitWellness');
    }
  }

  Future<Map<String, dynamic>> _map(Future<dynamic> call) async {
    final data = await call;
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _map(_send('POST', '/auth/register', auth: false, body: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }));

  Future<Map<String, dynamic>> login({required String email, required String password}) =>
      _map(_send('POST', '/auth/login', auth: false, body: {
        'email': email,
        'password': password,
      }));

  Future<void> logout() => _send('POST', '/auth/logout');

  Future<Map<String, dynamic>> me() => _map(_send('GET', '/me'));

  Future<Map<String, dynamic>> patchMe(Map<String, dynamic> changes) =>
      _map(_send('PATCH', '/me', body: changes));

  Future<Map<String, dynamic>> setGym({String? gymId, String? label}) =>
      _map(_send('PUT', '/me/gym', body: {
        if (gymId != null) 'gymId': gymId,
        if (label != null) 'label': label,
      }));

  Future<Map<String, dynamic>> purchasePlan(String plan, {required bool annual}) =>
      _map(_send('POST', '/me/plan', body: {'plan': plan, 'annual': annual}));

  Future<Map<String, dynamic>> switchPlan(String plan, {required bool annual}) =>
      _map(_send('POST', '/me/plan/switch', body: {'plan': plan, 'annual': annual}));

  Future<Map<String, dynamic>> cancelPlan() => _map(_send('POST', '/me/plan/cancel'));

  Future<void> saveReminders(List<Map<String, dynamic>> reminders) =>
      _send('PUT', '/me/reminders', body: {'reminders': reminders});

  Future<Map<String, dynamic>> addWorkoutItem({
    required String name,
    required String detail,
    required int sets,
    required int reps,
    required double weight,
    required int minutes,
    required String icon,
  }) =>
      _map(_send('POST', '/workouts/today', body: {
        'name': name,
        'detail': detail,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'minutes': minutes,
        'icon': icon,
      }));

  Future<Map<String, dynamic>> patchWorkoutItem(String id, bool done) =>
      _map(_send('PATCH', '/workouts/today/$id', body: {'done': done}));

  Future<void> deleteWorkoutItem(String id) => _send('DELETE', '/workouts/today/$id');

  Future<Map<String, dynamic>> logSet({
    required String exercise,
    required int setNumber,
    required int seconds,
  }) =>
      _map(_send('POST', '/workouts/sets', body: {
        'exercise': exercise,
        'setNumber': setNumber,
        'seconds': seconds,
      }));

  Future<Map<String, dynamic>> addGoal({
    required String title,
    required String unit,
    required double start,
    required double target,
    required double current,
    required String icon,
    required String color,
  }) =>
      _map(_send('POST', '/goals', body: {
        'title': title,
        'unit': unit,
        'start': start,
        'target': target,
        'current': current,
        'icon': icon,
        'color': color,
      }));

  Future<Map<String, dynamic>> patchGoal(String id, {double? current, double? target, String? title}) =>
      _map(_send('PATCH', '/goals/$id', body: {
        if (current != null) 'current': current,
        if (target != null) 'target': target,
        if (title != null) 'title': title,
      }));

  Future<Map<String, dynamic>> playVideo(String id) => _map(_send('POST', '/videos/$id/play'));

  Future<Map<String, dynamic>> sendMessage(String coach, String text) =>
      _map(_send('POST', '/coaching/$coach/messages', body: {'text': text}));
}
