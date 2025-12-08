import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/session.dart';
import 'screens/start_screen_one.dart';
import 'screens/start_screen_two.dart';
import 'screens/start_screen_three.dart';
import 'screens/login_screen.dart';
import 'screens/my_handbook.dart';
import 'components/connectivity_wrapper.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  // Make the app immersive (hide status and navigation bars) globally.
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final authToken = prefs.getString('authToken');

  if (authToken != null) {
    await UserSession.loadFromToken(authToken);
  }

  runApp(MyApp(showOnboarding: !hasSeenOnboarding));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});
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
    // Lock onboarding flow to portrait mode only while this page is active
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Restore to allow all orientations when leaving onboarding
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _next() {
    if (_controller.page != null && _controller.page! < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }
    // if we're on last page, navigate to login
    _completeOnboarding();
  }

  void _prev() {
    if (_controller.page != null && _controller.page! > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _skip() {
    _controller.animateToPage(2,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
              onPrev: _prev,
              onSkip: _skip),
          StartScreenTwo(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onNext: _next,
              onPrev: _prev,
              onSkip: _skip),
          StartScreenThree(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onNext: _next,
              onPrev: _prev,
              onSkip: _skip),
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
      title: 'REX Academy',
      builder: (context, child) {
        return ConnectivityWrapper(child: child ?? const SizedBox());
      },
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
      home: widget.showOnboarding
          ? OnboardingPage(
              themeMode: _themeMode, onThemeChanged: _setThemeMode)
          : (UserSession.isLoggedIn
              ? MyHandbookScreen(authToken: UserSession.token)
              : const LoginScreen()),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
