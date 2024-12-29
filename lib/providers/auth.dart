import 'dart:convert';

// import 'package:vendor_pannel/Providers/phoneauthnotifier.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/authstate.dart';
import '../utils/bbapi.dart';
import 'stateproviders.dart';

class AuthNotifier extends StateNotifier<AdminAuth> {
  AuthNotifier() : super(AdminAuth.initial());
  //   _loadUserFromPrefs();
  // }

  // // Load user data from SharedPreferences on startup
  // Future<void> _loadUserFromPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userData = prefs.getString('userData');
  //   if (userData != null) {
  //     final data = json.decode(userData) as Map<String, dynamic>;
  //     state = AdminAuth.fromJson(data);
  //     print('User loaded on app startup: ${state.data?.userRole}');
  //   }
  // }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      return true;
    }

    if (prefs.containsKey('userData')) {
      print('User authenticated');
      final extractData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

      if (state.data?.accessToken == null) {
        state = AdminAuth.fromJson(extractData);
      }
      return true;
    }
    print('User not authenticated');
    return false;
  }

  Future<LoginResult> adminLogin(
      String email, String password, WidgetRef ref) async {
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

        // Parse the response body to AdminAuth model
        AdminAuth adminAuth = AdminAuth.fromJson(responseBody!);

        // Update the state with the returned data
        state = state.copyWith(
          data: state.data?.copyWith(
            userId: responseBody['data']['user_id'],
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
          statusCode: responseBody['statusCode'],
          success: responseBody['success'],
          messages: List<String>.from(responseBody['messages']),
        );
        print('State updated with access token: ${state.data!.accessToken}');
        print('State updated in adminLogin: ${state.toJson()}');

        // Storing data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        print("SharedPreferences fetched successfully");

        // Store the entire AdminAuth object in SharedPreferences
        final userData = json.encode(adminAuth.toJson());
        bool saveResult = await prefs.setString('userData', userData);

        if (!saveResult) {
          print("Failed to save user data to SharedPreferences.");
        }

        // Also saving the access token separately if needed
        bool tokenSaveResult = await prefs.setString(
            'accessToken', adminAuth.data?.accessToken ?? '');
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
