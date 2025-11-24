import 'package:flutter/material.dart';
import 'start_screen_two.dart';

class StartScreenOne extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const StartScreenOne({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    this.onNext,
    this.onPrev,
  });

  Color _background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF6F6F8)
        : const Color(0xFF101622);
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF1F2937)
        : const Color(0xFFF9FAFB);
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF135BEC);

    // themeMode is passed down; the popup uses it via initialValue

    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        child: Column(
          children: [
            // top header image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                            'assets/images/start_screen_one_header.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // text
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Your English. Your World.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textPrimary(context),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A universal learning platform that helps learners of any age speak fluent English with ease—across continents and cultures.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textSecondary(context),
                          fontSize: 16,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // bottom controls
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
                              color: primary,
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
                              color: primary.withOpacity(0.2),
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
                        elevation: 6,
                      ),
                      onPressed: () {
                        if (onNext != null) {
                          onNext!();
                          return;
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (c) => StartScreenTwo(
                              themeMode: themeMode,
                              onThemeChanged: onThemeChanged),
                        ));
                      },
                      child: const Text('Join the Global Learners',
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
      // Removed theme selection FAB: theme is set via app menu in development
    );
  }
}
