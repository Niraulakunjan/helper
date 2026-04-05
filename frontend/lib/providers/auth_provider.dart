import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _accessToken;
  bool _loading = false;

  UserModel? get user => _user;
  String? get accessToken => _accessToken;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.login(username, password);
      _accessToken = data['access'];
      _user = UserModel.fromJson(data['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      // Persist user fields so we can restore role after app restart
      await prefs.setInt('user_id', _user!.id);
      await prefs.setString('user_username', _user!.username);
      await prefs.setString('user_email', _user!.email);
      await prefs.setString('user_phone', _user!.phone);
      await prefs.setString('user_role', _user!.role);
      await prefs.setBool('has_helper_profile', _user!.hasHelperProfile);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String phone, String password, String role) async {
    _loading = true;
    notifyListeners();
    try {
      await ApiService.register({'username': username, 'email': email, 'phone': phone, 'password': password, 'role': role});
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('has_helper_profile');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    
    if (_accessToken != null) {
      try {
        final res = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/auth/profile/'),
          headers: {'Authorization': 'Bearer $_accessToken', 'Content-Type': 'application/json'},
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _user = UserModel.fromJson(data);
          // Update cached values
          await prefs.setString('user_role', _user!.role);
          await prefs.setBool('has_helper_profile', _user!.hasHelperProfile);
        } else {
          // If token invalid, logout
          await logout();
        }
      } catch (e) {
        // Fallback to cached if server is down
        final role = prefs.getString('user_role');
        if (role != null) {
          _user = UserModel(
            id: prefs.getInt('user_id') ?? 0,
            username: prefs.getString('user_username') ?? '',
            email: prefs.getString('user_email') ?? '',
            phone: prefs.getString('user_phone') ?? '',
            role: role,
            hasHelperProfile: prefs.getBool('has_helper_profile') ?? false,
          );
        }
      }
    }
    notifyListeners();
  }

  /// Call this after the helper completes their profile setup.
  Future<void> markHelperProfileCreated() async {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      username: _user!.username,
      email: _user!.email,
      phone: _user!.phone,
      role: _user!.role,
      hasHelperProfile: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_helper_profile', true);
    notifyListeners();
  }
}
