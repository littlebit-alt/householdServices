import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Render free tier can take 50-60s to cold start — give it 90s to be safe
  static const Duration _timeout = Duration(seconds: 90);

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://householdservices.onrender.com/api',
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
    sendTimeout: _timeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Dio get dio => _dio;

  /// Returns true if the request took long enough to suggest a cold start.
  /// UI can use this to show a "server is warming up" message.
  static bool isLikelyColdStart(Duration elapsed) => elapsed.inSeconds >= 10;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _setAuthHeader() async {
    final token = await _getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    await _setAuthHeader();
    try {
      final response = await _dio.put(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    await _setAuthHeader();
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network settings.');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('The server is taking too long to respond. It may be starting up — please try again in a moment.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final message = data?['message'] ?? 'Server error (HTTP $statusCode)';
        return Exception(message);
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          final socketError = error.error as SocketException;
          if (socketError.message.contains('NO address associated with hostname') ||
              socketError.osError?.errorCode == 7) {
            return Exception('DNS lookup failed. Please check your internet connection or try using mobile data instead of WiFi.');
          }
          return Exception('Network error: ${socketError.message}');
        }
        return Exception('Network error: ${error.message}');
      default:
        return Exception('Something went wrong: ${error.message}');
    }
  }
}
