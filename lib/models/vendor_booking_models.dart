// lib/models/vendor_booking_models.dart (UPDATED - Compatible with your provider)

import 'package:bb_vendor/models/hall_booking.dart';
import 'package:bb_vendor/models/get_properties_model.dart';

// Helper class for organizing hall information
class HallInfo {
  final Data property;
  final Hall hall;

  HallInfo({required this.property, required this.hall});
}

// Enhanced VendorBookingData class with embedded user information
class VendorBookingData {
  final HallBookingData booking;
  final Data property;
  final Hall hall;

  // ✨ NEW: Embedded user information from backend
  final String? userName;
  final String? userEmail;
  final String? userMobile;

  VendorBookingData({
    required this.booking,
    required this.property,
    required this.hall,
    // ✨ NEW: Optional embedded user information
    this.userName,
    this.userEmail,
    this.userMobile,
  });

  // Existing property getters (unchanged)
  String get propertyName => property.propertyName ?? 'Unknown Property';
  String get hallName => hall.name ?? 'Unknown Hall';
  String get bookingStatus => booking.bookingStatus;
  String get bookingDate => booking.date;
  String get timeSlot => '${booking.slotFromTime} - ${booking.slotToTime}';
  int get bookingId => booking.id;
  int get userId => booking.userId;
  String get propertyAddress => property.address ?? 'No address';
  String get propertyLocation => property.location ?? 'No location';

  // ✨ NEW: Enhanced user information getters with multiple fallback sources
  String get displayUserName {
    // Try embedded user info first
    if (userName?.isNotEmpty == true) {
      return userName!;
    }
    // Try booking embedded user info as fallback
    if (booking.userName?.isNotEmpty == true) {
      return booking.userName!;
    }
    return 'Customer #$userId';
  }

  String get displayUserEmail {
    // Try embedded user info first
    if (userEmail?.isNotEmpty == true) {
      return userEmail!;
    }
    // Try booking embedded user info as fallback
    if (booking.userEmail?.isNotEmpty == true) {
      return booking.userEmail!;
    }
    return 'No email available';
  }

  String get displayUserMobile {
    // Try embedded user info first
    if (userMobile?.isNotEmpty == true) {
      return userMobile!;
    }
    // Try booking embedded user info as fallback
    if (booking.userMobile?.isNotEmpty == true) {
      return booking.userMobile!;
    }
    return 'No phone available';
  }

  // ✨ NEW: Check if we have embedded user information from any source
  bool get hasUserInfo {
    return (userName?.isNotEmpty == true) ||
        (userEmail?.isNotEmpty == true) ||
        (userMobile?.isNotEmpty == true) ||
        (booking.userName?.isNotEmpty == true) ||
        (booking.userEmail?.isNotEmpty == true) ||
        (booking.userMobile?.isNotEmpty == true);
  }

  // ✨ NEW: Get user info quality indicator
  String get userInfoQuality {
    final hasName = displayUserName != 'Customer #$userId';
    final hasEmail = displayUserEmail != 'No email available';
    final hasPhone = displayUserMobile != 'No phone available';

    if (hasName && hasEmail && hasPhone) {
      return 'complete';
    } else if (hasName || hasEmail || hasPhone) {
      return 'partial';
    } else {
      return 'limited';
    }
  }

