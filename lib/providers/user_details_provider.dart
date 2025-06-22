import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:bb_vendor/models/vendor_booking_models.dart';
import 'package:bb_vendor/utils/bbapi.dart';
import '../models/authstate.dart';
import 'auth.dart';

class EnhancedUserDetailsNotifier extends StateNotifier<Map<int, UserDetails>> {
  final Ref ref;

  EnhancedUserDetailsNotifier(this.ref) : super({});

  Future<UserDetails> fetchUserDetails(int userId) async {
    // Return cached data if available
    if (state.containsKey(userId)) {
      print('✓ Returning cached user details for user ID: $userId');
      return state[userId]!;
    }

    try {
      // Get auth token from AuthNotifier
      final authState = ref.read(authprovider);
      final token = authState.data?.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - no access token available');
      }

      print('🔍 Fetching user details for user ID: $userId');

      // Make API call to fetch user details
      final response = await http.get(
        Uri.parse('${Bbapi.baseUrl}/users/$userId'), // Adjust endpoint as needed
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        UserDetails userDetails;
        if (responseData['success'] == true && responseData['data'] != null) {
          // If API returns data in 'data' field with success flag
          userDetails = UserDetails.fromJson(responseData['data']);
        } else if (responseData['data'] != null) {
          // If API returns data in 'data' field
          userDetails = UserDetails.fromJson(responseData['data']);
        } else {
          // If API returns user data directly
          userDetails = UserDetails.fromJson(responseData);
        }

        // Cache the user details
        state = {...state, userId: userDetails};
        print('✓ User details cached for user ID: $userId');

        return userDetails;
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to fetch user details';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error fetching user details: $e');
      if (e.toString().contains('User not found') ||
          e.toString().contains('Authentication')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get cached user details
  UserDetails? getCachedUserDetails(int userId) {
    return state[userId];
  }

  // Clear cache for a specific user
  void clearUserCache(int userId) {
    final newState = Map<int, UserDetails>.from(state);
    newState.remove(userId);
    state = newState;
    print('🗑️ Cleared cache for user ID: $userId');
  }

  // Clear all cached user details
  void clearAllCache() {
    state = {};
    print('🗑️ Cleared all user details cache');
  }

  // Force refresh user details (bypass cache)
  Future<UserDetails> forceRefreshUserDetails(int userId) async {
    // Remove from cache first
    clearUserCache(userId);

    // Fetch fresh data
    return await fetchUserDetails(userId);
  }

  // Batch fetch multiple users (useful for booking lists)
  Future<List<UserDetails>> fetchMultipleUsers(List<int> userIds) async {
    final List<UserDetails> users = [];

    for (int userId in userIds) {
      try {
        final user = await fetchUserDetails(userId);
        users.add(user);
      } catch (e) {
        print('❌ Failed to fetch user $userId: $e');
        // Continue with other users even if one fails
      }
    }

    return users;
  }
}

// Enhanced provider instances
final enhancedUserDetailsNotifierProvider = StateNotifierProvider<EnhancedUserDetailsNotifier, Map<int, UserDetails>>((ref) {
  return EnhancedUserDetailsNotifier(ref);
});

// Provider to fetch user details for a specific user ID with auth integration
final enhancedUserDetailsProvider = FutureProvider.family.autoDispose<UserDetails, int>((ref, userId) async {
  // Check if user is authenticated first
  final authState = ref.watch(authprovider);

  // Fix null safety: Check for null values properly
  final isAuthenticated = authState.success == true &&
      authState.data?.accessToken != null &&
      authState.data!.accessToken!.isNotEmpty;

  if (!isAuthenticated) {
    throw Exception('Authentication required');
  }

  final notifier = ref.read(enhancedUserDetailsNotifierProvider.notifier);

  // Check if data is already cached
  final cached = notifier.getCachedUserDetails(userId);
  if (cached != null) {
    return cached;
  }

  // Fetch from API with auth token
  return await notifier.fetchUserDetails(userId);
});

// Provider for batch fetching users
final batchUserDetailsProvider = FutureProvider.family.autoDispose<List<UserDetails>, List<int>>((ref, userIds) async {
  final authState = ref.watch(authprovider);

  // Fix null safety: Check for null values properly
  final isAuthenticated = authState.success == true &&
      authState.data?.accessToken != null &&
      authState.data!.accessToken!.isNotEmpty;

  if (!isAuthenticated) {
    throw Exception('Authentication required');
  }

  final notifier = ref.read(enhancedUserDetailsNotifierProvider.notifier);
  return await notifier.fetchMultipleUsers(userIds);
});

// Mock implementation with better structure (for testing)
final enhancedMockUserDetailsProvider = FutureProvider.family.autoDispose<UserDetails, int>((ref, userId) async {
  // Check authentication even for mock - fix null safety
  final authState = ref.watch(authprovider);

  // Proper null safety check
  if (authState.success != true) {
    throw Exception('Authentication required');
  }

  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Enhanced mock data with more realistic information
  final mockUsers = {
    1: UserDetails(
      userId: 1,
      name: 'Rajesh Kumar',
      email: 'rajesh.kumar@gmail.com',
      phone: '+91 9876543210',
      address: '123, MG Road, Banjara Hills, Hyderabad, Telangana - 500034',
      profilePicture: 'https://via.placeholder.com/150',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    2: UserDetails(
      userId: 2,
      name: 'Priya Sharma',
      email: 'priya.sharma@gmail.com',
      phone: '+91 9876543211',
      address: '456, Jubilee Hills, Hyderabad, Telangana - 500033',
      profilePicture: 'https://via.placeholder.com/150',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    3: UserDetails(
      userId: 3,
      name: 'Arun Reddy',
      email: 'arun.reddy@gmail.com',
      phone: '+91 9876543212',
      address: '789, HITEC City, Madhapur, Hyderabad, Telangana - 500081',
      profilePicture: 'https://via.placeholder.com/150',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  };

  final user = mockUsers[userId];
  if (user != null) {
    return user;
  } else {
    // Generate dynamic mock data for unknown user IDs
    return UserDetails(
      userId: userId,
      name: 'Customer $userId',
      email: 'customer$userId@gmail.com',
      phone: '+91 987654${userId.toString().padLeft(4, '0')}',
      address: '$userId, Mock Street, Hyderabad, Telangana - ${userId.toString().padLeft(6, '0')}',
      createdAt: DateTime.now().subtract(Duration(days: userId * 2)),
    );
  }
});

// Helper provider to check if user details exist in cache
final userDetailsCacheProvider = Provider.family<UserDetails?, int>((ref, userId) {
  final cacheState = ref.watch(enhancedUserDetailsNotifierProvider);
  return cacheState[userId];
});

// Provider to get current auth user details (vendor/admin)
final currentUserProvider = Provider<UserDetails?>((ref) {
  final authState = ref.watch(authprovider);

  // Check if auth data exists and is valid
  if (authState.data == null) return null;

  // Convert auth data to UserDetails format for consistency
  return UserDetails(
    userId: authState.data!.userId ?? 0,
    name: authState.data!.username ?? 'Unknown',
    email: authState.data!.email ?? '',
    phone: authState.data!.mobileNo ?? '',
    address: authState.data!.address ?? '',
    profilePicture: authState.data!.profilePic,
    createdAt: DateTime.now(), // You might want to add this field to your auth model
  );
});

// Helper function to check authentication status
bool isUserAuthenticated(AdminAuth authState) {
  return authState.success == true &&
      authState.data?.accessToken != null &&
      authState.data!.accessToken!.isNotEmpty;
}

// Alternative provider with helper function for cleaner code
final enhancedUserDetailsProviderClean = FutureProvider.family.autoDispose<UserDetails, int>((ref, userId) async {
  final authState = ref.watch(authprovider);

  if (!isUserAuthenticated(authState)) {
    throw Exception('Authentication required');
  }

  final notifier = ref.read(enhancedUserDetailsNotifierProvider.notifier);

  // Check if data is already cached
  final cached = notifier.getCachedUserDetails(userId);
  if (cached != null) {
    return cached;
  }

  // Fetch from API with auth token
  return await notifier.fetchUserDetails(userId);
});