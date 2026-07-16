import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/static/request_action.dart';

class Api {
  static const String _baseUrl = 'https://ubaya.cloud/flutter/160423120/';

  final SecureStorageService _secureStorageService;

  Api(this._secureStorageService);

  /// Helper untuk parse response JSON + error handling
  Map<String, dynamic> _parseResponse(http.Response response) {
    // Server bisa mengirim 201 (Created) saat insert sukses.
    // Jadi anggap sukses untuk 2xx, selain itu baru lempar error.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Server returned status ${response.statusCode}: ${response.body}',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Failed to parse server response: ${response.body.substring(0, response.body.length.clamp(0, 200))}',
      );
    }
  }

  Future<Map<String, dynamic>> post({
    required RequestAction action,
    Map<String, dynamic> body = const {},
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode({'action': action.action, ...body}),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> postAuthenticated({
    required RequestAction action,
    Map<String, dynamic> body = const {},
  }) async {
    final token = await _secureStorageService.getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {..._headers(), 'Authorization': 'Bearer $token'},
      body: jsonEncode({'action': action.action, ...body}),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> postMultipartAuthenticated({
    required RequestAction action,
    Map<String, dynamic> body = const {},
    Map<String, dynamic> files = const {},
  }) async {
    final token = await _secureStorageService.getToken();

    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));


    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['action'] = action.action;

    body.forEach((key, value) {
      request.fields[key] = jsonEncode(value);
    });

    for (final entry in files.entries) {
      // For web, `files` should contain bytes + filename.
      // For mobile/desktop, it can contain `dart:io` File.
      final value = entry.value;

      if (kIsWeb) {
        // Expecting value shape: {"bytes": Uint8List, "filename": String}
        if (value is Map && value['bytes'] is Uint8List && value['filename'] is String) {
          request.files.add(
            http.MultipartFile.fromBytes(
              entry.key,
              value['bytes'] as Uint8List,
              filename: value['filename'] as String,
            ),
          );
        } else {
          throw Exception('Unsupported web multipart file payload for key ${entry.key}');
        }
      } else {

        // Mobile/Desktop: expect File
        if (value is File) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, value.path),
          );
        } else {
          throw Exception('Unsupported non-web multipart file payload for key ${entry.key}');
        }
      }
    }


    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _parseResponse(response);
  }

  Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
