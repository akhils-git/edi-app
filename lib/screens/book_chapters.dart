import 'package:flutter/material.dart';

import '../components/loading_box.dart';
import '../components/nav_bar.dart';
import 'user_profile_screen.dart';
import '../services/book_service.dart';
import '../services/chapter_service.dart';
import 'chapter_home.dart';
import '../services/session.dart';
import '../components/star_animation.dart';

class BookChaptersScreen extends StatefulWidget {
  final Book book;
  final String? authToken;

  // Add book thumbnail for chapter detail transfer
  final String? bookThumbnail;

  const BookChaptersScreen(
      {super.key, required this.book, this.authToken, this.bookThumbnail});

  @override
  State<BookChaptersScreen> createState() => _BookChaptersScreenState();
}

class _BookChaptersScreenState extends State<BookChaptersScreen> {
  late Future<List<Chapter>> _future;
  Map<String, Map<String, dynamic>> _chapterStatus = {};

  @override
  void initState() {
    super.initState();
    _future =
        ChapterService.getChaptersForBook(widget.book.id, widget.authToken);
    _fetchPlaybackStatus();
  }

  Future<void> _fetchPlaybackStatus() async {
    final currentUser = UserSession.currentUser;
    if (currentUser == null) return;

    final statusList = await ChapterService.getChapterPlaybackStatusForBook(
      userId: currentUser.id,
      bookId: widget.book.id,
      authToken: widget.authToken,
    );

    if (mounted) {
      setState(() {
        _chapterStatus = {
          for (var item in statusList) item['chapter_id'] as String: item
        };
      });
    }
  }

  String _calculateTotalDuration(String videoDuration) {
    Duration parseDuration(String s) {
      final parts = s.split(':');
      if (parts.length != 3) return Duration.zero;
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2]) ?? 0,
      );
    }

    final total = parseDuration(videoDuration);

    if (total.inMinutes == 0 && total.inSeconds > 0) {
      return '< 1 min lesson';
    }
    return '${total.inMinutes} min lesson';
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
            // Book card + dummy progress bar
            Column(
              children: [
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
                // Dummy Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                          )),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.2, // 2 of 10
                          minHeight: 7,
                          backgroundColor: isLight
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF374151),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF135bec)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You have completed 2 of 10 chapters.',
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
              ],
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
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChapterHomeScreen(
                                  chapter: ch,
                                  bookTitle: widget.book.title,
                                  bookThumbnail: widget.book.thumbnail,
                                ),
                              ),
                            );
                            _fetchPlaybackStatus();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Builder(builder: (context) {
                                    final status = _chapterStatus[ch.id];
                                    final isCompleted = status != null &&
                                        status['chapter_completed'] == true;
                                    return StarAnimation(enabled: isCompleted);
                                  }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isLight
                                            ? Colors.blue.shade50
                                            : const Color(0xFF1F2937),
                                      ),
                                      child: Builder(builder: (context) {
                                        final status = _chapterStatus[ch.id];
                                        final isCompleted = status != null &&
                                            status['chapter_completed'] == true;
                                        return Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.play_circle,
                                          color: isCompleted
                                              ? Colors.green
                                              : const Color(0xFF135bec),
                                        );
                                      }),
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
                                          const SizedBox(height: 4),
                                          Builder(builder: (context) {
                                            final status =
                                                _chapterStatus[ch.id];
                                            final isCompleted = status != null &&
                                                status['chapter_completed'] ==
                                                    true;
                                            final percentage = status != null
                                                ? (status['chapter_percentage']
                                                        as num)
                                                    .toInt()
                                                : 0;

                                            String durationText =
                                                _calculateTotalDuration(
                                                    ch.videoDuration);
                                            String statusText;
                                            if (isCompleted ||
                                                percentage == 100) {
                                              statusText = 'Chapter Completed';
                                            } else if (percentage == 0) {
                                              statusText = "Let's begin";
                                            } else {
                                              statusText =
                                                  '$percentage% Completed';
                                            }

                                            return Text(
                                              '$durationText | $statusText',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isLight
                                                    ? const Color(0xFF6B7280)
                                                    : const Color(0xFF9CA3AF),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16, color: Color(0xFF135bec)),
                                  ],
                                ),
                                ),
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
            NavBar(
                activeIndex: 1,
                onTap: (idx) {
                  if (idx == 2) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const UserProfileScreen()));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
