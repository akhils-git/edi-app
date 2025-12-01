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
}
