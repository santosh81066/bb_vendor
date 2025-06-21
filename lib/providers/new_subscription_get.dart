import 'package:bb_vendor/models/new_subscriptionplan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:bb_vendor/providers/loader.dart';

// ignore: unused_import
import "package:flutter/material.dart";

class SubscriptionNotifier extends StateNotifier<Subscription> {
  final Ref ref;
  SubscriptionNotifier(this.ref) : super(Subscription.initial());

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
  

  /// Fetch subscribers and update the state
  Future<void> getSubscribers() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      print("Access token is null.");
      return;
    }

    ref.read(loadingProvider.notifier).state = true; // Set loading to true
    try {
      final response = await http.get(
        Uri.parse(Bbapi.subscriptions),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final subscriptionData = Subscription.fromJson(res);
        state = subscriptionData; // Update state with fetched data
        print("Subscribers fetched successfully: $subscriptionData");
      } else {
        final res = json.decode(response.body);
        print(
          'Error fetching subscribers: ${res['messages']?.first ?? 'An unknown error occurred.'}',
        );
      }
    } catch (e) {
      print("Error fetching subscribers: $e");
    } finally {
      ref.read(loadingProvider.notifier).state = false; // Reset loading
    }
  }

  Future<void> addSubscriptionPlan({
  required int? propertyid,
  required int? subplanid,
  required String? starttime,
  required String? expirytime,
}) async {
  print("propertyid$propertyid...subplanid$subplanid...starttime$starttime...expiretime$expirytime");
  final uri = Uri.parse(Bbapi.addplantoproperty);

  ref.read(loadingProvider.notifier).state = true; // Set loading to true
  try {
    // Prepare the multipart request
    var request = http.MultipartRequest('POST', uri);

    // Create the attributes JSON object
    final attributes = {
      "property_id": propertyid,
      "sub_plan_id": subplanid,
      "start_time": starttime,
      "expiry_time": expirytime,
      "status": 1, // Assuming status is always 1
    };

    // Convert the attributes object to a JSON string
    request.fields['attributes'] = jsonEncode(attributes);

    // Send the request
    final send = await request.send();
    final res = await http.Response.fromStream(send);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseJson = json.decode(res.body);
      print('plan added to property successfully: $responseJson');

      // Refresh data after successfully adding a subscription
      await getSubscribers();
    } else {
      print('Error in request: ${res.statusCode}, ${res.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  } finally {
    ref.read(loadingProvider.notifier).state = false; // Reset loading
  }
}

}

/// Provider to manage loading state and API calls
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, Subscription>((ref) {
  return SubscriptionNotifier(ref);
});
