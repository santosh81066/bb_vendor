import 'package:bb_vendor/Models/addpropertymodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyNotifier extends StateNotifier<PropertyModel> {
  AddPropertyNotifier()
      : super(PropertyModel(
            propertyName: '',
            category: '',
            address1: '',
            propertyImage: null,
            location: '',
            address2: '',
            state: '',
            city: '',
            pincode: '',
            startTime: '',
            endTime: ''));

  void setPropertyImage(File image) {
    state = state.copyWith(propertyImage: image);
  }

  Future<void> addProperty(
    BuildContext context,
    WidgetRef ref,
    String? propertyName,
    String? category,
    String? address1,
    String? address2,
    String? location,
    String? state,
    String? city,
    String? pincode,
    String? startTime,
    String? endTime,
    File? propertyImage,
  ) async {
    Uri url = Uri.parse(Bbapi.addproperty);

    final request = http.MultipartRequest('POST', url);

    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    String? token;
    if (userData != null) {
      final extractedData = json.decode(userData) as Map<String, dynamic>;
      token = extractedData['token'];
    }

    // Debugging token
    print('Access Token: $token');

    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }

    if (propertyImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'property_pic',
        propertyImage.path,
      ));

      // Debugging file path
      print('Property Image Path: ${propertyImage.path}');
    }

    // Add the text fields to the request
    request.fields['property_name'] = propertyName ?? '';
    request.fields['category'] = category ?? '';
    request.fields['address_1'] = address1 ?? '';
    request.fields['address_2'] = address2 ?? '';
    request.fields['location'] = location ?? '';
    request.fields['state'] = state ?? '';
    request.fields['city'] = city ?? '';
    request.fields['pincode'] = pincode ?? '';
    request.fields['start_time'] = startTime ?? '';
    request.fields['end_time'] = endTime ?? '';

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      // Print the response body
      print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        // Handle the success response
        print(responseData);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Property added successfully'),
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
        Navigator.of(context)
            .pushNamed('/'); // Navigate to the home page or another page
      } else {
        // Handle the error response
        print('Property addition failed with status: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'Property addition failed: ${responseData['message'] ?? 'Unknown error'}'),
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
      print('An error occurred: $e');
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
}

// import 'package:banquetbookz_vendor/Models/addpropertymodel.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:banquetbookz_vendor/utils/bbapi.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// class SubscribersNotifier extends StateNotifier<subscription> {
//   SubscribersNotifier() : super(PropertyModel());