import 'package:flutter/material.dart';

import '../services/quiz_service.dart';
import '../services/session.dart';
import '../components/loading_box.dart';

class QuizScreen extends StatefulWidget {
  final String chapterId;
  const QuizScreen({super.key, required this.chapterId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _error;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer; // 'option_a', 'option_b', etc.

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final token = UserSession.token;
      final questions =
          await QuizService.fetchQuestions(widget.chapterId, token);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleNext() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      // Quiz finished logic here
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF3F4F6) : const Color(0xFF121212);
    final surfaceColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final primaryColor = const Color(0xFF007AFF);
    final textColor = isLight ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final secondaryTextColor =
        isLight ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final borderColor =
        isLight ? const Color(0xFFE5E7EB) : const Color(0xFF374151);
    final successColor = const Color(0xFF34D399);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const LoadingBox(message: 'Loading Quiz...'),
          ),
        ),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Center(
                child: Text(_error ?? 'No questions found',
                    style: TextStyle(color: textColor))),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for modal effect
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: double.infinity,
          constraints:
              const BoxConstraints(maxWidth: 480), // Max width for tablet/desktop
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 28, color: secondaryTextColor),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '${_currentQuestionIndex + 1}/${_questions.length}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: _handleNext,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        question.questionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24, // Approx 3xl
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildOption(
                        optionKey: 'option_a',
                        text: question.optionA,
                        isSelected: _selectedAnswer == 'option_a',
                        isCorrect: question.correctAnswer == 'option_a',
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        optionKey: 'option_b',
                        text: question.optionB,
                        isSelected: _selectedAnswer == 'option_b',
                        isCorrect: question.correctAnswer == 'option_b',
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        optionKey: 'option_c',
                        text: question.optionC,
                        isSelected: _selectedAnswer == 'option_c',
                        isCorrect: question.correctAnswer == 'option_c',
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        optionKey: 'option_d',
                        text: question.optionD,
                        isSelected: _selectedAnswer == 'option_d',
                        isCorrect: question.correctAnswer == 'option_d',
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer != null ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                    ),
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Next Question'
                          : 'Finish Quiz',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String optionKey,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required Color borderColor,
    required Color surfaceColor,
    required Color textColor,
    required Color successColor,
    required bool isLight,
  }) {
    // Logic for styling based on selection
    // If selected, we show if it's correct or not (for immediate feedback)
    // OR we just show it as selected.
    // Based on the user request, we'll just show selection state for now.
    // If we want to show correct/incorrect immediately:
    // Color currentBorderColor = isSelected ? (isCorrect ? successColor : Colors.red) : borderColor;

    // For now, let's just highlight selection.
    // If the user wants immediate feedback (green for correct), we can use isCorrect.
    // The design implies "correct" answer is green. Let's assume we show the green style if selected.

    Color currentBorderColor = borderColor;
    Color currentBgColor = surfaceColor;

    if (isSelected) {
      currentBorderColor = successColor;
      currentBgColor = isLight
          ? const Color(0xFFECFDF5)
          : const Color(0xFF064E3B).withOpacity(0.3);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = optionKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentBgColor,
          border: Border.all(
            color: currentBorderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Custom Radio
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? successColor : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
