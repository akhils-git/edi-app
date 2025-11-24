import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../components/nav_bar.dart';
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
                      return const Center(child: CircularProgressIndicator());
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
                        // Outer card container ensures consistent background and radius.
                        return Container(
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              // Image area: occupies majority of card height.
                              Expanded(
                                flex: 7,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  child: book.thumbnail.isNotEmpty
                                      ? Image.network(
                                          book.thumbnail,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              const Icon(Icons.book),
                                        )
                                      : const ColoredBox(
                                          color: Color(0xFFEAEAF0),
                                          child:
                                              Center(child: Icon(Icons.book)),
                                        ),
                                ),
                              ),
                              // Text area: title + description. Use a slightly
                              // larger flex to allow two lines for description.
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF0F1724)
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        book.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF6B7280)
                                              : const Color(0xFF9CA3AF),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
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
