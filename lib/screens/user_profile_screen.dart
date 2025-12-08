import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'login_screen.dart';
import '../components/nav_bar.dart';
import 'my_handbook.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserData? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = UserSession.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (_user == null) return;

    setState(() => _isLoading = true);
    try {
      final updatedUser = await AuthService.getUserDetails(_user!.id);
      if (mounted) {
        setState(() {
          _user = updatedUser;
          // Update session as well so other screens get the latest data
          UserSession.currentUser = updatedUser;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch user details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFF6F6F8) : const Color(0xFF0D1116);
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header similar to MyHandbook
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('My Profile',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: titleColor)),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: const LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // profile avatar + name + email
                    Center(
                      child: Column(
                        children: [
                          if (_user?.avatar != null && _user!.avatar!.isNotEmpty)
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: isLight
                                  ? const Color(0xFFE6E9F8)
                                  : const Color(0xFF1B2936),
                              child: ClipOval(
                                child: SizedBox(
                                  width: 96,
                                  height: 96,
                                  child: Image.network(
                                    _user!.avatar!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 48,
                                        color: isLight
                                            ? const Color(0xFF0F1724)
                                            : Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: isLight
                                  ? const Color(0xFFE6E9F8)
                                  : const Color(0xFF1B2936),
                              child: Text(
                                _user != null && _user!.name.isNotEmpty
                                    ? _user!.name
                                        .split(' ')
                                        .map((s) => s.isNotEmpty ? s[0] : '')
                                        .take(2)
                                        .join()
                                    : 'U',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: isLight
                                        ? const Color(0xFF0F1724)
                                        : Colors.white),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(_user?.name ?? 'Unknown User',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor)),
                          const SizedBox(height: 6),
                          Text(_user?.email ?? '-',
                              style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Account Information
                    Text('Account Information',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    Material(
                      color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.hardEdge,
                      child: Column(children: [
                        _buildInfoRow('Full Name', _user?.name ?? '-', isLight),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        _buildInfoRow('Email', _user?.email ?? '-', isLight),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        _buildInfoRow('Phone Number',
                            _user?.phoneNumber ?? 'Not available', isLight),
                      ]),
                    ),

                    const SizedBox(height: 18),

                    // Subscription
                    Text('Subscription',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    Material(
                      color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.hardEdge,
                      child: Column(children: [
                        _buildInfoRow('Current Plan', 'Platinum X', isLight,
                            highlightRight: true),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        _buildInfoRow(
                            'Start Date',
                            _formatDate(_user?.subscriptionStart),
                            isLight),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        _buildInfoRow(
                            'Renewal Date',
                            _formatDate(_user?.subscriptionEnd),
                            isLight),
                      ]),
                    ),

                    const SizedBox(height: 18),

                    // About
                    Text('About',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLight
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    Material(
                      color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.hardEdge,
                      child: Column(children: [
                        _buildActionRow('Privacy Policy', isLight),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        _buildActionRow('Terms and Conditions', isLight),
                        Divider(
                            height: 1,
                            color: isLight
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF2A2A2A)),
                        // Logout row
                        _buildLogoutRow(context, isLight),
                      ]),
                    ),

                    const SizedBox(height: 28),
                    Center(
                        child: Text('RC 1.0.1',
                            style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF9CA3AF)))),
                  ],
                ),
              ),
            ),
            
            NavBar(
              activeIndex: 1,
              onTap: (idx) {
                if (idx == 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) =>
                            MyHandbookScreen(authToken: UserSession.token)),
                    (route) => false,
                  );
                } else if (idx == 1) {
                  // Already on Profile
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLight,
      {bool highlightRight = false}) {
    final rightStyle = TextStyle(
      color: highlightRight
          ? const Color(0xFF136DEC)
          : (isLight
              ? const Color(0xFF6B7280)
              : const Color(0xFF9CA3AF)),
      fontWeight: highlightRight ? FontWeight.w600 : FontWeight.normal,
    );
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Flexible(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(value, style: rightStyle))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(String label, bool isLight) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: isLight
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow(BuildContext context, bool isLight) {
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;
    return InkWell(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isLight
                            ? Colors.red.shade50
                            : Colors.red.shade900.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.logout,
                          size: 36,
                          color: isLight
                              ? Colors.red.shade700
                              : Colors.red.shade200),
                    ),
                    const SizedBox(height: 14),
                    Text('Log out',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: titleColor)),
                    const SizedBox(height: 8),
                    Text('Are you sure you want to log out?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: isLight
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF))),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: isLight
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF2A2A2A)),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLight
                                  ? Colors.red.shade700
                                  : Colors.red.shade200,
                              foregroundColor:
                                  isLight ? Colors.white : Colors.black,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Log out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (confirmed == true) {
          UserSession.clear();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Text('Log out',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
