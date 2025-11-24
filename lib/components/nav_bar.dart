import 'package:flutter/material.dart';

/// Reusable bottom navigation bar component.
///
/// Usage:
/// ```dart
/// NavBar(
///   activeIndex: 1,
///   onTap: (idx) => print('tapped $idx'),
/// )
/// ```
class NavBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int index)? onTap;
  final List<_NavItemData> items;

  const NavBar({
    Key? key,
    this.activeIndex = 0,
    this.onTap,
    List<_NavItemData>? items,
  })  : items = items ??
            const [
              _NavItemData(icon: Icons.home, label: 'Home'),
              _NavItemData(icon: Icons.library_books, label: 'Library'),
              _NavItemData(icon: Icons.person, label: 'Profile'),
            ],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg =
        isLight ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.6);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final it = items[i];
          final active = i == activeIndex;
          final color = active
              ? const Color(0xFF135BEC)
              : (isLight ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF));

          return GestureDetector(
            onTap: () => onTap?.call(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(it.icon, color: color),
                const SizedBox(height: 4),
                Text(it.label, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}
