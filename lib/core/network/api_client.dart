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

  static Future<dynamic> _sendJson(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = _buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[API $method] Requesting: $url');
      final headers = await _getHeaders();
      final encoded = body != null ? jsonEncode(body) : null;
      final Future<http.Response> req;
      switch (method) {
        case 'POST':
          req = http.post(url, headers: headers, body: encoded);
          break;
        case 'PUT':
          req = http.put(url, headers: headers, body: encoded);
          break;
        case 'PATCH':
          req = http.patch(url, headers: headers, body: encoded);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      final response = await req.timeout(_timeout);
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
  }) =>
      _sendJson('POST', endpoint, body: body);

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) =>
      _sendJson('PUT', endpoint, body: body);

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) =>
      _sendJson('PATCH', endpoint, body: body);

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
      String message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['pesan'] != null)
          ? data['pesan'].toString()
          : 'HTTP Error ${response.statusCode}';

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

      throw Exception(message);
    }
  }
}
