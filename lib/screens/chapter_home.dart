import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/chapter_service.dart';
import '../components/nav_bar.dart';
import 'user_profile_screen.dart';
import 'video_player_screen.dart';
import '../services/quiz_service.dart';
import '../services/session.dart';
import 'quiz_screen.dart';
import 'package:floating/floating.dart';

import 'package:flutter/services.dart';

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
  bool _inlineHidden = false;
  bool _isVideoDragging = false;
  double _videoDragValue = 0.0;

  late AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  bool _audioInitialized = false;
  bool _isAudioLoading = false;
  bool _isDragging = false;
  final Floating _floating = Floating();

  // Quiz State
  bool _isLoadingQuizResult = true;
  Map<String, dynamic>? _quizResult;
  bool _hasQuestions = true;

  Timer? _playbackTimer;

  String _formatDurationForApi(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startPlaybackTimer() {
    if (_playbackTimer != null) return;
    _playbackTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _reportPlaybackProgress();
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _updatePlaybackTimerState() {
    final isVideoPlaying = _inlineController != null &&
        _inlineController!.value.isInitialized &&
        _inlineController!.value.isPlaying;
    final isAudioPlaying = _isAudioPlaying;

    if (isVideoPlaying || isAudioPlaying) {
      _startPlaybackTimer();
    } else {
      _stopPlaybackTimer();
    }
  }

  Future<void> _reportPlaybackProgress() async {
    final currentUser = UserSession.currentUser;
    if (currentUser == null) return;

    Duration videoDuration = Duration.zero;
    Duration videoPosition = Duration.zero;

    if (_inlineController != null && _inlineController!.value.isInitialized) {
      videoDuration = _inlineController!.value.duration;
      videoPosition = _inlineController!.value.position;
    }

    await ChapterService.updatePlaybackProgress(
      userId: currentUser.id,
      chapterId: widget.chapter.id,
      bookId: widget.chapter.bookId,
      videoTotalDuration: _formatDurationForApi(videoDuration),
      videoCurrentDuration: _formatDurationForApi(videoPosition),
      audioTotalDuration: _formatDurationForApi(_audioDuration),
      audioCurrentDuration: _formatDurationForApi(_audioPosition),
      authToken: UserSession.token,
    );
  }

  @override
  void initState() {
    super.initState();
    _initAndPlayInline();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
        _updatePlaybackTimerState();
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _audioDuration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted && !_isDragging) {
        setState(() {
          _audioPosition = newPosition;
        });
      }
    });

    _fetchQuizResult();
  }

  Future<void> _fetchQuizResult() async {
    final currentUser = UserSession.currentUser;
    final token = UserSession.token;

    // Check if questions exist
    try {
      final questions =
          await QuizService.fetchQuestions(widget.chapter.id, token);
      _hasQuestions = questions.isNotEmpty;
    } catch (e) {
      _hasQuestions = false;
    }

    if (currentUser != null && _hasQuestions) {
      final result = await QuizService.getQuizResult(
        userId: currentUser.id,
        chapterId: widget.chapter.id,
        authToken: token,
      );
      if (mounted) {
        setState(() {
          _quizResult = result;
          _isLoadingQuizResult = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingQuizResult = false;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _audioPlayer.dispose();
    _stopPlaybackTimer();
    _inlineController?.pause();
    _inlineController?.dispose();
    super.dispose();
  }

  Future<void> _initAndPlayInline() async {
    final url = widget.chapter.videoFile;
    if (url.isEmpty) return;
    _inlineController = VideoPlayerController.network(url);
    await _inlineController!.initialize();

    if (_inlineController!.value.aspectRatio < 1.0) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }

    _inlineController!.addListener(() {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
            _updatePlaybackTimerState();
          }
      });
    });
    setState(() {
      _inlineInitialized = true;
    });
    _inlineController!.play();
  }

  Future<void> _toggleAudio() async {
    if (widget.chapter.audioFile.isEmpty) return;

    setState(() {
      _isAudioLoading = true;
    });

    try {
      if (!_audioInitialized) {
        await _audioPlayer.setSourceUrl(widget.chapter.audioFile);
        setState(() {
          _audioInitialized = true;
        });
      }

      if (_isAudioPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF101622);
    final cardBg = isLight ? Colors.white : const Color(0xFF23272F);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;
    final subtitleColor =
        isLight ? const Color(0xFF6B7280) : const Color(0xFFBFC9DA);
    final surfaceColor = isLight ? Colors.white : const Color(0xFF23272F);
    final borderColor = isLight ? const Color(0xFFE5E7EB) : const Color(0xFF374151);

    final chapter = widget.chapter;
    final bookThumbnail = widget.bookThumbnail;

    // Check for landscape orientation to trigger embedded fullscreen
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape && _inlineInitialized && _inlineController != null) {
      return FullscreenVideoScreen(
        url: chapter.videoFile,
        startPosition: _inlineController!.value.position,
        controller: _inlineController,
        isEmbedded: true,
      );
    }

    return PiPSwitcher(
      childWhenEnabled: _inlineInitialized && _inlineController != null
          ? AspectRatio(
              aspectRatio: _inlineController!.value.aspectRatio,
              child: VideoPlayer(_inlineController!),
            )
          : const SizedBox(),
      childWhenDisabled: Scaffold(
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
                                  aspectRatio: _inlineInitialized &&
                                          _inlineController != null &&
                                          _inlineController!
                                                  .value.aspectRatio >
                                              0
                                      ? _inlineController!.value.aspectRatio
                                      : 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (_inlineInitialized &&
                                            _inlineController != null)
                                          (_inlineHidden
                                              ? Container(color: Colors.black)
                                              : VideoPlayer(_inlineController!))
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
                                        // Keep a tap area so users can toggle playback
                                        // by tapping the video. The icon will fade
                                        // out when playback is active but the handler
                                        // remains available.
                                        Positioned.fill(
                                          child: Center(
                                            child: GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () async {
                                                if (!_inlineInitialized) {
                                                  await _initAndPlayInline();
                                                } else {
                                                  final isPlaying =
                                                      _inlineController!
                                                          .value.isPlaying;
                                                  if (isPlaying) {
                                                    try {
                                                      await _inlineController!
                                                          .pause();
                                                    } catch (_) {}
                                                  } else {
                                                    try {
                                                      await _inlineController!
                                                          .play();
                                                    } catch (_) {}
                                                  }
                                                  if (mounted) setState(() {});
                                                }
                                              },
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                opacity: _inlineInitialized &&
                                                        _inlineController !=
                                                            null &&
                                                        _inlineController!
                                                            .value.isPlaying &&
                                                        !_inlineController!
                                                            .value.isBuffering
                                                    ? 0.0
                                                    : 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: _inlineInitialized &&
                                                          _inlineController !=
                                                              null &&
                                                          _inlineController!
                                                              .value.isBuffering
                                                      ? const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        )
                                                      : Icon(
                                                          _inlineInitialized &&
                                                                  _inlineController !=
                                                                      null &&
                                                                  _inlineController!
                                                                      .value
                                                                      .isPlaying
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
                                                (_inlineController!
                                                            .value.duration >
                                                        Duration.zero
                                                    ? _formatDuration(
                                                        _inlineController!
                                                            .value.duration)
                                                    : '--:--')
                                            : '--:--/--:--',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _inlineInitialized &&
                                                _inlineController != null
                                            ? SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  trackHeight: 4,
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                          enabledThumbRadius: 6),
                                                  overlayShape:
                                                      const RoundSliderOverlayShape(
                                                          overlayRadius: 14),
                                                  activeTrackColor: Colors.blueAccent,
                                                  inactiveTrackColor:
                                                      Colors.white24,
                                                  thumbColor: Colors.blueAccent,
                                                  overlayColor: Colors.blueAccent
                                                      .withOpacity(0.2),
                                                  trackShape:
                                                      const RectangularSliderTrackShape(),
                                                ),
                                                child: Slider(
                                                  value: (_isVideoDragging
                                                          ? _videoDragValue
                                                          : _inlineController!
                                                              .value
                                                              .position
                                                              .inMilliseconds
                                                              .toDouble())
                                                      .clamp(
                                                          0.0,
                                                          _inlineController!.value
                                                                      .duration
                                                                      .inMilliseconds >
                                                                  0
                                                              ? _inlineController!
                                                                  .value
                                                                  .duration
                                                                  .inMilliseconds
                                                                  .toDouble()
                                                              : 1.0),
                                                  min: 0.0,
                                                  max: _inlineController!.value
                                                              .duration.inMilliseconds >
                                                          0
                                                      ? _inlineController!.value
                                                          .duration.inMilliseconds
                                                          .toDouble()
                                                      : 1.0,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _videoDragValue = value;
                                                    });
                                                  },
                                                  onChangeStart: (value) {
                                                    setState(() {
                                                      _isVideoDragging = true;
                                                      _videoDragValue = value;
                                                    });
                                                  },
                                                  onChangeEnd: (value) async {
                                                    await _inlineController!.seekTo(
                                                        Duration(
                                                            milliseconds:
                                                                value.toInt()));
                                                    setState(() {
                                                      _isVideoDragging = false;
                                                    });
                                                  },
                                                ),
                                              )
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
                                          // Hide inline player to avoid two active surfaces
                                          if (mounted)
                                            setState(() => _inlineHidden = true);
                                          await _inlineController!.pause();
                                          final result =
                                              await Navigator.of(context)
                                                  .push<Duration?>(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FullscreenVideoScreen(
                                                      url: chapter.videoFile,
                                                      startPosition: currentPos,
                                                      controller:
                                                          _inlineController),
                                            ),
                                          );
                                          if (result != null) {
                                            await _inlineController!
                                                .seekTo(result);
                                          }
                                          // Ensure play is called after UI is restored
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            _inlineController!.play();
                                          });

                                          if (_inlineController != null &&
                                              _inlineController!.value.aspectRatio <
                                                  1.0) {
                                            SystemChrome.setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.portraitDown,
                                            ]);
                                          }

                                          if (mounted)
                                            setState(() => _inlineHidden = false);
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.fullscreen,
                                            color: Colors.white,
                                            size: 28),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          // Assuming _floating is initialized elsewhere, e.g., final _floating = Floating();
                                          // and 'package:floating/floating.dart' is imported.
                                          // This change only adds the button as per the instruction.
                                          // The actual PiP logic and UI adaptation would be a separate step.
                                          await _floating.enable(ImmediatePiP(
                                              aspectRatio: Rational.landscape()));
                                        },
                                        icon: const Icon(
                                            Icons.picture_in_picture_alt,
                                            color: Colors.white,
                                            size: 28),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: 180,
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.videocam_off,
                                        size: 32, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('No video available',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'This chapter does not contain a video yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
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
                                GestureDetector(
                                  onTap: _toggleAudio,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF135bec),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isAudioLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Icon(
                                            _isAudioPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32),
                                  ),
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
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 4,
                                          thumbShape: const RoundSliderThumbShape(
                                              enabledThumbRadius: 6),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                  overlayRadius: 14),
                                          activeTrackColor:
                                              const Color(0xFF135bec),
                                          inactiveTrackColor: isLight
                                              ? const Color(0xFFE5E7EB)
                                              : const Color(0xFF374151),
                                          thumbColor: const Color(0xFF135bec),
                                          overlayColor: const Color(0xFF135bec)
                                              .withOpacity(0.2),
                                          trackShape:
                                              const RectangularSliderTrackShape(),
                                        ),
                                        child: Slider(
                                          value: (_audioPosition.inMilliseconds >
                                                      0 &&
                                                  _audioPosition.inMilliseconds <=
                                                      _audioDuration
                                                          .inMilliseconds)
                                              ? _audioPosition.inMilliseconds
                                                  .toDouble()
                                              : 0.0,
                                          min: 0.0,
                                          max: _audioDuration.inMilliseconds > 0
                                              ? _audioDuration.inMilliseconds
                                                  .toDouble()
                                              : 1.0,
                                          onChanged: (value) {
                                            setState(() {
                                              _audioPosition = Duration(
                                                  milliseconds: value.toInt());
                                            });
                                          },
                                          onChangeStart: (_) {
                                            setState(() {
                                              _isDragging = true;
                                            });
                                          },
                                          onChangeEnd: (value) async {
                                            await _audioPlayer.seek(Duration(
                                                milliseconds: value.toInt()));
                                            setState(() {
                                              _isDragging = false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formatDuration(_audioPosition),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: subtitleColor)),
                                          Text(_formatDuration(_audioDuration),
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
                              height: 180,
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFF1B2936),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.music_off,
                                        size: 32, color: titleColor),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('No audio available',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: titleColor)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'There is no audio for this chapter yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: subtitleColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Adjusted margin to fit ListView padding
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16), // Adjusted to 16 for consistency
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4))
                          ]),
                      child: _isLoadingQuizResult
                          ? Center(child: CircularProgressIndicator())
                          : !_hasQuestions
                              ? Container(
                                  height: 180,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isLight
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFF1B2936),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.quiz_outlined,
                                            size: 32, color: titleColor),
                                      ),
                                      const SizedBox(height: 12),
                                      Text('No Quiz Available',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: titleColor)),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Check back later for this chapter\'s quiz.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: subtitleColor, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  children: [
                                    if (_quizResult != null) ...[
                                      // Last Score View
                                      Icon(Icons.emoji_events,
                                          color: Colors.amber, size: 32),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Last Score',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: subtitleColor)),
                                          Text(
                                              '${((_quizResult!['correct_answer'] / _quizResult!['total_questions']) * 100).round()}%', // Show percentage
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: titleColor))
                                        ],
                                      ),
                                    ] else ...[
                                      // Fresh Start View
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              Color(0xFFE0E7FF), // Light blue bg
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.quiz,
                                            color: Color(0xFF135bec), size: 24),
                                      ),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Test your knowledge',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: subtitleColor)),
                                          Text('Take the Quiz',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: titleColor))
                                        ],
                                      ),
                                    ],
                                    Spacer(),
                                    if (_quizResult != null &&
                                        ((_quizResult!['correct_answer'] /
                                                    _quizResult![
                                                        'total_questions']) *
                                                100)
                                            .round() ==
                                        100)
                                      const StarConfetti()
                                    else
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF135bec),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12)),
                                        onPressed: () async {
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => QuizScreen(
                                                chapterId: widget.chapter.id),
                                          );
                                          // Refresh result after quiz
                                          _fetchQuizResult();
                                        },
                                        child: Text(
                                            _quizResult != null
                                                ? 'Try Again'
                                                : 'Start Quiz',
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
        bottomNavigationBar: NavBar(
            activeIndex: 1,
            onTap: (idx) {
              if (idx == 2) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UserProfileScreen()));
              }
            }),
      ),
    );
  }
}

class StarConfetti extends StatefulWidget {
  const StarConfetti({super.key});

  @override
  State<StarConfetti> createState() => _StarConfettiState();
}

class _StarConfettiState extends State<StarConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStar(Colors.green, 0),
        _buildStar(Colors.pink, 1),
        _buildStar(Colors.yellow, 2),
        _buildStar(Colors.cyan, 3),
      ],
    );
  }

  Widget _buildStar(Color color, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = (_controller.value + index * 0.25) % 1.0;
        final double scale =
            1.0 + 0.5 * (0.5 - (t - 0.5).abs()); // Triangle wave 1.0 -> 1.25 -> 1.0
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(Icons.star_rounded, color: color, size: 28),
      ),
    );
  }
}
