import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Define a state for handling request states
enum PropertyState { initial, loading, success, failure }

// StateNotifier for managing property state
class AddPropertyNotifier extends StateNotifier<PropertyState> {
  AddPropertyNotifier() : super(PropertyState.initial);

  Future<void> addProperty({
    required Map<String, String> attributes,
    required File? coverpic,
  }) async {
    state = PropertyState.loading;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://www.gocodedesigners.com/bbaddproperty'),
      );

      // Add text fields
      request.fields['attributes'] = jsonEncode(attributes);

      // Add the image file if available
      if (coverpic != null) {
        request.files
            .add(await http.MultipartFile.fromPath('coverpic', coverpic.path));
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        state = PropertyState.success;
      } else {
        state = PropertyState.failure;
      }
    } catch (e) {
      state = PropertyState.failure;
    }
  }
}

// Declare a provider for the notifier
final addPropertyProvider =
    StateNotifierProvider<AddPropertyNotifier, PropertyState>(
  (ref) => AddPropertyNotifier(),
);
