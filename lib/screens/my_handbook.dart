import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../components/nav_bar.dart';

class MyHandbookScreen extends StatefulWidget {
  final String? authToken;

  const MyHandbookScreen({super.key, this.authToken});

  @override
  State<MyHandbookScreen> createState() => _MyHandbookScreenState();
}

class _MyHandbookScreenState extends State<MyHandbookScreen> {
  late Future<List<Category>> _future;

  @override
  void initState() {
    super.initState();
    _future = CategoryService.getCategories(widget.authToken);
  }

  IconData _iconForCategory(String slugOrName) {
    final key = slugOrName.toLowerCase();
    if (key.contains('life') || key.contains('general')) return Icons.language;
    if (key.contains('student') ||
        key.contains('kids') ||
        key.contains('school')) return Icons.school;
    if (key.contains('inspir')) return Icons.self_improvement;
    return Icons.menu_book;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF6F6F8)
        : const Color(0xFF0D1116);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('My Handbooks',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF0F1724)
                            : Colors.white)),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final cats = snap.data ?? [];
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: cats.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (c, i) {
                      final cat = cats[i];
                      final icon = _iconForCategory(cat.name);
                      return _CategoryCard(
                        title: cat.name,
                        subtitle: cat.description,
                        icon: icon,
                      );
                    },
                  );
                },
              ),
            ),
            NavBar(activeIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _CategoryCard(
      {required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardColor = isLight ? Colors.white : const Color(0xFF111827);
    final borderColor =
        isLight ? const Color(0xFFE6F0FF) : const Color(0xFF23303A);
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? const Color(0xFF0F1724)
                                  : Colors.white)),
                      const SizedBox(height: 8),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 14,
                              color: isLight
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                // decorative icon
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(icon,
                        size: 120,
                        color: isLight
                            ? const Color(0xFFDBEAFE).withOpacity(0.9)
                            : const Color(0xFF14314B).withOpacity(0.4)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
// _BottomNav and _NavItem removed — replaced by reusable `NavBar` in `lib/components`.
