import 'package:bb_vendor/models/addpropertymodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/models/get_properties_model.dart";
import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPropertyNotifier extends StateNotifier<Property> {
  AddPropertyNotifier() : super(Property.initial());

  /// Function to Add a Property with Attributes and an Image
  Future<void> addProperty(
    BuildContext context,
    WidgetRef ref,
    String propertyName,
    String selectedCategory,
    String address,
    String userid,
    String location,
    File? profileImage,
  ) async {
    print("Adding property...");
    print("Property Name: $propertyName");
    print("Category: $selectedCategory");
    print("Address: $address");
    print("Location: $location");
    print("Profile Image Path: ${profileImage?.path}");

    if (propertyName.trim().isEmpty) {
      throw Exception("Property name cannot be empty.");
    }
    if (selectedCategory.trim().isEmpty) {
      throw Exception("Category cannot be empty.");
    }
    if (address.trim().isEmpty) {
      throw Exception("Address cannot be empty.");
    }
    if (location.trim().isEmpty) {
      throw Exception("Location cannot be empty.");
    }

    final url = Uri.parse(Bbapi.addproperty);

    try {
      var request = http.MultipartRequest('POST', url);

      // Add attributes as JSON
      Map<String, dynamic> attributes = {
        "address": address,
        "location": location,
        "userid": userid,
        "propertyName": propertyName,
        "category": selectedCategory,
      };
      request.fields['attributes'] = jsonEncode(attributes);

      // Attach the image if available
      if (profileImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath("coverpic", profileImage.path));
      }

      print("Final Request Payload:");
      print(request.fields);

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;

      print("API Response Status Code: $statusCode");
      print("API Response Body: ${res.body}");

      if (statusCode == 200 || statusCode == 201) {
        print('Property added successfully: $responseBody');
      } else {
        throw Exception(responseBody['messages'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Error adding property: $e');
      rethrow;
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
