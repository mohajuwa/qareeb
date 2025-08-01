// lib/common_code/http_helper.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class HttpHelper {
  static http.Client? _client;

  static http.Client getClient() {
    if (_client == null) {
      HttpClient httpClient = HttpClient();

      // Bypass SSL certificate verification for self-signed certificates
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        // You can add specific host checking here if needed
        // For now, accept all certificates (development only)
        return true;
      };

      // Set timeouts
      httpClient.connectionTimeout = const Duration(seconds: 30);
      httpClient.idleTimeout = const Duration(seconds: 30);

      _client = IOClient(httpClient);
    }
    return _client!;
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }

  // Helper methods for common HTTP operations
  static Future<http.Response> get(String url, {Map<String, String>? headers}) {
    return getClient().get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(String url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return getClient()
        .post(Uri.parse(url), headers: headers, body: body, encoding: encoding);
  }

  static Future<http.StreamedResponse> multipartRequest(
      String method, String url) {
    var request = http.MultipartRequest(method, Uri.parse(url));
    return getClient().send(request);
  }
}
