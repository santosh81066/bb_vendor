import 'package:bb_vendor/models/addpropertymodel.dart';
import 'package:bb_vendor/providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/models/get_properties_model.dart";
import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bb_vendor/providers/loader.dart';

class AddPropertyNotifier extends StateNotifier<Property> {
  AddPropertyNotifier() : super(Property.initial());

  // void setPropertyImage(File image) {
  //   state = state.copyWith(propertyImage: image);
  // }

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
    print("user id.....$venderlogin");

    Uri url = Uri.parse(Bbapi.addproperty);

    final request = http.MultipartRequest('POST', url);

    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');
    print('Raw SharedPrefs userData: $userData');

    String? token;
      String? userId;
   if (userData != null) {
  final extractedData = json.decode(userData) as Map<String, dynamic>;
  token = extractedData['access_token']; 
  userId = extractedData['user_id']?.toString(); 
  }

    
    // Debugging token
    print('Access Token: $token');

    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }
   
  // Add attributes as JSON string with all required details
  Map<String, dynamic> attributes = {
    'address': address1 ?? '',
    'propertyName': propertyname ?? '',
    'location': sLoc ?? '',
    'userid': userId ?? '',
    'category': selectedCategoryid?.toString() ?? '',
  };

  // Add attributes as a JSON string
  request.fields['attributes'] = json.encode(attributes);
  print('Sending attributes: ${json.encode(attributes)}');


    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'coverpic',
        _profileImage.path,
      ));

      // Debugging file path
      print('Property Image Path: ${_profileImage.path}');
    }

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

  Future<void> addhallproperty(
    String? propertyname,
    int? properid,
    List<Map<String, TimeOfDay>>? slots,
    List<File>? images,
  ) async {
    print("add hall is working------------------");
    print("propertyname-$propertyname");
    print("propertyid-$properid");

    // Print slots
    if (slots != null && slots.isNotEmpty) {
      print("Slots:");
      for (var i = 0; i < slots.length; i++) {
        var slot = slots[i];
        var checkInTime = slot['check_in_time'];
        var checkOutTime = slot['check_out_time'];
        print(
            "Slot ${i + 1}: Check-in: ${checkInTime?.hour}:${checkInTime?.minute}, Check-out: ${checkOutTime?.hour}:${checkOutTime?.minute}");
      }
    } else {
      print("No slots available.");
    }

    // Print images
    if (images != null && images.isNotEmpty) {
      print("Images:");
      for (var i = 0; i < images.length; i++) {
        print("Image ${i + 1}: Path = ${images[i].path}");
      }
    } else {
      print("No images available.");
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

      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files
              .add(await http.MultipartFile.fromPath('images[]', image.path));
        }
      }

      // Add attributes to the request
      request.fields['attributes'] = jsonEncode({
        'property_id': properid,
        'name': propertyname,
        'slots': slots?.map((slot) {
          return {
            'check_in_time':
                '${slot['check_in_time']?.hour}:${slot['check_in_time']?.minute}',
            'check_out_time':
                '${slot['check_out_time']?.hour}:${slot['check_out_time']?.minute}',
          };
        }).toList(),
      });

      print("Final request payload:");
      print(request.fields);

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;

      print("API Response Status Code: $statusCode");
      print("API Response Body: ${res.body}");

      if (statusCode == 200 || statusCode == 201) {
        print('Hall added successfully: $responseBody');
      } else {
        throw Exception(responseBody['messages'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Error adding hall: $e');
      rethrow;
    }
  }

  Future<void> getproperty() async {
    print("fetching getproperties");

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
        print('Decoded Response: $decodedResponse');

        // Parse the response into the Property model
        Property property = Property.fromJson(decodedResponse);
        print('Parsed Properties: ${property.data![0]}');

        // Update the state with the fetched data
        state = property;
        // Debugging the state
        print("Updated state: ${state.data}");
      } else {
        final errorMessage = 'Error fetching properties: ${response.body}';
        print(errorMessage);

        // Optionally, handle the error in the state
        state = Property.initial().copyWith(messages: [errorMessage]);
      }
    } catch (e) {
      print("Error fetching properties: $e");

      // Optionally, handle the error in the state
      state = Property.initial().copyWith(messages: [e.toString()]);
    }
  }
}

final propertyNotifierProvider =
    StateNotifierProvider<AddPropertyNotifier, Property>((ref) {
  return AddPropertyNotifier();
});
