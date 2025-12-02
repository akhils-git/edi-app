import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../components/warning_popup.dart';
import '../components/success_popup.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const WarningPopup(
          title: 'Missing Information',
          message: 'Please fill in all fields to continue.',
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => const WarningPopup(
          title: 'Password Mismatch',
          message: 'The passwords you entered do not match.',
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });



    try {
      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phone,
        avatarFile: _selectedImage,
      );

      if (mounted && response.success) {
        _showSuccessDialog(response.data);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Check for duplicate key error
        if (errorMessage.contains('duplicate key') &&
            errorMessage.contains('email')) {
          errorMessage = 'This email address is already registered.';
        } else if (errorMessage.startsWith('ApiException')) {
           // Clean up ApiException message if possible, or just show the inner message
           // The toString of ApiException is 'ApiException(statusCode: ..., message: ...)'
           // We might want to extract just the message part if it's user friendly.
           // For now, let's rely on the fact that AuthService throws the message.
           // However, AuthService throws ApiException(message, code).
           // Let's try to parse it or just show it.
           // Actually, let's just show the message.
           // But wait, e.toString() includes the class name.
           // Let's cast if possible or just use regex.
        }
        
        // Better parsing:
        if (e is ApiException) {
           errorMessage = e.message;
           if (errorMessage.contains('duplicate key') && errorMessage.contains('email')) {
             errorMessage = 'This email address is already registered.';
           }
        }

        showDialog(
          context: context,
          builder: (context) => WarningPopup(
            title: 'Registration Failed',
            message: errorMessage,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  void _showSuccessDialog(UserData user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessPopup(
        user: user,
        onLoginPressed: () {
          Navigator.of(context).pop(); // Go back to login
        },
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String hint,
    TextEditingController controller,
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
      controller: controller,
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
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/login_logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                            border: Border.all(
                              color: primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
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
                _buildField(context, 'Full Name', _nameController, false),
                const SizedBox(height: 16),
                _buildField(context, 'Phone number', _phoneController, false,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildField(context, 'Email', _emailController, false,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField(context, 'Password', _passwordController, true),
                const SizedBox(height: 16),
                _buildField(
                    context, 'Confirm password', _confirmPasswordController, true),
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
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
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
