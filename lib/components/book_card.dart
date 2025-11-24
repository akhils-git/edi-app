import 'package:flutter/material.dart';
import '../services/book_service.dart';

/// A reusable book card showing a thumbnail, title, description and optional
/// author. Designed to fit inside a GridView with a portrait aspect ratio.
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            // Image area (~80%)
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
                        errorBuilder: (c, e, s) => const Icon(Icons.book),
                      )
                    : const ColoredBox(
                        color: Color(0xFFEAEAF0),
                        child: Center(child: Icon(Icons.book)),
                      ),
              ),
            ),

            // Text area (~20%)
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF0F1724) : Colors.white,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }
}
