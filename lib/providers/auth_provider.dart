// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  Map<String, dynamic>? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status  => _status;
  Map<String, dynamic>? get user => _user;
  String? get error      => _error;
  bool get isLoading     => _loading;

  AuthProvider() { checkAuth(); }

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      _user = await ApiService.getSavedUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    final res = await ApiService.login(email, password);
    _loading  = false;

    if (res['success'] == true) {
      await ApiService.saveToken(res['data']['token']);
      await ApiService.saveUser(res['data']['user']);
      _user   = res['data']['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = res['message'] ?? 'Login gagal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    final res = await ApiService.register(name, email, password);
    _loading  = false;

    if (res['success'] == true) {
      await ApiService.saveToken(res['data']['token']);
      await ApiService.saveUser(res['data']['user']);
      _user   = res['data']['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = res['message'] ?? 'Registrasi gagal';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
