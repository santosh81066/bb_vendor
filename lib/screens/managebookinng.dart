// lib/screens/manage_booking_screen.dart (FIXED VERSION)
import 'dart:ui';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/models/vendor_booking_models.dart';
import 'package:bb_vendor/providers/auth.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/authstate.dart';
import '../providers/addpropertynotifier.dart';
import '../providers/vendor_booking_provider.dart';
import 'bookingdetails.dart';

class ManageBookingScreen extends ConsumerStatefulWidget {
  const ManageBookingScreen({super.key});

  @override
  ConsumerState<ManageBookingScreen> createState() => _ManageBookingScreenState();
}

class _ManageBookingScreenState extends ConsumerState<ManageBookingScreen>
    with TickerProviderStateMixin {
  String searchQuery = '';
  String filter = 'All';
  int? _lastUserId;

  // Animation controllers
  AnimationController? _fadeController;
  AnimationController? _slideController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _pulseAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUserChange();
    });
  }

  void _initializeAnimations() {
    try {
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _fadeController!,
        curve: Curves.easeInOut,
      ));

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController!,
        curve: Curves.easeOutCubic,
      ));

      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ));

      _animationsInitialized = true;

      _fadeController!.forward();
      _slideController!.forward();
      _pulseController!.repeat(reverse: true);
    } catch (e) {
      print('Error initializing animations: $e');
      _animationsInitialized = false;
    }
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _checkForUserChange() {
    final currentUserId = ref.read(currentUserProvider);

    if (_lastUserId != null && _lastUserId != currentUserId) {
      print('User changed from $_lastUserId to $currentUserId, refreshing data...');
      _refreshAllData();
    }

    _lastUserId = currentUserId;
  }

  void _refreshAllData() {
    // Invalidate vendor-related providers to ensure fresh data
    ref.invalidate(vendorBookingsProvider);
    ref.invalidate(vendorBookingStatsProvider);
    ref.invalidate(propertyNotifierProvider);

    // Update manual refresh counter to trigger refresh
    ref.read(manualRefreshProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    // Watch for user changes and refresh data accordingly
    ref.listen(currentUserProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('Detected user change: $previous -> $next');
        _refreshAllData();
      }
    });

    final vendorBookingsAsync = ref.watch(vendorBookingsProvider);
    final currentUser = ref.watch(authprovider);
    final bookingStats = ref.watch(vendorBookingStatsProvider);

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: _buildAppBar(currentUser),
      body: _buildBody(vendorBookingsAsync, bookingStats),
    );
  }

  PreferredSizeWidget _buildAppBar(AdminAuth currentUser) {
    return AppBar(
      backgroundColor: CoustColors.veryLightPurple,
      elevation: 0,
      title: _animationsInitialized ? FadeTransition(
        opacity: _fadeAnimation!,
        child: _buildAppBarTitle(currentUser),
      ) : _buildAppBarTitle(currentUser),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: CoustColors.primaryPurple,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildRefreshButton(),
        _buildStatsButton(),
      ],
    );
  }

  Widget _buildAppBarTitle(AdminAuth currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        coustText(
          sName: 'Manage Bookings',
          txtcolor: CoustColors.primaryPurple,
          fontweight: FontWeight.bold,
          textsize: 18,
        ),
        if (currentUser.data?.username != null)
          coustText(
            sName: 'Welcome, ${currentUser.data!.username}',
            txtcolor: CoustColors.colrSubText,
            textsize: 12,
          ),
      ],
    );
  }

  Widget _buildRefreshButton() {
    if (!_animationsInitialized) {
      return IconButton(
        icon: Icon(Icons.refresh, color: CoustColors.primaryPurple),
        onPressed: _refreshAllData,
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation!.value,
          child: IconButton(
            icon: Icon(Icons.refresh, color: CoustColors.primaryPurple),
            onPressed: () {
              print('Manual refresh triggered');
              _refreshAllData();
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsButton() {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(vendorBookingStatsProvider);

        return IconButton(
          icon: Stack(
            children: [
              Icon(Icons.analytics, color: CoustColors.primaryPurple),
              if (stats.total > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: CoustColors.emerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${stats.total}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showStatsDialog(stats),
        );
      },
    );
  }

  Widget _buildBody(AsyncValue<List<VendorBookingData>> vendorBookingsAsync, BookingStats statsAsync) {
    Widget content = Column(
      children: [
        _buildSearchAndFilters(),
        _buildStatsRow(statsAsync),
        _buildBookingsList(vendorBookingsAsync),
      ],
    );

    if (!_animationsInitialized) return content;

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(
        position: _slideAnimation!,
        child: content,
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Enhanced Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.primaryPurple.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CoustTextfield(
              hint: "Search bookings, customers, emails...",
              radius: 30.0,
              width: 10,
              isVisible: false,
              prefixIcon: Icon(
                Icons.search,
                color: CoustColors.primaryPurple,
              ),
              fillcolor: CoustColors.colrMainbg,
              filled: true,
              onChanged: (value) {
                setState(() {
                  searchQuery = value!;
                });
                return null;
              },
            ),
          ),
        ),

        // Enhanced Filter tabs
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.primaryPurple.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CoustTabbar(
              filter: filter,
              length: 4, // Updated to include more filters
              tab0: "All",
              tab1: "Current",
              tab2: "Upcoming",
              tab3: "Cancelled",
               // New tab for blocked/pending bookings
              onTap: (selected) {
                setState(() {
                  switch (selected) {
                    case 0:
                      filter = "All";
                      break;
                    case 1:
                      filter = "Current";
                      break;
                    case 2:
                      filter = "Upcoming";
                      break;
                    case 3:
                      filter = "Cancelled";
                      break;

                  }
                });
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BookingStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.primaryPurple.withOpacity(0.1),
            CoustColors.mediumPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: CoustColors.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', stats.total.toString(), CoustColors.primaryPurple),
          _buildStatDivider(),
          _buildStatItem('Confirmed', stats.confirmed.toString(), CoustColors.emerald),
          _buildStatDivider(),
          _buildStatItem('Today', stats.today.toString(), CoustColors.gold),
          _buildStatDivider(),
          _buildStatItem('Revenue', stats.formattedRevenue, CoustColors.mediumPurple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CoustColors.colrSubText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CoustColors.colrStrock1.withOpacity(0.1),
            CoustColors.colrStrock1.withOpacity(0.4),
            CoustColors.colrStrock1.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(AsyncValue<List<VendorBookingData>> vendorBookingsAsync) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CoustColors.colrMainbg.withOpacity(0.95),
                CoustColors.veryLightPurple.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: CoustColors.colrStrock1.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CoustColors.primaryPurple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: vendorBookingsAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorWidget(error.toString()),
                data: (bookings) => _buildBookingsListContent(bookings),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsListContent(List<VendorBookingData> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    // Create filter object for the provider
    final filterObj = BookingFilter(
      status: filter,
      searchQuery: searchQuery,
    );

    // Use the filtered bookings provider
    final filteredBookings = ref.watch(filteredBookingsProvider(filterObj));

    if (filteredBookings.isEmpty) {
      return _buildNoResultsState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildBookingItem(filteredBookings[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingItem(VendorBookingData bookingData) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (bookingData.booking.isPaid) {
      case 'c':
        statusColor = CoustColors.emerald;
        statusBgColor = CoustColors.emerald.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        break;
      case 'cl':
        statusColor = CoustColors.rose;
        statusBgColor = CoustColors.rose.withOpacity(0.1);
        statusIcon = Icons.cancel;
        break;
      case 'b':
        statusColor = CoustColors.gold;
        statusBgColor = CoustColors.gold.withOpacity(0.1);
        statusIcon = Icons.pending;
        break;
      case '0':
      default:
        statusColor = CoustColors.colrSubText;
        statusBgColor = CoustColors.colrSubText.withOpacity(0.1);
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.colrMainbg,
            CoustColors.veryLightPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CoustColors.colrStrock1.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookingDetailsScreen(
                  bookingData: bookingData,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property and Hall name
                      coustText(
                        sName: bookingData.propertyName,
                        fontweight: FontWeight.bold,
                        textsize: 16,
                        txtcolor: CoustColors.primaryPurple,
                      ),
                      const SizedBox(height: 4),
                      coustText(
                        sName: bookingData.hallName,
                        textsize: 14,
                        txtcolor: CoustColors.colrSubText,
                      ),

                      const SizedBox(height: 8),

                      // ENHANCED: Customer information using embedded data
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CoustColors.primaryPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: CoustColors.primaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: coustText(
                                sName: bookingData.displayUserName,
                                textsize: 12,
                                txtcolor: CoustColors.primaryPurple,
                                fontweight: FontWeight.w600,
                              ),
                            ),
                            // Show data indicator
                            if (bookingData.hasUserInfo)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: CoustColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: CoustColors.mediumPurple,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: coustText(
                              sName: bookingData.formattedDate,
                              textsize: 12,
                              txtcolor: CoustColors.colrSubText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: CoustColors.mediumPurple,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: coustText(
                              sName: bookingData.formattedTimeSlot,
                              textsize: 12,
                              txtcolor: CoustColors.colrSubText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: coustText(
                          sName: bookingData.bookingStatus,
                          textsize: 12,
                          fontweight: FontWeight.w600,
                          txtcolor: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow and ID
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: CoustColors.primaryPurple,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CoustColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${bookingData.booking.id}',
                        style: TextStyle(
                          fontSize: 10,
                          color: CoustColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  CoustColors.primaryPurple,
                  CoustColors.mediumPurple,
                ],
              ),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CoustColors.colrMainbg),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your bookings...',
            style: TextStyle(
              color: CoustColors.colrSubText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CoustColors.rose.withOpacity(0.2),
                    CoustColors.rose.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: CoustColors.rose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CoustColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CoustColors.colrSubText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  'Retry',
                  CoustColors.primaryPurple,
                      () => _refreshAllData(),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  'Refresh Auth',
                  CoustColors.gold,
                      () async {
                    await ref.read(authprovider.notifier).forceRefreshUserData();
                    _refreshAllData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final currentUser = ref.read(authprovider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CoustColors.primaryPurple.withOpacity(0.2),
                    CoustColors.mediumPurple.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.event_note,
                size: 50,
                color: CoustColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Bookings Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No bookings found for ${currentUser.data?.username ?? 'this vendor'}.\nBookings will appear here once customers book your halls.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CoustColors.colrSubText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              'Check for New Bookings',
              CoustColors.primaryPurple,
                  () => _refreshAllData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CoustColors.colrSubText.withOpacity(0.2),
                    CoustColors.colrSubText.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: CoustColors.colrSubText,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CoustColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No bookings match your current search or filter criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CoustColors.colrSubText,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'Clear Filters',
              CoustColors.mediumPurple,
                  () {
                setState(() {
                  searchQuery = '';
                  filter = 'All';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: CoustColors.colrMainbg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showStatsDialog(BookingStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CoustColors.colrMainbg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Booking Statistics',
          style: TextStyle(
            color: CoustColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Bookings', stats.total.toString()),
            _buildStatRow('Confirmed', stats.confirmed.toString()),
            _buildStatRow('Cancelled', stats.cancelled.toString()),
            _buildStatRow('Blocked/Pending', stats.blocked.toString()),
            _buildStatRow('Today\'s Bookings', stats.today.toString()),
            _buildStatRow('Upcoming', stats.upcoming.toString()),
            const SizedBox(height: 8),
            Divider(color: CoustColors.colrStrock1.withOpacity(0.3)),
            const SizedBox(height: 8),
            _buildStatRow('Total Revenue', stats.formattedRevenue, isHighlight: true),
            _buildStatRow('Confirmation Rate', '${stats.confirmationRate.toStringAsFixed(1)}%', isHighlight: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: CoustColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CoustColors.colrSubText,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? CoustColors.primaryPurple : CoustColors.colrMainText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}