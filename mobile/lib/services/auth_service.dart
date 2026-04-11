import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _provider;
  String? _userType;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get provider => _provider;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;
  bool get isProvider => _userType == 'provider';

  AuthService() { _loadFromStorage(); }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userType = prefs.getString('userType');
    final userData = prefs.getString('user');
    final providerData = prefs.getString('provider');
    if (userData != null) {
      try { _user = Map<String, dynamic>.from(jsonDecode(userData)); } catch (_) {}
    }
    if (providerData != null) {
      try { _provider = Map<String, dynamic>.from(jsonDecode(providerData)); } catch (_) {}
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/login', {'email': email, 'password': password});
      _token = res['token'];
      _user = Map<String, dynamic>.from(res['user']);
      _userType = 'user';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'user');
      await prefs.setString('user', jsonEncode(_user));
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> providerLogin(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/provider/login', {'email': email, 'password': password});
      _token = res['token'];
      _provider = Map<String, dynamic>.from(res['provider']);
      _userType = 'provider';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'provider');
      await prefs.setString('provider', jsonEncode(_provider));
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/register', data);
      return {'success': true, 'userId': res['userId']};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(int userId, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/verify-otp', {'userId': userId, 'otp': otp});
      _token = res['token'];
      _user = Map<String, dynamic>.from(res['user']);
      _userType = 'user';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userType', 'user');
      await prefs.setString('user', jsonEncode(_user));
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}