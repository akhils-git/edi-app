import 'package:flutter/material.dart';

class QuizCompletedScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surfaceColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final primaryColor = const Color(0xFF007AFF);
    final textColor = isLight ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final secondaryTextColor =
        isLight ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final successColor = const Color(0xFF34D399);
    final warningColor = const Color(0xFFFBBF24);

    final percentage = (score / totalQuestions * 100).round();

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Header
            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: successColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: successColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Quiz Completed!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      "You've successfully completed the chapter quiz. Keep up the fantastic work!",
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Score Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(isLight ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Score',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isLight
                                      ? primaryColor
                                      : const Color(0xFF7DD3FC), // sky-300
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$score/$totalQuestions ($percentage%)',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: List.generate(3, (index) {
                              // 3 stars logic:
                              // 100% -> 3 stars
                              // >= 66% -> 2 stars
                              // >= 33% -> 1 star
                              // < 33% -> 0 stars
                              int stars = 0;
                              if (percentage == 100) {
                                stars = 3;
                              } else if (percentage >= 66) {
                                stars = 2;
                              } else if (percentage >= 33) {
                                stars = 1;
                              }

                              return Icon(
                                index < stars ? Icons.star : Icons.star_border,
                                size: 36,
                                color: warningColor,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
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
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Back to Chapter',
                    style: TextStyle(
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
    );
  }
}
