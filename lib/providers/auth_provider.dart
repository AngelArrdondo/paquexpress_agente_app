// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // Constructor: intenta auto-login
  AuthProvider() {
    autoLogin();
  }

  /// ************************************
  /// AUTO LOGIN
  /// ************************************
  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners();

    final savedToken = await _authService.getToken();

    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
    } else {
      _token = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ************************************
  /// LOGIN
  /// ************************************
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final token = await _authService.login(username, password);

    _isLoading = false;

    if (token != null && token.isNotEmpty) {
      _token = token;
      notifyListeners();
      return true;
    } else {
      _token = null;
      notifyListeners();
      return false;
    }
  }

  /// ************************************
  /// LOGOUT
  /// ************************************
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _token = null;

    _isLoading = false;
    notifyListeners();
  }
}
