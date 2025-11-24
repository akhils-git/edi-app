import 'package:flutter/material.dart';

import '../components/loading_box.dart';
import '../components/nav_bar.dart';
import '../services/book_service.dart';
import '../services/chapter_service.dart';

class BookChaptersScreen extends StatefulWidget {
  final Book book;
  final String? authToken;

  const BookChaptersScreen({super.key, required this.book, this.authToken});

  @override
  State<BookChaptersScreen> createState() => _BookChaptersScreenState();
}

class _BookChaptersScreenState extends State<BookChaptersScreen> {
  late Future<List<Chapter>> _future;

  @override
  void initState() {
    super.initState();
    _future =
        ChapterService.getChaptersForBook(widget.book.id, widget.authToken);
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
                    child: Text(widget.book.title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: titleColor)),
                  ),
                ],
              ),
            ),

            // Top book card (summary)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // text block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.book.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              )),
                          const SizedBox(height: 6),
                          if ((widget.book.author ?? '').isNotEmpty)
                            Text('By ${widget.book.author}',
                                style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                )),
                        ],
                      ),
                    ),

                    // thumbnail
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFEAEAF0),
                        image: widget.book.thumbnail.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.book.thumbnail),
                                fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chapters list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<Chapter>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LoadingBox(message: 'Loading chapters');
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final chapters = snap.data ?? [];
                    if (chapters.isEmpty) {
                      return const Center(child: Text('No chapters'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      itemCount: chapters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ch = chapters[index];
                        return InkWell(
                          onTap: () {
                            // TODO: open chapter player or detail screen
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ch.mediaCount > 0
                                        ? Colors.blue.shade50
                                        : (isLight
                                            ? Colors.green.shade50
                                            : Colors.green.shade900
                                                .withOpacity(0.12)),
                                  ),
                                  child: Icon(
                                    ch.mediaCount > 0
                                        ? Icons.play_circle
                                        : Icons.check_circle,
                                    color: ch.mediaCount > 0
                                        ? Colors.blue
                                        : Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ch.heading,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: titleColor,
                                          )),
                                      const SizedBox(height: 4),
                                      Text(
                                        ch.description.isNotEmpty
                                            ? ch.description
                                            : '${ch.mediaCount} min lesson',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isLight
                                              ? const Color(0xFF6B7280)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.blue),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // reuse nav bar
            NavBar(activeIndex: 1),
          ],
        ),
      ),
    );
  }
}
