import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _provider;
  String? _userType;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get provider => _provider;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  bool get isProvider => _userType == 'provider';

  AuthService() {
    ApiService.initialize();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userType = prefs.getString('userType');
      final userData = prefs.getString('user');
      final providerData = prefs.getString('provider');
      
      if (userData != null) {
        try {
          _user = Map<String, dynamic>.from(jsonDecode(userData));
        } catch (e) {
          debugPrint('Error parsing user data: $e');
        }
      }
      
      if (providerData != null) {
        try {
          _provider = Map<String, dynamic>.from(jsonDecode(providerData));
        } catch (e) {
          debugPrint('Error parsing provider data: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return true;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!await _checkConnectivity()) {
      _isLoading = false;
      _error = 'No internet connection. Please enable WiFi or mobile data.';
      notifyListeners();
      return {'success': false, 'message': _error};
    }

    try {
      debugPrint('🔐 Login attempt: $email');
      final res = await ApiService.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

      _token = res['token'];
      _user = Map<String, dynamic>.from(res['user']);
      _userType = 'user';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'user');
      await prefs.setString('user', jsonEncode(_user));

      _error = null;
      notifyListeners();
      debugPrint('✅ Login successful');
      return {'success': true};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Login failed: $_error');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> providerLogin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!await _checkConnectivity()) {
      _isLoading = false;
      _error = 'No internet connection. Please enable WiFi or mobile data.';
      notifyListeners();
      return {'success': false, 'message': _error};
    }

    try {
      debugPrint('🔐 Provider login attempt: $email');
      final res = await ApiService.post('/auth/provider/login', {
        'email': email.trim(),
        'password': password,
      });

      _token = res['token'];
      _provider = Map<String, dynamic>.from(res['provider']);
      _userType = 'provider';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'provider');
      await prefs.setString('provider', jsonEncode(_provider));

      _error = null;
      notifyListeners();
      debugPrint('✅ Provider login successful');
      return {'success': true};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Provider login failed: $_error');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!await _checkConnectivity()) {
      _isLoading = false;
      _error = 'No internet connection. Please enable WiFi or mobile data.';
      notifyListeners();
      return {'success': false, 'message': _error};
    }

    try {
      debugPrint('📝 Registration attempt: ${data['email']}');
      final res = await ApiService.post('/auth/register', {
        'fullName': data['fullName'],
        'email': data['email']?.trim(),
        'phone': data['phone'],
        'password': data['password'],
      });

      _error = null;
      notifyListeners();
      debugPrint('✅ Registration successful');
      return {'success': true, 'userId': res['userId']};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Registration failed: $_error');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(int userId, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!await _checkConnectivity()) {
      _isLoading = false;
      _error = 'No internet connection.';
      notifyListeners();
      return {'success': false, 'message': _error};
    }

    try {
      debugPrint('🔢 OTP verification: user $userId');
      final res = await ApiService.post('/auth/verify-otp', {
        'userId': userId,
        'otp': otp,
      });

      _token = res['token'];
      _user = Map<String, dynamic>.from(res['user']);
      _userType = 'user';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'user');
      await prefs.setString('user', jsonEncode(_user));

      _error = null;
      notifyListeners();
      debugPrint('✅ OTP verified');
      return {'success': true};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ OTP verification failed: $_error');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!await _checkConnectivity()) {
      _isLoading = false;
      _error = 'No internet connection.';
      notifyListeners();
      return {'success': false, 'message': _error};
    }

    try {
      debugPrint('🔑 Forgot password: $email');
      final res = await ApiService.post('/auth/forgot-password', {
        'email': email.trim(),
      });

      _error = null;
      notifyListeners();
      return {'success': true, 'userId': res['userId']};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPassword(int userId, String otp, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/reset-password', {
        'userId': userId,
        'otp': otp,
        'newPassword': newPassword,
      });

      _error = null;
      notifyListeners();
      return {'success': true};

    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _provider = null;
    _userType = null;
    _error = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ Logged out');
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}