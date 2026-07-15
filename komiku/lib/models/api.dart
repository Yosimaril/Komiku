import 'dart:convert';

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
      body: jsonEncode({
        'action': action.action,
        ...body,
      }),
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
      headers: {
        ..._headers(),
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'action': action.action,
        ...body,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
