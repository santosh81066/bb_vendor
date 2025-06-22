// Create this file: lib/models/vendor_booking_models.dart

import 'package:bb_vendor/models/hall_booking.dart';
import 'package:bb_vendor/models/get_properties_model.dart';

// Helper class for organizing hall information
class HallInfo {
  final Data property;
  final Hall hall;

  HallInfo({required this.property, required this.hall});
}

// Main VendorBookingData class - single definition
class VendorBookingData {
  final HallBookingData booking;
  final Data property;
  final Hall hall;

  VendorBookingData({
    required this.booking,
    required this.property,
    required this.hall,
  });

  String get propertyName => property.propertyName ?? 'Unknown Property';
  String get hallName => hall.name ?? 'Unknown Hall';
  String get bookingStatus => booking.bookingStatus;
  String get bookingDate => booking.date;
  String get timeSlot => '${booking.slotFromTime} - ${booking.slotToTime}';
  int get bookingId => booking.id;
  int get userId => booking.userId;
  String get propertyAddress => property.address ?? 'No address';
  String get propertyLocation => property.location ?? 'No location';

  // Convert booking status to filter-friendly format
  String get filterStatus {
    switch (booking.isPaid) {
      case 'c':
        return 'Current'; // Confirmed/Current
      case 'cl':
        return 'Cancelled';
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

  // Get relative date description
  String get relativeDateDescription {
    if (isToday) return 'Today';
    if (isPastBooking) return 'Past';
    return 'Upcoming';
  }
}

// Booking statistics model
class BookingStats {
  final int total;
  final int confirmed;
  final int cancelled;
  final int pending;
  final int today;

  BookingStats({
    required this.total,
    required this.confirmed,
    required this.cancelled,
    required this.pending,
    required this.today,
  });

  factory BookingStats.empty() {
    return BookingStats(
      total: 0,
      confirmed: 0,
      cancelled: 0,
      pending: 0,
      today: 0,
    );
  }
}

// Booking filter model
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
}

// User Details Model
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
      userId: json['user_id'] ?? json['id'],
      name: json['name'] ?? json['full_name'] ?? 'Unknown User',
      email: json['email'] ?? 'No email provided',
      phone: json['phone'] ?? json['mobile'] ?? 'No phone provided',
      address: json['address'] ?? 'No address provided',
      profilePicture: json['profile_picture'] ?? json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
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
}