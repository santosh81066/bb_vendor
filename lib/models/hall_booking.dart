// lib/models/hall_booking.dart (UPDATED with embedded user info support)
enum BookingStatus {
  available,   // '0'
  confirmed,   // 'c'
  cancelled,   // 'cl'
  blocked,     // 'b'
}

String getBookingStatusName(String code) {
  switch (code) {
    case 'c':
      return 'Confirmed';
    case 'cl':
      return 'Cancelled';
    case 'b':
      return 'Blocked/Pending';
    case '0':
    default:
      return 'Available';
  }
}

String bookingStatusToString(BookingStatus status) {
  switch (status) {
    case BookingStatus.confirmed:
      return 'c';
    case BookingStatus.cancelled:
      return 'cl';
    case BookingStatus.blocked:
      return 'b';
    case BookingStatus.available:
      return '0';
  }
}

class HallBookingRequest {
  final int? id;
  final int hallId;
  final int userId;
  final String date;
  final String slotFromTime;
  final String slotToTime;
  final String isPaid;

  HallBookingRequest({
    this.id,
    required this.hallId,
    required this.userId,
    required this.date,
    required this.slotFromTime,
    required this.slotToTime,
    required this.isPaid,
  });

  factory HallBookingRequest.fromJson(Map<String, dynamic> json) {
    return HallBookingRequest(
      id: json['id'],
      hallId: json['hall_id'],
      userId: json['user_id'],
      date: json['date'],
      slotFromTime: json['slot_from_time'],
      slotToTime: json['slot_to_time'],
      isPaid: json['is_paid'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'hall_id': hallId,
      'user_id': userId,
      'date': date,
      'slot_from_time': slotFromTime,
      'slot_to_time': slotToTime,
      'is_paid': isPaid,
    };

    if (id != null) data['id'] = id!;
    return data;
  }
}

class BookingUpdateRequest {
  final int bookingId;
  final String isPaid;

  BookingUpdateRequest({required this.bookingId, required this.isPaid});

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'is_paid': isPaid,
  };
}

// ✨ UPDATED: Enhanced HallBookingData with embedded user information
class HallBookingData {
  final int id;
  final int hallId;
  final int userId;
  final String date;
  final String slotFromTime;
  final String slotToTime;
  final String isPaid;
  final String bookingStatus;

  // ✨ NEW: Embedded user information from backend
  final String? userName;
  final String? userEmail;
  final String? userMobile;

  HallBookingData({
    required this.id,
    required this.hallId,
    required this.userId,
    required this.date,
    required this.slotFromTime,
    required this.slotToTime,
    required this.isPaid,
    required this.bookingStatus,
    this.userName,
    this.userEmail,
    this.userMobile,
  });

  factory HallBookingData.fromJson(Map<String, dynamic> json) {
    return HallBookingData(
      id: json['id'],
      hallId: json['hall_id'],
      userId: json['user_id'],
      date: json['date'],
      slotFromTime: json['slot_from_time'],
      slotToTime: json['slot_to_time'],
      isPaid: json['is_paid'],
      bookingStatus: getBookingStatusName(json['is_paid']),
      // ✨ NEW: Parse embedded user information
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      userMobile: json['user_mobile']?.toString(),
    );
  }

  // Enhanced copyWith method
  HallBookingData copyWith({
    int? id,
    int? hallId,
    int? userId,
    String? date,
    String? slotFromTime,
    String? slotToTime,
    String? isPaid,
    String? bookingStatus,
    String? userName,
    String? userEmail,
    String? userMobile,
  }) {
    return HallBookingData(
      id: id ?? this.id,
      hallId: hallId ?? this.hallId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      slotFromTime: slotFromTime ?? this.slotFromTime,
      slotToTime: slotToTime ?? this.slotToTime,
      isPaid: isPaid ?? this.isPaid,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userMobile: userMobile ?? this.userMobile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hall_id': hallId,
      'user_id': userId,
      'date': date,
      'slot_from_time': slotFromTime,
      'slot_to_time': slotToTime,
      'is_paid': isPaid,
      'booking_status': bookingStatus,
      'user_name': userName,
      'user_email': userEmail,
      'user_mobile': userMobile,
    };
  }

