import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants.dart';

class Book {
  final String id;
  final String categoryId;
  final String ownerId;
  final String title;
  final String? author;
  final String description;
  final String thumbnail;

  Book({
    required this.id,
    required this.categoryId,
    required this.ownerId,
    required this.title,
    this.author,
    required this.description,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['_id'] as String,
        categoryId: json['category_id'] as String? ?? '',
        ownerId: json['ownerId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        author: json['author'] as String?,
        description: json['description'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );
}

class BookService {
  BookService._();

  /// GET /api/v1/books/category/<categoryId>
  static Future<List<Book>> getBooksForCategory(String categoryId,
      [String? authToken]) async {
    final uri = Uri.parse('${apiBaseUrl}api/v1/books/category/$categoryId');
    final headers = <String, String>{'Accept': 'application/json'};
    if (authToken != null && authToken.isNotEmpty)
      headers['Authorization'] = 'Bearer $authToken';

    if (headers.containsKey('Authorization')) {
      print(
          'BookService.getBooksForCategory: Authorization=${headers['Authorization']}');
    } else {
      print('BookService.getBooksForCategory: No Authorization header');
    }

    http.Response resp;
    try {
      resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
    } on SocketException catch (e) {
      throw Exception(
          'Network error: $e. Ensure the backend at $apiBaseUrl is running and reachable from the device.');
    }

    print('BookService.getBooksForCategory: status=${resp.statusCode}');
    if (resp.statusCode == 200) {
      try {
        final decoded = jsonDecode(resp.body);
        final List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          data = decoded['data'] as List<dynamic>;
        } else {
          data = [];
        }
        return data
            .map((e) => Book.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Invalid response format: $e');
      }
    }

    print('BookService.getBooksForCategory: body=${resp.body}');
    throw Exception('Failed to load books: ${resp.statusCode} ${resp.body}');
  }
}
