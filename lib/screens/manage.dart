import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Header animation controller
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Pulse animation controller for interactive elements
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _headerController.forward();
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _cardData = [
    {
      'title': 'Manage Bookings',
      'subtitle': 'Handle reservations & events',
      'icon': Icons.event_note_rounded,
      'color': CoustColors.primaryPurple,
      'gradient': [CoustColors.primaryPurple, CoustColors.mediumPurple],
      'route': '/managebooking',
      'stats': '24 Active'
    },
    {
      'title': 'Manage Properties',
      'subtitle': 'Halls & venue management',
      'icon': Icons.store_rounded,
      'color': CoustColors.teal,
      'gradient': [CoustColors.teal, CoustColors.deepBlue],
      'route': '/manageproperty',
      'stats': '8 Venues'
    },
    {
      'title': 'Transactions',
      'subtitle': 'Payments & financial records',
      'icon': Icons.account_balance_wallet_rounded,
      'color': CoustColors.gold,
      'gradient': [CoustColors.gold, CoustColors.rose],
      'route': '/alltransactions',
      'stats': '₹45,230'
    },
    {
      'title': 'Calendar',
      'subtitle': 'Schedule & availability',
      'icon': Icons.calendar_month_rounded,
      'color': CoustColors.magenta,
      'gradient': [CoustColors.magenta, CoustColors.accentPurple],
      'route': '/manageCalendar',
      'stats': '12 Events'
    },
  ];

  // Helper method to get responsive values based on screen size
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  double _getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    double? desktop,
  }) {
    if (_isLargeScreen(context)) {
      return desktop ?? tablet;
    } else if (_isTablet(context)) {
      return tablet;
    }
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return SafeArea(
            child: Column(
              children: [
                // Enhanced Premium Header with purple theme animations - Fixed height
                SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerAnimation,
                    child: _buildAnimatedHeader(context),
                  ),
                ),

                // Enhanced Card Grid with responsive layout - Fixed constraints
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(_getResponsiveValue(
                                context,
                                mobile: 16,
                                tablet: 24,
                              )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: _getResponsiveValue(
                                    context,
                                    mobile: 16,
                                    tablet: 20,
                                  )),
                                  _buildResponsiveGrid(context, constraints),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _getResponsiveValue(
        context,
        mobile: 120,
        tablet: 140,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.gradientStart,
            CoustColors.gradientMiddle,
            CoustColors.gradientEnd,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: CoustColors.darkPurple.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Enhanced decorative elements with animation using purple theme
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _headerController,
              builder: (context, child) {
                final delay = index * 0.1;
                final animation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _headerController,
                  curve: Interval(delay, 1.0, curve: Curves.easeOut),
                ));

                return Positioned(
                  top: -40 + (index * 20),
                  right: -40 + (index * 30),
                  child: Opacity(
                    opacity: animation.value * 0.15,
                    child: Transform.scale(
                      scale: animation.value,
                      child: Container(
                        width: 140 - (index * 15),
                        height: 140 - (index * 15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CoustColors.veryLightPurple.withOpacity(0.1 + (index * 0.02)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Animated floating particles with purple theme
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // Simple alternating movement without trigonometric functions
                double offsetX = _pulseController.value > 0.5 ? 5.0 : -5.0;
                double offsetY = index.isEven
                    ? (_pulseController.value > 0.5 ? 3.0 : -3.0)
                    : (_pulseController.value > 0.5 ? -3.0 : 3.0);

                return Positioned(
                  top: 20 + (index * 25),
                  left: 50 + (index * 40),
                  child: Transform.translate(
                    offset: Offset(offsetX, offsetY),
                    child: Container(
                      width: 6 + (index * 2),
                      height: 6 + (index * 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CoustColors.veryLightPurple.withOpacity(0.4 - (index * 0.1)),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main header content
          Padding(
            padding: EdgeInsets.only(
              top: _getResponsiveValue(context, mobile: 30, tablet: 40),
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _headerController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (1 - _headerController.value) * -50,
                              0,
                            ),
                            child: Opacity(
                              opacity: _headerController.value,
                              child: coustText(
                                sName: "Vendor Hub",
                                txtcolor: CoustColors.colrMainbg,
                                textsize: _getResponsiveValue(
                                  context,
                                  mobile: 22,
                                  tablet: 26,
                                  desktop: 30,
                                ),
                                fontweight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _headerController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (1 - _headerController.value) * -30,
                              0,
                            ),
                            child: Opacity(
                              opacity: _headerController.value,
                              child: coustText(
                                sName: "Manage Properties • Bookings • Calendar",
                                txtcolor: CoustColors.colrMainbg.withOpacity(0.85),
                                textsize: _getResponsiveValue(
                                  context,
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                                fontweight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _headerController.value,
                      child: Transform.rotate(
                        angle: (1 - _headerController.value) * 0.5,
                        child: Container(
                          width: _getResponsiveValue(context, mobile: 45, tablet: 50),
                          height: _getResponsiveValue(context, mobile: 45, tablet: 50),
                          decoration: BoxDecoration(
                            color: CoustColors.veryLightPurple.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CoustColors.veryLightPurple.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.business_center_outlined,
                            color: CoustColors.colrMainbg,
                            size: _getResponsiveValue(context, mobile: 20, tablet: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, BoxConstraints constraints) {
    final availableHeight = constraints.maxHeight - 60; // Account for title and spacing

    if (_isTablet(context)) {
      // Tablet layout: 2x2 or 3 column grid with calculated heights
      final cardHeight = (availableHeight - 40) / 2; // 2 rows with spacing

      return SizedBox(
        height: availableHeight,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isLargeScreen(context) ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _isLargeScreen(context) ? 1.1 : 0.9,
          ),
          itemCount: _cardData.length,
          itemBuilder: (context, index) {
            return _buildAnimatedCard(
              cardData: _cardData[index],
              index: index,
            );
          },
        ),
      );
    } else {
      // Mobile layout: Fixed 2x2 grid with calculated heights
      final cardHeight = (availableHeight - 16) / 2; // 2 rows with spacing between

      return SizedBox(
        height: availableHeight,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: cardHeight,
                      child: _buildAnimatedCard(
                        cardData: _cardData[0],
                        index: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: cardHeight,
                      child: _buildAnimatedCard(
                        cardData: _cardData[1],
                        index: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: cardHeight,
                      child: _buildAnimatedCard(
                        cardData: _cardData[2],
                        index: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: cardHeight,
                      child: _buildAnimatedCard(
                        cardData: _cardData[3],
                        index: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAnimatedCard({
    required Map<String, dynamic> cardData,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Fixed intervals to ensure end values don't exceed 1.0
        final startTime = 0.2 + (index * 0.1);
        final endTime = (0.6 + (index * 0.1)).clamp(0.0, 1.0); // Clamp to max 1.0

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.8),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startTime.clamp(0.0, 1.0),
            endTime,
            curve: Curves.easeOutCubic,
          ),
        ));

        final scaleAnimation = Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startTime.clamp(0.0, 1.0),
            endTime,
            curve: Curves.easeOutBack,
          ),
        ));

        final rotationAnimation = Tween<double>(
          begin: 0.1,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startTime.clamp(0.0, 1.0),
            endTime,
            curve: Curves.easeOut,
          ),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Transform.rotate(
              angle: rotationAnimation.value,
              child: _buildEnhancedCard(cardData, context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCard(Map<String, dynamic> cardData, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(cardData['route']),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardData['gradient'],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CoustColors.colrStrock1.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cardData['color'].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: CoustColors.primaryPurple.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Enhanced background decorative elements with purple theme
              Positioned(
                top: -20,
                right: -20,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_pulseController.value * 0.05),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CoustColors.veryLightPurple.withOpacity(0.15),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Floating particles with purple theme
              ...List.generate(2, (i) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    // Simple alternating movement
                    double offsetX = _pulseController.value > 0.5 ? 1.5 : -1.5;
                    double offsetY = i.isEven
                        ? (_pulseController.value > 0.5 ? 1.5 : -1.5)
                        : (_pulseController.value > 0.5 ? -1.5 : 1.5);

                    return Positioned(
                      top: 25 + (i * 15),
                      right: 15 + (i * 10),
                      child: Transform.translate(
                        offset: Offset(offsetX, offsetY),
                        child: Container(
                          width: 3 + (i * 1),
                          height: 3 + (i * 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CoustColors.veryLightPurple.withOpacity(0.4 - (i * 0.1)),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main content with enhanced animations and purple theme
              Padding(
                padding: EdgeInsets.all(_getResponsiveValue(
                  context,
                  mobile: 16,
                  tablet: 20,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with enhanced icon and stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: 'icon_${cardData['title']}',
                          child: Container(
                            width: _getResponsiveValue(context, mobile: 48, tablet: 54),
                            height: _getResponsiveValue(context, mobile: 48, tablet: 54),
                            decoration: BoxDecoration(
                              color: CoustColors.veryLightPurple.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: CoustColors.veryLightPurple.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              cardData['icon'],
                              color: CoustColors.colrMainbg,
                              size: _getResponsiveValue(context, mobile: 24, tablet: 26),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CoustColors.veryLightPurple.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CoustColors.veryLightPurple.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: coustText(
                            sName: cardData['stats'],
                            txtcolor: CoustColors.colrMainbg,
                            textsize: _getResponsiveValue(context, mobile: 10, tablet: 11),
                            fontweight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Enhanced title and subtitle section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        coustText(
                          sName: cardData['title'],
                          txtcolor: CoustColors.colrMainbg,
                          textsize: _getResponsiveValue(context, mobile: 16, tablet: 18),
                          fontweight: FontWeight.bold,
                        ),
                        SizedBox(height: 4),
                        coustText(
                          sName: cardData['subtitle'],
                          txtcolor: CoustColors.colrMainbg.withOpacity(0.85),
                          textsize: _getResponsiveValue(context, mobile: 11, tablet: 12),
                          fontweight: FontWeight.w400,
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Enhanced action arrow with animation and purple theme
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            // Simple horizontal movement
                            double offsetX = _pulseController.value > 0.5 ? 1.0 : -1.0;

                            return Transform.translate(
                              offset: Offset(offsetX, 0),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: CoustColors.veryLightPurple.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: CoustColors.veryLightPurple.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: CoustColors.colrMainbg,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}