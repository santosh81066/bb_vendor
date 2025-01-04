import 'package:bb_vendor/Providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bb_vendor/Models/get_properties_model.dart';

class PropertyRepository {
  final Ref ref;
  PropertyRepository(this.ref);
  final String _baseUrl = 'http://93.127.172.164:8080/api/properties/';

  Future<List<Property>> fetchProperties() async {
    final getaccesstoken = ref.read(authprovider).data?.accessToken;

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $getaccesstoken',
        },
      );

      // Print the response body for debugging
      final responseBody = response.body;
      print('Response Body: $responseBody');
      // print("Access token: $getaccesstoken");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load properties. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching properties: $e');
      rethrow;
    }
  }
}
