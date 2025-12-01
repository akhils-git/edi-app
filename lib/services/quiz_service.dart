import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class Question {
  final String id;
  final String chapterId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  Question({
    required this.id,
    required this.chapterId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      chapterId: json['chapter_id'],
      questionText: json['questionText'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAnswer: json['correctAnswer'],
    );
  }
}

class QuizService {
  static Future<List<Question>> fetchQuestions(String chapterId,
      [String? authToken]) async {
    final url = Uri.parse('${apiBaseUrl}api/v1/questions/$chapterId');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((q) => Question.fromJson(q)).toList();
        } else {
          throw Exception('Failed to load questions: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }


  static Future<void> submitQuizResult({
    required String userId,
    required String chapterId,
    required int totalQuestions,
    required int correctAnswer,
    required int totalPoint,
    String? authToken,
  }) async {
    final url = Uri.parse('${apiBaseUrl}api/v1/quiz-results');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    final body = json.encode({
      'user_id': userId,
      'chapter_id': chapterId,
      'total_questions': totalQuestions,
      'correct_answer': correctAnswer,
      'total_point': totalPoint,
    });

    print('Submitting quiz result to: $url');
    print('Request body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] != true) {
          throw Exception(
              'Failed to submit quiz result: ${jsonResponse['message']}');
        }
      } else {
        print('Failed response body: ${response.body}');
        throw Exception(
            'Failed to submit quiz result: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting quiz result: $e');
    }
  }


  static Future<Map<String, dynamic>?> getQuizResult({
    required String userId,
    required String chapterId,
    String? authToken,
  }) async {
    final url = Uri.parse('${apiBaseUrl}api/v1/quiz-results/get-result');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    final body = json.encode({
      'user_id': userId,
      'chapter_id': chapterId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          // Quiz result not found or other logical failure
          return null;
        }
      } else {
        // Handle 404 or other errors as "not found" or throw
        // The user request says "responce body fail" implies success: false
        // We can treat non-200 or success: false as null result
        return null;
      }
    } catch (e) {
      print('Error fetching quiz result: $e');
      return null;
    }
  }
}
