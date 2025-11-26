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
  final VideoPlayerController?
      controller; // optional existing controller to reuse

  const FullscreenVideoScreen(
      {Key? key,
      required this.url,
      required this.startPosition,
      this.controller})
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
  VoidCallback? _fullscreenListener;
  bool _loadError = false;
  String? _errorMessage;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    // Force landscape and immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Initialize controller async (don't mark initState async)
    _initializeFullscreen();
  }

  Future<void> _initializeFullscreen() async {
    // If an existing controller was provided, reuse it to avoid creating
    // a second MediaCodec/ExoPlayer instance which can cause native crashes.
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
      // If the provided controller isn't initialized, initialize it first.
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
      // seek to desired start position
      await _controller.seekTo(widget.startPosition);
      // attach listener below and start playing
      _fullscreenListener = () {
        try {
          if (!mounted) return;
          if (_controller.value.hasError) {
            // Record the error once and surface a user-facing message.
            if (!_loadError) {
              _loadError = true;
              _errorMessage =
                  _controller.value.errorDescription ?? 'Playback error';
              try {
                _controller.pause();
              } catch (_) {}
              try {
                if (_fullscreenListener != null)
                  _controller.removeListener(_fullscreenListener!);
              } catch (_) {}
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Playback error'),
                      content: Text(_errorMessage!),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('OK')),
                      ],
                    ),
                  ).then((_) {
                    if (mounted) Navigator.of(context).pop();
                  });
                });
              }
            }
            return;
          }
          if (mounted) setState(() {});
        } catch (e, st) {
          debugPrint('Fullscreen listener error: $e\n$st');
        }
      };
      _controller.addListener(_fullscreenListener!);
      if (mounted)
        setState(() {
          _initialized = true;
        });
      try {
        await _controller.play();
      } catch (e) {
        _loadError = true;
        _errorMessage = e.toString();
        debugPrint('Error starting playback in fullscreen: $_errorMessage');
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Playback error'),
                content: Text(_errorMessage!),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK')),
                ],
              ),
            ).then((_) {
              if (mounted) Navigator.of(context).pop();
            });
          });
        }
      }
      return;
    }

    _ownsController = true;
    _controller = VideoPlayerController.network(widget.url);
    try {
      await _controller.initialize();
      await _controller.seekTo(widget.startPosition);
      _fullscreenListener = () {
        try {
          if (!mounted) return;
          if (_controller.value.hasError) {
            if (!_loadError) {
              _loadError = true;
              _errorMessage =
                  _controller.value.errorDescription ?? 'Playback error';
              debugPrint('Fullscreen video error: $_errorMessage');
              try {
                _controller.pause();
              } catch (_) {}
              try {
                if (_fullscreenListener != null)
                  _controller.removeListener(_fullscreenListener!);
              } catch (_) {}
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Playback error'),
                      content: Text(_errorMessage!),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('OK')),
                      ],
                    ),
                  ).then((_) {
                    if (mounted) Navigator.of(context).pop();
                  });
                });
              }
            }
            return;
          }
          setState(() {});
        } catch (e, st) {
          debugPrint('Fullscreen listener error: $e\n$st');
        }
      };
      _controller.addListener(_fullscreenListener!);
      if (mounted)
        setState(() {
          _initialized = true;
        });
      try {
        await _controller.play();
      } catch (e) {
        debugPrint(
            'Error starting playback in fullscreen (owned controller): $e');
      }
    } catch (e, st) {
      debugPrint('Error initializing fullscreen controller: $e\n$st');
      // Surface an error and pop
      _loadError = true;
      _errorMessage = e.toString();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Playback error'),
              content: Text(_errorMessage!),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK')),
              ],
            ),
          ).then((_) {
            if (mounted) Navigator.of(context).pop();
          });
        });
      }
    }
  }

  Future<void> _restoreAndPop() async {
    final pos = _controller.value.position;
    // If this fullscreen screen owns the controller (it created it),
    // pause it here. If the controller was passed in from the inline
    // player, avoid pausing to prevent races or native resource issues
    // when returning to the inline screen.
    if (_ownsController) {
      try {
        await _controller.pause();
      } catch (_) {}
    }
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
      if (_fullscreenListener != null) {
        _controller.removeListener(_fullscreenListener!);
      }
    } catch (_) {}
    try {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } catch (_) {}
    // Only dispose the underlying controller if this fullscreen screen
    // created/owns it. If the controller was passed in from the inline
    // player, we must not dispose it here (inline screen expects to reuse it).
    if (_ownsController) {
      try {
        _controller.dispose();
      } catch (_) {}
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
  bool _isInFullscreen = false;

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
        // attach listener and keep it removable
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
    try {
      _controller.removeListener(_onControllerUpdated);
    } catch (_) {}
    try {
      if (_controller.value.isInitialized && _controller.value.isPlaying) {
        _controller.pause();
      }
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (_) {}
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
                      // If we are showing fullscreen using the same controller,
                      // don't render the inline VideoPlayer to avoid two active
                      // platform surfaces that can lead to native crashes.
                      _isInFullscreen
                          ? Container(color: Colors.black)
                          : VideoPlayer(_controller),
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
                                // Pause and dispose the inline controller before creating
                                // a fullscreen controller to avoid two active platform
                                // surfaces.
                                try {
                                  await _controller.pause();
                                } catch (_) {}
                                try {
                                  await _controller.dispose();
                                } catch (_) {}
                                if (mounted)
                                  setState(() {
                                    _initialized = false;
                                  });

                                final result =
                                    await Navigator.of(context).push<Duration?>(
                                  MaterialPageRoute(
                                    builder: (_) => FullscreenVideoScreen(
                                      url: widget.url,
                                      startPosition: currentPos,
                                      // let fullscreen create its own controller
                                      controller: null,
                                    ),
                                  ),
                                );

                                // Re-create the inline controller after returning
                                _controller =
                                    VideoPlayerController.network(widget.url);
                                await _controller.initialize();
                                _controller.addListener(_onControllerUpdated);
                                if (result != null) {
                                  await _controller.seekTo(result);
                                } else {
                                  await _controller.seekTo(currentPos);
                                }
                                if (wasPlaying) {
                                  await _controller.play();
                                  _startHideTimerIfNeeded();
                                }
                                if (mounted)
                                  setState(() {
                                    _initialized = true;
                                  });
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
