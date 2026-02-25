import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  static const _userKey = 'hyperzone_user';
  static const String baseUrl = 'http://localhost:8080';

  // ------------ SIGNUP ------------
  // Calls POST /users with {username, email, password}
  Future<String?> signup(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // success → SignupScreen expects null = success
        return null;
      } else {
        // try to read JSON error { "message": "..." }
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] is String) {
            return data['message'] as String;
          }
        } catch (_) {}
        return 'Signup failed (${response.statusCode})';
      }
    } catch (e) {
      return 'Signup error: $e';
    }
  }

  // ------------ LOGIN ------------
  // Calls POST /users/login with {username, password}
  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,   // login by username (not email)
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Backend now returns: { "id": 1, "username": "...", "email": "..." }
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // Save ID safely (int or string)
        if (data['id'] != null) {
          final intId = data['id'] is int
              ? data['id'] as int
              : int.tryParse(data['id'].toString()) ?? 0;
          await prefs.setInt('user_id', intId);
        }

        await prefs.setString(
            'user_username', data['username']?.toString() ?? '');
        await prefs.setString(
            'user_email', data['email']?.toString() ?? '');
        await prefs.setBool('is_logged_in', true);

        // success → LoginScreen expects null = success
        return null;
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] is String) {
            return data['message'] as String;
          }
        } catch (_) {}
        return 'Login failed (${response.statusCode})';
      }
    } catch (e) {
      return 'Login error: $e';
    }
  }

  // ------------ LOGOUT ------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ------------ GET SAVED USER (for Drawer / Profile) ------------
  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;

    final id = prefs.getInt('user_id');
    final username = prefs.getString('user_username');
    final email = prefs.getString('user_email');

    if (id == null || username == null || email == null) {
      return null;
    }

    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
    Future<Map<String, dynamic>?> getCurrentUser() async {
    
    return getSavedUser();
  }
}


