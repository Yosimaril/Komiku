import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/static/request_action.dart';

class Api {
  static const String _baseUrl = 'https://ubaya.cloud/flutter/160423120/';

  final SecureStorageService _secureStorageService;

  Api(this._secureStorageService);

  Future<Map<String, dynamic>> post({
    required RequestAction action,
    Map<String, dynamic> body = const {},
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode({'action': action.action, ...body}),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
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

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postMultipartAuthenticated({
    required RequestAction action,
    Map<String, dynamic> body = const {},
    Map<String, File> files = const {},
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
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
