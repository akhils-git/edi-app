import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../components/nav_bar.dart';
import '../components/book_card.dart';
import '../components/loading_box.dart';
import '../services/book_service.dart';

class BookHomeScreen extends StatefulWidget {
  final Category category;
  final String? authToken;

  const BookHomeScreen({super.key, required this.category, this.authToken});

  @override
  State<BookHomeScreen> createState() => _BookHomeScreenState();
}

class _BookHomeScreenState extends State<BookHomeScreen> {
  late Future<List<Book>> _future;

  @override
  void initState() {
    super.initState();
    _future =
        BookService.getBooksForCategory(widget.category.id, widget.authToken);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF0D1116);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: titleColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.category.name,
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
                child: FutureBuilder<List<Book>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingBox(message: 'Loading your books');
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final books = snap.data ?? [];
                    if (books.isEmpty) {
                      return const Center(
                          child: Text('No books in this category'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      itemCount: books.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        // Portrait card: taller than wide. Tweak this number if you
                        // want a different thumbnail/title proportion.
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(book: book);
                      },
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
