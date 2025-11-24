import 'package:flutter/material.dart';

class StartScreenThree extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  final VoidCallback? onSkip;

  const StartScreenThree({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    this.onNext,
    this.onPrev,
    this.onSkip,
  });

  Color _background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF6F6F8)
        : const Color(0xFF101622);
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF111318)
        : const Color(0xFFFFFFFF);
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF111318)
        : const Color(0xFFBFC7D6);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF135BEC);

    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        child: Column(
          children: [
            // top app bar area with Skip
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 36),
                  GestureDetector(
                    onTap: () {
                      if (onSkip != null) {
                        onSkip!();
                        return;
                      }
                      if (onNext != null) onNext!();
                    },
                    child: Text('Skip',
                        style: TextStyle(
                            color: _textSecondary(context),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // header image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            'assets/images/start_screen_three_header.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // texts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text('Speak English with Confidence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _textPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                      'Achieve fluency with our 100% online courses. Learn anytime, anywhere, at your own pace.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _textSecondary(context),
                          fontSize: 16,
                          height: 1.4)),
                ],
              ),
            ),

            const Spacer(),

            // footer indicators and CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 8),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 8),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(8))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 6),
                      onPressed: () {
                        if (onNext != null) onNext!();
                      },
                      child: const Text('Continue',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
