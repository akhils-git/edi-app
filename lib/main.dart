import 'package:flutter/material.dart';
import 'screens/start_screen_one.dart';
import 'screens/start_screen_two.dart';
import 'screens/start_screen_three.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class OnboardingPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const OnboardingPage(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_controller.page != null && _controller.page! < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prev() {
    if (_controller.page != null && _controller.page! > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        children: [
          StartScreenOne(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onNext: _next,
              onPrev: _prev),
          StartScreenTwo(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onNext: _next,
              onPrev: _prev),
          StartScreenThree(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onNext: _next,
              onPrev: _prev),
        ],
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'edu-app',
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home:
          OnboardingPage(themeMode: _themeMode, onThemeChanged: _setThemeMode),
    );
  }
}
