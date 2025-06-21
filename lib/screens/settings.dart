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
  bool _isLoading = true; // Initialize the loading state variable

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      // Try to refresh auth state from SharedPreferences
      final success = await ref.read(authprovider.notifier).tryAutoLogin();
      print('Auth refresh in settings: $success');

      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CoustColors.veryLightPurple,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CoustColors.primaryPurple),
          ),
        ),
      );
    }

    final logout = ref.watch(authprovider.notifier);
    final authState = ref.watch(authprovider);
    final userName = authState.data?.username ?? 'User';
    final userEmail = authState.data?.email ?? 'user@example.com';

    // If still no user data, show refresh button
    if (authState.data == null ||
        (authState.data?.username == null && authState.data?.email == null)) {
      return Scaffold(
        backgroundColor: CoustColors.veryLightPurple,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: CoustColors.primaryPurple,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CoustColors.gradientStart,
                  CoustColors.gradientMiddle,
                  CoustColors.gradientEnd,
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CoustColors.lightPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off,
                  size: 64,
                  color: CoustColors.darkPurple.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'User data not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CoustColors.darkPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try refreshing or log in again',
                style: TextStyle(color: CoustColors.darkPurple.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeAuthState,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoustColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(
                  'Go to Login',
                  style: TextStyle(color: CoustColors.primaryPurple),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: AppBar(
        backgroundColor: CoustColors.primaryPurple,
        elevation: 0,
        title: const coustText(
          sName: "Settings",
          txtcolor: Colors.white,
          fontSize: 22,
          fontweight: FontWeight.bold,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CoustColors.gradientStart,
                CoustColors.gradientMiddle,
                CoustColors.gradientEnd,
              ],
            ),
          ),
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
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: CoustColors.lightPurple.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CoustColors.primaryPurple.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CoustColors.lightPurple.withOpacity(0.3),
                            CoustColors.primaryPurple.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CoustColors.primaryPurple.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: CoustColors.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          coustText(
                            sName: userName,
                            fontSize: 20,
                            txtcolor: CoustColors.darkPurple,
                            fontweight: FontWeight.bold,
                          ),
                          const SizedBox(height: 6),
                          coustText(
                            sName: userEmail,
                            fontSize: 14,
                            txtcolor: CoustColors.darkPurple.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: CoustColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: CoustColors.primaryPurple,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/editprofile');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section Title
              coustText(
                sName: "Account",
                fontSize: 20,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.darkPurple,
              ),
              const SizedBox(height: 16),

              // Settings Options
              _buildSettingItem(
                icon: Icons.person_outline,
                title: "Edit Profile",
                accentColor: CoustColors.primaryPurple,
                onTap: () {
                  Navigator.of(context).pushNamed('/editprofile');
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                accentColor: CoustColors.teal,
                onTap: () {
                  // Handle notifications settings
                },
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: "Security",
                accentColor: CoustColors.accentPurple,
                onTap: () {
                  // Handle security settings
                },
              ),

              const SizedBox(height: 28),

              // Section Title
              coustText(
                sName: "Preferences",
                fontSize: 20,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.darkPurple,
              ),
              const SizedBox(height: 16),

              _buildSettingItem(
                icon: Icons.language_outlined,
                title: "Language",
                accentColor: CoustColors.magenta,
                onTap: () {
                  // Handle language settings
                },
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: "Theme",
                accentColor: CoustColors.deepBlue,
                onTap: () {
                  // Handle theme settings
                },
              ),

              const SizedBox(height: 28),

              // Section Title
              coustText(
                sName: "Support",
                fontSize: 20,
                fontweight: FontWeight.bold,
                txtcolor: CoustColors.darkPurple,
              ),
              const SizedBox(height: 16),

              _buildSettingItem(
                icon: Icons.help_outline,
                title: "Help Center",
                accentColor: CoustColors.emerald,
                onTap: () {
                  Navigator.of(context).pushNamed('/helpcenter');
                },
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: "About",
                accentColor: CoustColors.gold,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),

              const SizedBox(height: 40),

              // Logout Button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: CoustColors.rose.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final shouldLogout = await _showLogoutConfirmation(context);
                      if (shouldLogout == true) {
                        await logout.logoutUser();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
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
                      backgroundColor: CoustColors.rose,
                      minimumSize: const Size(220, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.15),
                accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 24,
          ),
        ),
        title: coustText(
          sName: title,
          fontSize: 16,
          txtcolor: CoustColors.darkPurple,
          fontweight: FontWeight.w500,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: accentColor.withOpacity(0.6),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Logout",
            style: TextStyle(
              color: CoustColors.darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: CoustColors.darkPurple.withOpacity(0.7),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: CoustColors.lightPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: CoustColors.darkPurple.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CoustColors.rose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}