  // ✨ NEW: Enhanced search method including user information
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return propertyName.toLowerCase().contains(searchQuery) ||
        hallName.toLowerCase().contains(searchQuery) ||
        bookingDate.toLowerCase().contains(searchQuery) ||
        bookingId.toString().contains(searchQuery) ||
        displayUserName.toLowerCase().contains(searchQuery) ||
        displayUserEmail.toLowerCase().contains(searchQuery) ||
        displayUserMobile.contains(searchQuery) ||
        bookingStatus.toLowerCase().contains(searchQuery);
  }

  // ✨ NEW: Create UserDetails object from embedded info
  UserDetails get embeddedUserDetails {
    return UserDetails.fromEmbeddedInfo(
      userId: userId,
      userName: displayUserName != 'Customer #$userId' ? displayUserName : null,
      userEmail: displayUserEmail != 'No email available' ? displayUserEmail : null,
      userMobile: displayUserMobile != 'No phone available' ? displayUserMobile : null,
    );
  }

  // Convert booking status to filter-friendly format
  String get filterStatus {
    switch (booking.isPaid) {
      case 'c':
        return 'Current'; // Confirmed/Current
      case 'cl':
        return 'Cancelled';
      case 'b':
        return 'Blocked'; // ✨ UPDATED: Added blocked status
      case '0':
        return 'Available';
      default:
        return 'Upcoming'; // Default for any other status
    }
  }

  // Get formatted date for display
  String get formattedDate {
    try {
      final parts = booking.date.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];

        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        final monthName = months[int.tryParse(month) ?? 0];
        return '$day $monthName $year';
      }
    } catch (e) {
      // If parsing fails, return original date
    }
    return booking.date;
  }

  // Get formatted time slot
  String get formattedTimeSlot {
    try {
      final fromParts = booking.slotFromTime.split(':');
      final toParts = booking.slotToTime.split(':');

      if (fromParts.length >= 2 && toParts.length >= 2) {
        final fromHour = int.tryParse(fromParts[0]) ?? 0;
        final fromMin = fromParts[1];
        final toHour = int.tryParse(toParts[0]) ?? 0;
        final toMin = toParts[1];

        final fromAmPm = fromHour >= 12 ? 'PM' : 'AM';
        final toAmPm = toHour >= 12 ? 'PM' : 'AM';

        final fromDisplayHour = fromHour > 12 ? fromHour - 12 : (fromHour == 0 ? 12 : fromHour);
        final toDisplayHour = toHour > 12 ? toHour - 12 : (toHour == 0 ? 12 : toHour);

        return '$fromDisplayHour:$fromMin $fromAmPm - $toDisplayHour:$toMin $toAmPm';
      }
    } catch (e) {
      // If parsing fails, return original time slot
    }
    return timeSlot;
  }

  // Check if booking is in the past
  bool get isPastBooking {
    try {
      final bookingDateTime = DateTime.parse(booking.date);
      final now = DateTime.now();
      return bookingDateTime.isBefore(DateTime(now.year, now.month, now.day));
    } catch (e) {
      return false;
    }
  }

  // Check if booking is today
  bool get isToday {
    try {
      final bookingDate = DateTime.parse(booking.date);
      final now = DateTime.now();
      return bookingDate.year == now.year &&
          bookingDate.month == now.month &&
          bookingDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  // ✨ NEW: Check if booking is upcoming
  bool get isUpcoming {
    try {
      final bookingDate = DateTime.parse(booking.date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      return bookingDateOnly.isAfter(today);
    } catch (e) {
      return false;
    }
  }

  // Get relative date description
  String get relativeDateDescription {
    if (isToday) return 'Today';
    if (isPastBooking) return 'Past';
    return 'Upcoming';
  }

  // ✨ NEW: Status checking helpers
  bool get isConfirmed => booking.isPaid == 'c';
  bool get isCancelled => booking.isPaid == 'cl';
  bool get isBlocked => booking.isPaid == 'b';
  bool get isAvailable => booking.isPaid == '0';

  // ✨ NEW: Copy with method for updates
  VendorBookingData copyWith({
    HallBookingData? booking,
    Data? property,
    Hall? hall,
    String? userName,
    String? userEmail,
    String? userMobile,
  }) {
    return VendorBookingData(
      booking: booking ?? this.booking,
      property: property ?? this.property,
      hall: hall ?? this.hall,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userMobile: userMobile ?? this.userMobile,
    );
  }

  // ✨ NEW: Convert to JSON with embedded user info
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'property': property.toJson(),
      'hall': hall.toJson(),
      'user_name': userName,
      'user_email': userEmail,
      'user_mobile': userMobile,
    };
  }
}

// ✨ ENHANCED: Booking statistics model with comprehensive stats
class BookingStats {
  final int total;
  final int confirmed;
  final int cancelled;
  final int pending;
  final int blocked; // ✨ NEW: Added blocked status
  final int today;
  final int upcoming; // ✨ NEW: Added upcoming count
  final double totalRevenue; // ✨ NEW: Added revenue tracking

