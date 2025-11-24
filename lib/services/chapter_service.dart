import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants.dart';

class Chapter {
  final String id;
  final String bookId;
  final String heading;
  final String description;
  final int mediaCount;
  final String videoFile;
  final String audioFile;
  final String thumbnail;

  Chapter({
    required this.id,
    required this.bookId,
    required this.heading,
    required this.description,
    required this.mediaCount,
    required this.videoFile,
    required this.audioFile,
    required this.thumbnail,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['_id'] as String? ?? '',
        bookId: json['bookId'] as String? ?? '',
        heading: json['heading'] as String? ?? '',
        description: json['description'] as String? ?? '',
        mediaCount: (json['mediaCount'] as num?)?.toInt() ?? 0,
        videoFile: json['video_file'] as String? ?? '',
        audioFile: json['audio_file'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );
}

class ChapterService {
  ChapterService._();

  /// GET /api/v1/chapters/book/<bookId>
  static Future<List<Chapter>> getChaptersForBook(String bookId,
      [String? authToken]) async {
    final uri = Uri.parse('${apiBaseUrl}api/v1/chapters/book/$bookId');
    final headers = <String, String>{'Accept': 'application/json'};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    if (headers.containsKey('Authorization')) {
      print('ChapterService: Authorization=${headers['Authorization']}');
    }

    http.Response resp;
    try {
      resp = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 15),
          );
    } on SocketException catch (e) {
      if (Platform.isAndroid) {
        final fallback =
            Uri.parse('http://10.0.2.2:3010/api/v1/chapters/book/$bookId');
        try {
          print('ChapterService: SocketException, retrying with $fallback');
          resp = await http.get(fallback, headers: headers).timeout(
                const Duration(seconds: 10),
              );
        } catch (e2) {
          throw Exception('Network error: $e2');
        }
      } else {
        throw Exception('Network error: $e');
      }
    }

    print('ChapterService.getChaptersForBook: status=${resp.statusCode}');
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
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Invalid response format: $e');
      }
    }

    print('ChapterService.getChaptersForBook: body=${resp.body}');
    throw Exception('Failed to load chapters: ${resp.statusCode} ${resp.body}');
  }
}
