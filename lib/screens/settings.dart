import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/providers/auth.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final logout = ref.watch(authprovider.notifier);
    final authState = ref.watch(authprovider);
    final userName = authState.data?.username ?? 'User';
    final userEmail = authState.data?.email ?? 'user@example.com';

    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        backgroundColor: CoustColors.colrHighlightedText,
        elevation: 0,
        title: const coustText(
          sName: "Settings",
          txtcolor: Colors.white,
          textsize: 22,
          fontweight: FontWeight.bold,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: CoustColors.colrMainbg,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: CoustColors.colrHighlightedText.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: CoustColors.colrHighlightedText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          coustText(
                            sName: userName,
                            textsize: 20,
                            txtcolor: CoustColors.colrEdtxt2,
                            fontweight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          coustText(
                            sName: userEmail,
                            textsize: 14,
                            txtcolor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: CoustColors.colrHighlightedText,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/editprofile');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Title
              const coustText(
                sName: "Account",
                textsize: 18,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.colrEdtxt2,
              ),
              const SizedBox(height: 12),

              // Settings Options
              _buildSettingItem(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () {
                  Navigator.of(context).pushNamed('/editprofile');
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                onTap: () {
                  // Handle notifications settings
                },
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: "Security",
                onTap: () {
                  // Handle security settings
                },
              ),

              const SizedBox(height: 24),

              // Section Title
              const coustText(
                sName: "Preferences",
                textsize: 18,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.colrEdtxt2,
              ),
              const SizedBox(height: 12),

              _buildSettingItem(
                icon: Icons.language_outlined,
                title: "Language",
                onTap: () {
                  // Handle language settings
                },
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: "Theme",
                onTap: () {
                  // Handle theme settings
                },
              ),

              const SizedBox(height: 24),

              // Section Title
              const coustText(
                sName: "Support",
                textsize: 18,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.colrEdtxt2,
              ),
              const SizedBox(height: 12),

              _buildSettingItem(
                icon: Icons.help_outline,
                title: "Help Center",
                onTap: () {
                  // Handle help center navigation
                },
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: "About",
                onTap: () {
                  // Handle about page navigation
                },
              ),

              const SizedBox(height: 32),

              // Logout Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldLogout = await _showLogoutConfirmation(context);
                    if (shouldLogout == true) {
                      await logout.logoutUser();
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CoustColors.colrMainbg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CoustColors.colrHighlightedText.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: CoustColors.colrHighlightedText,
            size: 24,
          ),
        ),
        title: coustText(
          sName: title,
          textsize: 16,
          txtcolor: CoustColors.colrEdtxt2,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

Future<bool?> _showLogoutConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}