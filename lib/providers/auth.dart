import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/authstate.dart';
import '../utils/bbapi.dart';
import 'stateproviders.dart';

class AuthNotifier extends StateNotifier<AdminAuth> {
  AuthNotifier() : super(AdminAuth.initial()) {
    // Automatically try to restore user session when notifier is created
    _initializeAuth();
  }

  bool _isInitialized = false;

  // Add the missing getters
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated {
    return state.data?.accessToken != null && state.data!.accessToken!.isNotEmpty;
  }

  int? get currentUserId {
    return state.data?.userId;
  }

  Future<void> _initializeAuth() async {
    try {
      await tryAutoLogin();
    } catch (e) {
      print('Error during auth initialization: $e');
    } finally {
      _isInitialized = true;
    }
  }

  // Add this method to your AuthNotifier class for better debugging
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('=== AUTO LOGIN DEBUG ===');

      // Check all keys in SharedPreferences
      final allKeys = prefs.getKeys();
      print('All SharedPreferences keys: $allKeys');

      // Check if userData exists in SharedPreferences
      if (prefs.containsKey('userData')) {
        print('✓ userData key found in SharedPreferences');

        final userDataString = prefs.getString('userData');
        print('Raw userData string: $userDataString');

        if (userDataString != null && userDataString.isNotEmpty) {
          try {
            final extractData = json.decode(userDataString) as Map<String, dynamic>;
            print('✓ Successfully parsed JSON: $extractData');

            // Check if token is still valid (optional)
            if (_isTokenValid(extractData)) {
              // IMPORTANT: Update the state with the stored data
              state = AdminAuth.fromJson(extractData);

              // Add this verification
              print('✓ State restored from SharedPreferences');
              print('Current state after restore: ${state.toJson()}');
              print('Restored access token: ${state.data?.accessToken}');
              print('Restored username: ${state.data?.username}');
              print('Restored email: ${state.data?.email}');

              // Verify the state was actually updated
              if (state.data?.accessToken != null && state.data!.accessToken!.isNotEmpty) {
                print('✓ Auto-login successful - valid token found');
                return true;
              } else {
                print('❌ State updated but no valid token found');
                return false;
              }
            } else {
              print('❌ Token expired, clearing stored data');
              await _clearStoredData();
              return false;
            }

          } catch (jsonError) {
            print('❌ Error parsing JSON: $jsonError');
            await _clearStoredData(); // Clear corrupted data
            return false;
          }
        } else {
          print('❌ userData string is null or empty');
        }
      } else {
        print('❌ userData key not found in SharedPreferences');
      }

      // Fallback: check for access token only
      final accessToken = prefs.getString('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        print("Access token found: $accessToken");
        // If you only have the token, you might want to create a minimal state
        // or make an API call to get user details
        return true;
      }

      print('❌ User not authenticated - no data found');
      return false;

    } catch (e) {
      print('❌ Error during auto-login: $e');
      return false;
    }
  }

  bool _isTokenValid(Map<String, dynamic> userData) {
    try {
      final expiresAt = userData['data']?['access_token_expires_at'];
      if (expiresAt == null) return true; // No expiry info, assume valid

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      final now = DateTime.now();

      return expiryTime.isAfter(now);
    } catch (e) {
      print('Error checking token validity: $e');
      return true; // Assume valid if can't check
    }
  }

  Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.remove('accessToken');
      state = AdminAuth.initial();
    } catch (e) {
      print('Error clearing stored data: $e');
    }
  }

// Add this method to your AuthNotifier class
  Future<void> forceRefreshUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = json.decode(userDataString) as Map<String, dynamic>;
        state = AdminAuth.fromJson(userData);
        print('✓ User data force refreshed');
        print('Current user: ${state.data?.username}');
      } else {
        print('❌ No user data found in SharedPreferences');
      }
    } catch (e) {
      print('❌ Error force refreshing user data: $e');
    }
  }

