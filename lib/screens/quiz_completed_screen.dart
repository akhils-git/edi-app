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
                    SuccessAnimation(color: successColor),
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

class SuccessAnimation extends StatefulWidget {
  final Color color;
  const SuccessAnimation({super.key, required this.color});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: CheckPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    final p1 = Offset(w * 0.28, h * 0.52);
    final p2 = Offset(w * 0.45, h * 0.70);
    final p3 = Offset(w * 0.75, h * 0.35);

    final l1 = (p2 - p1).distance;
    final l2 = (p3 - p2).distance;
    final total = l1 + l2;

    final currentLen = total * progress;

    path.moveTo(p1.dx, p1.dy);

    if (currentLen <= l1) {
      final t = currentLen / l1;
      final p = Offset.lerp(p1, p2, t)!;
      path.lineTo(p.dx, p.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (currentLen - l1) / l2;
      final p = Offset.lerp(p2, p3, t)!;
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
