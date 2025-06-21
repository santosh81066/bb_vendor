// Import this for the blur effect
import 'dart:ui';
import 'package:bb_vendor/Screens/dashboard.dart';
import 'package:bb_vendor/Screens/manage.dart';
import 'package:bb_vendor/Screens/sales.dart';
import 'package:bb_vendor/Screens/settings.dart';
import 'package:flutter/material.dart';
import '../Colors/coustcolors.dart'; // Adjust import path as needed

class CustomNavigation extends StatefulWidget {
  const CustomNavigation({super.key});

  @override
  State<CustomNavigation> createState() => _CustomNavigationState();
}

class _CustomNavigationState extends State<CustomNavigation>
    with TickerProviderStateMixin {
  final _pageOptions = [
    DashboardScreen(),
    ManageScreen(),
    SalesScreen(),
    SettingsScreen(),
  ];

  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Updated navigation items with purple theme colors
  final List<NavItem> _navItems = [
    NavItem(Icons.dashboard_rounded, 'Dashboard', CoustColors.primaryPurple),
    NavItem(Icons.inventory_2_rounded, 'Manage', CoustColors.teal),
    NavItem(Icons.trending_up_rounded, 'Sales', CoustColors.emerald),
    NavItem(Icons.settings_rounded, 'Settings', CoustColors.magenta),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: _pageOptions[_currentIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.06), // 6% of screen width
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.veryLightPurple.withOpacity(0.95),
                  CoustColors.veryLightPurple.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              border: Border.all(
                color: CoustColors.colrStrock1.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.primaryPurple.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: CoustColors.darkPurple.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: screenHeight * 0.09, // 9% of screen height
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // 5% of screen width
                  vertical: screenHeight * 0.01, // 1% of screen height
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _navItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    NavItem item = entry.value;
                    bool isSelected = _currentIndex == index;

                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.003,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              item.color.withOpacity(0.25),
                              item.color.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          border: isSelected
                              ? Border.all(
                            color: item.color.withOpacity(0.4),
                            width: 1.5,
                          )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item.color.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? item.color
                                    : CoustColors.colrSubText,
                                size: screenWidth * (isSelected ? 0.055 : 0.05),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.002),
                            Flexible(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? item.color
                                      : CoustColors.colrSubText,
                                  fontSize: screenWidth * (isSelected ? 0.025 : 0.022),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }
}

// Alternative Floating Action Button Style Navigation with Purple Theme
class FloatingBottomNavigation extends StatefulWidget {
  const FloatingBottomNavigation({super.key});

  @override
  State<FloatingBottomNavigation> createState() => _FloatingBottomNavigationState();
}

class _FloatingBottomNavigationState extends State<FloatingBottomNavigation> {
  final _pageOptions = [
    DashboardScreen(),
    ManageScreen(),
    SalesScreen(),
    SettingsScreen(),
  ];

  int _currentIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(Icons.dashboard_rounded, 'Dashboard', CoustColors.primaryPurple),
    NavItem(Icons.inventory_2_rounded, 'Manage', CoustColors.teal),
    NavItem(Icons.trending_up_rounded, 'Sales', CoustColors.emerald),
    NavItem(Icons.settings_rounded, 'Settings', CoustColors.magenta),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: _pageOptions[_currentIndex],
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.025),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          boxShadow: [
            BoxShadow(
              color: CoustColors.primaryPurple.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CoustColors.veryLightPurple.withOpacity(0.9),
                    CoustColors.veryLightPurple.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.1),
                border: Border.all(
                  color: CoustColors.colrStrock1.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _navItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  NavItem item = entry.value;
                  bool isSelected = _currentIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [
                            item.color,
                            item.color.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: item.color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? CoustColors.colrMainbg
                                : item.color,
                            size: screenWidth * (isSelected ? 0.06 : 0.05),
                          ),
                          if (isSelected) ...[
                            SizedBox(height: screenHeight * 0.003),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: CoustColors.colrMainbg,
                                fontSize: screenWidth * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Enhanced Purple Theme Gradient Navigation (Alternative Style)
class GradientBottomNavigation extends StatefulWidget {
  const GradientBottomNavigation({super.key});

  @override
  State<GradientBottomNavigation> createState() => _GradientBottomNavigationState();
}

class _GradientBottomNavigationState extends State<GradientBottomNavigation> {
  final _pageOptions = [
    DashboardScreen(),
    ManageScreen(),
    SalesScreen(),
    SettingsScreen(),
  ];

  int _currentIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(Icons.dashboard_rounded, 'Dashboard', CoustColors.primaryPurple),
    NavItem(Icons.inventory_2_rounded, 'Manage', CoustColors.teal),
    NavItem(Icons.trending_up_rounded, 'Sales', CoustColors.emerald),
    NavItem(Icons.settings_rounded, 'Settings', CoustColors.magenta),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: _pageOptions[_currentIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.gradientStart,
                  CoustColors.gradientMiddle,
                  CoustColors.gradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.08),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Container(
              height: screenHeight * 0.085,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  NavItem item = entry.value;
                  bool isSelected = _currentIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CoustColors.colrMainbg.withOpacity(0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        border: isSelected
                            ? Border.all(
                          color: CoustColors.colrMainbg.withOpacity(0.4),
                          width: 1.5,
                        )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? CoustColors.colrMainbg
                                : CoustColors.colrMainbg.withOpacity(0.7),
                            size: screenWidth * (isSelected ? 0.055 : 0.05),
                          ),
                          SizedBox(height: screenHeight * 0.003),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? CoustColors.colrMainbg
                                  : CoustColors.colrMainbg.withOpacity(0.7),
                              fontSize: screenWidth * (isSelected ? 0.025 : 0.022),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for navigation items
class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem(this.icon, this.label, this.color);
}