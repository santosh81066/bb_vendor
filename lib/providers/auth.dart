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
  AuthNotifier() : super(AdminAuth.initial());

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

          } catch (jsonError) {
            print('❌ Error parsing JSON: $jsonError');
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

        // Storing data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        print("SharedPreferences fetched successfully");

        // Store the entire AdminAuth object in SharedPreferences
        final userData = json.encode(state.toJson());
        bool saveResult = await prefs.setString('userData', userData);

        print("login time -localdata in shared preferences==$saveResult");

        if (!saveResult) {
          print("Failed to save user data to SharedPreferences.");
        }

        // Also saving the access token separately if needed
        bool tokenSaveResult =
        await prefs.setString('accessToken', state.data?.accessToken ?? '');
        if (!tokenSaveResult) {
          print("Failed to save access token to SharedPreferences.");
        }
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

  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print("Retrieved token: $token"); // Debug print
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

        final prefs = await SharedPreferences.getInstance();
        // Fixed: Use consistent key 'userData'
        prefs.setString('userData', json.encode(updateddata.toJson()));

        print("Updated Admin Data: $updateddata");

        // Fixed: Check for consistent key 'userData'
        final localdata = prefs.containsKey("userData");
        print("localdata-afterupdated==$localdata");
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AdminAuth.initial(); // Clear the state after logout
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