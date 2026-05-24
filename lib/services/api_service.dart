// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://joanportofolio.web.id/habit_tracker_api';

  // ─── Token Management ───────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    return data != null ? jsonDecode(data) : null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // ─── Headers ────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ─── Generic Request ────────────────────────
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final url = '$baseUrl/$endpoint';
      print('>>> POST $url');
      print('>>> BODY: ${jsonEncode(body)}');

      final res = await http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );

      print('<<< STATUS: ${res.statusCode}');
      print('<<< BODY: ${res.body}');

      return jsonDecode(res.body);
    } catch (e) {
      print('!!! ERROR: $e');
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (params != null) uri = uri.replace(queryParameters: {...uri.queryParameters, ...params});

      print('>>> GET $uri');
      final res = await http.get(uri, headers: await _headers(auth: true));
      print('<<< STATUS: ${res.statusCode}');
      print('<<< BODY: ${res.body}');

      return jsonDecode(res.body);
    } catch (e) {
      print('!!! ERROR: $e');
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ─── AUTH ────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) =>
      _post('api/auth/index.php?action=login', {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(String name, String email, String password) =>
      _post('api/auth/index.php?action=register', {'name': name, 'email': email, 'password': password});

  static Future<Map<String, dynamic>> forgotPassword(String email) =>
      _post('api/auth/index.php?action=forgot-password', {'email': email});

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String token,
    String newPassword,
  ) =>
      _post('api/auth/index.php?action=reset-password', {
        'email': email,
        'token': token,
        'new_password': newPassword,
      });

  static Future<Map<String, dynamic>> getProfile() =>
      _get('api/auth/index.php?action=profile');

  static Future<Map<String, dynamic>> updateProfile(String name, {String? newPassword}) =>
      _post('api/auth/index.php?action=update-profile', {
        'name': name,
        if (newPassword != null) 'new_password': newPassword,
      }, auth: true);

  // ─── HABITS ──────────────────────────────────
  static Future<Map<String, dynamic>> getTodayHabits() =>
      _get('api/habits/index.php?action=today');

  static Future<Map<String, dynamic>> getHabits() =>
      _get('api/habits/index.php?action=list');

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) =>
      _post('api/habits/index.php?action=create', data, auth: true);

  static Future<Map<String, dynamic>> updateHabit(Map<String, dynamic> data) =>
      _post('api/habits/index.php?action=update', data, auth: true);

  static Future<Map<String, dynamic>> deleteHabit(int id) =>
      _post('api/habits/index.php?action=delete', {'id': id}, auth: true);

  static Future<Map<String, dynamic>> toggleHabit(
    int habitId, {
    String? date,
    String? note,
  }) =>
      _post('api/habits/index.php?action=toggle', {
        'habit_id': habitId,
        if (date != null) 'date': date,
        if (note != null) 'note': note,
      }, auth: true);

  static Future<Map<String, dynamic>> getStats() =>
      _get('api/habits/index.php?action=stats');
}