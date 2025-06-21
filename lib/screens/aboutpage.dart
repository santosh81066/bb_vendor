import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  String appVersion = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  Future<void> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: CoustColors.rose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: CoustColors.primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name Section
            _buildAppHeader(),

            const SizedBox(height: 30),

            // App Description
            _buildDescriptionSection(),

            const SizedBox(height: 30),

            // Features Section
            _buildFeaturesSection(),

            const SizedBox(height: 30),

            // Version Information
            _buildVersionInfo(),

            const SizedBox(height: 30),

            // Contact Information
            _buildContactSection(),

            const SizedBox(height: 30),

            // Legal Links
            _buildLegalSection(),

            const SizedBox(height: 20),

            // Copyright
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.lightPurple,
            CoustColors.mediumPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Icon/Logo
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CoustColors.accentPurple,
                  CoustColors.darkPurple,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.darkPurple.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.event_available,
              size: 42,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Banquetbookz Vendor',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your Venue Management Partner',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Our App',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CoustColors.darkPurple,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Banquetbookz Vendor is a comprehensive venue management application designed to help banquet hall owners and event venue managers streamline their operations. From managing bookings to tracking sales and handling customer relationships, our app provides all the tools you need to run your venue business efficiently.',
            style: TextStyle(
              fontSize: 16,
              color: CoustColors.darkPurple.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Calendar Management',
        'description': 'Manage your venue availability and bookings effortlessly',
        'color': CoustColors.primaryPurple,
      },
      {
        'icon': Icons.analytics,
        'title': 'Sales Analytics',
        'description': 'Track your revenue and performance with detailed insights',
        'color': CoustColors.teal,
      },
      {
        'icon': Icons.manage_accounts,
        'title': 'Property Management',
        'description': 'Add and manage multiple venues from one dashboard',
        'color': CoustColors.accentPurple,
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Tracking',
        'description': 'Monitor transactions and payment status in real-time',
        'color': CoustColors.magenta,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CoustColors.darkPurple,
            ),
          ),
          const SizedBox(height: 18),
          ...features.map((feature) => _buildFeatureItem(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['description'] as String,
            feature['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
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
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CoustColors.darkPurple.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CoustColors.darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'App Version:',
                style: TextStyle(
                  fontSize: 16,
                  color: CoustColors.darkPurple.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CoustColors.veryLightPurple,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CoustColors.lightPurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  appVersion.isNotEmpty ? appVersion : '1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Build Number:',
                style: TextStyle(
                  fontSize: 16,
                  color: CoustColors.darkPurple.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CoustColors.veryLightPurple,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CoustColors.lightPurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  buildNumber.isNotEmpty ? buildNumber : '1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CoustColors.darkPurple,
            ),
          ),
          const SizedBox(height: 18),
          _buildContactItem(
            Icons.email,
            'Email Support',
            'support@banquetbookz.com',
            CoustColors.primaryPurple,
                () => _launchUrl('mailto:support@banquetbookz.com'),
          ),
          _buildContactItem(
            Icons.phone,
            'Phone Support',
            '+1 (555) 123-4567',
            CoustColors.teal,
                () => _launchUrl('tel:+15551234567'),
          ),
          _buildContactItem(
            Icons.language,
            'Website',
            'www.banquetbookz.com',
            CoustColors.accentPurple,
                () => _launchUrl('https://www.banquetbookz.com'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle, Color accentColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CoustColors.darkPurple,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: CoustColors.darkPurple.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CoustColors.darkPurple,
            ),
          ),
          const SizedBox(height: 18),
          _buildLegalItem(
            'Terms of Service',
                () => _launchUrl('https://www.banquetbookz.com/terms'),
          ),
          _buildLegalItem(
            'Privacy Policy',
                () => _launchUrl('https://www.banquetbookz.com/privacy'),
          ),
          _buildLegalItem(
            'End User License Agreement',
                () => _launchUrl('https://www.banquetbookz.com/eula'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: CoustColors.darkPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: CoustColors.primaryPurple.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '© 2025 Banquetbookz. All rights reserved.',
        style: TextStyle(
          fontSize: 14,
          color: CoustColors.darkPurple.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}