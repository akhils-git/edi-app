import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  void dispose() {
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

  Widget _buildField(
    BuildContext context,
    String hint,
    bool obscureText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final secondary = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF616F89)
        : const Color(0xFFA1AAB8);
    final border = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFE0E3E7)
        : const Color(0xFF333C4A);
    final bgField = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF101622);
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondary),
        filled: true,
        fillColor: bgField,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF135BEC);
    final secondary = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF616F89)
        : const Color(0xFFA1AAB8);
    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: _textPrimary(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
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
                ),
                const SizedBox(height: 16),
                Text('English Academy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary(context))),
                const SizedBox(height: 8),
                Text('Create an account to start learning.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: secondary)),
                const SizedBox(height: 32),
                // Form fields
                _buildField(context, 'Full Name', false),
                const SizedBox(height: 16),
                _buildField(context, 'Phone number', false,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildField(context, 'Email', false,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(context, 'Password', true),
                const SizedBox(height: 16),
                _buildField(context, 'Confirm password', true),
                const SizedBox(height: 32),
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
                    child: const Text('Sign Up',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
                // No social sign up
                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: TextStyle(color: secondary)),
                      const SizedBox(width: 6),
                      GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('Log in',
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
