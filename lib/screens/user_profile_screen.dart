import 'package:flutter/material.dart';
import '../services/session.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final titleColor = isLight ? const Color(0xFF0F1724) : Colors.white;
    final titleStyle =
        TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: titleColor);

    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xFFF6F6F8) : const Color(0xFF0D1116),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header: back + title + settings
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: titleColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('My Profile',
                          style: titleStyle, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8), // Adjusted to maintain layout
                ],
              ),

              const SizedBox(height: 12),

              // profile avatar + name + email
              Center(
                child: Column(
                  children: [
                    if (user?.avatar != null && user!.avatar!.isNotEmpty)
                      CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(user.avatar!))
                    else
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: isLight
                            ? const Color(0xFFE6E9F8)
                            : const Color(0xFF1B2936),
                        child: Text(
                          user != null && user.name.isNotEmpty
                              ? user.name
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
                    Text(user?.name ?? 'Unknown User',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: titleColor)),
                    const SizedBox(height: 6),
                    Text(user?.email ?? '-',
                        style: TextStyle(
                            color: isLight
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF))),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Information
              Text('Account Information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.hardEdge,
                child: Column(children: [
                  _buildInfoRow('Full Name', user?.name ?? '-', isLight),
                  Divider(
                      height: 1,
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF2A2A2A)),
                  _buildInfoRow('Email', user?.email ?? '-', isLight),
                  Divider(
                      height: 1,
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF2A2A2A)),
                  _buildInfoRow('Phone Number', '-', isLight),
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
              Container(
                decoration: BoxDecoration(
                    color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.hardEdge,
                child: Column(children: [
                  _buildInfoRow('Current Plan', 'Selected Annually', isLight,
                      highlightRight: true),
                  Divider(
                      height: 1,
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF2A2A2A)),
                  _buildInfoRow('Renewal Date', 'December 24, 2024', isLight),
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
              Container(
                decoration: BoxDecoration(
                    color: isLight ? Colors.white : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16)),
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
                  child: Text('Version 1.0.2',
                      style: TextStyle(
                          color: isLight
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLight,
      {bool highlightRight = false}) {
    final rightStyle = TextStyle(
      color: highlightRight
          ? const Color(0xFF136DEC)
          : (isLight ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
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
    return InkWell(
      onTap: () {
        UserSession.clear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Center(
            child: Text('Log out',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red))),
      ),
    );
  }
}
