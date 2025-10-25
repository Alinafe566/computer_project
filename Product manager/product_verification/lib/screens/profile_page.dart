import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Test User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'test@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileSection('Account', [
            _buildProfileItem(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Navigate to edit profile
              },
            ),
            _buildProfileItem(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                // TODO: Navigate to change password
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildProfileSection('App Settings', [
            _buildProfileItem(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Handle notification toggle
                },
              ),
            ),
            _buildProfileItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                // TODO: Navigate to language settings
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildProfileSection('Support', [
            _buildProfileItem(
              icon: Icons.help,
              title: 'Help & FAQ',
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            _buildProfileItem(
              icon: Icons.feedback,
              title: 'Send Feedback',
              onTap: () {
                // TODO: Navigate to feedback
              },
            ),
            _buildProfileItem(
              icon: Icons.info,
              title: 'About MBS Verify',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildProfileSection('Account Actions', [
            _buildProfileItem(
              icon: Icons.logout,
              title: 'Logout',
              titleColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MBS Verify'),
        content: const Text(
          'MBS Verify v1.0.0\n\nMalawi Bureau of Standards product verification system that helps consumers identify authentic products and report counterfeits.\n\nDeveloped to protect consumers and support genuine manufacturers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}