import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';

class Category {
  final String id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
      );
}

class CategoryService {
  CategoryService._();

  /// Fetch categories. If [authToken] is provided it will be sent as
  /// `Authorization: Bearer <token>`.
  static Future<List<Category>> getCategories([String? authToken]) async {
    final uri = Uri.parse('${apiBaseUrl}api/v1/categories');
    final headers = <String, String>{'Accept': 'application/json'};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    // Debug: print the Authorization header when present so we can
    // verify the token is being sent from the device.
    if (headers.containsKey('Authorization')) {
      // avoid printing very long tokens in production; this is debug-only
      print(
          'CategoryService.getCategories: Authorization=${headers['Authorization']}');
    } else {
      print('CategoryService.getCategories: No Authorization header');
    }

    final resp = await http.get(uri, headers: headers);
    print('CategoryService.getCategories: response status=${resp.statusCode}');
    if (resp.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(resp.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Log body for easier diagnosis (helpful for 401 responses)
    print('CategoryService.getCategories: response body=${resp.body}');
    throw Exception(
        'Failed to load categories: ${resp.statusCode} ${resp.body}');
  }
}
