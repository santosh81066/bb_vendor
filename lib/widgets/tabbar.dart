import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CoustTabbar extends StatefulWidget {
  CoustTabbar({super.key, required this.filter, required this.length,required this.tab0,required this.tab1,required this.tab2,this.tab3,this.onTap});
  String filter;
  int length;
  String tab0;
  String tab1;
  String tab2;
  String? tab3;
  final String? Function(int?)? onTap;

  @override
  State<CoustTabbar> createState() => _CoustTabbarState();
}

class _CoustTabbarState extends State<CoustTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.length, vsync: this);
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
        color: CoustColors.colrMainbg,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: CoustColors.colrMainbg,
        unselectedLabelColor: CoustColors.colrSubText,
        labelColor: CoustColors.colrHighlightedText,

        indicatorColor: CoustColors.colrHighlightedText, // Remove the underline
        indicatorPadding:
            EdgeInsets.symmetric(vertical: 8.0), // Adjust indicator height
        labelPadding: EdgeInsets.only(right: 20, left: 15),

        automaticIndicatorColorAdjustment: false,
        onTap:widget.onTap ,
        controller: _tabController,
        tabs:  [
          Tab(text: widget.tab0),
          Tab(text: widget.tab1),
          Tab(text: widget.tab2),
          if (widget.length == 4) Tab(text: widget.tab3!),
        ],
      ),
    );
  }
}
