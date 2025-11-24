import 'package:flutter/material.dart';
import '../services/chapter_service.dart';
import '../components/nav_bar.dart';
import 'video_player_screen.dart';

class ChapterHomeScreen extends StatelessWidget {
  final Chapter chapter;
  final String? bookTitle;
  final String? bookThumbnail;

  const ChapterHomeScreen(
      {super.key, required this.chapter, this.bookTitle, this.bookThumbnail});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF101622);
    final cardBg = isLight ? Colors.white : const Color(0xFF23272F);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;
    final subtitleColor =
        isLight ? const Color(0xFF6B7280) : const Color(0xFFBFC9DA);
    return Scaffold(
      backgroundColor: bgColor,
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
                    child: Text(
                      bookTitle ?? 'Chapter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // ...existing code for summary, video, audio, quiz...
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chapter Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          chapter.description.isNotEmpty
                              ? chapter.description
                              : 'No summary available.',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ...existing code for video/audio/quiz...
                  Container(
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black : const Color(0xFF23272F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 18),

                    child: chapter.videoFile.isNotEmpty
                        ? Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: bookThumbnail != null && bookThumbnail!.isNotEmpty
                                    ? Image.network(bookThumbnail!, fit: BoxFit.cover)
                                    : Container(color: Colors.black),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (chapter.videoFile.isNotEmpty) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (_) => VideoPlayerScreen(url: chapter.videoFile)));
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Dummy controls bar
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.replay_10, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('1:23', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8),
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: 0.25,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text('4:56', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      const SizedBox(width: 8),
                                      Icon(Icons.fullscreen, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 180,
                            alignment: Alignment.center,
                            child: Text('No Video available !',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(16),
                    child: chapter.audioFile.isNotEmpty
                        ? Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF135bec),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.pause,
                                    color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chapter.heading,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: titleColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: 0.33,
                                        minHeight: 4,
                                        backgroundColor: isLight
                                            ? const Color(0xFFE5E7EB)
                                            : const Color(0xFF374151),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                const Color(0xFF135bec)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('01:32',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: subtitleColor)),
                                        Text('04:15',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: subtitleColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 80,
                            alignment: Alignment.center,
                            child: Text('No Audio available !',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Score',
                                style: TextStyle(
                                    fontSize: 13, color: subtitleColor)),
                            Text('85%',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor))
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF135bec),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {},
                          child: Text('Start Quiz',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(activeIndex: 1),
    );
  }
}
