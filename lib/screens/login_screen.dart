import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'create_account.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'my_handbook.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  // alert state: null = hidden, 'success' or 'error'
  String? _alertType;
  String? _alertTitle;
  String? _alertMessage;
  @override
  void initState() {
    super.initState();
    // System UI mode is managed globally in `main.dart` (immersive full-screen).
    _usernameController.addListener(() {
      if (_alertType != null) {
        setState(() {
          _alertType = null;
          _alertTitle = null;
          _alertMessage = null;
        });
      }
    });
    _passwordController.addListener(() {
      if (_alertType != null) {
        setState(() {
          _alertType = null;
          _alertTitle = null;
          _alertMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // listeners cleaned up by disposing controllers
    super.dispose();
  }

  // Helper to show alert banners above the form
  Widget _buildAlert() {
    if (_alertType == null) return const SizedBox.shrink();

    if (_alertType == 'success') {
      final bg = const Color(0xFF10B981); // green
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _alertMessage ?? 'Success',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // error
    final border = const Color(0xFFFCA5A5);
    final bg = const Color(0xFFFEE2E2);
    final text = const Color(0xFF991B1B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: text),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _alertTitle ?? 'Login Failed',
                  style: TextStyle(
                      color: text, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  _alertMessage ??
                      'Invalid email or password. Please try again.',
                  style: TextStyle(color: text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: _background(context),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
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

                  // alert (success / error) shown above the email field
                  if (_alertType != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildAlert(),
                    ),

                  // form
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Email or username',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF616F89)
                            : const Color(0xFFA1AAB8),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : const Color(0xFF15202B),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFE0E3E7)
                                  : const Color(0xFF333C4A),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF616F89)
                            : const Color(0xFFA1AAB8),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : const Color(0xFF15202B),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFE0E3E7)
                                  : const Color(0xFF333C4A),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                      onPressed: _loading
                          ? null
                          : () async {
                              // close keyboard when user taps login
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _loading = true;
                                // clear any previous alert
                                _alertType = null;
                                _alertTitle = null;
                                _alertMessage = null;
                              });
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text;
                              try {
                                final resp =
                                    await AuthService.login(username, password);
                                if (resp.success) {
                                  // store session info globally
                                  UserSession.setFromAuthResponse(resp);
                                  setState(() {
                                    _alertType = 'success';
                                    _alertMessage =
                                        'Login successful! Welcome back.';
                                  });
                                  await Future.delayed(
                                      const Duration(milliseconds: 800));
                                  if (mounted) {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (_) => MyHandbookScreen(
                                                authToken: resp.token)));
                                  }
                                } else {
                                  // show error alert above email field
                                  setState(() {
                                    _alertType = 'error';
                                    _alertTitle = 'Login Failed';
                                    _alertMessage =
                                        'Invalid email or password. Please try again.';
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _alertType = 'error';
                                  _alertTitle = 'Login Failed';
                                  _alertMessage =
                                      'Invalid email or password. Please try again.';
                                });
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Log in',
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
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const CreateAccountScreen()));
                            },
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
      ),
    );
  }
}
