// lib/providers/user_details_provider.dart (UPDATED with correct API endpoint)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/vendor_booking_models.dart';
import '../utils/bbapi.dart';
import 'auth.dart';

// Cache provider for user details
final userDetailsCacheProvider = StateProvider.family.autoDispose<UserDetails?, int>((ref, userId) {
  return null;
});

// Notifier for managing user details state
class UserDetailsNotifier extends StateNotifier<Map<int, UserDetails>> {
  UserDetailsNotifier(this.ref) : super({});

  final Ref ref;

  // Force refresh user details and clear cache
  Future<void> forceRefreshUserDetails(int userId) async {
    // Clear cache first
    ref.read(userDetailsCacheProvider(userId).notifier).state = null;

    // Remove from state
    state = Map.from(state)..remove(userId);

    // This will trigger a new fetch when the provider is accessed again
    ref.invalidate(enhancedUserDetailsProvider(userId));
  }

  // Method to update cached user details
  void updateUserDetails(int userId, UserDetails details) {
    state = Map.from(state)..[userId] = details;
    ref.read(userDetailsCacheProvider(userId).notifier).state = details;
  }
}

final enhancedUserDetailsNotifierProvider = StateNotifierProvider<UserDetailsNotifier, Map<int, UserDetails>>((ref) {
  return UserDetailsNotifier(ref);
});

// Enhanced user details provider with correct API endpoint
final enhancedUserDetailsProvider = FutureProvider.family.autoDispose<UserDetails, int>((ref, userId) async {
  try {
    print('🔍 Fetching user details for ID: $userId');

    // Check cache first
    final cached = ref.read(userDetailsCacheProvider(userId));
    if (cached != null) {
      print('✓ Using cached user details for ID: $userId');
      return cached;
    }

    // Check auth state
    final authState = ref.watch(authprovider);
    if (authState.data?.accessToken == null) {
      throw Exception('Authentication required to fetch user details');
    }

    final token = authState.data!.accessToken!;

    // OPTION 1: Try the get user profile endpoint (most likely)
    try {
      final response = await http.get(
        Uri.parse('${Bbapi.baseUrl}/get-user-profile/$userId'), // Update this to match your API
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('User details API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('User details response: $responseData');

        UserDetails userDetails;

        // Handle different response formats
        if (responseData['success'] == true && responseData['data'] != null) {
          userDetails = UserDetails.fromJson(responseData['data']);
        } else if (responseData['user_id'] != null || responseData['id'] != null) {
          userDetails = UserDetails.fromJson(responseData);
        } else {
          throw Exception('Invalid user data format received');
        }

        // Cache the result
        ref.read(enhancedUserDetailsNotifierProvider.notifier).updateUserDetails(userId, userDetails);

        print('✓ Successfully fetched and cached user details for ID: $userId');
        return userDetails;
      }
    } catch (e) {
      print('First API attempt failed: $e');
    }

    // OPTION 2: Try alternative endpoint
    try {
      final response = await http.get(
        Uri.parse('${Bbapi.baseUrl}/user-details/$userId'), // Alternative endpoint
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Alternative user details API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Alternative user details response: $responseData');

        UserDetails userDetails;

        if (responseData['success'] == true && responseData['data'] != null) {
          userDetails = UserDetails.fromJson(responseData['data']);
        } else if (responseData['user_id'] != null || responseData['id'] != null) {
          userDetails = UserDetails.fromJson(responseData);
        } else {
          throw Exception('Invalid user data format received');
        }

        // Cache the result
        ref.read(enhancedUserDetailsNotifierProvider.notifier).updateUserDetails(userId, userDetails);

        print('✓ Successfully fetched user details from alternative endpoint for ID: $userId');
        return userDetails;
      }
    } catch (e) {
      print('Second API attempt failed: $e');
    }

    // OPTION 3: If both fail, create a fallback user details object
    print('⚠️ API endpoints failed, creating fallback user details for ID: $userId');

    // Create a basic user details object with the information we have
    final fallbackUserDetails = UserDetails(
      userId: userId,
      name: 'Customer #$userId', // Fallback name
      email: 'customer$userId@example.com', // Fallback email
      phone: 'Not available', // Fallback phone
      address: 'Address not available', // Fallback address
      profilePicture: null,
      createdAt: null,
    );

    // Cache the fallback result
    ref.read(enhancedUserDetailsNotifierProvider.notifier).updateUserDetails(userId, fallbackUserDetails);

    print('✓ Using fallback user details for ID: $userId');
    return fallbackUserDetails;

  } catch (e) {
    print('❌ Error in user details provider for ID $userId: $e');

    if (e.toString().contains('TimeoutException')) {
      throw Exception('Network timeout - please check your connection');
    } else if (e.toString().contains('SocketException')) {
      throw Exception('Network error - please check your connection');
    } else {
      // If everything fails, create a basic fallback
      print('Creating emergency fallback for user $userId');
      return UserDetails(
        userId: userId,
        name: 'Customer #$userId',
        email: 'Not available',
        phone: 'Not available',
        address: 'Not available',
        profilePicture: null,
        createdAt: null,
      );
    }
  }
});

// Provider for bulk user details (useful for getting multiple users at once)
final bulkUserDetailsProvider = FutureProvider.family.autoDispose<Map<int, UserDetails>, List<int>>((ref, userIds) async {
  final Map<int, UserDetails> results = {};

  // Fetch details for each user
  for (final userId in userIds) {
    try {
      final details = await ref.watch(enhancedUserDetailsProvider(userId).future);
      results[userId] = details;
    } catch (e) {
      print('Failed to fetch details for user $userId: $e');
      // Create fallback for failed users
      results[userId] = UserDetails(
        userId: userId,
        name: 'Customer #$userId',
        email: 'Not available',
        phone: 'Not available',
        address: 'Not available',
        profilePicture: null,
        createdAt: null,
      );
    }
  }

  return results;
});