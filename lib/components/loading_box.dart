import 'package:flutter/material.dart';

/// Small reusable loading box: rounded card with a spinner and a message.
class LoadingBox extends StatelessWidget {
  final String message;
  final double width;
  final double height;

  const LoadingBox(
      {super.key, required this.message, this.width = 200, this.height = 96});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? Colors.white : const Color(0xFF0D1116);
    final textColor = isLight ? const Color(0xFF0F1724) : Colors.white;

    return Center(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLight ? 0.08 : 0.4),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            // Animated book spinner replaces the circular progress indicator
            BookSpinner(size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated book icon that flips along Y axis to simulate page flipping.
class BookSpinner extends StatefulWidget {
  final double size;
  final Color? color;

  const BookSpinner({super.key, this.size = 32.0, this.color});

  @override
  State<BookSpinner> createState() => _BookSpinnerState();
}

class _BookSpinnerState extends State<BookSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;
          final angle = t * 2 * 3.1415926535897932;

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          final showingFront = (t % 1.0) < 0.5;

          return Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: Icon(
              showingFront ? Icons.menu_book : Icons.book,
              size: widget.size,
              color: color,
            ),
          );
        },
      ),
    );
  }
}
