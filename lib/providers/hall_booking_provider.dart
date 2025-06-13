import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/hall_booking.dart';
import '../providers/auth.dart';
import '../utils/bbapi.dart';

final hallBookingProvider =
StateNotifierProvider<HallBookingNotifier, AsyncValue<void>>((ref) {
  return HallBookingNotifier(ref);
});

class HallBookingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  HallBookingNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> postBooking({
    required int hallId,
    required int? bookingId,
    required String date,
    required String slotFromTime,
    required String slotToTime,
    required String isPaid,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Read auth state once at the beginning
      var authState = ref.read(authprovider);
      int? userId = authState.data?.userId;
      String? token = authState.data?.accessToken;

      // If user ID is missing, try auto-login
      if (userId == null) {
        final authNotifier = ref.read(authprovider.notifier);
        await authNotifier.tryAutoLogin();

        // Re-read the auth state after auto-login
        authState = ref.read(authprovider);
        userId = authState.data?.userId;
        token = authState.data?.accessToken; // Update token reference too

        if (userId == null) throw Exception('User ID not found.');
      }

      // If token is still null after potential auto-login, re-read auth state
      if (token == null || token.isEmpty) {
        authState = ref.read(authprovider);
        token = authState.data?.accessToken;

        if (token == null || token.isEmpty) {
          throw Exception('Access token not found.');
        }
      }

      final headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

      // Get all existing bookings for this slot
      final getResponse = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: headers,
      );

      if (getResponse.statusCode != 200) {
        throw Exception('Failed to fetch existing bookings');
      }

      final responseData = jsonDecode(getResponse.body);
      final bookings = responseData['data'] as List;
      int? existingBookingId;
      bool slotAlreadyConfirmed = false;

      // Check for existing bookings in this slot
      for (var booking in bookings) {
        if (booking['hall_id'] == hallId &&
            booking['date'] == date &&
            booking['slot_from_time'] == slotFromTime &&
            booking['slot_to_time'] == slotToTime) {

          // Check if any user has already confirmed this slot
          if (booking['is_paid'] == 'c') {
            slotAlreadyConfirmed = true;
            break;
          }

          // Check if current user has existing booking for this slot
          if (booking['user_id'] == userId) {
            existingBookingId = booking['id'];
          }
        }
      }

      // Prevent booking if slot is already confirmed by someone else
      if (slotAlreadyConfirmed) {
        throw Exception('This slot has already been confirmed by another user');
      }

      // If current user has existing booking or bookingId is provided, update it
      if (existingBookingId != null || bookingId != null) {
        await updateBookingPaymentStatus(
          bookingId: existingBookingId ?? bookingId!,
          status: isPaid,
        );
        return;
      }

      // Create new booking
      final requestBody = {
        "hall_id": hallId,
        "user_id": userId,
        "date": date,
        "slot_from_time": slotFromTime,
        "slot_to_time": slotToTime,
        "is_paid": isPaid,
      };

      final postResponse = await http.post(
        Uri.parse(Bbapi.hallbooking),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
        state = const AsyncValue.data(null);
      } else {
        final responseData = jsonDecode(postResponse.body);
        final messages = responseData['messages'];
        throw Exception(messages is List ? messages.join(', ') : (messages ?? 'Booking failed'));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

// Helper method to get fresh auth token
  String? _getFreshToken() {
    final authState = ref.read(authprovider);
    final token = authState.data?.accessToken;

    print('Getting fresh token - exists: ${token != null && token.isNotEmpty}');
    if (token != null && token.length > 10) {
      print('Token preview: ${token.substring(0, 10)}...');
    }

    return token;
  }

// Updated updateBookingPaymentStatus method
  Future<void> updateBookingPaymentStatus({
    required int bookingId,
    required String status,
  }) async {
    state = const AsyncValue.loading();

    try {
      final token = _getFreshToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found.');
      }

      final headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

      final patchBody = jsonEncode({
        "booking_id": bookingId,
        "is_paid": status,
      });

      final url = Uri.parse(Bbapi.hallbooking);

      final patchResponse = await http.patch(
        url,
        headers: headers,
        body: patchBody,
      );

      if (patchResponse.statusCode == 200) {
        state = const AsyncValue.data(null);
      } else {
        final responseData = jsonDecode(patchResponse.body);
        final errorMessage = responseData['messages']?.join(', ') ?? 'Failed to update booking payment status';
        throw Exception(errorMessage);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }


  // Method to cancel a booking
  Future<bool> cancelBooking({
    required int bookingId,
  }) async {
    state = const AsyncValue.loading();

    try {
      await updateBookingPaymentStatus(
        bookingId: bookingId,
        status: 'cl', // Using 'cl' for cancelled status as per your enum
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print("Error cancelling booking: $e");
      return false;
    }
  }

  // Fixed method to match the expected interface in PaymentPage
  Future<bool> updateBookingWithPayment({
    required int hallId,
    required int? bookingId,
    required String date,
    required String slotFromTime,
    required String slotToTime,
    required String paymentMethod,
    required String paymentId,
    required double amount,
    required bool isSuccess,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Set the payment status code based on your booking status enum
      // 'c' = confirmed, 'b' = blocked/pending, 'cl' = cancelled, '0' = available
      final String paymentStatus = isSuccess ? 'c' : 'b'; // Fixed: Using 'c' for confirmed

      // First update the booking payment status
      await postBooking(
        hallId: hallId,
        bookingId: bookingId,
        date: date,
        slotFromTime: slotFromTime,
        slotToTime: slotToTime,
        isPaid: paymentStatus,
      );

      // Get the booking ID if not provided (for newly created bookings)
      int finalBookingId;
      if (bookingId == null) {
        finalBookingId = await _getBookingId(
            hallId: hallId,
            date: date,
            slotFromTime: slotFromTime,
            slotToTime: slotToTime
        );
      } else {
        finalBookingId = bookingId;
      }

      // If payment is successful, ensure the status is 'c' (confirmed)
      if (isSuccess) {
        await updateBookingPaymentStatus(
          bookingId: finalBookingId,
          status: 'c', // Fixed: Using 'c' for confirmed
        );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print("Error updating booking with payment: $e");
      return false;
    }
  }

// Updated _getBookingId method
  Future<int> _getBookingId({
    required int hallId,
    required String date,
    required String slotFromTime,
    required String slotToTime,
  }) async {
    try {
      final authState = ref.read(authprovider);
      int? userId = authState.data?.userId;
      final token = _getFreshToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found.');
      }

      final headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch bookings');
      }

      final responseData = jsonDecode(response.body);
      final bookings = responseData['data'] as List;

      for (var booking in bookings) {
        if (booking['user_id'] == userId &&
            booking['hall_id'] == hallId &&
            booking['date'] == date &&
            booking['slot_from_time'] == slotFromTime &&
            booking['slot_to_time'] == slotToTime) {
          return booking['id'];
        }
      }

      throw Exception('Booking not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HallBookingData>> getBookings() async {
    try {
      final authState = ref.read(authprovider);
      final token = authState.data?.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found.');
      }

      final headers = {
        'Authorization': 'Token $token', // Fixed: Using 'Token' prefix
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(Bbapi.hallbooking),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final HallBookingResponse bookingResponse = HallBookingResponse.fromJson(responseData);
        return bookingResponse.data;
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['messages']?.join(', ') ?? 'Failed to fetch bookings';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

}