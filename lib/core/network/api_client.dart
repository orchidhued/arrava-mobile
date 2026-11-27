import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class ApiResponseException implements Exception {
  final int statusCode;
  final String message;
  final int? retryAfter;
  final bool invalidSession;

  const ApiResponseException(
    this.statusCode,
    this.message, {
    this.retryAfter,
    this.invalidSession = false,
  });

  @override
  String toString() => 'Exception: $message';
}

class ApiClient {
  static Future<dynamic> uploadProfilePhoto(List<int> bytes, String filename) =>
      postMultipart(
        '/student/profile',
        fields: {'_method': 'PUT'},
        photoBytes: bytes,
        photoFilename: filename,
      );

  static Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    final url = _buildUri(endpoint);
    final headers = await _getHeaders();
    // PHP parses uploaded files on POST; Laravel routes it as PUT.
    headers.remove('Content-Type');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields.addAll(fields)
      ..files.add(
        http.MultipartFile.fromBytes(
          'foto_profil',
          photoBytes,
          filename: photoFilename,
        ),
      );
    try {
      final response = await (() async {
        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      })().timeout(const Duration(seconds: 30));
      return await _handleResponse(response, headers);
    } on TimeoutException {
      throw Exception('Upload foto terlalu lama. Silakan coba lagi.');
    } on http.ClientException catch (e) {
      throw Exception(_clientExceptionMessage(e, url));
    }
  }

  static String _clientExceptionMessage(http.ClientException e, Uri url) {
    final isLocalhost = url.host == '127.0.0.1' || url.host == 'localhost';
    final hint = (!kIsWeb && isLocalhost)
        ? ' Di HP Android fisik, jalankan "adb reverse tcp:8000 tcp:8000" jika pakai kabel USB, atau ganti baseUrl ke IP Wi-Fi PC (192.168.18.4).'
        : ' Pastikan Laravel aktif dengan "php artisan serve --host=0.0.0.0 --port=8000" dan CORS diizinkan.';
    return 'Gagal menghubungi API ($url): ${e.message}. $hint';
  }

  static const Duration _timeout = Duration(seconds: 10);

  static Uri _buildUri(String endpoint) {
    final base = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$base$path');
  }

  static Future<Map<String, String>> _getHeaders({
    bool authenticated = true,
  }) async {
    final token = authenticated ? await SecureStorage.getToken() : null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API GET] Requesting: $url');
      final headers = await _getHeaders(authenticated: authenticated);
      final response = await http.get(url, headers: headers).timeout(_timeout);
      return await _handleResponse(response, headers);
    } on TimeoutException catch (_) {
      throw Exception(
        'Koneksi timeout ($url). Server backend tidak merespons dalam 10 detik.',
      );
    } on http.ClientException catch (e) {
      throw Exception(_clientExceptionMessage(e, url));
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Gagal menghubungi API ($url): $e');
    }
  }

  static Future<dynamic> _sendJson(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API $method] Requesting: $url');
      // 1. Siapkan Header (Token & Tipe Data)
      final headers = await _getHeaders(authenticated: authenticated);
      // 2. PROSES PEMBUNGKUSAN KE JSON
      // Jika ada data (body), ubah menjadi teks JSON string
      String? jsonPayload;
      if (body != null) {
        jsonPayload = jsonEncode(body);
      }
      // 3. PROSES PENGIRIMAN HTTP KE LARAVEL
      final Future<http.Response> request;
      if (method == 'POST') {
        request = http.post(url, headers: headers, body: jsonPayload);
      } else if (method == 'PUT') {
        request = http.put(url, headers: headers, body: jsonPayload);
      } else if (method == 'PATCH') {
        request = http.patch(url, headers: headers, body: jsonPayload);
      } else {
        throw ArgumentError('Metode HTTP tidak didukung: $method');
      }
      // 4. Tunggu respons dari server (Maksimal 10 detik)
      final response = await request.timeout(_timeout);
      // 5. Bongkar respons JSON yang dibalas server
      return await _handleResponse(response, headers);
    } on TimeoutException catch (_) {
      throw Exception(
        'Koneksi timeout ($url). Server backend tidak merespons dalam 10 detik.',
      );
    } on http.ClientException catch (e) {
      throw Exception(_clientExceptionMessage(e, url));
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Gagal menghubungi API ($url): $e');
    }
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => _sendJson('POST', endpoint, body: body, authenticated: authenticated);

  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) =>
      _sendJson('PUT', endpoint, body: body);

  static Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) =>
      _sendJson('PATCH', endpoint, body: body);

  static Future<dynamic> delete(String endpoint) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API DELETE] Requesting: $url');
      final headers = await _getHeaders();
      final response = await http
          .delete(url, headers: headers)
          .timeout(_timeout);
      return await _handleResponse(response, headers);
    } on TimeoutException catch (_) {
      throw Exception(
        'Koneksi timeout ($url). Server backend tidak merespons dalam 10 detik.',
      );
    } on http.ClientException catch (e) {
      throw Exception(_clientExceptionMessage(e, url));
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Gagal menghubungi API ($url): $e');
    }
  }

  static Future<dynamic> _handleResponse(
    http.Response response,
    Map<String, String> headers,
  ) async {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw ApiResponseException(
        response.statusCode,
        'Format respons server tidak valid (${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic>) {
        if (data['success'] == true ||
            data['status'] == 'success' ||
            data['data'] != null ||
            data['token'] != null) {
          return data;
        }
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Permintaan gagal.');
        }
      }
      return data;
    } else {
      String message;
      final authorization = headers['Authorization'];
      final invalidSession =
          authorization != null &&
          data is Map &&
          (response.statusCode == 401 || data['code'] == 'session_revoked');
      if (invalidSession) {
        final currentToken = await SecureStorage.getToken();
        if (authorization == 'Bearer $currentToken') {
          await SecureStorage.delete('auth_token');
        }
        message =
            data['message']?.toString() ??
            'Sesi login telah berakhir. Silakan masuk kembali.';
      } else {
        message = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : (data is Map && data['pesan'] != null)
            ? data['pesan'].toString()
            : 'HTTP Error ${response.statusCode}';
      }

      if (data is Map && data['errors'] is Map) {
        final errMap = data['errors'] as Map;
        final errorList = <String>[];
        for (final entry in errMap.entries) {
          final val = entry.value;
          if (val is List) {
            errorList.addAll(val.map((e) => e.toString()));
          } else if (val != null) {
            errorList.add(val.toString());
          }
        }
        if (errorList.isNotEmpty) {
          message = errorList.join('\n');
        }
      }

      throw ApiResponseException(
        response.statusCode,
        message,
        invalidSession: invalidSession,
        retryAfter:
            int.tryParse('${data is Map ? data['retry_after'] ?? '' : ''}') ??
            int.tryParse(response.headers['retry-after'] ?? ''),
      );
    }
  }
}
