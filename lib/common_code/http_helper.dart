import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  // Default timeout settings
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _extendedTimeout = Duration(seconds: 30);
  static const Duration _connectTimeout = Duration(seconds: 10);

  // Retry settings
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Create HTTP client with custom settings
  static http.Client _createClient() {
    return http.Client();
  }

  // Enhanced GET request with timeout and retry logic
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    int? maxRetries,
  }) async {
    return _executeWithRetry(
      () => _performGet(url, headers: headers, timeout: timeout),
      maxRetries ?? _maxRetries,
    );
  }

  // Enhanced POST request with timeout and retry logic
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    int? maxRetries,
  }) async {
    return _executeWithRetry(
      () => _performPost(url,
          headers: headers, body: body, encoding: encoding, timeout: timeout),
      maxRetries ?? _maxRetries,
    );
  }

  // Enhanced PUT request
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    int? maxRetries,
  }) async {
    return _executeWithRetry(
      () => _performPut(url,
          headers: headers, body: body, encoding: encoding, timeout: timeout),
      maxRetries ?? _maxRetries,
    );
  }

  // Enhanced DELETE request
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
    int? maxRetries,
  }) async {
    return _executeWithRetry(
      () => _performDelete(url,
          headers: headers, body: body, encoding: encoding, timeout: timeout),
      maxRetries ?? _maxRetries,
    );
  }

  // Internal GET implementation
  static Future<http.Response> _performGet(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);

      if (kDebugMode) {
        print('🌐 GET Request: $url');
        print('📋 Headers: ${headers ?? "None"}');
      }

      // Enhanced headers with additional metadata
      final enhancedHeaders = {
        'User-Agent': 'QareebApp/1.0 (Flutter)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        ...?headers,
      };

      final response = await client
          .get(uri, headers: enhancedHeaders)
          .timeout(timeout ?? _defaultTimeout);

      if (kDebugMode) {
        print('📡 GET Response Status: ${response.statusCode}');
        print('📏 Response Length: ${response.body.length} characters');
      }

      _validateResponse(response);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ GET Request Error: $e');
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  // Internal POST implementation
  static Future<http.Response> _performPost(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);

      if (kDebugMode) {
        print('🌐 POST Request: $url');
        print('📋 Headers: ${headers ?? "None"}');
        print('📦 Body Length: ${body?.toString().length ?? 0} characters');
      }

      // Enhanced headers
      final enhancedHeaders = {
        'User-Agent': 'QareebApp/1.0 (Flutter)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        if (body != null && headers?['Content-Type'] == null)
          'Content-Type': 'application/json; charset=utf-8',
        ...?headers,
      };

      final response = await client
          .post(uri, headers: enhancedHeaders, body: body, encoding: encoding)
          .timeout(timeout ?? _defaultTimeout);

      if (kDebugMode) {
        print('📡 POST Response Status: ${response.statusCode}');
        print('📏 Response Length: ${response.body.length} characters');
      }

      _validateResponse(response);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ POST Request Error: $e');
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  // Internal PUT implementation
  static Future<http.Response> _performPut(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);

      if (kDebugMode) {
        print('🌐 PUT Request: $url');
      }

      final enhancedHeaders = {
        'User-Agent': 'QareebApp/1.0 (Flutter)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        if (body != null && headers?['Content-Type'] == null)
          'Content-Type': 'application/json; charset=utf-8',
        ...?headers,
      };

      final response = await client
          .put(uri, headers: enhancedHeaders, body: body, encoding: encoding)
          .timeout(timeout ?? _defaultTimeout);

      _validateResponse(response);
      return response;
    } finally {
      client.close();
    }
  }

  // Internal DELETE implementation
  static Future<http.Response> _performDelete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);

      if (kDebugMode) {
        print('🌐 DELETE Request: $url');
      }

      final enhancedHeaders = {
        'User-Agent': 'QareebApp/1.0 (Flutter)',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        ...?headers,
      };

      final response = await client
          .delete(uri, headers: enhancedHeaders, body: body, encoding: encoding)
          .timeout(timeout ?? _defaultTimeout);

      _validateResponse(response);
      return response;
    } finally {
      client.close();
    }
  }

  // Execute request with retry logic
  static Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
    int maxRetries,
  ) async {
    int attempt = 0;
    Duration delay = _retryDelay;

    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempt++;

        if (kDebugMode) {
          print('🔄 Attempt $attempt/$maxRetries failed: $e');
        }

        // Don't retry for certain types of errors
        if (_shouldRetry(e) && attempt < maxRetries) {
          if (kDebugMode) {
            print('⏳ Retrying in ${delay.inSeconds} seconds...');
          }
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
        } else {
          // Enhance error message for better user understanding
          throw _enhanceError(e);
        }
      }
    }

    throw Exception('Request failed after $maxRetries attempts');
  }

  // Determine if error should trigger a retry
  static bool _shouldRetry(dynamic error) {
    if (error is TimeoutException) return true;
    if (error is SocketException) return true;
    if (error is HandshakeException) return true;
    if (error is HttpException) return true;

    // Check for specific error messages
    String errorString = error.toString().toLowerCase();
    if (errorString.contains('deadline_exceeded')) return true;
    if (errorString.contains('connection reset')) return true;
    if (errorString.contains('connection refused')) return true;
    if (errorString.contains('network unreachable')) return true;
    if (errorString.contains('timeout')) return true;

    return false;
  }

  // Enhance error messages for better user experience
  static Exception _enhanceError(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (error is TimeoutException || errorString.contains('timeout')) {
      return TimeoutException(
        'انتهت مهلة الطلب. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
        const Duration(seconds: 30),
      );
    }

    if (error is SocketException || errorString.contains('socket')) {
      return const SocketException(
        'فشل الاتصال. تحقق من اتصال الإنترنت.',
      );
    }

    if (errorString.contains('deadline_exceeded')) {
      return Exception(
        'انتهت مهلة الاتصال. الشبكة بطيئة أو غير مستقرة.',
      );
    }

    if (errorString.contains('certificate') ||
        errorString.contains('handshake')) {
      return const HandshakeException(
        'خطأ في شهادة الأمان. تحقق من إعدادات التاريخ والوقت.',
      );
    }

    if (errorString.contains('host lookup') ||
        errorString.contains('resolve')) {
      return const SocketException(
        'لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت.',
      );
    }

    // Return enhanced generic error
    return Exception('خطأ في الشبكة: ${error.toString()}');
  }

  // Validate HTTP response
  static void _validateResponse(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = _getHttpErrorMessage(response.statusCode);

      if (kDebugMode) {
        print('❌ HTTP Error ${response.statusCode}: $errorMessage');
        print('📄 Response Body: ${response.body}');
      }

      throw HttpException(
        '$errorMessage (${response.statusCode})',
        uri: response.request?.url,
      );
    }
  }

  // Get user-friendly HTTP error messages
  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب خاطئ - تحقق من البيانات المرسلة';
      case 401:
        return 'غير مخول - تحقق من بيانات تسجيل الدخول';
      case 403:
        return 'ممنوع - ليس لديك صلاحية للوصول';
      case 404:
        return 'غير موجود - الخدمة غير متوفرة';
      case 408:
        return 'انتهت مهلة الطلب';
      case 429:
        return 'كثرة الطلبات - حاول مرة أخرى لاحقاً';
      case 500:
        return 'خطأ في الخادم - حاول مرة أخرى';
      case 502:
        return 'خطأ في البوابة - الخادم غير متاح';
      case 503:
        return 'الخدمة غير متاحة حالياً';
      case 504:
        return 'انتهت مهلة البوابة';
      default:
        return 'خطأ في الشبكة';
    }
  }

  // Health check method
  static Future<bool> checkConnectivity(String baseUrl) async {
    try {
      final response = await get(
        '$baseUrl/health',
        timeout: const Duration(seconds: 5),
        maxRetries: 1,
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('🔍 Connectivity check failed: $e');
      }
      return false;
    }
  }

  // Download file with progress callback
  static Future<List<int>> downloadFile(
    String url, {
    Map<String, String>? headers,
    Function(int received, int total)? onProgress,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);

      if (headers != null) {
        request.headers.addAll(headers);
      }

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw HttpException(
            'Download failed with status ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];

      await response.stream.listen(
        (chunk) {
          bytes.addAll(chunk);
          onProgress?.call(bytes.length, contentLength);
        },
      ).asFuture();

      return bytes;
    } finally {
      client.close();
    }
  }

  // Upload file with progress callback
  static Future<http.Response> uploadFile(
    String url,
    String fieldName,
    String filePath,
    List<int> fileBytes, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    Function(int sent, int total)? onProgress,
  }) async {
    final client = _createClient();
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: filePath.split('/').last,
      );

      request.files.add(multipartFile);

      final response = await client.send(request);
      return await http.Response.fromStream(response);
    } finally {
      client.close();
    }
  }
}
