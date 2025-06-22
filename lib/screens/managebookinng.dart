// lib/screens/manage_booking_screen.dart
import 'dart:ui';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/models/vendor_booking_models.dart'; // Import the new provider file
import 'package:bb_vendor/providers/auth.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/addpropertynotifier.dart';
import '../providers/user_details_provider.dart';
import '../providers/vendor_booking_provider.dart' hide currentUserProvider;
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
  int? _lastUserId; // Track the last user ID to detect vendor changes

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

    // Initialize animations
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

    // Mark animations as initialized
    _animationsInitialized = true;

    // Start animations
    _fadeController!.forward();
    _slideController!.forward();
    _pulseController!.repeat(reverse: true);

    // Initialize with current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUserChange();
    });
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
      // User has changed, invalidate all related providers
      print('User changed from $_lastUserId to $currentUserId, refreshing data...');
      _refreshAllData();
    }

    _lastUserId = currentUserId as int?;
  }

  void _refreshAllData() {
    // Invalidate all vendor-related providers to ensure fresh data
    ref.invalidate(vendorBookingsProvider);
    ref.invalidate(vendorBookingStatsProvider);
    // Also invalidate property provider in case properties changed
    ref.invalidate(propertyNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Watch for user changes
    ref.listen(currentUserProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('Detected user change: $previous -> $next');
        _refreshAllData();
      }
    });

    final vendorBookingsAsync = ref.watch(vendorBookingsProvider);
    final currentUser = ref.watch(authprovider);

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: AppBar(
        backgroundColor: CoustColors.veryLightPurple,
        elevation: 0,
        title: _animationsInitialized ? FadeTransition(
          opacity: _fadeAnimation!,
          child: Column(
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
          ),
        ) : Column(
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
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: CoustColors.primaryPurple,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _animationsInitialized ? AnimatedBuilder(
            animation: _pulseAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation!.value,
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: CoustColors.primaryPurple,
                  ),
                  onPressed: () {
                    print('Manual refresh triggered');
                    _refreshAllData();
                  },
                ),
              );
            },
          ) : IconButton(
            icon: Icon(
              Icons.refresh,
              color: CoustColors.primaryPurple,
            ),
            onPressed: () {
              print('Manual refresh triggered');
              _refreshAllData();
            },
          ),
          // Add user indicator
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: CoustColors.primaryPurple,
            ),
            onPressed: () {
              _showUserInfo(context);
            },
          ),
        ],
      ),
      body: _animationsInitialized ? FadeTransition(
        opacity: _fadeAnimation!,
        child: SlideTransition(
          position: _slideAnimation!,
          child: Column(
            children: [
              // Enhanced Search field with purple theme
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
                    hint: "Search bookings...",
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

              // Filter tabs with enhanced styling
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
                    length: 4,
                    tab0: "All",
                    tab1: "Current",
                    tab2: "Upcoming",
                    tab3: "Cancelled",
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

              const SizedBox(height: 10),

              // Enhanced Bookings list with glassmorphism
              Expanded(
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
                          data: (bookings) => _buildBookingsList(bookings),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ) : Column(
        children: [
          // Enhanced Search field with purple theme
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
                hint: "Search bookings...",
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

          // Filter tabs with enhanced styling
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
                length: 4,
                tab0: "All",
                tab1: "Current",
                tab2: "Upcoming",
                tab3: "Cancelled",
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

          const SizedBox(height: 10),

          // Enhanced Bookings list with glassmorphism
          Expanded(
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
                      data: (bookings) => _buildBookingsList(bookings),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  void _showUserInfo(BuildContext context) {
    final currentUser = ref.read(authprovider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CoustColors.colrMainbg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Current User',
          style: TextStyle(
            color: CoustColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoRow('User ID', '${currentUser.data?.userId ?? 'Not available'}'),
            _buildUserInfoRow('Username', '${currentUser.data?.username ?? 'Not available'}'),
            _buildUserInfoRow('Email', '${currentUser.data?.email ?? 'Not available'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: CoustColors.colrSubText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoustColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Refresh Data',
              style: TextStyle(color: CoustColors.colrMainbg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CoustColors.colrMainText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: CoustColors.colrSubText),
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

  Widget _buildBookingsList(List<VendorBookingData> bookings) {
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

  Widget _buildBookingItem(VendorBookingData bookingData) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (bookingData.booking.isPaid) {
      case 'c': // Confirmed
        statusColor = CoustColors.emerald;
        statusBgColor = CoustColors.emerald.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        break;
      case 'cl': // Cancelled
        statusColor = CoustColors.rose;
        statusBgColor = CoustColors.rose.withOpacity(0.1);
        statusIcon = Icons.cancel;
        break;
      case '0': // Available
        statusColor = CoustColors.colrSubText;
        statusBgColor = CoustColors.colrSubText.withOpacity(0.1);
        statusIcon = Icons.schedule;
        break;
      default: // Upcoming/Pending
        statusColor = CoustColors.primaryPurple;
        statusBgColor = CoustColors.primaryPurple.withOpacity(0.1);
        statusIcon = Icons.pending;
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

                      const SizedBox(height: 12),

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
                              sName: bookingData.bookingDate,
                              textsize: 12,
                              txtcolor: CoustColors.colrSubText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                              sName: bookingData.timeSlot,
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
}