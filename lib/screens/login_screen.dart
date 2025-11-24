import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // hide top status bar only (keep navigation bar visible)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    // restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Color _background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF6F6F8)
        : const Color(0xFF101622);
  }

  Color _textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF111318)
        : const Color(0xFFFFFFFF);
  }

  Color _textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF616F89)
        : const Color(0xFFA1AAB8);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF135BEC);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // no back button
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: _background(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // logo
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/login_logo.png'),
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('English Academy',
                          style: TextStyle(
                              color: _textPrimary(context),
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Log in to continue your learning journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _textSecondary(context), fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // form
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email or username',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF616F89)
                          : const Color(0xFFA1AAB8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color(0xFF15202B),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE0E3E7)
                            : const Color(0xFF333C4A),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE0E3E7)
                            : const Color(0xFF333C4A),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF616F89)
                          : const Color(0xFFA1AAB8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color(0xFF15202B),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE0E3E7)
                            : const Color(0xFF333C4A),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE0E3E7)
                            : const Color(0xFF333C4A),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {},
                    child: const Text('Log in',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),

                TextButton(
                  onPressed: () {},
                  child: Text('Forgot password?',
                      style: TextStyle(color: primary)),
                ),

                // removed social buttons and extra placeholders

                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New user?',
                          style: TextStyle(color: _textSecondary(context))),
                      const SizedBox(width: 6),
                      GestureDetector(
                          onTap: () {},
                          child: Text('Sign up with email',
                              style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
