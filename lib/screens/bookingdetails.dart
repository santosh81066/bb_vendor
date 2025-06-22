import 'dart:ui';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/models/vendor_booking_models.dart';
import 'package:bb_vendor/providers/hall_booking_provider.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Providers/auth.dart';
import '../providers/user_details_provider.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final VendorBookingData bookingData;

  const BookingDetailsScreen({
    super.key,
    required this.bookingData,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;

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
  }

  void _initializeAnimations() {
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

    // Start animations
    _fadeController!.forward();
    _slideController!.forward();
    _pulseController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  _onWillPop(bool pop) async {
    ref.read(refundissued.notifier).state = false;
    ref.read(canclebuttonprovider.notifier).state = CoustColors.rose;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get customer details using the booking's user ID
    final customerDetailsAsync = ref.watch(enhancedUserDetailsProvider(widget.bookingData.userId));

    // Debug: Print the user ID being fetched
    print('🔍 Fetching details for user ID: ${widget.bookingData.userId}');
    print('📋 Booking ID: ${widget.bookingData.booking.id}');

    return PopScope(
      onPopInvoked: _onWillPop,
      child: Scaffold(
        backgroundColor: CoustColors.veryLightPurple,
        appBar: AppBar(
          backgroundColor: CoustColors.veryLightPurple,
          elevation: 0,
          title: _animationsInitialized ? FadeTransition(
            opacity: _fadeAnimation!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                coustText(
                  sName: 'Booking Details',
                  txtcolor: CoustColors.primaryPurple,
                  fontweight: FontWeight.bold,
                  textsize: 18,
                ),
                Text(
                  'Customer ID: ${widget.bookingData.userId}',
                  style: TextStyle(
                    color: CoustColors.colrSubText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              coustText(
                sName: 'Booking Details',
                txtcolor: CoustColors.primaryPurple,
                fontweight: FontWeight.bold,
                textsize: 18,
              ),
              Text(
                'Customer ID: ${widget.bookingData.userId}',
                style: TextStyle(
                  color: CoustColors.colrSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
                      print('🔄 Force refreshing user details for ID: ${widget.bookingData.userId}');
                      // Force refresh customer data
                      ref.read(enhancedUserDetailsNotifierProvider.notifier)
                          .forceRefreshUserDetails(widget.bookingData.userId);
                      ref.invalidate(enhancedUserDetailsProvider(widget.bookingData.userId));
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
                print('🔄 Force refreshing user details for ID: ${widget.bookingData.userId}');
                // Force refresh customer data
                ref.read(enhancedUserDetailsNotifierProvider.notifier)
                    .forceRefreshUserDetails(widget.bookingData.userId);
                ref.invalidate(enhancedUserDetailsProvider(widget.bookingData.userId));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return _animationsInitialized ? FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: _buildContent(customerDetailsAsync, ref),
                ),
              ) : _buildContent(customerDetailsAsync, ref);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<UserDetails> customerDetailsAsync, WidgetRef ref) {
    return Column(
      children: [
        // Booking Information Card
        _buildAnimatedCard(
          child: _buildBookingInfoCard(),
          delay: 0,
        ),

        // Customer Details Card (using enhanced provider)
        _buildAnimatedCard(
          child: _buildCustomerDetailsCard(customerDetailsAsync),
          delay: 200,
        ),

        // Venue Details Card
        _buildAnimatedCard(
          child: _buildVenueDetailsCard(),
          delay: 400,
        ),

        // Payment Details Card (if confirmed)
        if (widget.bookingData.booking.isPaid == 'c')
          _buildAnimatedCard(
            child: _buildPaymentDetailsCard(),
            delay: 600,
          ),

        // Refund Details Card (if refund issued)
        if (ref.watch(refundissued))
          _buildAnimatedCard(
            child: _buildRefundDetailsCard(),
            delay: 800,
          ),

        // Action Buttons
        _buildAnimatedCard(
          child: _buildActionButtons(ref),
          delay: 1000,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnimatedCard({required Widget child, required int delay}) {
    if (!_animationsInitialized) return child;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CoustColors.colrMainbg,
            CoustColors.veryLightPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: CoustColors.colrStrock1.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetailsCard(AsyncValue<UserDetails> customerDetailsAsync) {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.primaryPurple.withOpacity(0.2),
                      CoustColors.mediumPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: CoustColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Customer Details",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
              // Show cached indicator
              Consumer(
                builder: (context, ref, child) {
                  final cached = ref.watch(userDetailsCacheProvider(widget.bookingData.userId));
                  if (cached != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CoustColors.emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cached',
                        style: TextStyle(
                          color: CoustColors.emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          customerDetailsAsync.when(
            loading: () => _buildLoadingWidget(),
            error: (error, stack) => _buildErrorWidget(error),
            data: (customerDetails) => _buildCustomerDetailsContent(customerDetails),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
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
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading customer details...',
              style: TextStyle(
                color: CoustColors.colrSubText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    String errorMessage = error.toString();
    IconData errorIcon = Icons.error_outline;
    Color errorColor = CoustColors.rose;

    if (errorMessage.contains('Authentication required')) {
      errorIcon = Icons.login;
      errorColor = CoustColors.gold;
      errorMessage = 'Please login to view customer details';
    } else if (errorMessage.contains('User not found')) {
      errorIcon = Icons.person_off;
      errorMessage = 'Customer not found';
    } else if (errorMessage.contains('Network error')) {
      errorIcon = Icons.wifi_off;
      errorMessage = 'Network connection error';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  errorColor.withOpacity(0.2),
                  errorColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(errorIcon, color: errorColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Retry',
                CoustColors.primaryPurple,
                    () => ref.invalidate(enhancedUserDetailsProvider(widget.bookingData.userId)),
              ),
              if (errorMessage.contains('Authentication'))
                _buildActionButton(
                  'Refresh Auth',
                  CoustColors.gold,
                      () {
                    // Navigate to login or refresh auth
                    ref.read(authprovider.notifier).forceRefreshUserData();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: CoustColors.colrMainbg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCustomerDetailsContent(UserDetails customerDetails) {
    return Column(
      children: [
        if (customerDetails.profilePicture != null && customerDetails.profilePicture!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.primaryPurple.withOpacity(0.2),
                      CoustColors.mediumPurple.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CoustColors.primaryPurple.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(customerDetails.profilePicture!),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading error
                  },
                  child: customerDetails.profilePicture!.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 40,
                    color: CoustColors.primaryPurple,
                  )
                      : null,
                ),
              ),
            ),
          ),
        bookingDetailRow('Customer ID:', customerDetails.userId.toString()),
        bookingDetailRow('Name:', customerDetails.name),
        bookingDetailRow('Email:', customerDetails.email),
        bookingDetailRow('Phone:', customerDetails.phone),
        bookingDetailRow('Address:', customerDetails.address),
        if (customerDetails.createdAt != null)
          bookingDetailRow('Member Since:', _formatDate(customerDetails.createdAt!)),
      ],
    );
  }

  Widget _buildVendorDetailsCard(UserDetails vendorDetails) {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.teal.withOpacity(0.2),
                      CoustColors.teal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: CoustColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Vendor Details",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (vendorDetails.profilePicture != null && vendorDetails.profilePicture!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        CoustColors.teal.withOpacity(0.2),
                        CoustColors.teal.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CoustColors.teal.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(vendorDetails.profilePicture!),
                    child: vendorDetails.profilePicture!.isEmpty
                        ? Icon(
                      Icons.business,
                      size: 30,
                      color: CoustColors.teal,
                    )
                        : null,
                  ),
                ),
              ),
            ),
          bookingDetailRow('Vendor ID:', vendorDetails.userId.toString()),
          bookingDetailRow('Name:', vendorDetails.name),
          bookingDetailRow('Email:', vendorDetails.email),
          bookingDetailRow('Phone:', vendorDetails.phone),
          if (vendorDetails.address.isNotEmpty)
            bookingDetailRow('Address:', vendorDetails.address),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    final booking = widget.bookingData.booking;

    return _buildEnhancedCard(
      margin: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.emerald.withOpacity(0.2),
                      CoustColors.emerald.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note,
                  color: CoustColors.emerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Booking Information",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
              _buildStatusChip(booking.isPaid),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          bookingDetailRow('Booking ID:', '#${booking.id}'),
          bookingDetailRow('Booking Date:', widget.bookingData.formattedDate),
          bookingDetailRow('Time Slot:', widget.bookingData.formattedTimeSlot),
          bookingDetailRow('Status:', widget.bookingData.bookingStatus),
          bookingDetailRow('Created:', _formatDateTime(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildVenueDetailsCard() {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.magenta.withOpacity(0.2),
                      CoustColors.magenta.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: CoustColors.magenta,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Venue Details",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          bookingDetailRow('Property:', widget.bookingData.propertyName),
          bookingDetailRow('Hall:', widget.bookingData.hallName),
          bookingDetailRow('Address:', widget.bookingData.propertyAddress),
          bookingDetailRow('Location:', widget.bookingData.propertyLocation),
          if (widget.bookingData.hall.capacity != null)
            bookingDetailRow('Capacity:', '${widget.bookingData.hall.capacity} people'),
          if (widget.bookingData.hall.price != null)
            bookingDetailRow('Base Price:', '₹${widget.bookingData.hall.price}'),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.emerald.withOpacity(0.2),
                      CoustColors.emerald.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payment,
                  color: CoustColors.emerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Payment Details",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          bookingDetailRow('Transaction ID:', 'TXN${widget.bookingData.bookingId}${DateTime.now().millisecondsSinceEpoch}'),
          bookingDetailRow('Base Amount:', '₹${widget.bookingData.hall.price ?? 0}'),
          bookingDetailRow('GST (18%):', '₹${_calculateGST(widget.bookingData.hall.price ?? 0)}'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          bookingDetailRow(
              'Total Payment:',
              '₹${_calculateTotal(widget.bookingData.hall.price ?? 0)}',
              isTotal: true,
              color: CoustColors.emerald
          ),
          bookingDetailRow(
              'Payment Status:',
              'Completed',
              isTotal: true,
              color: CoustColors.emerald
          ),
        ],
      ),
    );
  }

  Widget _buildRefundDetailsCard() {
    final totalAmount = _calculateTotal(widget.bookingData.hall.price ?? 0);
    final cancellationFee = (totalAmount * 0.1).round();
    final refundAmount = totalAmount - cancellationFee;

    return _buildEnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CoustColors.rose.withOpacity(0.2),
                      CoustColors.rose.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.money_off,
                  color: CoustColors.rose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: coustText(
                  sName: "Refund Details",
                  textsize: 18,
                  fontweight: FontWeight.bold,
                  txtcolor: CoustColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          bookingDetailRow('Refund Transaction ID:', 'RFD${widget.bookingData.bookingId}${DateTime.now().millisecondsSinceEpoch}'),
          bookingDetailRow('Original Amount:', '₹$totalAmount'),
          bookingDetailRow('Cancellation Fee:', '₹$cancellationFee'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CoustColors.colrStrock1.withOpacity(0.1),
                  CoustColors.colrStrock1.withOpacity(0.4),
                  CoustColors.colrStrock1.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          bookingDetailRow(
              'Refund Amount:',
              '₹$refundAmount',
              isTotal: true,
              color: CoustColors.rose
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    final booking = widget.bookingData.booking;
    final isConfirmed = booking.isPaid == 'c';
    final isCancelled = booking.isPaid == 'cl';
    final refundIssued = ref.watch(refundissued);

    if (isCancelled && !refundIssued) {
      return const SizedBox.shrink();
    }

    return _buildEnhancedCard(
      margin: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (isConfirmed && !refundIssued && !isCancelled) ...[
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isProcessing
                      ? [Colors.grey, Colors.grey.shade400]
                      : [CoustColors.rose, CoustColors.rose.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing ? Colors.grey : CoustColors.rose).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _handleCancelAndRefund(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isProcessing ? "Processing..." : "Cancel & Refund",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.colrMainbg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: CoustColors.primaryPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => _contactCustomer(),
                    icon: Icon(
                      Icons.phone,
                      color: CoustColors.primaryPurple,
                      size: 16,
                    ),
                    label: Flexible(
                      child: Text(
                        'Contact',
                        style: TextStyle(
                          color: CoustColors.primaryPurple,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
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
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _viewOnMap(),
                    icon: Icon(
                      Icons.map,
                      color: CoustColors.colrMainbg,
                      size: 16,
                    ),
                    label: Flexible(
                      child: Text(
                        'Location',
                        style: TextStyle(
                          color: CoustColors.colrMainbg,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'c':
        chipColor = CoustColors.emerald;
        statusText = 'Confirmed';
        statusIcon = Icons.check_circle;
        break;
      case 'cl':
        chipColor = CoustColors.rose;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      case '0':
        chipColor = CoustColors.colrSubText;
        statusText = 'Available';
        statusIcon = Icons.schedule;
        break;
      default:
        chipColor = CoustColors.primaryPurple;
        statusText = 'Pending';
        statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withOpacity(0.2),
            chipColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelAndRefund(WidgetRef ref) async {
    final confirmed = await _showCancelConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final bookingNotifier = ref.read(hallBookingProvider.notifier);
      final success = await bookingNotifier.cancelBooking(
        bookingId: widget.bookingData.bookingId,
      );

      if (success) {
        ref.read(refundissued.notifier).state = true;
        ref.read(canclebuttonprovider.notifier).state = CoustColors.colrSubText;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled and refund initiated successfully'),
            backgroundColor: CoustColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $e'),
          backgroundColor: CoustColors.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CoustColors.colrMainbg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Booking',
          style: TextStyle(
            color: CoustColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? A cancellation fee will be deducted from the refund amount.',
          style: TextStyle(color: CoustColors.colrSubText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: CoustColors.colrSubText),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CoustColors.rose, CoustColors.rose.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Yes, Cancel',
                style: TextStyle(color: CoustColors.colrMainbg),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _contactCustomer() {
    // Get customer details from the provider
    final customerDetailsAsync = ref.read(enhancedUserDetailsProvider(widget.bookingData.userId));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CoustColors.colrMainbg,
              CoustColors.veryLightPurple.withOpacity(0.3),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: CoustColors.colrStrock1.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Customer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CoustColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer ID: ${widget.bookingData.userId}',
              style: TextStyle(
                fontSize: 12,
                color: CoustColors.colrSubText,
              ),
            ),
            const SizedBox(height: 20),

            // Show customer details for contact
            customerDetailsAsync.when(
              data: (customer) => Column(
                children: [
                  // Customer info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CoustColors.primaryPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: CoustColors.primaryPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name.isNotEmpty ? customer.name : 'Unknown Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CoustColors.primaryPurple,
                                ),
                              ),
                              if (customer.email.isNotEmpty)
                                Text(
                                  customer.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CoustColors.colrSubText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact options with customer data
                  _buildContactOption(
                      Icons.phone,
                      'Call Customer',
                      customer.phone.isNotEmpty ? customer.phone : 'No phone number',
                      customer.phone.isNotEmpty,
                          () {
                        Navigator.pop(context);
                        if (customer.phone.isNotEmpty) {
                          print('📞 Calling customer: ${customer.phone}');
                          // Implement phone call functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${customer.phone}...'),
                              backgroundColor: CoustColors.primaryPurple,
                            ),
                          );
                        }
                      }
                  ),
                  _buildContactOption(
                      Icons.message,
                      'Send SMS',
                      customer.phone.isNotEmpty ? customer.phone : 'No phone number',
                      customer.phone.isNotEmpty,
                          () {
                        Navigator.pop(context);
                        if (customer.phone.isNotEmpty) {
                          print('💬 Sending SMS to: ${customer.phone}');
                          // Implement SMS functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening SMS to ${customer.phone}...'),
                              backgroundColor: CoustColors.primaryPurple,
                            ),
                          );
                        }
                      }
                  ),
                  _buildContactOption(
                      Icons.email,
                      'Send Email',
                      customer.email.isNotEmpty ? customer.email : 'No email address',
                      customer.email.isNotEmpty,
                          () {
                        Navigator.pop(context);
                        if (customer.email.isNotEmpty) {
                          print('📧 Sending email to: ${customer.email}');
                          // Implement email functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening email to ${customer.email}...'),
                              backgroundColor: CoustColors.primaryPurple,
                            ),
                          );
                        }
                      }
                  ),
                ],
              ),
              loading: () => Column(
                children: [
                  CircularProgressIndicator(
                    color: CoustColors.primaryPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading customer contact details...',
                    style: TextStyle(color: CoustColors.colrSubText),
                  ),
                ],
              ),
              error: (error, _) => Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: CoustColors.rose,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load customer contact details',
                    style: TextStyle(color: CoustColors.rose),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Fallback contact options
                  _buildContactOption(Icons.phone, 'Call Customer', 'Contact unavailable', false, () {}),
                  _buildContactOption(Icons.message, 'Send SMS', 'Contact unavailable', false, () {}),
                  _buildContactOption(Icons.email, 'Send Email', 'Contact unavailable', false, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle, bool isEnabled, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnabled
              ? CoustColors.colrStrock1.withOpacity(0.2)
              : CoustColors.colrSubText.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: isEnabled,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [
                CoustColors.primaryPurple.withOpacity(0.2),
                CoustColors.primaryPurple.withOpacity(0.1),
              ]
                  : [
                CoustColors.colrSubText.withOpacity(0.1),
                CoustColors.colrSubText.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isEnabled ? CoustColors.primaryPurple : CoustColors.colrSubText,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isEnabled ? CoustColors.colrMainText : CoustColors.colrSubText,
            fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: CoustColors.colrSubText,
            fontSize: 12,
          ),
        ),
        trailing: isEnabled
            ? Icon(
          Icons.arrow_forward_ios,
          color: CoustColors.primaryPurple,
          size: 16,
        )
            : Icon(
          Icons.block,
          color: CoustColors.colrSubText,
          size: 16,
        ),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }

  void _viewOnMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening location in maps...'),
        backgroundColor: CoustColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  int _calculateGST(int baseAmount) {
    return (baseAmount * 0.18).round();
  }

  int _calculateTotal(int baseAmount) {
    return baseAmount + _calculateGST(baseAmount);
  }

  Widget bookingDetailRow(String title, String detail,
      {bool isTotal = false, Color color = CoustColors.colrMainText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: coustText(
              overflow: TextOverflow.ellipsis,
              sName: title,
              fontweight: isTotal ? FontWeight.bold : FontWeight.w500,
              txtcolor: isTotal ? color : CoustColors.colrSubText,
              textsize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: coustText(
              overflow: TextOverflow.ellipsis,
              sName: detail,
              fontweight: isTotal ? FontWeight.bold : FontWeight.normal,
              txtcolor: isTotal ? color : CoustColors.colrMainText,
              textsize: 14,
            ),
          ),
        ],
      ),
    );
  }
}