import 'dart:math';
import 'package:flutter/material.dart';

import '../services/quiz_service.dart';
import '../services/session.dart';
import 'package:confetti/confetti.dart';
import '../components/loading_box.dart';
import 'quiz_completed_screen.dart';

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
  bool _isSubmitted = false;
  int _score = 0;
  late ConfettiController _confettiController;
  late ConfettiController _wrongConfettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _wrongConfettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _fetchQuestions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _wrongConfettiController.dispose();
    super.dispose();
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

  Future<void> _handleNext() async {
    // Calculate score if submitted
    if (_isSubmitted) {
      final question = _questions[_currentQuestionIndex];
      if (_selectedAnswer == question.correctAnswer) {
        _score++;
      }
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isSubmitted = false;
      });
    } else {
      // Quiz finished logic here
      setState(() {
        _isLoading = true;
      });

      try {
        final token = UserSession.token;
        final currentUser = UserSession.currentUser;

        if (currentUser != null) {
          // Calculate total points as percentage
          final totalPoints = ((_score / _questions.length) * 100).round();

          await QuizService.submitQuizResult(
            userId: currentUser.id,
            chapterId: widget.chapterId,
            totalQuestions: _questions.length,
            correctAnswer: _score,
            totalPoint: totalPoints,
            authToken: token,
          );
        }
      } catch (e) {
        // Handle error silently or show snackbar?
        // For now, we proceed to show the result screen even if submission fails,
        // or we could show an error. Let's just log it and proceed.
        debugPrint('Error submitting quiz result: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => QuizCompletedScreen(
                score: _score,
                totalQuestions: _questions.length,
              ),
            ),
          );
        }
      }
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
          child: Stack(
            children: [
              Column(
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
                        showFeedback: _isSubmitted,
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
                        showFeedback: _isSubmitted,
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
                        showFeedback: _isSubmitted,
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
                        showFeedback: _isSubmitted,
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
                    onPressed: _selectedAnswer != null
                        ? () {
                            if (_isSubmitted) {
                              _handleNext();
                            } else {
                              setState(() {
                                _isSubmitted = true;
                              });
                              // Check if correct and play confetti
                              final question = _questions[_currentQuestionIndex];
                              if (_selectedAnswer == question.correctAnswer) {
                                _confettiController.play();
                              } else {
                                _wrongConfettiController.play();
                              }
                            }
                          }
                        : null,
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
                      _isSubmitted
                          ? (_currentQuestionIndex < _questions.length - 1
                              ? 'Next Question'
                              : 'Finish Quiz')
                          : 'Check Answer',
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
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.lightGreen,
                    Colors.greenAccent,
                  ],
                  createParticlePath: drawHappyFace,
                  numberOfParticles: 15,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                  ],
                  createParticlePath: drawStar,
                  numberOfParticles: 15,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _wrongConfettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.redAccent,
                    Color(0xFFEF5350), // red-400
                  ],
                  createParticlePath: drawSadFace,
                  numberOfParticles: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A custom Path to paint a happy face.
  Path drawHappyFace(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Face
    path.addOval(Rect.fromLTWH(0, 0, w, h));

    // Left Eye
    path.addOval(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.15, h * 0.15));

    // Right Eye
    path.addOval(Rect.fromLTWH(w * 0.6, h * 0.35, w * 0.15, h * 0.15));

    // Mouth (Smile)
    path.moveTo(w * 0.3, h * 0.65);
    path.quadraticBezierTo(w * 0.5, h * 0.85, w * 0.7, h * 0.65);
    path.quadraticBezierTo(w * 0.5, h * 0.75, w * 0.3, h * 0.65);

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  /// A custom Path to paint a sad face.
  Path drawSadFace(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Face
    path.addOval(Rect.fromLTWH(0, 0, w, h));

    // Left Eye
    path.addOval(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.15, h * 0.15));

    // Right Eye
    path.addOval(Rect.fromLTWH(w * 0.6, h * 0.35, w * 0.15, h * 0.15));

    // Mouth (Frown)
    path.moveTo(w * 0.3, h * 0.75);
    path.quadraticBezierTo(w * 0.5, h * 0.55, w * 0.7, h * 0.75);
    path.quadraticBezierTo(w * 0.5, h * 0.65, w * 0.3, h * 0.75);

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  Widget _buildOption({
    required String optionKey,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required bool showFeedback,
    required Color borderColor,
    required Color surfaceColor,
    required Color textColor,
    required Color successColor,
    required bool isLight,
  }) {
    Color currentBorderColor = borderColor;
    Color currentBgColor = surfaceColor;
    Color radioBorderColor = const Color(0xFFD1D5DB);
    Color? radioFillColor;

    if (showFeedback) {
      if (isCorrect) {
        // Correct answer always green
        currentBorderColor = successColor;
        currentBgColor = isLight
            ? const Color(0xFFECFDF5)
            : const Color(0xFF064E3B).withOpacity(0.3);
        radioBorderColor = successColor;
        radioFillColor = successColor;
      } else if (isSelected) {
        // Selected but wrong -> Red
        currentBorderColor = Colors.red;
        currentBgColor = isLight
            ? const Color(0xFFFEF2F2)
            : const Color(0xFF7F1D1D).withOpacity(0.3);
        radioBorderColor = Colors.red;
        radioFillColor = Colors.red;
      }
    } else if (isSelected) {
      // Selected state before feedback (though logic implies immediate feedback)
      currentBorderColor = successColor;
      currentBgColor = isLight
          ? const Color(0xFFECFDF5)
          : const Color(0xFF064E3B).withOpacity(0.3);
      radioBorderColor = successColor;
      radioFillColor = successColor;
    }

    return GestureDetector(
      onTap: () {
        if (!showFeedback) {
          setState(() {
            _selectedAnswer = optionKey;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentBgColor,
          border: Border.all(
            color: currentBorderColor,
            width: (isSelected || (showFeedback && isCorrect)) ? 2 : 1,
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
                  color: radioBorderColor,
                  width: 2,
                ),
              ),
              child: (isSelected || (showFeedback && isCorrect))
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: radioFillColor,
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
