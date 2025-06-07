// Import this for the blur effect
import 'dart:ui';
import 'package:bb_vendor/Screens/dashboard.dart';
import 'package:bb_vendor/Screens/manage.dart';
import 'package:bb_vendor/Screens/sales.dart';
import 'package:bb_vendor/Screens/settings.dart';
import 'package:flutter/material.dart';

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

  // Navigation items data
  final List<NavItem> _navItems = [
    NavItem(Icons.dashboard_rounded, 'Dashboard', Colors.blue),
    NavItem(Icons.inventory_2_rounded, 'Manage', Colors.green),
    NavItem(Icons.trending_up_rounded, 'Sales', Colors.orange),
    NavItem(Icons.settings_rounded, 'Settings', Colors.purple),
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
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                          horizontal: screenWidth * 0.02, // Reduced padding
                          vertical: screenHeight * 0.003, // Reduced padding
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              item.color.withOpacity(0.2),
                              item.color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          border: isSelected
                              ? Border.all(
                            color: item.color.withOpacity(0.3),
                            width: 1,
                          )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.01), // Reduced padding
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
                                    : Colors.grey.shade600,
                                size: screenWidth * (isSelected ? 0.055 : 0.05), // Reduced icon size
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.002), // Reduced spacing
                            Flexible(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? item.color
                                      : Colors.grey.shade600,
                                  fontSize: screenWidth * (isSelected ? 0.025 : 0.022), // Reduced font size
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

// Alternative Floating Action Button Style Navigation
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
    NavItem(Icons.dashboard_rounded, 'Dashboard', Colors.blue),
    NavItem(Icons.inventory_2_rounded, 'Manage', Colors.green),
    NavItem(Icons.trending_up_rounded, 'Sales', Colors.orange),
    NavItem(Icons.settings_rounded, 'Settings', Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: _pageOptions[_currentIndex],
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.025), // 2.5% of screen height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navItems.asMap().entries.map((entry) {
            int index = entry.key;
            NavItem item = entry.value;
            bool isSelected = _currentIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: screenWidth * (isSelected ? 0.16 : 0.12), // 16% or 12% of screen width
                height: screenWidth * (isSelected ? 0.16 : 0.12), // Keep it square
                child: FloatingActionButton(
                  heroTag: "nav_$index",
                  backgroundColor: isSelected
                      ? item.color
                      : Colors.white,
                  elevation: isSelected ? 8 : 4,
                  onPressed: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? Colors.white
                            : item.color,
                        size: screenWidth * (isSelected ? 0.06 : 0.05), // 6% or 5% of screen width
                      ),
                      if (isSelected) ...[
                        SizedBox(height: screenHeight * 0.002), // 0.2% of screen height
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.02, // 2% of screen width
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

