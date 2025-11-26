import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/chapter_service.dart';
import '../components/nav_bar.dart';
import 'video_player_screen.dart';

// Helper to format duration as MM:SS
String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class ChapterHomeScreen extends StatefulWidget {
  final Chapter chapter;
  final String? bookTitle;
  final String? bookThumbnail;

  const ChapterHomeScreen(
      {super.key, required this.chapter, this.bookTitle, this.bookThumbnail});

  @override
  State<ChapterHomeScreen> createState() => _ChapterHomeScreenState();
}

class _ChapterHomeScreenState extends State<ChapterHomeScreen> {
  VideoPlayerController? _inlineController;
  bool _inlineInitialized = false;

  @override
  void dispose() {
    _inlineController?.pause();
    _inlineController?.dispose();
    super.dispose();
  }

  Future<void> _initAndPlayInline() async {
    final url = widget.chapter.videoFile;
    if (url.isEmpty) return;
    _inlineController = VideoPlayerController.network(url);
    await _inlineController!.initialize();
    _inlineController!.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() {
      _inlineInitialized = true;
    });
    _inlineController!.play();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF101622);
    final cardBg = isLight ? Colors.white : const Color(0xFF23272F);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;
    final subtitleColor =
        isLight ? const Color(0xFF6B7280) : const Color(0xFFBFC9DA);

    final chapter = widget.chapter;
    final bookThumbnail = widget.bookThumbnail;

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
                      widget.bookTitle ?? 'Chapter',
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
                                color: titleColor)),
                        const SizedBox(height: 8),
                        Text(
                          chapter.description.isNotEmpty
                              ? chapter.description
                              : 'No summary available.',
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  // Video box: show inline player when initialized, else thumbnail + play button
                  Container(
                    decoration: BoxDecoration(
                        color: isLight ? Colors.black : const Color(0xFF23272F),
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 18),
                    child: chapter.videoFile.isNotEmpty
                        ? Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (_inlineInitialized &&
                                          _inlineController != null)
                                        VideoPlayer(_inlineController!)
                                      else if (bookThumbnail != null &&
                                          bookThumbnail.isNotEmpty)
                                        Image.network(bookThumbnail,
                                            fit: BoxFit.cover)
                                      else
                                        Container(color: Colors.black),
                                      Positioned.fill(
                                        child: Container(
                                            color:
                                                Colors.black.withOpacity(0.28)),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_inlineInitialized) {
                                                await _initAndPlayInline();
                                              } else {
                                                if (_inlineController!
                                                    .value.isPlaying) {
                                                  _inlineController!.pause();
                                                } else {
                                                  _inlineController!.play();
                                                }
                                                setState(() {});
                                              }
                                            },
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              opacity: (_inlineInitialized &&
                                                      _inlineController !=
                                                          null &&
                                                      _inlineController!
                                                          .value.isPlaying)
                                                  ? 0.0
                                                  : 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Icon(
                                                    _inlineInitialized &&
                                                            _inlineController !=
                                                                null &&
                                                            _inlineController!
                                                                .value.isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // controls bar below video
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        if (!_inlineInitialized ||
                                            _inlineController == null) return;
                                        final current =
                                            _inlineController!.value.position;
                                        final target = current -
                                            const Duration(seconds: 10);
                                        final seekTo = target > Duration.zero
                                            ? target
                                            : Duration.zero;
                                        await _inlineController!.seekTo(seekTo);
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.replay_10,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _inlineInitialized &&
                                              _inlineController != null
                                          ? _formatDuration(_inlineController!
                                                  .value.position) +
                                              '/' +
                                              _formatDuration(_inlineController!
                                                  .value.duration)
                                          : '--:--/--:--',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _inlineInitialized &&
                                              _inlineController != null
                                          ? VideoProgressIndicator(_inlineController!,
                                              allowScrubbing: true,
                                              colors: VideoProgressColors(
                                                  playedColor: Colors.white,
                                                  bufferedColor: Colors.white54,
                                                  backgroundColor:
                                                      Colors.white24))
                                          : Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(2)),
                                              child: FractionallySizedBox(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  widthFactor: 0.25,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  2))))),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () async {
                                        if (!_inlineInitialized ||
                                            _inlineController == null) return;
                                        final wasPlaying =
                                            _inlineController!.value.isPlaying;
                                        final currentPos =
                                            _inlineController!.value.position;
                                        await _inlineController!.pause();
                                        final result =
                                            await Navigator.of(context)
                                                .push<Duration?>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                FullscreenVideoScreen(
                                                    url: chapter.videoFile,
                                                    startPosition: currentPos),
                                          ),
                                        );
                                        if (result != null) {
                                          await _inlineController!
                                              .seekTo(result);
                                        }
                                        if (wasPlaying)
                                          _inlineController!.play();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.fullscreen,
                                          color: Colors.white),
                                    ),
                                  ],
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
                                    fontWeight: FontWeight.w600)),
                          ),
                  ),
                  // audio and quiz cards follow (existing UI)
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
                                          color: titleColor),
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
                                    fontWeight: FontWeight.w600)),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: cardBg, borderRadius: BorderRadius.circular(16)),
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
                                  horizontal: 24, vertical: 12)),
                          onPressed: () {},
                          child: Text('Start Quiz',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
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
