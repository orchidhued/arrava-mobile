import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static Future<dynamic> uploadProfilePhoto(
    List<int> bytes,
    String filename,
  ) async {
    final url = _buildUri('/student/profile');
    final headers = await _getHeaders();
    // PHP parses uploaded files on POST; Laravel routes it as PUT.
    headers.remove('Content-Type');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['_method'] = 'PUT'
      ..files.add(
        http.MultipartFile.fromBytes('foto_profil', bytes, filename: filename),
      );
    try {
      final response = await (() async {
        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      })().timeout(const Duration(seconds: 30));
      return _handleResponse(response, url);
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

  static Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API GET] Requesting: $url');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(_timeout);
      return _handleResponse(response, url);
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
  }) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API POST] Requesting: $url | Body: $body');
      final headers = await _getHeaders();
      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response, url);
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

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API PUT] Requesting: $url');
      final headers = await _getHeaders();
      final response = await http
          .put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response, url);
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

  static Future<dynamic> delete(String endpoint) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API DELETE] Requesting: $url');
      final headers = await _getHeaders();
      final response = await http
          .delete(url, headers: headers)
          .timeout(_timeout);
      return _handleResponse(response, url);
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

  static dynamic _handleResponse(http.Response response, Uri url) {
    if (kDebugMode) {
      debugPrint(
        '[API RESPONSE] [$url] Status: ${response.statusCode} | Body: ${response.body}',
      );
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Format respons server tidak valid (${response.statusCode}): ${response.body.length > 100 ? response.body.substring(0, 100) : response.body}',
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
      final message = (data is Map && data['message'] != null)
          ? data['message']
          : (data is Map && data['pesan'] != null)
          ? data['pesan']
          : 'HTTP Error ${response.statusCode}';
      throw Exception(message);
    }
  }
}