// Also add this method to manually check stored data
  Future<void> debugStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== STORED DATA DEBUG ===');

    final userData = prefs.getString('userData');
    final accessToken = prefs.getString('accessToken');

    print('Stored userData: $userData');
    print('Stored accessToken: $accessToken');

    if (userData != null) {
      try {
        final parsed = json.decode(userData);
        print('Parsed userData: $parsed');
      } catch (e) {
        print('Error parsing stored userData: $e');
      }
    }
  }

  Future<LoginResult> adminLogin(
      BuildContext context, email, String password, WidgetRef ref) async {
    final loadingState = ref.watch(loadingProvider.notifier);
    int responseCode = 0;
    String? errorMessage;
    Map<String, dynamic>? responseBody;

    try {
      loadingState.state = true;

      // Making the API request with email and password in the body
      var response = await http.post(
        Uri.parse(Bbapi.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      responseCode = response.statusCode;
      responseBody = json.decode(response.body);
      print('Response Code: $responseCode');
      print('login Response: $responseBody');

      if (responseCode == 200 && responseBody?['success'] == true) {
        loadingState.state = false;

        // Update the state with the returned data
        state = state.copyWith(
          data: state.data?.copyWith(
            userId: responseBody!['data']['user_id'],
            username: responseBody['data']['username'],
            email: responseBody['data']['email'],
            address: responseBody['data']['address'],
            location: responseBody['data']['location'],
            userRole: responseBody['data']['user_role'],
            userStatus: responseBody['data']['user_status'],
            mobileNo: responseBody['data']['mobile_no']?.toString(),
            accessToken: responseBody['data']['access_token'],
            accessTokenExpiresAt: responseBody['data']
            ['access_token_expires_at'],
            refreshToken: responseBody['data']['refresh_token'],
            refreshTokenExpiresAt: responseBody['data']
            ['refresh_token_expires_at'],
            profilePic: responseBody['data']['profile_pic'],
          ),
          statusCode: responseBody!['statusCode'],
          success: responseBody['success'],
          messages: List<String>.from(responseBody['messages']),
        );
        print('State updated with access token: ${state.data!.accessToken}');
        print('State updated in adminLogin: ${state.toJson()}');

        // Store data using the new method
        await _storeUserData();

      } else {
        loadingState.state = false;
        errorMessage =
            responseBody?['messages']?.first ?? 'An unknown error occurred.';
      }
    } catch (e) {
      loadingState.state = false;
      errorMessage = e.toString();
      print("Catch: $errorMessage");
    }

    // Return the result with the response body included
    return LoginResult(responseCode,
        errorMessage: errorMessage, responseBody: responseBody);
  }

  Future<void> _storeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(state.toJson());

      bool saveResult = await prefs.setString('userData', userData);
      bool tokenSaveResult = await prefs.setString('accessToken', state.data?.accessToken ?? '');

      print("User data saved to SharedPreferences: $saveResult");
      print("Access token saved to SharedPreferences: $tokenSaveResult");

      if (!saveResult || !tokenSaveResult) {
        print("Warning: Failed to save some user data to SharedPreferences");
      }
    } catch (e) {
      print("Error storing user data: $e");
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      // First try to get from current state
      if (state.data?.accessToken != null && state.data!.accessToken!.isNotEmpty) {
        return state.data!.accessToken;
      }

      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print("Retrieved token from SharedPreferences: $token");
      return token;
    } catch (e) {
      print("Error retrieving access token: $e");
      return null;
    }
  }

  Future<void> updateUser(
      String username,
      String email,
      String mobile,
      File? profileImage,
      WidgetRef ref,
      ) async {
    final url = Uri.parse(Bbapi.updateeuser);
    final token = await _getAccessToken();
    final userId = state.data!.userId;
    print("userid: $userId");

    if (userId == null) {
      throw Exception('userid is not found');
    }

    if (token == null || token.isEmpty) {
      throw Exception('Access token is not available');
    }

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Token $token',
          'Content-Type': 'multipart/form-data',
        })
        ..fields['id'] = userId.toString()
        ..fields['username'] = username
        ..fields['email'] = email
        ..fields['mobile_no'] = mobile;

      if (profileImage != null) {
        if (await profileImage.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'profile_pic',
            profileImage.path,
          ));
        } else {
          print("Profile image file does not exist: ${profileImage.path}");
          throw Exception("Profile image file not found");
        }
      }

      print("Request URL: ${request.url}");
      print("Request Fields: ${request.fields}");
      print("Request Headers: ${request.headers}");

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      print("Update Response Body: ${responseData.body}");
      print("Response Status Code: ${responseData.statusCode}");

      if (responseData.statusCode == 200) {
        final responseJson = json.decode(responseData.body);
        print("updated profile page: $responseJson");

        AdminAuth updateddata = AdminAuth.fromJson(responseJson);
        state = updateddata;

        // Store updated data
        await _storeUserData();

        print("Updated Admin Data: $updateddata");
      } else {
        final error =
            json.decode(responseData.body)['message'] ?? 'Error updating user';
        throw Exception(error);
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    print('Logging out...');
    await _clearStoredData();
    print('User logged out and state cleared.');
  }
}

String cleanErrorMessage(String errorMessage) {
  // Remove the "ERROR:" prefix
  String cleanedMessage = errorMessage.replaceFirst('ERROR:', '');

  // Remove the curly brackets
  cleanedMessage = cleanedMessage.replaceAll(RegExp(r'[{}]'), '');

  // Trim any extra whitespace
  cleanedMessage = cleanedMessage.trim();

  return cleanedMessage;
}

final authprovider = StateNotifierProvider<AuthNotifier, AdminAuth>((ref) {
  return AuthNotifier();
});

// Model class to represent the login result
class LoginResult {
  final int statusCode;
  final String? errorMessage;
  final Map<String, dynamic>? responseBody;

  LoginResult(this.statusCode, {this.errorMessage, this.responseBody});
}