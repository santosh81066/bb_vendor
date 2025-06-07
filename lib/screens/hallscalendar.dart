import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../Providers/auth.dart';
import '../Providers/hall_booking_provider.dart';
import '../Widgets/buildhallfeatures.dart';
import '../Widgets/dateselection.dart';
import '../Widgets/hall_selection.dart';
import '../Widgets/slotselection.dart';
import '../models/get_properties_model.dart';
import '../models/hall_booking.dart';
import '../utils/bbapi.dart';

class StepByStepHallBookingScreen extends ConsumerStatefulWidget {
  const StepByStepHallBookingScreen({super.key});

  @override
  ConsumerState<StepByStepHallBookingScreen> createState() => _StepByStepHallBookingScreenState();
}

class _StepByStepHallBookingScreenState extends ConsumerState<StepByStepHallBookingScreen>
    with TickerProviderStateMixin {
  int currentStep = 0, selectedHallIndex = 0;
  late String selectedYear, selectedMonth;
  late DateTime focusedDay, firstDay, lastDay;
  DateTime? selectedDay;
  String? selectedSlot;
  Map<String, BookingStatus> bookingStatuses = {};
  Map<String, int> bookingUserIds = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PageController _hallPageController = PageController();
  bool _isAuthInitialized = false;

  late List<String> years;
  static const allMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  late List<String> months;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();

    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hallPageController.dispose();
    super.dispose();
  }

  // Add method to initialize authentication
  void _initializeAuth() async {
    try {
      debugPrint("Initializing authentication...");

      // Try to auto-login to restore user session
      final authNotifier = ref.read(authprovider.notifier);
      final success = await authNotifier.tryAutoLogin();

      if (success) {
        debugPrint("✓ Authentication initialized successfully");
        // Force refresh user data to ensure state is properly updated
        await authNotifier.forceRefreshUserData();

        setState(() {
          _isAuthInitialized = true;
        });

        // Load existing bookings after auth is initialized
        _loadExistingBookings();
      } else {
        debugPrint("❌ Authentication initialization failed");
        _showSnackBar('Authentication failed. Please login again.', isError: true);
        // Navigate back to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint("Error initializing auth: $e");
      _showSnackBar('Authentication error. Please login again.', isError: true);
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _initializeData() {
    final now = DateTime.now();
    selectedMonth = allMonths[now.month - 1];
    selectedYear = now.year.toString();
    focusedDay = now;
    years = List.generate(5, (i) => (now.year + i).toString());
    _updateMonthsList();
    _updateCalendarBounds();
    // Don't load bookings here - wait for auth to be initialized
  }

  BookingStatus _mapStatusCode(String code) => switch (code) {
    'c' => BookingStatus.confirmed,  // Confirmed/Paid
    'b' => BookingStatus.blocked,    // Blocked/Pending payment
    'cl' => BookingStatus.available, // Cancelled (back to available)
    'n' => BookingStatus.available,  // Failed payment (back to available)
    _ => BookingStatus.available,    // Default to available
  };

  void _loadExistingBookings() async {
    try {
      // Check if auth is initialized before proceeding
      if (!_isAuthInitialized) {
        debugPrint("Auth not initialized, skipping booking load");
        return;
      }

      final authState = ref.read(authprovider);
      final token = _getAccessToken(authState);

      if (token == null || token.isEmpty) {
        debugPrint("No access token found in _loadExistingBookings");
        return;
      }

      debugPrint("Loading existing bookings with token: ${token.substring(0, 10)}...");

      final response = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List bookings = responseData['data'] ?? [];
        final updatedStatuses = <String, BookingStatus>{};
        final updatedUserIds = <String, int>{};

        for (var booking in bookings) {
          final key = _getBookingKey(
              booking['hall_id'] ?? 0,
              booking['date'] ?? '',
              booking['slot_from_time'] ?? '',
              booking['slot_to_time'] ?? ''
          );
          updatedStatuses[key] = _mapStatusCode(booking['is_paid'] ?? '');
          updatedUserIds[key] = booking['user_id'] ?? 0;
        }

        if (mounted) {
          setState(() {
            bookingStatuses = updatedStatuses;
            bookingUserIds = updatedUserIds;
          });
          debugPrint("✓ Loaded ${bookings.length} existing bookings");
        }
      } else {
        debugPrint("Failed to load bookings: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading bookings: $e");
    }
  }

  void _updateCalendarBounds() {
    int year = int.parse(selectedYear);
    int month = allMonths.indexOf(selectedMonth) + 1;
    firstDay = DateTime(year, month, 1);
    lastDay = DateTime(year, month + 1, 0);
    focusedDay = firstDay;
  }

  void _updateMonthsList() {
    final now = DateTime.now();
    months = int.parse(selectedYear) == now.year ?
    allMonths.sublist(now.month - 1) : List.from(allMonths);
  }

  String _getBookingKey(int hallId, String date, String fromTime, String toTime) =>
      '$hallId-$date-$fromTime-$toTime';

  void _nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Helper method to get access token from auth state
  String? _getAccessToken(dynamic authState) {
    try {
      // Check if authState has data property
      if (authState?.data != null) {
        final data = authState.data;

        // Try accessing accessToken property directly
        if (data.accessToken != null) {
          return data.accessToken as String?;
        }

        // Try accessing access_token property
        if (data.access_token != null) {
          return data.access_token as String?;
        }

        // If data is a Map, try accessing token from map
        if (data is Map<String, dynamic>) {
          return data['accessToken'] as String? ??
              data['access_token'] as String? ??
              data['token'] as String?;
        }
      }

      // Try accessing token directly from authState
      if (authState?.accessToken != null) {
        return authState.accessToken as String?;
      }

      if (authState?.access_token != null) {
        return authState.access_token as String?;
      }

      return null;
    } catch (e) {
      debugPrint("Error getting access token: $e");
      return null;
    }
  }

  // Helper method to get user ID from auth state
  int? _getUserId(dynamic authState) {
    try {
      // Check if authState has data property
      if (authState?.data != null) {
        final data = authState.data;

        // Try accessing userId property directly
        if (data.userId != null) {
          return data.userId as int?;
        }

        // Try accessing user_id property
        if (data.user_id != null) {
          return data.user_id as int?;
        }

        // If data is a Map, try accessing userId from map
        if (data is Map<String, dynamic>) {
          return data['userId'] as int? ??
              data['user_id'] as int? ??
              data['id'] as int?;
        }
      }

      // Try accessing userId directly from authState
      if (authState?.userId != null) {
        return authState.userId as int?;
      }

      if (authState?.user_id != null) {
        return authState.user_id as int?;
      }

      return null;
    } catch (e) {
      debugPrint("Error getting user ID: $e");
      return null;
    }
  }

  // Helper method to get auth data safely
  Map<String, dynamic>? _getAuthData() {
    try {
      final authState = ref.read(authprovider);
      final token = _getAccessToken(authState);
      final userId = _getUserId(authState);

      debugPrint("Auth state type: ${authState.runtimeType}");
      debugPrint("Token exists: ${token != null && token!.isNotEmpty}");
      debugPrint("User ID: $userId");

      if (token != null && token.isNotEmpty) {
        return {
          'accessToken': token,
          'userId': userId,
        };
      }

      return null;
    } catch (e) {
      debugPrint("Error getting auth data: $e");
      return null;
    }
  }

  void _goToPayment() async {
    // Check if authentication is properly initialized
    if (!_isAuthInitialized) {
      _showSnackBar('Authentication not initialized. Please wait or restart the app.', isError: true);
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) {
      _showSnackBar('Property data not found', isError: true);
      return;
    }

    final Data property = args['property'];
    if (property.halls == null || property.halls!.isEmpty) {
      _showSnackBar('No halls available', isError: true);
      return;
    }

    final hall = property.halls![selectedHallIndex];

    if (selectedDay == null || selectedSlot == null) {
      _showSnackBar('Please select date and time slot', isError: true);
      return;
    }

    final slotParts = selectedSlot!.split('From: ')[1].split(' To: ');
    if (slotParts.length != 2) {
      _showSnackBar('Invalid slot format', isError: true);
      return;
    }

    final formattedDate = "${selectedDay!.year}-${selectedDay!.month.toString().padLeft(2, '0')}-${selectedDay!.day.toString().padLeft(2, '0')}";

    try {
      // Use the helper method to get auth data safely
      final authData = _getAuthData();
      final token = authData?['accessToken'] as String?;
      final userId = authData?['userId'] as int?;

      debugPrint("Auth check - Token exists: ${token != null && token!.isNotEmpty}");
      debugPrint("Auth check - User ID: $userId");
      debugPrint("Auth check - Token preview: ${token?.substring(0, 10)}...");

      if (token == null || token.isEmpty) {
        _showSnackBar('Access token not found. Please login again.', isError: true);
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      _showSnackBar('Blocking slot...', isError: false);

      // Create the booking with 'blocked' status
      await ref.read(hallBookingProvider.notifier).postBooking(
        hallId: hall.hallId!,
        bookingId: null,
        date: formattedDate,
        slotFromTime: slotParts[0],
        slotToTime: slotParts[1],
        isPaid: 'b',
      );

      final bookingKey = _getBookingKey(hall.hallId ?? 0, formattedDate, slotParts[0], slotParts[1]);
      setState(() {
        bookingStatuses[bookingKey] = BookingStatus.blocked;
      });

      if (mounted) {
        Navigator.pushNamed(context, '/payment', arguments: {
          'hallId': hall.hallId,
          'date': formattedDate,
          'slotFromTime': slotParts[0],
          'slotToTime': slotParts[1],
          'hallName': hall.name,
          'price': hall.price,
          'onPaymentSuccess': (bool success) {
            if (success) {
              _handlePaymentSuccess(hall, formattedDate, slotParts[0], slotParts[1]);
            } else {
              _handlePaymentFailure(hall, formattedDate, slotParts[0], slotParts[1]);
            }
          },
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to block slot: ${e.toString()}', isError: true);
        debugPrint('Detailed error: $e');
      }
    }
  }

  void _handlePaymentFailure(Hall hall, String date, String fromTime, String toTime) async {
    final bookingKey = _getBookingKey(hall.hallId ?? 0, date, fromTime, toTime);

    try {
      final authData = _getAuthData();
      final token = authData?['accessToken'] as String?;
      final userId = authData?['userId'] as int?;

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode != 200) throw Exception("Failed to retrieve booking data");

      final responseData = jsonDecode(response.body);
      final List bookings = responseData['data'] ?? [];
      int? bookingId;

      for (var booking in bookings) {
        if (booking['hall_id'] == hall.hallId &&
            booking['user_id'] == userId &&
            booking['date'] == date &&
            booking['slot_from_time'] == fromTime &&
            booking['slot_to_time'] == toTime &&
            booking['is_paid'] == 'b') {
          bookingId = booking['id'];
          break;
        }
      }

      if (bookingId != null) {
        // Call cancelBooking method correctly
        final success = await ref.read(hallBookingProvider.notifier).cancelBooking(bookingId: bookingId);

        if (success && mounted) {
          setState(() => bookingStatuses[bookingKey] = BookingStatus.available);
          _showSnackBar('Slot has been released due to payment failure', isError: false);
        }
      }

      _loadExistingBookings();
    } catch (e) {
      if (mounted) _showSnackBar('Failed to handle payment failure: ${e.toString()}', isError: true);
    }
  }

  void _handlePaymentSuccess(Hall hall, String date, String fromTime, String toTime) async {
    final bookingKey = _getBookingKey(hall.hallId ?? 0, date, fromTime, toTime);

    try {
      final authData = _getAuthData();
      final token = authData?['accessToken'] as String?;
      final userId = authData?['userId'] as int?;

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode != 200) throw Exception("Failed to retrieve booking data");

      final responseData = jsonDecode(response.body);
      final List bookings = responseData['data'] ?? [];
      int? bookingId;

      for (var booking in bookings) {
        if (booking['hall_id'] == hall.hallId &&
            booking['user_id'] == userId &&
            booking['date'] == date &&
            booking['slot_from_time'] == fromTime &&
            booking['slot_to_time'] == toTime &&
            booking['is_paid'] == 'b') {
          bookingId = booking['id'];
          break;
        }
      }

      if (bookingId == null) throw Exception("Blocked booking not found for payment update.");

      // Call updateBookingPaymentStatus method correctly
      await ref.read(hallBookingProvider.notifier).updateBookingPaymentStatus(
        bookingId: bookingId,
        status: 'c',
      );

      if (mounted) {
        setState(() => bookingStatuses[bookingKey] = BookingStatus.confirmed);
        _showDialog();
      }
      _loadExistingBookings();
    } catch (e) {
      if (mounted) _showSnackBar('Payment update failed: ${e.toString()}', isError: true);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Your hall has been successfully booked.'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isError ? Icons.error : Icons.check, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildStep1(List<Hall> halls) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final selectedCardHeight = screenHeight * 0.28;
    final unselectedCardHeight = screenHeight * 0.25;
    final cardMargin = screenHeight * 0.015;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader('Choose Your Perfect Hall', Icons.home_work),
          SizedBox(height: screenHeight * 0.02),
          Flexible(
            child: ListView.builder(
              itemCount: halls.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => selectedHallIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(
                    bottom: cardMargin,
                    left: selectedHallIndex == index ? 0 : screenWidth * 0.02,
                    right: selectedHallIndex == index ? 0 : screenWidth * 0.02,
                  ),
                  height: selectedHallIndex == index ? selectedCardHeight : unselectedCardHeight,
                  child: HallSelection(
                    hall: halls[index],
                    isSelected: selectedHallIndex == index,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: screenWidth * 0.2, color: Colors.grey.shade300),
          SizedBox(height: screenHeight * 0.025),
          Text(
              message,
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600]),
        borderRadius: BorderRadius.circular(screenWidth * 0.038),
      ),
      child: Row(
        children: [
          _iconContainer(icon, Colors.white.withOpacity(0.2)),
          SizedBox(width: screenWidth * 0.038),
          Expanded(
            child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconContainer(IconData icon, [Color? backgroundColor]) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
      ),
      child: Icon(
          icon,
          color: backgroundColor != null ? Colors.white : Colors.deepPurple,
          size: screenWidth * 0.06
      ),
    );
  }

  Widget _buildNavigationButtons() => Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        if (currentStep > 0) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isAuthInitialized ? _handleNextButton : null,
            icon: Icon(currentStep == 3 ? Icons.payment : Icons.arrow_forward),
            label: Text(currentStep == 3 ? 'Proceed to Payment' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAuthInitialized ? Colors.deepPurple : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
            ),
          ),
        ),
      ],
    ),
  );

  void _handleNextButton() {
    if (currentStep == 2 && selectedDay == null) {
      _showSnackBar('Please select a date', isError: true);
      return;
    }
    if (currentStep == 3 && selectedSlot == null) {
      _showSnackBar('Please select a time slot', isError: true);
      return;
    }
    currentStep == 3 ? _goToPayment() : _nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hall Booking')),
        body: _buildEmpty('Property data not found', Icons.error_outline),
      );
    }

    final Data property = args['property'];
    final halls = property.halls ?? [];
    final authState = ref.watch(authprovider); // Watch for real-time updates

    if (halls.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hall Booking')),
        body: _buildEmpty('No halls found for this property', Icons.error_outline),
      );
    }

    final selectedHall = halls[selectedHallIndex];

    // Show loading indicator while auth is initializing
    if (!_isAuthInitialized) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Hall Booking'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing authentication...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.propertyName ?? 'Hall Booking',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold
              ),
            ),
            if (property.address != null)
              Text(
                  property.address!,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      color: Colors.grey.shade600
                  )
              ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.deepPurple,
              size: MediaQuery.of(context).size.width * 0.06,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: switch (currentStep) {
                0 => Container(
                  constraints: const BoxConstraints(maxHeight: double.infinity),
                  child: _buildStep1(halls),
                ),
                1 => SingleChildScrollView(child: EnhancedHallFeatures(selectedHall)),
                2 => SingleChildScrollView(
                  child: Dateselection(
                    selectedDay: selectedDay,
                    selectedYear: selectedYear,
                    selectedMonth: selectedMonth,
                    onDateSelected: (date) => setState(() => selectedDay = date),
                    onYearChanged: (year) {
                      setState(() {
                        selectedYear = year;
                        _updateMonthsList();
                        if (!months.contains(selectedMonth)) selectedMonth = months.first;
                        _updateCalendarBounds();
                        selectedDay = null;
                      });
                    },
                    onMonthChanged: (month) {
                      setState(() {
                        selectedMonth = month;
                        _updateCalendarBounds();
                        selectedDay = null;
                      });
                    },
                  ),
                ),
                3 => SingleChildScrollView(
                  child: Slotselection(
                    hall: selectedHall,
                    selectedDay: selectedDay,
                    selectedSlot: selectedSlot,
                    bookingStatuses: bookingStatuses,
                    bookingUserIds: bookingUserIds,
                    currentUserId: _getAuthData()?['userId'] as int?,
                    onSlotSelected: (slot) => setState(() => selectedSlot = slot),
                  ),
                ),
                _ => const SizedBox(),
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }
}