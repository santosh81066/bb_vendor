// lib/Widgets/tabbar.dart (FIXED VERSION)
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:flutter/material.dart';

class CoustTabbar extends StatefulWidget {
  final String filter;
  final int length;
  final String tab0;
  final String tab1;
  final String tab2;
  final String? tab3;
  final String? tab4; // ✨ ADDED: Support for 5th tab
  final Function(int)? onTap; // ✨ FIXED: Correct function signature

  const CoustTabbar({
    super.key,
    required this.filter,
    required this.length,
    required this.tab0,
    required this.tab1,
    required this.tab2,
    this.tab3,
    this.tab4, // ✨ ADDED: Optional 5th tab parameter
    this.onTap,
  });

  @override
  State<CoustTabbar> createState() => _CoustTabbarState();
}

class _CoustTabbarState extends State<CoustTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.length, vsync: this);
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(CoustTabbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle length changes
    if (oldWidget.length != widget.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.length, vsync: this);
    }

    // Update selected index when filter changes
    if (oldWidget.filter != widget.filter) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    // ✨ NEW: Set the correct tab based on current filter
    switch (widget.filter) {
      case "All":
        _selectedIndex = 0;
        break;
      case "Current":
        _selectedIndex = 1;
        break;
      case "Upcoming":
        _selectedIndex = 2;
        break;
      case "Cancelled":
        _selectedIndex = 3;
        break;
      default:
        _selectedIndex = 0;
    }

    // Update the tab controller if the index has changed
    if (_tabController.index != _selectedIndex) {
      _tabController.animateTo(_selectedIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.colrMainbg,
            CoustColors.veryLightPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: CoustColors.colrStrock1.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: TabBar(
          controller: _tabController,
          isScrollable: false, // ✨ CHANGED: Make it fit the width
          tabAlignment: TabAlignment.fill, // ✨ CHANGED: Fill the available space
          dividerColor: Colors.transparent,

          // ✨ ENHANCED: Better styling
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CoustColors.primaryPurple,
                CoustColors.mediumPurple,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CoustColors.primaryPurple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.all(4),
          indicatorSize: TabBarIndicatorSize.tab,

          // ✨ ENHANCED: Better text styling
          labelColor: CoustColors.colrMainbg,
          unselectedLabelColor: CoustColors.colrSubText,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),

          // ✨ FIXED: Proper onTap handling
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (widget.onTap != null) {
              widget.onTap!(index);
            }
          },

          // ✨ ENHANCED: Dynamic tabs with icons and proper handling
          tabs: _buildTabs(),
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    List<Widget> tabs = [
      _buildTab(widget.tab0, 0),
      _buildTab(widget.tab1, 1),
      _buildTab(widget.tab2, 2),
    ];

    // ✨ ENHANCED: Support for 4th tab
    if (widget.length >= 4 && widget.tab3 != null) {
      tabs.add(_buildTab(widget.tab3!, 3));
    }

    // ✨ NEW: Support for 5th tab
    if (widget.length >= 5 && widget.tab4 != null) {
      tabs.add(_buildTab(widget.tab4!, 4));
    }

    return tabs;
  }

  Widget _buildTab(String text, int index) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✨ NEW: Add status indicators based on tab type
          if (_getTabIcon(text) != null) ...[
            Icon(
              _getTabIcon(text),
              size: 14,
              color: isSelected
                  ? CoustColors.colrMainbg
                  : _getTabColor(text),
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? CoustColors.colrMainbg
                    : CoustColors.colrSubText,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ✨ NEW: Get appropriate icon for each tab
  IconData? _getTabIcon(String tabText) {
    switch (tabText.toLowerCase()) {
      case 'all':
        return Icons.dashboard;
      case 'current':
        return Icons.today;
      case 'upcoming':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'blocked':
        return Icons.pending;
      default:
        return null;
    }
  }

  // ✨ NEW: Get appropriate color for each tab type
  Color _getTabColor(String tabText) {
    switch (tabText.toLowerCase()) {
      case 'current':
        return CoustColors.emerald;
      case 'upcoming':
        return CoustColors.primaryPurple;
      case 'cancelled':
        return CoustColors.rose;
      case 'blocked':
        return CoustColors.gold;
      default:
        return CoustColors.colrSubText;
    }
  }
}