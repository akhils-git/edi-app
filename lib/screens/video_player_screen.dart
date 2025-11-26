import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class FullscreenVideoScreen extends StatefulWidget {
  final String url;
  final Duration startPosition;

  const FullscreenVideoScreen(
      {Key? key, required this.url, required this.startPosition})
      : super(key: key);

  @override
  State<FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<FullscreenVideoScreen> {
  // Helper to format duration as MM:SS
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Force landscape and immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) async {
        // Seek to the position passed from previous screen
        await _controller.seekTo(widget.startPosition);
        _controller.addListener(() {
          if (mounted) setState(() {});
        });
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  Future<void> _restoreAndPop() async {
    final pos = _controller.value.position;
    await _controller.pause();
    // Do not dispose the controller here — let the framework call dispose()
    // to avoid accessing a disposed controller from lifecycle callbacks.
    // Restore portrait mode and UI
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (mounted) Navigator.of(context).pop(pos);
  }

  @override
  void dispose() {
    // In case dispose is called directly, try restoring orientations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Guard controller accesses — it may already be disposed if pop logic
    // disposed it earlier. Use try/catch to avoid throwing during teardown.
    try {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } catch (_) {
      // ignore errors reading controller state if it's already disposed
    }
    try {
      _controller.dispose();
    } catch (_) {
      // ignore if already disposed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _restoreAndPop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _initialized
            ? Stack(
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () async {
                        await _restoreAndPop();
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final current = _controller.value.position;
                            final target =
                                current - const Duration(seconds: 10);
                            final seekTo =
                                target > Duration.zero ? target : Duration.zero;
                            await _controller.seekTo(seekTo);
                            setState(() {});
                          },
                          icon:
                              const Icon(Icons.replay_10, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.blueAccent,
                                  bufferedColor: Colors.white54,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  _formatDuration(_controller.value.position) +
                                      '/' +
                                      _formatDuration(
                                          _controller.value.duration),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Helper to format duration as MM:SS
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  void _startHideTimerIfNeeded() {
    _hideTimer?.cancel();
    if (_controller.value.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  void _onControllerUpdated() {
    if (!mounted) return;
    final playing = _controller.value.isPlaying;
    if (playing) {
      _startHideTimerIfNeeded();
    } else {
      // if paused or buffering, keep controls visible
      _hideTimer?.cancel();
      if (!_showControls) setState(() => _showControls = true);
    }
    // update UI for progress/time changes
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _controller.addListener(_onControllerUpdated);
        setState(() {
          _initialized = true;
        });
        _controller.play();
        // ensure hide timer gets scheduled after playback begins
        _startHideTimerIfNeeded();
      });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                    if (_showControls) _startHideTimerIfNeeded();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final current = _controller.value.position;
                                final target =
                                    current - const Duration(seconds: 10);
                                final seekTo = target > Duration.zero
                                    ? target
                                    : Duration.zero;
                                await _controller.seekTo(seekTo);
                                setState(() {});
                              },
                              icon: const Icon(Icons.replay_10,
                                  color: Colors.white),
                            ),
                            // show play/pause only when NOT playing — hide during playback
                            !_controller.value.isPlaying
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_controller.value.isPlaying) {
                                          _controller.pause();
                                          _hideTimer?.cancel();
                                          _showControls = true;
                                        } else {
                                          _controller.play();
                                          _startHideTimerIfNeeded();
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox(width: 48, height: 48),
                            IconButton(
                              onPressed: () async {
                                final wasPlaying = _controller.value.isPlaying;
                                final currentPos = _controller.value.position;
                                await _controller.pause();
                                final result =
                                    await Navigator.of(context).push<Duration?>(
                                  MaterialPageRoute(
                                    builder: (_) => FullscreenVideoScreen(
                                      url: widget.url,
                                      startPosition: currentPos,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await _controller.seekTo(result);
                                }
                                if (wasPlaying) {
                                  _controller.play();
                                  _startHideTimerIfNeeded();
                                }
                              },
                              icon: const Icon(Icons.fullscreen,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: Colors.blueAccent,
                                      bufferedColor: Colors.white54,
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      _formatDuration(
                                              _controller.value.position) +
                                          '/' +
                                          _formatDuration(
                                              _controller.value.duration),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
