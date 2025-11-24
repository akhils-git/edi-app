import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../components/nav_bar.dart';

class BookHomeScreen extends StatelessWidget {
  final Category category;

  const BookHomeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF0D1116);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;

    // Simple placeholder list for books — if your API provides book data,
    // this can be replaced by passing the list inside `Category`.
    final sampleBooks = [
      {
        'title': 'The Art of Living',
        'image': 'assets/images/start_screen_one_header.png'
      },
      {
        'title': 'Mindful Moments',
        'image': 'assets/images/start_screen_two_header.png'
      },
      {
        'title': 'Financial Freedom',
        'image': 'assets/images/start_screen_three_header.png'
      },
      {
        'title': 'Healthy Habits',
        'image': 'assets/images/start_screen_one_header.png'
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: titleColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(category.name,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: titleColor)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  itemCount: sampleBooks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.9),
                  itemBuilder: (context, index) {
                    final book = sampleBooks[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(book['image']!,
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(book['title']!,
                            style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF0F1724)
                                    : Colors.white)),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Reuse the NavBar; place Library active index as 1
            NavBar(activeIndex: 1),
          ],
        ),
      ),
    );
  }
}
