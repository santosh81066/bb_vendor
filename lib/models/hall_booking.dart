enum BookingStatus {
  available,   // '0'
  confirmed,   // 'c'
  cancelled,   // 'cl'
}

String getBookingStatusName(String code) {
  switch (code) {
    case 'c':
      return 'Confirmed';
    case 'cl':
      return 'Cancelled';
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

class HallBookingData {
  final int id;
  final int hallId;
  final int userId;
  final String date;
  final String slotFromTime;
  final String slotToTime;
  final String isPaid;
  final String bookingStatus;

  HallBookingData({
    required this.id,
    required this.hallId,
    required this.userId,
    required this.date,
    required this.slotFromTime,
    required this.slotToTime,
    required this.isPaid,
    required this.bookingStatus,
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
    );
  }

  // CopyWith method for updates
  HallBookingData copyWith({
    int? id,
    int? hallId,
    int? userId,
    String? date,
    String? slotFromTime,
    String? slotToTime,
    String? isPaid,
    String? bookingStatus,
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
    };
  }
}

