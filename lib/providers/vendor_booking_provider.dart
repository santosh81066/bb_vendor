// lib/providers/vendor_bookings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/models/vendor_booking_models.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:bb_vendor/providers/hall_booking_provider.dart';
import 'package:bb_vendor/providers/auth.dart';

// Enhanced provider for vendor bookings with proper auth dependency
final vendorBookingsProvider = FutureProvider.autoDispose<List<VendorBookingData>>((ref) async {
  try {
    // Watch auth state to ensure provider refreshes when user changes
    final authState = ref.watch(authprovider);

    print('=== VENDOR BOOKINGS PROVIDER DEBUG ===');
    print('Auth state: ${authState.data?.userId}');
    print('Username: ${authState.data?.username}');

    // Check if user is authenticated
    if (authState.data?.userId == null || authState.data?.accessToken == null) {
      // Try auto-login
      print('User not authenticated, trying auto-login...');
      await ref.read(authprovider.notifier).tryAutoLogin();

      // Re-read auth state after auto-login attempt
      final newAuthState = ref.read(authprovider);
      if (newAuthState.data?.userId == null) {
        throw Exception('Please login to view your bookings');
      }
    }

    final currentUserId = ref.read(authprovider).data!.userId!;
    print('Current user ID: $currentUserId');

    // Get vendor properties with proper error handling
    print('Fetching vendor properties...');
    await ref.read(propertyNotifierProvider.notifier).getproperty();
    final propertiesState = ref.read(propertyNotifierProvider);

    if (propertiesState.data == null) {
      throw Exception('Failed to load properties. Please check your connection.');
    }

    final properties = propertiesState.data!;
    print('Found ${properties.length} properties for vendor');

    if (properties.isEmpty) {
      print('No properties found for this vendor');
      return []; // Return empty list, not an error
    }

    // Get all hall IDs for this vendor with detailed logging
    final Map<int, HallInfo> vendorHalls = {};
    int totalHalls = 0;

    for (final property in properties) {
      print('Property: ${property.propertyName} (ID: ${property.propertyId})');
      for (final hall in property.halls ?? []) {
        if (hall.hallId != null) {
          vendorHalls[hall.hallId!] = HallInfo(
            property: property,
            hall: hall,
          );
          totalHalls++;
          print('  Hall: ${hall.name} (ID: ${hall.hallId})');
        }
      }
    }

    print('Total halls for vendor: $totalHalls');

    if (vendorHalls.isEmpty) {
      print('No halls found for this vendor');
      return []; // Return empty list if no halls
    }

    // Get all bookings
    print('Fetching all bookings...');
    final bookingNotifier = ref.read(hallBookingProvider.notifier);
    final allBookings = await bookingNotifier.getBookings();
    print('Total bookings in system: ${allBookings.length}');

    // Filter bookings for vendor's halls and combine with property/hall info
    final vendorBookings = <VendorBookingData>[];

    for (final booking in allBookings) {
      final hallInfo = vendorHalls[booking.hallId];
      if (hallInfo != null) {
        vendorBookings.add(VendorBookingData(
          booking: booking,
          property: hallInfo.property,
          hall: hallInfo.hall,
        ));
        print('Added booking: ${booking.id} for hall: ${hallInfo.hall.name}');
      }
    }

    print('Vendor bookings found: ${vendorBookings.length}');

    // Sort by date (newest first), then by time
    vendorBookings.sort((a, b) {
      final dateComparison = b.booking.date.compareTo(a.booking.date);
      if (dateComparison != 0) return dateComparison;

      // If same date, sort by time
      return b.booking.slotFromTime.compareTo(a.booking.slotFromTime);
    });

    print('=== VENDOR BOOKINGS PROVIDER SUCCESS ===');
    return vendorBookings;

  } catch (e, stackTrace) {
    print('=== VENDOR BOOKINGS PROVIDER ERROR ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Failed to load bookings: ${e.toString()}');
  }
});

// Provider for booking statistics that depends on auth state
final vendorBookingStatsProvider = Provider.autoDispose<BookingStats>((ref) {
  // Watch auth state to ensure stats refresh when user changes
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      int total = bookings.length;
      int confirmed = bookings.where((b) => b.booking.isPaid == 'c').length;
      int cancelled = bookings.where((b) => b.booking.isPaid == 'cl').length;
      int pending = bookings.where((b) => b.booking.isPaid == '0').length;
      int today = bookings.where((b) => b.isToday).length;

      return BookingStats(
        total: total,
        confirmed: confirmed,
        cancelled: cancelled,
        pending: pending,
        today: today,
      );
    },
    loading: () => BookingStats.empty(),
    error: (_, __) => BookingStats.empty(),
  );
});

// Provider for filtered bookings that depends on auth state
final filteredBookingsProvider = Provider.family.autoDispose<List<VendorBookingData>, BookingFilter>((ref, filter) {
  // Watch auth state to ensure filtered bookings refresh when user changes
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      return bookings.where((booking) {
        // Filter by status
        if (filter.status != 'All' && booking.filterStatus != filter.status) {
          return false;
        }

        // Filter by search query
        if (filter.searchQuery.isNotEmpty) {
          final query = filter.searchQuery.toLowerCase();
          return booking.propertyName.toLowerCase().contains(query) ||
              booking.hallName.toLowerCase().contains(query) ||
              booking.bookingDate.toLowerCase().contains(query) ||
              booking.bookingId.toString().contains(query);
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider to check if current user has changed
final currentUserProvider = Provider.autoDispose<int?>((ref) {
  final authState = ref.watch(authprovider);
  return authState.data?.userId;
});