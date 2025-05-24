
import 'package:bb_vendor/providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/models/get_properties_model.dart";
import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyNotifier extends StateNotifier<Property> {
  AddPropertyNotifier() : super(Property.initial());

  Future<void> addProperty(
    BuildContext context,
    WidgetRef ref,
    String? propertyname,
    int? selectedCategoryid,
    String? address1,
    File? _profileImage,
    String? sLoc,
  ) async {
    final venderlogin = ref.watch(authprovider).data?.userId;

    Uri url = Uri.parse(Bbapi.addproperty);

    final request = http.MultipartRequest('POST', url);

    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    String? token;
    String? userId;
    if (userData != null) {
      final extractedData = json.decode(userData) as Map<String, dynamic>;
      token = extractedData['data']
          ['access_token']; // Fix: access the token from the 'data' object
      userId = extractedData['data']['user_id']
          ?.toString(); // Fix: access the user_id from the 'data' object
    }

    // Debugging token
    // Add this to debug

    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }

    // Add attributes as JSON string with all required details
    Map<String, dynamic> attributes = {
      'address': address1 ?? '',
      'propertyName': propertyname ?? '',
      'location': sLoc ?? '',
      'userid': userId ?? '', // This should now have the correct user ID
      'category': selectedCategoryid?.toString() ?? '',
    };

    // Add attributes as a JSON string
    request.fields['attributes'] = json.encode(attributes);

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'coverpic',
        _profileImage.path,
      ));

      // Debugging file path
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      // Print the response body

      if (response.statusCode == 201) {
        // Handle the success response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Property added successfully'),
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 30,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF6418C3),
                    ),
                    child: Center(
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('This is a SnackBar!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ));
      } else {
        // Handle the error response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'Property addition failed: ${responseData['messages']?.join(", ") ?? 'Unknown error'}'),
              actions: [
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> addhallproperty(
      String? propertyname,
      int? properid,
      List<Map<String, TimeOfDay>>? slots,
      List<File>? images,
      Map<String, dynamic> hallDetails,
      ) async {

    // Print slots
    if (slots != null && slots.isNotEmpty) {
      for (var i = 0; i < slots.length; i++) {
        var slot = slots[i];
        var checkInTime = slot['check_in_time'];
        var checkOutTime = slot['check_out_time'];
      }
    } else {
    }

    // Print images
    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
      }
    } else {
    }

    if (propertyname == null || propertyname.trim().isEmpty) {
      throw Exception("Property name cannot be null or empty.");
    }
    if (properid == null) {
      throw Exception("Property ID cannot be null.");
    }

    final url = Uri.parse(Bbapi.addhall);

    try {
      var request = http.MultipartRequest('POST', url);

      // Add authorization token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');

      String? token;
      if (userData != null) {
        final extractedData = json.decode(userData) as Map<String, dynamic>;
        token = extractedData['data']['access_token'];
      }

      if (token != null) {
        request.headers['Authorization'] = 'Token $token';
      }

      // Add images to the request
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files
              .add(await http.MultipartFile.fromPath('images[]', image.path));
        }
      }

      // Add attributes to the request - use the hallDetails directly since it's already formatted
      request.fields['attributes'] = jsonEncode(hallDetails);


      final response = await request.send();
      final res = await http.Response.fromStream(response);

      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;


      if (statusCode == 200 || statusCode == 201) {
      } else {
        throw Exception(responseBody['messages'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getproperty() async {

    try {
      // Ensure the correct endpoint for fetching property is used.
      final response = await http.get(
        Uri.parse(Bbapi.addproperty), // Use the appropriate endpoint here.
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Parse the response into the Property model
        Property property = Property.fromJson(decodedResponse);

        // Update the state with the fetched data
        state = property;
        // Debugging the state
      } else {
        final errorMessage = 'Error fetching properties: ${response.body}';

        // Optionally, handle the error in the state
        state = Property.initial().copyWith(messages: [errorMessage]);
      }
    } catch (e) {

      // Optionally, handle the error in the state
      state = Property.initial().copyWith(messages: [e.toString()]);
    }
  }
}

final propertyNotifierProvider =
    StateNotifierProvider<AddPropertyNotifier, Property>((ref) {
  return AddPropertyNotifier();
});
