// lib/providers/vendor_booking_provider.dart (FIXED VERSION)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/models/vendor_booking_models.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:bb_vendor/providers/hall_booking_provider.dart';
import 'package:bb_vendor/providers/auth.dart';

import '../models/hall_booking.dart';

// Enhanced provider for vendor bookings with proper auth dependency and error handling
final vendorBookingsProvider = FutureProvider.autoDispose<List<VendorBookingData>>((ref) async {
  try {
    print('=== VENDOR BOOKINGS PROVIDER DEBUG ===');

    // Watch auth state to ensure provider refreshes when user changes
    final authState = ref.watch(authprovider);
    final currentUserId = authState.data?.userId;
    final accessToken = authState.data?.accessToken;

    print('Auth state - User ID: $currentUserId, Has token: ${accessToken != null}');

    // Enhanced authentication check
    if (currentUserId == null || accessToken == null || accessToken.isEmpty) {
      print('❌ User not authenticated, attempting auto-login...');

      // Try auto-login
      final authNotifier = ref.read(authprovider.notifier);
      final autoLoginSuccess = await authNotifier.tryAutoLogin();

      if (!autoLoginSuccess) {
        throw Exception('Authentication required - please login to view your bookings');
      }

      // Re-read auth state after successful auto-login
      final newAuthState = ref.read(authprovider);
      final newUserId = newAuthState.data?.userId;
      final newToken = newAuthState.data?.accessToken;

      if (newUserId == null || newToken == null) {
        throw Exception('Authentication failed - please login again');
      }

      print('✓ Auto-login successful for user: $newUserId');
    }

    // Get vendor properties with enhanced error handling
    print('📋 Fetching vendor properties...');
    final propertyNotifier = ref.read(propertyNotifierProvider.notifier);

    try {
      await propertyNotifier.getproperty();
    } catch (e) {
      print('❌ Error fetching properties: $e');
      throw Exception('Failed to load properties: ${e.toString()}');
    }

    final propertiesState = ref.read(propertyNotifierProvider);

    if (propertiesState.data == null) {
      print('❌ Properties state is null');
      throw Exception('Failed to load properties - please try again');
    }

    final properties = propertiesState.data!;
    print('✓ Found ${properties.length} properties for vendor');

    if (properties.isEmpty) {
      print('ℹ️ No properties found for this vendor');
      return []; // Return empty list for vendors with no properties
    }

    // Build vendor halls map with enhanced logging
    final Map<int, HallInfo> vendorHalls = {};
    int totalHalls = 0;

    for (final property in properties) {
      print('🏢 Property: ${property.propertyName} (ID: ${property.propertyId})');

      final halls = property.halls ?? [];
      print('  └─ Halls count: ${halls.length}');

      for (final hall in halls) {
        if (hall.hallId != null) {
          vendorHalls[hall.hallId!] = HallInfo(
            property: property,
            hall: hall,
          );
          totalHalls++;
          print('    └─ Hall: ${hall.name} (ID: ${hall.hallId})');
        } else {
          print('    └─ ⚠️ Hall without ID found: ${hall.name}');
        }
      }
    }

    print('✓ Total halls mapped: $totalHalls');

    if (vendorHalls.isEmpty) {
      print('ℹ️ No halls found for this vendor\'s properties');
      return []; // Return empty list if no halls
    }

    // Get all bookings with enhanced error handling
    print('📅 Fetching all bookings...');
    final bookingNotifier = ref.read(hallBookingProvider.notifier);

    List<HallBookingData> allBookings;
    try {
      allBookings = await bookingNotifier.getBookings();
      print('✓ Retrieved ${allBookings.length} total bookings from system');
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      throw Exception('Failed to load bookings: ${e.toString()}');
    }

    // Filter and combine bookings with hall/property information
    final vendorBookings = <VendorBookingData>[];
    int matchedBookings = 0;

    for (final booking in allBookings) {
      final hallInfo = vendorHalls[booking.hallId];
      if (hallInfo != null) {
        try {
          vendorBookings.add(VendorBookingData(
            booking: booking,
            property: hallInfo.property,
            hall: hallInfo.hall,
          ));
          matchedBookings++;
          print('✓ Matched booking ${booking.id} to hall: ${hallInfo.hall.name}');
        } catch (e) {
          print('⚠️ Error creating VendorBookingData for booking ${booking.id}: $e');
          // Continue with other bookings even if one fails
        }
      }
    }

    print('✓ Successfully matched $matchedBookings bookings to vendor halls');

    // Sort bookings by date (newest first), then by time
    vendorBookings.sort((a, b) {
      try {
        final dateComparison = b.booking.date.compareTo(a.booking.date);
        if (dateComparison != 0) return dateComparison;

        // If same date, sort by time
        return b.booking.slotFromTime.compareTo(a.booking.slotFromTime);
      } catch (e) {
        print('⚠️ Error sorting bookings: $e');
        return 0; // Keep original order if sorting fails
      }
    });

    print('=== VENDOR BOOKINGS PROVIDER SUCCESS ===');
    print('Final result: ${vendorBookings.length} bookings for vendor');

    return vendorBookings;

  } catch (e, stackTrace) {
    print('=== VENDOR BOOKINGS PROVIDER ERROR ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');

    // Provide more specific error messages
    if (e.toString().contains('Authentication')) {
      throw Exception('Please login to view your bookings');
    } else if (e.toString().contains('Network') || e.toString().contains('SocketException')) {
      throw Exception('Network error - please check your connection and try again');
    } else if (e.toString().contains('timeout')) {
      throw Exception('Request timeout - please try again');
    } else {
      throw Exception('Failed to load bookings: ${e.toString()}');
    }
  }
});

