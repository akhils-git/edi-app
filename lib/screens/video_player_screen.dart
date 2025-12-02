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

  final bool isEmbedded;

  const FullscreenVideoScreen(
      {Key? key,
      required this.url,
      required this.startPosition,
      this.controller,
      this.isEmbedded = false})
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

  void _startHideTimerIfNeeded() {
    _hideTimer?.cancel();
    if (_controller.value.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  late VideoPlayerController _controller;
  bool _initialized = false;
  VoidCallback? _fullscreenListener;
  bool _loadError = false;
  String? _errorMessage;
  bool _ownsController = false;

  bool _showControls = true;
  Timer? _hideTimer;
  bool _isVideoDragging = false;

  double _videoDragValue = 0.0;
  BoxFit _fit = BoxFit.contain;

  @override
  void initState() {
    super.initState();
    // Force immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
      
      // Set orientation based on video aspect ratio
      if (!widget.isEmbedded) {
        if (_controller.value.aspectRatio < 1.0) {
          // Portrait video
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        } else {
          // Landscape video
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
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
          // When playback is active, schedule auto-hide; when paused/buffering,
          // cancel the hide timer and show controls.
          if (_controller.value.isPlaying && !_controller.value.isBuffering) {
            _startHideTimerIfNeeded();
          } else {
            _hideTimer?.cancel();
            if (!_showControls && mounted) setState(() => _showControls = true);
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
      if (!_loadError) _startHideTimerIfNeeded();
      return;
    }

    _ownsController = true;
    _controller = VideoPlayerController.network(widget.url);
    try {
      await _controller.initialize();
      
      // Set orientation based on video aspect ratio
      if (!widget.isEmbedded) {
        if (_controller.value.aspectRatio < 1.0) {
          // Portrait video
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        } else {
          // Landscape video
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      }

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
          if (_controller.value.isPlaying && !_controller.value.isBuffering) {
            _startHideTimerIfNeeded();
          } else {
            _hideTimer?.cancel();
            if (!_showControls && mounted) setState(() => _showControls = true);
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
      _startHideTimerIfNeeded();
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
    // Restore portrait mode and UI
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (widget.isEmbedded) {
      // If embedded (tilt mode), forcing portrait will cause the parent to rebuild in portrait
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      // We don't pop here because the orientation change will handle the UI switch
    } else {
      // If pushed, allow all orientations so the previous screen can rotate if needed
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      // If we don't own the controller (shared), we don't need to return the position
      // because the shared controller is already at the correct position.
      // Returning null prevents the caller from seeking (which causes stutter).
      if (mounted) Navigator.of(context).pop(_ownsController ? pos : null);
    }
  }

  @override
  void dispose() {
    // In case dispose is called directly, try restoring orientations
    // In case dispose is called directly, try restoring orientations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // Guard controller accesses — it may already be disposed if pop logic
    // disposed it earlier. Use try/catch to avoid throwing during teardown.
    try {
      if (_fullscreenListener != null) {
        _controller.removeListener(_fullscreenListener!);
      }
    } catch (_) {}
    _hideTimer?.cancel();
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
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (mounted) {
                    setState(() => _showControls = !_showControls);
                    if (_showControls) {
                      _startHideTimerIfNeeded();
                    } else {
                      _hideTimer?.cancel();
                    }
                  }
                },
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: _fit,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                    if (_showControls && !widget.isEmbedded)
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
                    if (_showControls)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!widget.isEmbedded)
                              IconButton(
                                iconSize: 48,
                                onPressed: () async {
                                  if (mounted)
                                    setState(() => _showControls = true);
                                  _hideTimer?.cancel();
                                  final current = _controller.value.position;
                                  final target =
                                      current - const Duration(seconds: 10);
                                  final seekTo = target > Duration.zero
                                      ? target
                                      : Duration.zero;
                                  await _controller.seekTo(seekTo);
                                  _startHideTimerIfNeeded();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.replay_10,
                                    color: Colors.white),
                              ),
                            if (!widget.isEmbedded) const SizedBox(width: 32),
                            IconButton(
                              iconSize: 64,
                              onPressed: () {
                                if (mounted)
                                  setState(() => _showControls = true);
                                _hideTimer?.cancel();
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
                              icon: _controller.value.isBuffering
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                            ),
                            if (!widget.isEmbedded) const SizedBox(width: 32),
                            if (!widget.isEmbedded)
                              IconButton(
                                iconSize: 48,
                                onPressed: () async {
                                  if (mounted)
                                    setState(() => _showControls = true);
                                  _hideTimer?.cancel();
                                  final current = _controller.value.position;
                                  final target =
                                      current + const Duration(seconds: 10);
                                  final duration = _controller.value.duration;
                                  final seekTo =
                                      target < duration ? target : duration;
                                  await _controller.seekTo(seekTo);
                                  _startHideTimerIfNeeded();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.forward_10,
                                    color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    if (_showControls && !widget.isEmbedded)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 14),
                                      activeTrackColor: Colors.blueAccent,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.blueAccent,
                                      overlayColor:
                                          Colors.blueAccent.withOpacity(0.2),
                                      trackShape:
                                          const RectangularSliderTrackShape(),
                                    ),
                                    child: Slider(
                                      value: (_isVideoDragging
                                              ? _videoDragValue
                                              : _controller
                                                  .value.position.inMilliseconds
                                                  .toDouble())
                                          .clamp(
                                              0.0,
                                              _controller.value.duration
                                                          .inMilliseconds >
                                                      0
                                                  ? _controller.value.duration
                                                      .inMilliseconds
                                                      .toDouble()
                                                  : 1.0),
                                      min: 0.0,
                                      max: _controller.value.duration
                                                  .inMilliseconds >
                                              0
                                          ? _controller.value.duration
                                              .inMilliseconds
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
                                        _hideTimer?.cancel();
                                      },
                                      onChangeEnd: (value) async {
                                        await _controller.seekTo(Duration(
                                            milliseconds: value.toInt()));
                                        setState(() {
                                          _isVideoDragging = false;
                                        });
                                        _startHideTimerIfNeeded();
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      _formatDuration(
                                              _controller.value.position) +
                                          '/' +
                                          (_controller.value.duration >
                                                  Duration.zero
                                              ? _formatDuration(
                                                  _controller.value.duration)
                                              : '--:--'),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _fit = _fit == BoxFit.contain
                                      ? BoxFit.cover
                                      : BoxFit.contain;
                                });
                                if (_showControls) _startHideTimerIfNeeded();
                              },
                              icon: Icon(
                                _fit == BoxFit.contain
                                    ? Icons.zoom_out_map
                                    : Icons.zoom_in_map,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
                                          (_controller.value.duration >
                                                  Duration.zero
                                              ? _formatDuration(
                                                  _controller.value.duration)
                                              : '--:--'),
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
