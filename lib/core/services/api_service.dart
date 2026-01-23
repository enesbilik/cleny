import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'supabase_service.dart';

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, dynamic>? details;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.details,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
      error: json['error'],
      details: json['details'],
    );
  }
}

/// API Service - Backend ile iletişim
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  
  ApiService._();

  String get _baseUrl {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    return '$supabaseUrl/functions/v1';
  }

  /// Auth header'ı al
  Future<Map<String, String>> _getHeaders() async {
    final session = SupabaseService.client.auth.currentSession;
    final accessToken = session?.accessToken;

    return {
      'Content-Type': 'application/json',
      'Authorization': accessToken != null ? 'Bearer $accessToken' : '',
      'apikey': dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    };
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      debugPrint('API GET: $uri');
      
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      debugPrint('API POST: $uri');
      debugPrint('Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();

      debugPrint('API PUT: $uri');

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();

      debugPrint('API PATCH: $uri');

      final response = await http.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();

      debugPrint('API DELETE: $uri');

      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Response handler
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic)? fromJson) {
    debugPrint('API Response [${response.statusCode}]: ${response.body}');

    try {
      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, fromJson);
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(success: true, data: null);
      }
      return ApiResponse(success: false, error: 'Invalid response format');
    }
  }
}

// Singleton instance
final apiService = ApiService.instance;