// Enhanced booking statistics provider with error handling
final vendorBookingStatsProvider = Provider.autoDispose<BookingStats>((ref) {
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      try {
        int total = bookings.length;
        int confirmed = bookings.where((b) => b.booking.isPaid == 'c').length;
        int cancelled = bookings.where((b) => b.booking.isPaid == 'cl').length;
        int pending = bookings.where((b) => b.booking.isPaid == '0').length;
        int today = bookings.where((b) {
          try {
            return b.isToday;
          } catch (e) {
            print('Error checking if booking is today: $e');
            return false;
          }
        }).length;

        return BookingStats(
          total: total,
          confirmed: confirmed,
          cancelled: cancelled,
          pending: pending,
          today: today,
        );
      } catch (e) {
        print('Error calculating booking stats: $e');
        return BookingStats.empty();
      }
    },
    loading: () => BookingStats.empty(),
    error: (_, __) => BookingStats.empty(),
  );
});

// Enhanced filtered bookings provider with better error handling
final filteredBookingsProvider = Provider.family.autoDispose<List<VendorBookingData>, BookingFilter>((ref, filter) {
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      try {
        return bookings.where((booking) {
          // Filter by status
          if (filter.status != 'All' && booking.filterStatus != filter.status) {
            return false;
          }

          // Filter by search query
          if (filter.searchQuery.isNotEmpty) {
            final query = filter.searchQuery.toLowerCase();
            try {
              return booking.propertyName.toLowerCase().contains(query) ||
                  booking.hallName.toLowerCase().contains(query) ||
                  booking.bookingDate.toLowerCase().contains(query) ||
                  booking.bookingId.toString().contains(query);
            } catch (e) {
              print('Error filtering booking ${booking.bookingId}: $e');
              return false;
            }
          }

          return true;
        }).toList();
      } catch (e) {
        print('Error filtering bookings: $e');
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider to track current user with enhanced change detection
final currentUserProvider = Provider.autoDispose<int?>((ref) {
  final authState = ref.watch(authprovider);
  final userId = authState.data?.userId;

  // Add a listener to detect user changes
  ref.listen(authprovider, (previous, next) {
    final previousUserId = previous?.data?.userId;
    final nextUserId = next.data?.userId;

    if (previousUserId != nextUserId) {
      print('🔄 User change detected: $previousUserId -> $nextUserId');
      // Invalidate dependent providers when user changes
      ref.invalidate(vendorBookingsProvider);
      ref.invalidate(vendorBookingStatsProvider);
    }
  });

  return userId;
});

// Provider for checking if data needs refresh
final dataRefreshProvider = Provider.autoDispose<bool>((ref) {
  final authState = ref.watch(authprovider);
  final currentTime = DateTime.now();

  // You could implement logic here to determine if data should be refreshed
  // based on time elapsed, user changes, etc.

  return false; // Default to not needing refresh
});