  BookingStats({
    required this.total,
    required this.confirmed,
    required this.cancelled,
    required this.pending,
    required this.blocked,
    required this.today,
    required this.upcoming,
    required this.totalRevenue,
  });

  factory BookingStats.empty() {
    return BookingStats(
      total: 0,
      confirmed: 0,
      cancelled: 0,
      pending: 0,
      blocked: 0,
      today: 0,
      upcoming: 0,
      totalRevenue: 0.0,
    );
  }

  // ✨ NEW: Calculate comprehensive stats from booking list
  factory BookingStats.fromBookings(List<VendorBookingData> bookings) {
    int confirmed = 0;
    int cancelled = 0;
    int pending = 0;
    int blocked = 0;
    int today = 0;
    int upcoming = 0;
    double revenue = 0.0;

    for (final booking in bookings) {
      // Count by status
      if (booking.isConfirmed) {
        confirmed++;
        // Add to revenue if confirmed and hall has price
        if (booking.hall.price != null) {
          revenue += booking.hall.price!.toDouble();
        }
      } else if (booking.isCancelled) {
        cancelled++;
      } else if (booking.isBlocked) {
        blocked++;
      } else {
        pending++;
      }

      // Count by date
      if (booking.isToday) {
        today++;
      } else if (booking.isUpcoming) {
        upcoming++;
      }
    }

    return BookingStats(
      total: bookings.length,
      confirmed: confirmed,
      cancelled: cancelled,
      pending: pending,
      blocked: blocked,
      today: today,
      upcoming: upcoming,
      totalRevenue: revenue,
    );
  }

  // ✨ NEW: Get confirmation rate percentage
  double get confirmationRate {
    if (total == 0) return 0.0;
    return (confirmed / total) * 100;
  }

  // ✨ NEW: Get cancellation rate percentage
  double get cancellationRate {
    if (total == 0) return 0.0;
    return (cancelled / total) * 100;
  }

  // ✨ NEW: Get today's activity percentage
  double get todayActivityRate {
    if (total == 0) return 0.0;
    return (today / total) * 100;
  }

  // ✨ NEW: Get average revenue per booking
  double get averageRevenuePerBooking {
    if (confirmed == 0) return 0.0;
    return totalRevenue / confirmed;
  }

  // ✨ NEW: Check if stats are healthy (good confirmation rate)
  bool get hasHealthyStats {
    return confirmationRate >= 70.0 && cancellationRate <= 20.0;
  }

  // ✨ NEW: Get formatted revenue string
  String get formattedRevenue {
    if (totalRevenue >= 100000) {
      return '₹${(totalRevenue / 100000).toStringAsFixed(1)}L';
    } else if (totalRevenue >= 1000) {
      return '₹${(totalRevenue / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${totalRevenue.toStringAsFixed(0)}';
    }
  }

  // ✨ NEW: Copy with method
  BookingStats copyWith({
    int? total,
    int? confirmed,
    int? cancelled,
    int? pending,
    int? blocked,
    int? today,
    int? upcoming,
    double? totalRevenue,
  }) {
    return BookingStats(
      total: total ?? this.total,
      confirmed: confirmed ?? this.confirmed,
      cancelled: cancelled ?? this.cancelled,
      pending: pending ?? this.pending,
      blocked: blocked ?? this.blocked,
      today: today ?? this.today,
      upcoming: upcoming ?? this.upcoming,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }

  // ✨ NEW: Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'confirmed': confirmed,
      'cancelled': cancelled,
      'pending': pending,
      'blocked': blocked,
      'today': today,
      'upcoming': upcoming,
      'total_revenue': totalRevenue,
      'confirmation_rate': confirmationRate,
      'cancellation_rate': cancellationRate,
    };
  }
}

// Booking filter model (unchanged)
class BookingFilter {
  final String status;
  final String searchQuery;

