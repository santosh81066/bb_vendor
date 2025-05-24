import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bb_vendor/Models/registrationstatemodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(RegistrationState());

  void setProfileImage(File image) {
    state = state.copyWith(profileImage: image);
  }

  void setPropertyImage(File image) {
    state = state.copyWith(propertyImage: image);
  }

  Future<void> register(
      BuildContext context,
      WidgetRef ref,
      String? username,
      String? email,
      String? password,
      String? contactNumber,
      File? profileImage,
      String timezone, // Add timezone as a parameter
      ) async {
    Uri url = Uri.parse(Bbapi.registration);
    print("Registration Data: $username, $email, $password, $contactNumber");
    print("time----zone:$timezone");

    try {
      final request = http.MultipartRequest('POST', url);

      if (profileImage != null) {
        print("Uploading profile image: ${profileImage.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilepic', // Correct field name as confirmed
            profileImage.path,
          ),
        );
      } else {
        print("No profile image selected");
      }

      final data = {
        "username": username ?? '',
        "mobileno": contactNumber ?? '',
        "email": email ?? '',
        "role": "v",
        "userstatus": "1",
        "password": password ?? '',
        "timezone": timezone, // Include the timezone in the payload
      };

      request.fields.addAll({
        "attributes": json.encode(data),
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 201) {
        // Registration successful
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Registration failed
        final errorMessage =
            json.decode(responseBody)['messages']?.join(', ') ?? "Unknown error";
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Registration failed: $errorMessage'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error during registration: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}