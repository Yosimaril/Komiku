import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komiku/static/request_action.dart';

class Api {
  static const String _baseUrl = 'https://ubaya.cloud/flutter/160423120/';

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
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _authenticatedHeaders(),
      body: jsonEncode({'action': action.action, ...body}),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, String> _authenticatedHeaders() {
    return {..._headers(), 'Authorization': 'Bearer TEMPORARY'};
  }
}
