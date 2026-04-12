import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://householdservices.onrender.com/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Dio get dio => _dio;

  static void initialize() {
    // Configure for Android compatibility
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Handle SSL certificates on Android
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // Add logging interceptor
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('➡️ ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('⬅️ ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ ERROR: ${error.type}');
        debugPrint('Message: ${error.message}');
        if (error.response != null) {
          debugPrint('Response: ${error.response?.data}');
        }
        if (error.error != null) {
          debugPrint('Underlying: ${error.error}');
        }
        return handler.next(error);
      },
    ));
  }

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
        return Exception('Connection timed out. Please try again.');
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