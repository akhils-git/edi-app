import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StarAnimation extends StatefulWidget {
  final bool enabled;
  const StarAnimation({super.key, this.enabled = true});

  @override
  State<StarAnimation> createState() => _StarAnimationState();
}

class _StarAnimationState extends State<StarAnimation>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final List<_Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateStars();
    _ticker = createTicker(_onTick)..start();
  }

  void _generateStars() {
    for (int i = 0; i < 12; i++) {
      _stars.add(_createStar(randomY: true));
    }
  }

  _Star _createStar({bool randomY = false}) {
    return _Star(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : 1.1,
      size: 8 + _random.nextDouble() * 12,
      color: [
        Colors.amber,
        Colors.orange,
        Colors.purpleAccent,
        Colors.blueAccent,
        Colors.pinkAccent,
        Colors.greenAccent,
        Colors.cyanAccent,
      ][_random.nextInt(7)],
      vx: (_random.nextDouble() - 0.5) * 0.2, // Horizontal drift
      vy: -0.1 - _random.nextDouble() * 0.3, // Upward speed
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 2.0,
    );
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !widget.enabled) return;
    
    // Calculate delta time in seconds
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Cap dt to prevent huge jumps if paused/backgrounded
    if (dt > 0.1) return;

    for (var star in _stars) {
      star.x += star.vx * dt;
      star.y += star.vy * dt;
      star.rotation += star.rotationSpeed * dt;

      // Respawn if it goes too far up
      if (star.y < -0.2) {
        _resetStar(star);
      }
      
      // Wrap horizontally
      if (star.x < -0.2) star.x = 1.2;
      if (star.x > 1.2) star.x = -0.2;
    }
    setState(() {});
  }

  void _resetStar(_Star star) {
    star.x = _random.nextDouble();
    star.y = 1.1;
    star.vx = (_random.nextDouble() - 0.5) * 0.2;
    star.vy = -0.1 - _random.nextDouble() * 0.3;
    star.rotation = _random.nextDouble() * 2 * pi;
    star.rotationSpeed = (_random.nextDouble() - 0.5) * 2.0;
    star.color = [
        Colors.amber,
        Colors.orange,
        Colors.purpleAccent,
        Colors.blueAccent,
        Colors.pinkAccent,
        Colors.greenAccent,
        Colors.cyanAccent,
      ][_random.nextInt(7)];
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: _stars.map((star) {
          return Positioned(
            left: star.x * constraints.maxWidth,
            top: star.y * constraints.maxHeight,
            child: Transform.rotate(
              angle: star.rotation,
              child: Icon(
                Icons.star,
                color: star.color.withOpacity(0.8),
                size: star.size,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _Star {
  double x;
  double y;
  double size;
  Color color;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
  });
}
