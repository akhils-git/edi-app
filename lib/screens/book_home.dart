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
                                flex: 8,
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
                              // Text area: heading, description, author — occupy ~20%.
                              // Reduce padding and font sizes; restrict to single lines
                              // so the small area fits the content.
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF0F1724)
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        book.description,
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF6B7280)
                                              : const Color(0xFF9CA3AF),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if ((book.author ?? '').isNotEmpty)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 12,
                                              color: isLight
                                                  ? const Color(0xFF6B7280)
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                book.author ?? '',
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isLight
                                                      ? const Color(0xFF6B7280)
                                                      : const Color(0xFF9CA3AF),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
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
