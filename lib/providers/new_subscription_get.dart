import 'package:bb_vendor/models/new_subscriptionplan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:bb_vendor/providers/loader.dart';

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

// import 'package:bb_vendor/Providers/auth.dart';
// import 'package:bb_vendor/models/new_subscriptionplan.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class SubscriptionRepository {
//   final Ref ref;
//   SubscriptionRepository(this.ref);

//   final String _baseUrl = 'http://93.127.172.164:8080/api/subscription-plans/';

//   Future<List<SubscriptionPlan>> fetchSubscriptionPlans() async {
//     try {
//       final authState = ref.watch(authprovider); // Accessing the AuthNotifier
//       final token = authState.data?.accessToken;

//       final response = await http.get(
//         Uri.parse(_baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Token $token', // Use the token from AuthNotifier
//         },
//       );

//       print('Access Token for Subscription screen: $token');
//       print('Response Body: ${response.body}');
//       print('Response Code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         print('Full Response: $jsonResponse');

//         List<SubscriptionPlan> subscriptionPlans = [];

//         jsonResponse.forEach((key, value) {
//           List<dynamic> plansJson = value as List<dynamic>;
//           subscriptionPlans.addAll(
//             plansJson.map((data) => SubscriptionPlan.fromJson(data)).toList(),
//           );
//         });

//         if (subscriptionPlans.isEmpty) {
//           print('No subscription data found');
//         }

//         return subscriptionPlans;
//       } else {
//         print('Error fetching subscriptions: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Error: $e');
//       return [];
//     }
//   }
// }

// final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
//   return SubscriptionRepository(ref);
// });

// final subscriptionPlansProvider =
//     FutureProvider<List<SubscriptionPlan>>((ref) async {
//   final repository = ref.read(subscriptionRepositoryProvider);
//   return repository.fetchSubscriptionPlans();
// });