  BookingFilter({
    required this.status,
    required this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookingFilter &&
              runtimeType == other.runtimeType &&
              status == other.status &&
              searchQuery == other.searchQuery;

  @override
  int get hashCode => status.hashCode ^ searchQuery.hashCode;

  @override
  String toString() => 'BookingFilter(status: $status, searchQuery: $searchQuery)';

  // ✨ NEW: Copy with method
  BookingFilter copyWith({
    String? status,
    String? searchQuery,
  }) {
    return BookingFilter(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // ✨ NEW: Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'search_query': searchQuery,
    };
  }

  // ✨ NEW: Create from JSON
  factory BookingFilter.fromJson(Map<String, dynamic> json) {
    return BookingFilter(
      status: json['status'] ?? 'All',
      searchQuery: json['search_query'] ?? '',
    );
  }
}

// Enhanced User Details Model
class UserDetails {
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? profilePicture;
  final DateTime? createdAt;

  UserDetails({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.profilePicture,
    this.createdAt,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['user_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['full_name'] ?? json['username'] ?? 'Unknown User',
      email: json['email'] ?? 'No email provided',
      phone: json['phone'] ?? json['mobile'] ?? json['mobile_no']?.toString() ?? 'No phone provided',
      address: json['address'] ?? 'No address provided',
      profilePicture: json['profile_picture'] ?? json['avatar'] ?? json['profile_pic'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // ✨ NEW: Create from embedded booking user info
  factory UserDetails.fromEmbeddedInfo({
    required int userId,
    String? userName,
    String? userEmail,
    String? userMobile,
  }) {
    return UserDetails(
      userId: userId,
      name: userName?.isNotEmpty == true ? userName! : 'Customer #$userId',
      email: userEmail?.isNotEmpty == true ? userEmail! : 'No email available',
      phone: userMobile?.isNotEmpty == true ? userMobile! : 'No phone available',
      address: 'Address not available',
      profilePicture: null,
      createdAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // ✨ NEW: Check if user details are complete
  bool get isComplete {
    return name != 'Unknown User' &&
        name != 'Customer #$userId' &&
        email != 'No email provided' &&
        email != 'No email available' &&
        phone != 'No phone provided' &&
        phone != 'No phone available';
  }

  // ✨ NEW: Get data quality indicator
  String get dataQuality {
    if (isComplete) return 'complete';
    if (name.contains('Customer #') &&
        email.contains('No email') &&
        phone.contains('No phone')) {
      return 'limited';
    }
    return 'partial';
  }

  // ✨ NEW: Get display name for UI
  String get displayName {
    if (name.isNotEmpty && name != 'Unknown User' && !name.startsWith('Customer #')) {
      return name;
    }
    return 'Customer #$userId';
  }

  // ✨ NEW: Get contact availability
  bool get hasContactInfo {
    return (email.isNotEmpty && email != 'No email provided' && email != 'No email available') ||
        (phone.isNotEmpty && phone != 'No phone provided' && phone != 'No phone available');
  }

  // ✨ NEW: Copy with method
  UserDetails copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return UserDetails(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ✨ NEW: Enum for booking status with helper methods
enum BookingStatusType {
  available,   // '0'
  confirmed,   // 'c'
  cancelled,   // 'cl'
  blocked,     // 'b'
}

extension BookingStatusTypeExtension on BookingStatusType {
  String get code {
    switch (this) {
      case BookingStatusType.confirmed:
        return 'c';
      case BookingStatusType.cancelled:
        return 'cl';
      case BookingStatusType.blocked:
        return 'b';
      case BookingStatusType.available:
        return '0';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatusType.confirmed:
        return 'Confirmed';
      case BookingStatusType.cancelled:
        return 'Cancelled';
      case BookingStatusType.blocked:
        return 'Blocked/Pending';
      case BookingStatusType.available:
        return 'Available';
    }
  }

  String get filterName {
    switch (this) {
      case BookingStatusType.confirmed:
        return 'Current';
      case BookingStatusType.cancelled:
        return 'Cancelled';
      case BookingStatusType.blocked:
        return 'Blocked';
      case BookingStatusType.available:
        return 'Available';
    }
  }

  static BookingStatusType fromCode(String code) {
    switch (code) {
      case 'c':
        return BookingStatusType.confirmed;
      case 'cl':
        return BookingStatusType.cancelled;
      case 'b':
        return BookingStatusType.blocked;
      case '0':
      default:
        return BookingStatusType.available;
    }
  }
}