  // ✨ NEW: Helper methods for user information with fallbacks
  String get displayUserName => userName?.isNotEmpty == true ? userName! : 'Customer #$userId';
  String get displayUserEmail => userEmail?.isNotEmpty == true ? userEmail! : 'No email available';
  String get displayUserMobile => userMobile?.isNotEmpty == true ? userMobile! : 'No phone available';

  // ✨ NEW: Check if we have embedded user information
  bool get hasUserInfo => userName?.isNotEmpty == true || userEmail?.isNotEmpty == true || userMobile?.isNotEmpty == true;

  // ✨ NEW: Get user info quality
  String get userInfoQuality {
    final hasName = userName?.isNotEmpty == true;
    final hasEmail = userEmail?.isNotEmpty == true;
    final hasPhone = userMobile?.isNotEmpty == true;

    if (hasName && hasEmail && hasPhone) {
      return 'complete';
    } else if (hasName || hasEmail || hasPhone) {
      return 'partial';
    } else {
      return 'limited';
    }
  }

  // ✨ NEW: Status checking helpers
  bool get isConfirmed => isPaid == 'c';
  bool get isCancelled => isPaid == 'cl';
  bool get isBlocked => isPaid == 'b';
  bool get isAvailable => isPaid == '0';

  // ✨ NEW: Date checking helpers
  bool get isToday {
    try {
      final bookingDate = DateTime.parse(date);
      final now = DateTime.now();
      return bookingDate.year == now.year &&
          bookingDate.month == now.month &&
          bookingDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  bool get isUpcoming {
    try {
      final bookingDate = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      return bookingDateOnly.isAfter(today);
    } catch (e) {
      return false;
    }
  }

  bool get isPast {
    try {
      final bookingDate = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      return bookingDateOnly.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  // ✨ NEW: Get formatted date
  String get formattedDate {
    try {
      final parts = date.split('-');
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
    return date;
  }

  // ✨ NEW: Get formatted time slot
  String get formattedTimeSlot {
    try {
      final fromParts = slotFromTime.split(':');
      final toParts = slotToTime.split(':');

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
    return '$slotFromTime - $slotToTime';
  }

  // ✨ NEW: Create UserDetails from embedded info
  UserDetails get embeddedUserDetails {
    return UserDetails(
      userId: userId,
      name: displayUserName,
      email: displayUserEmail,
      phone: displayUserMobile,
      address: 'Address not available',
      profilePicture: null,
      createdAt: null,
    );
  }

  // ✨ NEW: Search helper
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return id.toString().contains(searchQuery) ||
        date.toLowerCase().contains(searchQuery) ||
        bookingStatus.toLowerCase().contains(searchQuery) ||
        displayUserName.toLowerCase().contains(searchQuery) ||
        displayUserEmail.toLowerCase().contains(searchQuery) ||
        displayUserMobile.contains(searchQuery);
  }
}

// ✨ NEW: Simple UserDetails class for hall booking context
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
      name: json['name'] ?? json['username'] ?? json['user_name'] ?? 'Unknown User',
      email: json['email'] ?? json['user_email'] ?? 'No email available',
      phone: json['phone'] ?? json['mobile'] ?? json['mobile_no'] ?? json['user_mobile']?.toString() ?? 'No phone available',
      address: json['address'] ?? 'No address available',
      profilePicture: json['profile_picture'] ?? json['profile_pic'] ?? json['avatar'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
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

class HallBookingResponse {
  final int statusCode;
  final bool success;
  final List<dynamic> messages;
  final List<HallBookingData> data;

  HallBookingResponse({
    required this.statusCode,
    required this.success,
    required this.messages,
    required this.data,
  });

  factory HallBookingResponse.fromJson(Map<String, dynamic> json) {
    List<HallBookingData> bookingsData = [];
    if (json['data'] is List) {
      bookingsData = (json['data'] as List)
          .map((item) => HallBookingData.fromJson(item))
          .toList();
    }
    return HallBookingResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      messages: json['messages'] ?? [],
      data: bookingsData,
    );
  }

  // Factory for initial/empty state
  factory HallBookingResponse.initial() {
    return HallBookingResponse(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  // CopyWith method for state updates
  HallBookingResponse copyWith({
    int? statusCode,
    bool? success,
    List<dynamic>? messages,
    List<HallBookingData>? data,
  }) {
    return HallBookingResponse(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }
}