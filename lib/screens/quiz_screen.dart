import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selectedOption = 2; // Default selected for demo (0-indexed)

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

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for modal effect
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 480), // Max width for tablet/desktop
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
                          '3/10',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
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
                        value: 0.3,
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
                        'Which of the following sentences uses the correct verb tense?',
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
                        index: 0,
                        text: 'She will go to the store yesterday.',
                        isSelected: _selectedOption == 0,
                        isCorrect: false, // For demo logic
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        index: 1,
                        text: 'She is goes to the store now.',
                        isSelected: _selectedOption == 1,
                        isCorrect: false,
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        index: 2,
                        text: 'She went to the store yesterday.',
                        isSelected: _selectedOption == 2,
                        isCorrect: true, // This is the correct one in the design
                        borderColor: borderColor,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        successColor: successColor,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                      _buildOption(
                        index: 3,
                        text: 'She go to the store tomorrow.',
                        isSelected: _selectedOption == 3,
                        isCorrect: false,
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
                    onPressed: () {},
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
                      'Next Question',
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
      ),
    );
  }

  Widget _buildOption({
    required int index,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required Color borderColor,
    required Color surfaceColor,
    required Color textColor,
    required Color successColor,
    required bool isLight,
  }) {
    // Logic for styling based on selection (mimicking the HTML design)
    // The design shows the correct answer highlighted in green with a checkmark style radio.
    // Unselected items have a grey border.

    Color currentBorderColor = borderColor;
    Color currentBgColor = surfaceColor;
    
    if (isSelected) {
        // In the design, the selected item (which is correct) has a green border and light green bg
        // We will assume for this dummy UI that the selected item is the "correct" one being shown
        currentBorderColor = successColor;
        currentBgColor = isLight ? const Color(0xFFECFDF5) : const Color(0xFF064E3B).withOpacity(0.3); // green-50 / green-900/30
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
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
          borderRadius: BorderRadius.circular(16), // Rounded-lg approx
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
                  color: isSelected ? successColor : const Color(0xFFD1D5DB), // gray-300
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
