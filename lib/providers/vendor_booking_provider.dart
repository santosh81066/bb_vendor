// lib/providers/vendor_booking_provider.dart (FIXED VERSION - Compatible with your models)
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
          // ✨ UPDATED: Create VendorBookingData with embedded user info support
          vendorBookings.add(VendorBookingData(
            booking: booking,
            property: hallInfo.property,
            hall: hallInfo.hall,
            // ✨ NEW: Extract embedded user info from HallBookingData
            userName: booking.userName,
            userEmail: booking.userEmail,
            userMobile: booking.userMobile,
          ));
          matchedBookings++;
          print('✓ Matched booking ${booking.id} to hall: ${hallInfo.hall.name}');

          // ✨ NEW: Log embedded user info
          if (booking.hasUserInfo) {
            print('  └─ 📧 User: ${booking.displayUserName} (${booking.displayUserEmail})');
          } else {
            print('  └─ ⚠️ No embedded user info for booking ${booking.id}');
          }
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

    // ✨ NEW: Log user info statistics
    final bookingsWithUserInfo = vendorBookings.where((b) => b.hasUserInfo).length;
    print('📊 Bookings with embedded user info: $bookingsWithUserInfo/${vendorBookings.length}');

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

// ✨ UPDATED: Enhanced booking statistics provider with better stats calculation
final vendorBookingStatsProvider = Provider.autoDispose<BookingStats>((ref) {
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      try {
        // ✨ NEW: Use the enhanced BookingStats.fromBookings method
        return BookingStats.fromBookings(bookings);
      } catch (e) {
        print('Error calculating booking stats: $e');
        return BookingStats.empty();
      }
    },
    loading: () => BookingStats.empty(),
    error: (_, __) => BookingStats.empty(),
  );
});

// ✨ UPDATED: Enhanced filtered bookings provider with embedded user info search
final filteredBookingsProvider = Provider.family.autoDispose<List<VendorBookingData>, BookingFilter>((ref, filter) {
  final authState = ref.watch(authprovider);
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      try {
        return bookings.where((booking) {
          // Filter by status with enhanced status matching
          if (filter.status != 'All') {
            switch (filter.status) {
              case 'Current':
              // Current bookings are confirmed bookings for today
                return booking.isConfirmed && booking.isToday;
              case 'Upcoming':
              // Upcoming bookings are confirmed bookings in the future
                return booking.isConfirmed && booking.isUpcoming;
              case 'Cancelled':
                return booking.isCancelled;
              case 'Blocked':
                return booking.isBlocked;
              default:
                return true;
            }
          }

          // ✨ ENHANCED: Filter by search query including embedded user info
          if (filter.searchQuery.isNotEmpty) {
            return booking.matchesSearchQuery(filter.searchQuery);
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

// ✨ NEW: Provider for getting a specific booking by ID
final bookingByIdProvider = Provider.family.autoDispose<VendorBookingData?, int>(
      (ref, bookingId) {
    final bookingsAsync = ref.watch(vendorBookingsProvider);

    return bookingsAsync.whenOrNull(
      data: (bookings) {
        try {
          return bookings.firstWhere((booking) => booking.booking.id == bookingId);
        } catch (e) {
          return null;
        }
      },
    );
  },
);

// ✨ NEW: Provider for getting bookings by user ID
final bookingsByUserProvider = Provider.family.autoDispose<List<VendorBookingData>, int>(
      (ref, userId) {
    final bookingsAsync = ref.watch(vendorBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        return bookings.where((booking) => booking.booking.userId == userId).toList();
      },
      loading: () => <VendorBookingData>[],
      error: (_, __) => <VendorBookingData>[],
    );
  },
);

// ✨ NEW: Provider for manual refresh functionality
final manualRefreshProvider = StateProvider<int>((ref) => 0);

// ✨ NEW: Provider for refreshable bookings
final refreshableVendorBookingsProvider = FutureProvider.autoDispose<List<VendorBookingData>>((ref) {
  // Watch the manual refresh counter to trigger refreshes
  ref.watch(manualRefreshProvider);

  // This will re-trigger the vendor bookings provider
  return ref.watch(vendorBookingsProvider.future);
});

// Provider for checking if data needs refresh
final dataRefreshProvider = Provider.autoDispose<bool>((ref) {
  final authState = ref.watch(authprovider);
  final currentTime = DateTime.now();

  // You could implement logic here to determine if data should be refreshed
  // based on time elapsed, user changes, etc.

  return false; // Default to not needing refresh
});

// ✨ NEW: Helper provider for user info quality stats
final userInfoQualityProvider = Provider.autoDispose<Map<String, int>>((ref) {
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) {
      int complete = 0;
      int partial = 0;
      int limited = 0;

      for (final booking in bookings) {
        switch (booking.userInfoQuality) {
          case 'complete':
            complete++;
            break;
          case 'partial':
            partial++;
            break;
          case 'limited':
            limited++;
            break;
        }
      }

      return {
        'complete': complete,
        'partial': partial,
        'limited': limited,
        'total': bookings.length,
      };
    },
    loading: () => {'complete': 0, 'partial': 0, 'limited': 0, 'total': 0},
    error: (_, __) => {'complete': 0, 'partial': 0, 'limited': 0, 'total': 0},
  );
});

// ✨ NEW: Provider for today's bookings
final todayBookingsProvider = Provider.autoDispose<List<VendorBookingData>>((ref) {
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) => bookings.where((booking) => booking.isToday).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// ✨ NEW: Provider for upcoming bookings
final upcomingBookingsProvider = Provider.autoDispose<List<VendorBookingData>>((ref) {
  final bookingsAsync = ref.watch(vendorBookingsProvider);

  return bookingsAsync.when(
    data: (bookings) => bookings.where((booking) => booking.isUpcoming).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// ✨ NEW: Extension methods for easier data access
extension VendorBookingDataExtensions on VendorBookingData {
  bool get needsUserInfo => !hasUserInfo;
  bool get hasCompleteUserInfo => userInfoQuality == 'complete';
  bool get hasPartialUserInfo => userInfoQuality == 'partial';
  bool get hasLimitedUserInfo => userInfoQuality == 'limited';
}