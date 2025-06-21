import 'dart:async';
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
  AddPropertyNotifier(this.ref) : super(Property.initial());

  final Ref ref; // Add ref to access other providers

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    // You can notify listeners if needed
  }

  // Add this method to get user-specific properties
  Future<void> getUserProperties() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        state = Property.initial().copyWith(
            messages: ['User not authenticated. Please login again.']
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${Bbapi.addproperty}?vendor_id=$currentUserId'), // Add vendor_id filter to API
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        Property property = Property.fromJson(decodedResponse);

        // Additional client-side filtering as backup
        if (property.data != null) {
          final filteredData = property.data!.where((prop) =>
          prop.vendorId == currentUserId
          ).toList();

          state = property.copyWith(data: filteredData);
        } else {
          state = property;
        }
      } else {
        final errorMessage = 'Error fetching properties: ${response.body}';
        state = Property.initial().copyWith(messages: [errorMessage]);
      }
    } catch (e) {
      state = Property.initial().copyWith(messages: [e.toString()]);
    } finally {
      _setLoading(false);
    }
  }

  // Update the existing getproperty method to include user filtering
  Future<void> getproperty() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        state = Property.initial().copyWith(
            messages: ['User not authenticated. Please login again.']
        );
        return;
      }

      final response = await http.get(
        Uri.parse(Bbapi.addproperty),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        Property property = Property.fromJson(decodedResponse);

        // Filter properties by current user ID
        if (property.data != null) {
          final userProperties = property.data!.where((prop) =>
          prop.vendorId == currentUserId
          ).toList();

          state = property.copyWith(data: userProperties);

          print('Filtered ${userProperties.length} properties for user $currentUserId');
        } else {
          state = property;
        }
      } else {
        final errorMessage = 'Error fetching properties: ${response.body}';
        state = Property.initial().copyWith(messages: [errorMessage]);
      }
    } catch (e) {
      state = Property.initial().copyWith(messages: [e.toString()]);
    } finally {
      _setLoading(false);
    }
  }

  // Add method to get properties by category for current user
  List<Data> getPropertiesByCategory(int? category) {
    final currentUserId = ref.read(authprovider).data?.userId;
    final allProperties = state.data ?? [];

    if (currentUserId == null) return [];

    // Filter by user first, then by category
    var userProperties = allProperties.where((prop) =>
    prop.vendorId == currentUserId
    ).toList();

    if (category == null) return userProperties;

    return userProperties.where((prop) => prop.category == category).toList();
  }

  // Add method to get property count for current user
  int getUserPropertyCount() {
    final currentUserId = ref.read(authprovider).data?.userId;
    if (currentUserId == null) return 0;

    return (state.data ?? []).where((prop) =>
    prop.vendorId == currentUserId
    ).length;
  }

  // Add method to check if user owns a specific property
  bool isUserProperty(int propertyId) {
    final currentUserId = ref.read(authprovider).data?.userId;
    if (currentUserId == null) return false;

    final property = (state.data ?? []).firstWhere(
          (prop) => prop.propertyId == propertyId,
      orElse: () => Data.initial(),
    );

    return property.vendorId == currentUserId;
  }

  Future<void> addProperty(
      BuildContext context,
      WidgetRef ref,
      String? propertyname,
      int? selectedCategoryid,
      String? address1,
      File? _profileImage,
      String? sLoc, {
        // New property manager parameters
        String? managerName,
        String? managerPhone,
        String? managerEmail,
        String? managerDesignation,
        String? managerExperience,
        File? managerImage,
      }) async {
    if (_isLoading) return; // Prevent multiple submissions

    _setLoading(true);

    // Show loading dialog
    _showLoadingDialog(context);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        Navigator.of(context).pop(); // Close loading dialog
        await _showErrorDialog(
          context,
          'Authentication Error',
          'Please login again to add properties.',
        );
        return;
      }

      Uri url = Uri.parse(Bbapi.addproperty);
      final request = http.MultipartRequest('POST', url);

      // Retrieve the token from SharedPreferences
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

      // Enhanced attributes with property manager details
      Map<String, dynamic> attributes = {
        // Property details
        'address': address1?.trim() ?? '',
        'propertyName': propertyname?.trim() ?? '',
        'location': sLoc ?? '',
        'userid': currentUserId.toString(), // Use current user ID
        'category': selectedCategoryid?.toString() ?? '',

        // Property manager details
        'manager': {
          'name': managerName?.trim() ?? '',
          'phone': managerPhone?.trim() ?? '',
          'email': managerEmail?.trim() ?? '',
          'designation': managerDesignation?.trim() ?? '',
          'experience': managerExperience?.trim() ?? '',
          'hasImage': managerImage != null,
        },
      };

      // Add attributes as a JSON string
      request.fields['attributes'] = json.encode(attributes);

      // Add property cover picture
      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'coverpic',
          _profileImage.path,
        ));
      }

      // Add manager image if provided
      if (managerImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'manager_image',
          managerImage.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        // Show success with enhanced dialog
        await _showSuccessDialog(context, propertyname ?? 'Property');

        // Show success snackbar
        _showSnackBar(
          context,
          'Property "${propertyname ?? 'Unknown'}" added successfully!',
          isError: false,
        );

        // Refresh the properties list to include the new property
        await getproperty();

        // Navigate back to previous screen
        Navigator.of(context).pop();

      } else {
        // Handle error response
        final responseData = json.decode(responseBody);
        await _showErrorDialog(
          context,
          'Property Addition Failed',
          _parseErrorMessage(responseData),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await _showErrorDialog(
        context,
        'Network Error',
        _getErrorMessage(e),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Enhanced updateProperty method
  Future<void> updateProperty(
      BuildContext context,
      WidgetRef ref,
      int propertyId,
      String? propertyname,
      int? selectedCategoryid,
      String? address1,
      File? _profileImage,
      String? sLoc, {
        // Property manager parameters
        String? managerName,
        String? managerPhone,
        String? managerEmail,
        String? managerDesignation,
        String? managerExperience,
        File? managerImage,
        // Additional parameters
        String? address2,
        String? state,
        String? city,
        String? pincode,
        String? startTime,
        String? endTime,
      }) async {
    if (_isLoading) return;

    _setLoading(true);

    // Show loading dialog
    _showUpdateLoadingDialog(context);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        Navigator.of(context).pop();
        await _showErrorDialog(
          context,
          'Authentication Error',
          'Please login again to update properties.',
        );
        return;
      }

      // Check if user owns this property
      if (!isUserProperty(propertyId)) {
        Navigator.of(context).pop();
        await _showErrorDialog(
          context,
          'Permission Denied',
          'You don\'t have permission to update this property.',
        );
        return;
      }

      // Use dedicated update endpoint if available, otherwise use the same endpoint with update flag
      Uri url = Uri.parse(Bbapi.updateproperty ?? '${Bbapi.addproperty}/update');
      final request = http.MultipartRequest('POST', url);

      // Add authorization token
      await _addAuthorizationHeader(request);

      // Prepare attributes for update
      Map<String, dynamic> attributes = {
        'propertyId': propertyId,
        'userid': currentUserId,
        'operation': 'update',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Only include fields that are being updated (not null)
      if (propertyname != null && propertyname.trim().isNotEmpty) {
        attributes['propertyName'] = propertyname.trim();
      }

      if (selectedCategoryid != null) {
        attributes['category'] = selectedCategoryid;
      }

      if (address1 != null && address1.trim().isNotEmpty) {
        attributes['address'] = address1.trim();
      }

      if (sLoc != null && sLoc.trim().isNotEmpty) {
        attributes['location'] = sLoc.trim();
      }

      // Additional optional fields
      if (address2 != null && address2.trim().isNotEmpty) {
        attributes['address2'] = address2.trim();
      }

      if (state != null && state.trim().isNotEmpty) {
        attributes['state'] = state.trim();
      }

      if (city != null && city.trim().isNotEmpty) {
        attributes['city'] = city.trim();
      }

      if (pincode != null && pincode.trim().isNotEmpty) {
        attributes['pincode'] = pincode.trim();
      }

      if (startTime != null) {
        attributes['startTime'] = startTime;
      }

      if (endTime != null) {
        attributes['endTime'] = endTime;
      }

      // Property manager details (only if provided)
      if (managerName != null && managerName.trim().isNotEmpty) {
        attributes['manager'] = {
          'name': managerName.trim(),
          'phone': managerPhone?.trim() ?? '',
          'email': managerEmail?.trim() ?? '',
          'designation': managerDesignation?.trim() ?? '',
          'experience': managerExperience?.trim() ?? '',
          'hasImage': managerImage != null,
        };
      }

      request.fields['attributes'] = json.encode(attributes);

      // Add property cover picture if provided
      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'coverpic',
          _profileImage.path,
        ));
      }

      // Add manager image if provided
      if (managerImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'manager_image',
          managerImage.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        // Show success dialog
        await _showUpdateSuccessDialog(context, propertyname ?? 'Property');

        // Show success snackbar
        _showSnackBar(
          context,
          'Property "${propertyname ?? 'Unknown'}" updated successfully!',
          isError: false,
        );

        // Refresh the properties list
        await getproperty();

        // Navigate back
        Navigator.of(context).pop();

      } else {
        final responseData = json.decode(responseBody);
        await _showErrorDialog(
          context,
          'Update Failed',
          _parseErrorMessage(responseData),
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await _showErrorDialog(
        context,
        'Network Error',
        _getErrorMessage(e),
      );
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Quick update method for simple field updates
  Future<void> quickUpdateProperty(
      BuildContext context,
      WidgetRef ref,
      int propertyId,
      Map<String, dynamic> updates,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    // Show simple loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Updating property...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (!isUserProperty(propertyId)) {
        throw Exception('You don\'t have permission to update this property');
      }

      // Use dedicated update endpoint if available
      Uri url = Uri.parse(Bbapi.updateproperty ?? '${Bbapi.addproperty}/update');
      final request = http.MultipartRequest('POST', url);

      // Add authorization
      await _addAuthorizationHeader(request);

      // Prepare minimal attributes for quick update
      Map<String, dynamic> attributes = {
        'propertyId': propertyId,
        'userid': currentUserId,
        ...updates,
        'timestamp': DateTime.now().toIso8601String(),
        'operation': 'quick_update',
      };

      request.fields['attributes'] = json.encode(attributes);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        _showSnackBar(context, 'Property updated successfully!', isError: false);
        await getproperty(); // Refresh data
      } else {
        final responseData = json.decode(responseBody);
        throw Exception(_parseErrorMessage(responseData));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'Update failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // UPDATED: Delete property method to match your PHP API exactly
  // UPDATED: Delete property method to match your PHP API exactly
  Future<void> deleteProperty(BuildContext context, int propertyId) async {
    if (_isLoading) return;

    _setLoading(true);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Deleting property...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user owns this property before attempting delete
      if (!isUserProperty(propertyId)) {
        throw Exception('You don\'t have permission to delete this property');
      }

      // Get authorization token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      String? token;

      if (userData != null) {
        final extractedData = json.decode(userData) as Map<String, dynamic>;
        token = extractedData['data']['access_token'];
      }

      // Make DELETE request with JSON body (exactly matching your PHP API)
      final response = await http.delete(
        Uri.parse(Bbapi.addproperty), // Use your property API endpoint
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'id': propertyId, // Exactly as expected by your PHP API
        }),
      );

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Handle response based on your PHP API structure
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the response indicates success (based on your PHP API format)
        if (responseData['success'] == true) {
          // Remove from local state immediately for better UX
          final updatedProperties = (state.data ?? [])
              .where((prop) => prop.propertyId != propertyId)
              .toList();

          state = state.copyWith(data: updatedProperties);

          // Show success message from API response
          final message = responseData['message'] ?? 'Property deleted successfully!';
          _showSnackBar(context, message, isError: false);
        } else {
          // Handle case where status is 200 but success is false
          final errorMessage = responseData['message'] ?? 'Failed to delete property';
          throw Exception(errorMessage);
        }
      } else if (response.statusCode == 400) {
        // Bad request (invalid property ID)
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Invalid Property ID';
        throw Exception(errorMessage);
      } else if (response.statusCode == 404) {
        // Property not found
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Property not found';
        throw Exception(errorMessage);
      } else if (response.statusCode == 500) {
        // Server error
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'There was an issue with the delete request - please try again';
        throw Exception(errorMessage);
      } else {
        // Unexpected status code
        throw Exception('Unexpected error occurred (Status: ${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'Delete failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }

// Updated delete handler for the ManagePropertyScreen
  Future<void> _handleDeleteProperty(BuildContext context, Data property) async {
    Navigator.pop(context); // Close confirmation dialog

    try {
      // Call the delete method from your notifier
      await ref.read(propertyNotifierProvider.notifier).deleteProperty(
        context,
        property.propertyId!,
      );
    } catch (e) {
      // Error is already handled in the delete method
      print('Delete error: $e');
    }
  }

  Future<void> testDeleteProperty(int propertyId) async {
  try {
  final response = await http.delete(
  Uri.parse(Bbapi.addproperty),
  headers: {
  'Content-Type': 'application/json',
  },
  body: json.encode({
  'id': propertyId,
  }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  final responseData = json.decode(response.body);
  print('Parsed Response: $responseData');

  } catch (e) {
  print('Test Error: $e');
  }
  }
  // UPDATED: Delete hall method to match PHP API pattern

// Enhanced delete hall method
  Future<void> deleteHall(BuildContext context, int hallId, int propertyId) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (!isUserProperty(propertyId)) {
        throw Exception('You don\'t have permission to modify this property');
      }

      // Get authorization token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      String? token;

      if (userData != null) {
        final extractedData = json.decode(userData) as Map<String, dynamic>;
        token = extractedData['data']['access_token'];
      }

      // Use DELETE method for hall
      final response = await http.delete(
        Uri.parse(Bbapi.addhall),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'hall_id': hallId, // Use hall_id instead of just id
          'property_id': propertyId, // Add property_id for validation
        }),
      );

      print('Delete hall response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Refresh properties to update halls list
          await getproperty();

          final message = responseData['message'] ?? 'Hall deleted successfully!';
          _showSnackBar(context, message, isError: false);
        } else {
          final errorMessage = responseData['message'] ?? 'Failed to delete hall';
          throw Exception(errorMessage);
        }
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Delete failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _showSnackBar(context, 'Delete failed: ${e.toString()}', isError: true);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

// Helper method to validate hall data
  Map<String, String> validateHallData({
    required String hallName,
    required int propertyId,
    required List<Map<String, TimeOfDay>> slots,
    List<File>? images,
    bool isUpdate = false,
  }) {
    Map<String, String> errors = {};

    if (hallName.trim().isEmpty) {
      errors['hallName'] = 'Hall name is required';
    }

    if (propertyId <= 0) {
      errors['propertyId'] = 'Valid property ID is required';
    }

    if (slots.isEmpty) {
      errors['slots'] = 'At least one time slot is required';
    }

    // Validate slots don't overlap
    for (int i = 0; i < slots.length; i++) {
      for (int j = i + 1; j < slots.length; j++) {
        final slot1 = slots[i];
        final slot2 = slots[j];

        final checkIn1 = slot1['check_in_time']!;
        final checkOut1 = slot1['check_out_time']!;
        final checkIn2 = slot2['check_in_time']!;
        final checkOut2 = slot2['check_out_time']!;

        // Check for overlap
        if (_timeSlotsOverlap(checkIn1, checkOut1, checkIn2, checkOut2)) {
          errors['slots'] = 'Time slots cannot overlap';
          break;
        }
      }
      if (errors.containsKey('slots')) break;
    }

    // For new halls, require at least one image
    if (!isUpdate && (images == null || images.isEmpty)) {
      errors['images'] = 'At least one image is required';
    }

    return errors;
  }

// Helper method to check if time slots overlap
  bool _timeSlotsOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return !(end1Minutes <= start2Minutes || start1Minutes >= end2Minutes);
  }

  // UPDATED: Enhanced batch delete method for multiple properties
  Future<void> batchDeleteProperties(
      BuildContext context,
      List<int> propertyIds,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Deleting Properties',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6418C3),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6418C3)),
            ),
            const SizedBox(height: 16),
            Text('Deleting ${propertyIds.length} properties...'),
            const SizedBox(height: 8),
            const Text(
              'Please wait, this may take a moment',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user owns all properties
      for (final propertyId in propertyIds) {
        if (!isUserProperty(propertyId)) {
          throw Exception('You don\'t have permission to delete some properties');
        }
      }

      int successCount = 0;
      int failCount = 0;
      List<String> failedProperties = [];

      // Get authorization token once
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('userData');
      String? token;

      if (userData != null) {
        final extractedData = json.decode(userData) as Map<String, dynamic>;
        token = extractedData['data']['access_token'];
      }

      // Delete properties sequentially (to avoid overwhelming the server)
      for (final propertyId in propertyIds) {
        try {
          final response = await http.delete(
            Uri.parse(Bbapi.addproperty),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Token $token',
            },
            body: json.encode({
              'id': propertyId,
            }),
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              successCount++;
            } else {
              failCount++;
              failedProperties.add('Property ID: $propertyId');
            }
          } else {
            failCount++;
            failedProperties.add('Property ID: $propertyId (Status: ${response.statusCode})');
          }

          // Small delay to prevent overwhelming the server
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          failCount++;
          failedProperties.add('Property ID: $propertyId (Error: ${e.toString()})');
        }
      }

      // Close progress dialog
      Navigator.of(context).pop();

      // Update local state - remove successfully deleted properties
      if (successCount > 0) {
        final deletedIds = propertyIds.take(successCount).toList();
        final updatedProperties = (state.data ?? [])
            .where((prop) => !deletedIds.contains(prop.propertyId))
            .toList();

        state = state.copyWith(data: updatedProperties);
      }

      // Show detailed result dialog
      await _showBatchDeleteResultDialog(
        context,
        successCount,
        failCount,
        failedProperties,
      );

    } catch (e) {
      // Close progress dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showSnackBar(context, 'Batch delete failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to show batch delete results
  Future<void> _showBatchDeleteResultDialog(
      BuildContext context,
      int successCount,
      int failCount,
      List<String> failedProperties,
      ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batch Delete Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: failCount > 0 ? Colors.orange : Colors.green,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Successfully deleted: $successCount properties',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (failCount > 0) ...[
                const SizedBox(height: 12),
                // Failure summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Failed to delete: $failCount properties',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (failedProperties.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Failed properties:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ...failedProperties.take(3).map((prop) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            '• $prop',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                        if (failedProperties.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              '• ... and ${failedProperties.length - 3} more',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // NEW: Batch update method
  Future<void> batchUpdateProperties(
      BuildContext context,
      List<int> propertyIds,
      Map<String, dynamic> updates,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user owns all properties
      for (final propertyId in propertyIds) {
        if (!isUserProperty(propertyId)) {
          throw Exception('You don\'t have permission to update some properties');
        }
      }

      Uri url = Uri.parse(Bbapi.updateproperty ?? '${Bbapi.addproperty}/batch-update');
      final request = http.MultipartRequest('POST', url);

      // Add authorization
      await _addAuthorizationHeader(request);

      // Prepare batch update attributes
      Map<String, dynamic> attributes = {
        'propertyIds': propertyIds,
        'updates': updates,
        'userid': currentUserId,
        'operation': 'batch_update',
        'timestamp': DateTime.now().toIso8601String(),
      };

      request.fields['attributes'] = json.encode(attributes);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        await getproperty(); // Refresh data
        _showSnackBar(context, 'Properties updated successfully!', isError: false);
      } else {
        final responseData = json.decode(responseBody);
        throw Exception(_parseErrorMessage(responseData));
      }
    } catch (e) {
      _showSnackBar(context, 'Batch update failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to add authorization header
  Future<void> _addAuthorizationHeader(http.MultipartRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null) {
      final extractedData = json.decode(userData) as Map<String, dynamic>;
      String? token = extractedData['data']['access_token'];
      if (token != null) {
        request.headers['Authorization'] = 'Token $token';
      }
    }
  }

  // Enhanced validation for update
  Map<String, String> validateUpdatePropertyData({
    int? propertyId,
    String? propertyname,
    int? selectedCategoryid,
    String? address1,
    String? sLoc,
    String? managerName,
    String? managerPhone,
    String? managerEmail,
  }) {
    Map<String, String> errors = {};

    if (propertyId == null) {
      errors['propertyId'] = 'Property ID is required for update';
    }

    // For updates, we only validate if fields are provided (not null/empty)
    if (propertyname != null && propertyname.trim().isEmpty) {
      errors['propertyname'] = 'Property name cannot be empty';
    }

    if (address1 != null && address1.trim().isEmpty) {
      errors['address'] = 'Address cannot be empty';
    }

    if (sLoc != null && sLoc.trim().isEmpty) {
      errors['location'] = 'Location cannot be empty';
    }

    // Validate manager details if provided
    if (managerName != null && managerName.trim().isNotEmpty) {
      if (managerPhone != null && managerPhone.trim().isNotEmpty) {
        if (!RegExp(r'^[0-9]{10}$').hasMatch(managerPhone.trim())) {
          errors['managerPhone'] = 'Phone number must be 10 digits';
        }
      }

      if (managerEmail != null && managerEmail.trim().isNotEmpty) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(managerEmail)) {
          errors['managerEmail'] = 'Please enter a valid email address';
        }
      }
    }

    return errors;
  }

  // Rest of your existing methods...
  Future<void> addhallproperty(
      String? propertyname,
      int? properid,
      List<Map<String, TimeOfDay>>? slots,
      List<File>? images,
      Map<String, dynamic> hallDetails,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception("User not authenticated. Please login again.");
      }

      // Check if user owns this property
      if (!isUserProperty(properid!)) {
        throw Exception("You don't have permission to modify this property.");
      }

      // Validation
      if (propertyname == null || propertyname.trim().isEmpty) {
        throw Exception("Property name cannot be null or empty.");
      }
      if (properid == null) {
        throw Exception("Property ID cannot be null.");
      }

      final url = Uri.parse(Bbapi.addhall);
      var request = http.MultipartRequest('POST', url);

      // Add authorization token
      await _addAuthorizationHeader(request);

      // Add images to the request
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(
              await http.MultipartFile.fromPath('images[]', image.path)
          );
        }
      }

      // Format slots for API
      List<Map<String, String>> formattedSlots = slots!.map((slot) {
        return {
          'check_in_time': '${slot['check_in_time']!.hour.toString().padLeft(2, '0')}:${slot['check_in_time']!.minute.toString().padLeft(2, '0')}:00',
          'check_out_time': '${slot['check_out_time']!.hour.toString().padLeft(2, '0')}:${slot['check_out_time']!.minute.toString().padLeft(2, '0')}:00',
        };
      }).toList();

      // Enhanced hall details with proper structure
      Map<String, dynamic> enhancedHallDetails = {
        'property_id': properid,
        'name': propertyname.trim(),
        'vendor_id': currentUserId,
        'operation': 'create',
        'timestamp': DateTime.now().toIso8601String(),
        'slots': formattedSlots,
        'images_count': images?.length ?? 0,

        // Hall attributes
        ...hallDetails,
      };


      request.fields['attributes'] = jsonEncode(enhancedHallDetails);
      print('Sending hall data: ${jsonEncode(enhancedHallDetails)}');
      final response = await request.send();
      final res = await http.Response.fromStream(response);
      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;
      print('Hall creation response: $statusCode - $responseBody');

      if (statusCode == 200 || statusCode == 201) {
        // Refresh properties to show updated hall
        await getproperty();
      } else {
        throw Exception(responseBody['message'] ?? responseBody['messages'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  // Add this method to your AddPropertyNotifier class

  Future<void> updateHall(
      BuildContext context,
      int hallId,
      String hallName,
      int propertyId,
      List<Map<String, TimeOfDay>>? slots,
      List<File>? images,
      Map<String, dynamic> hallDetails,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user owns this property
      if (!isUserProperty(propertyId)) {
        throw Exception('You don\'t have permission to modify this property');
      }

      // Validation
      if (hallName.trim().isEmpty) {
        throw Exception("Hall name cannot be empty.");
      }

      final url = Uri.parse(Bbapi.updatehall);
      var request = http.MultipartRequest('POST', url);

      // Add authorization token
      await _addAuthorizationHeader(request);

      // Add images to the request if provided
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          request.files.add(
              await http.MultipartFile.fromPath('images[]', images[i].path)
          );
        }
      }

      // Format slots for API (only if provided)
      List<Map<String, String>>? formattedSlots;
      if (slots != null && slots.isNotEmpty) {
        formattedSlots = slots.map((slot) {
          return {
            'check_in_time': '${slot['check_in_time']!.hour.toString().padLeft(2, '0')}:${slot['check_in_time']!.minute.toString().padLeft(2, '0')}:00',
            'check_out_time': '${slot['check_out_time']!.hour.toString().padLeft(2, '0')}:${slot['check_out_time']!.minute.toString().padLeft(2, '0')}:00',
          };
        }).toList();
      }

      // Enhanced hall details with update-specific information
      Map<String, dynamic> enhancedHallDetails = {
        'hall_id': hallId, // Essential for update
        'property_id': propertyId,
        'name': hallName.trim(),
        'vendor_id': currentUserId,
        'operation': 'update',
        'timestamp': DateTime.now().toIso8601String(),
        'images_count': images?.length ?? 0,

        // Include formatted slots only if provided
        if (formattedSlots != null) 'slots': formattedSlots,

        // Hall attributes
        ...hallDetails,
      };

      request.fields['attributes'] = jsonEncode(enhancedHallDetails);

      print('Updating hall data: ${jsonEncode(enhancedHallDetails)}');

      final response = await request.send();
      final res = await http.Response.fromStream(response);
      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;

      print('Hall update response: $statusCode - $responseBody');

      if (statusCode == 200) {
        if (responseBody['success'] == true) {
          // Refresh properties to show updated hall
          await getproperty();
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to update hall');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Update failed with status: $statusCode');
      }
    } catch (e) {
      print('Hall update error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

// Add this method for quick hall updates (similar to quickUpdateProperty)
  Future<void> quickUpdateHall(
      BuildContext context,
      int hallId,
      int propertyId,
      Map<String, dynamic> updates,
      ) async {
    if (_isLoading) return;

    _setLoading(true);

    // Show simple loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Updating hall...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final currentUserId = ref.read(authprovider).data?.userId;

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (!isUserProperty(propertyId)) {
        throw Exception('You don\'t have permission to update this hall');
      }

      // Use dedicated update endpoint if available
      Uri url = Uri.parse(Bbapi.updatehall ?? '${Bbapi.addhall}/update');
      final request = http.MultipartRequest('POST', url);

      // Add authorization
      await _addAuthorizationHeader(request);

      // Prepare minimal attributes for quick update
      Map<String, dynamic> attributes = {
        'hall_id': hallId,
        'property_id': propertyId,
        'userid': currentUserId,
        ...updates,
        'timestamp': DateTime.now().toIso8601String(),
        'operation': 'quick_update',
      };

      request.fields['attributes'] = json.encode(attributes);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        if (responseData['success'] == true) {
          _showSnackBar(context, 'Hall updated successfully!', isError: false);
          await getproperty(); // Refresh data
        } else {
          throw Exception(responseData['message'] ?? 'Update failed');
        }
      } else {
        final responseData = json.decode(responseBody);
        throw Exception(_parseErrorMessage(responseData));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'Update failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }
  // Custom loading dialog for update
  void _showUpdateLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6418C3)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Updating Property...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we update your property',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom success dialog for update
  Future<void> _showUpdateSuccessDialog(BuildContext context, String propertyName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Updated Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Property "$propertyName" has been updated successfully',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6418C3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Include all your existing UI helper methods...
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6418C3)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Adding Property...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we process your request',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String propertyName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Property "$propertyName" has been added successfully',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6418C3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(
      BuildContext context,
      String title,
      String message,
      ) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  // UPDATED: Fixed error parsing to match your PHP API response format
  String _parseErrorMessage(Map<String, dynamic> responseData) {
    // Your PHP API returns 'message' (singular), not 'messages' (plural)
    if (responseData['message'] != null) {
      return responseData['message'].toString();
    }

    // Fallback for other APIs that might use 'messages' (plural)
    if (responseData['messages'] != null) {
      if (responseData['messages'] is List) {
        return (responseData['messages'] as List).join(", ");
      } else if (responseData['messages'] is String) {
        return responseData['messages'];
      }
    }

    // Additional fallbacks
    if (responseData['error'] != null) {
      return responseData['error'];
    }

    if (responseData['errors'] != null) {
      if (responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        return errors.values.join(", ");
      } else if (responseData['errors'] is List) {
        return (responseData['errors'] as List).join(", ");
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is http.ClientException) {
      return 'Network error. Please check your connection and try again.';
    } else if (error is FormatException) {
      return 'Invalid server response. Please try again later.';
    } else if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  // Utility method to validate property data before submission
  Map<String, String> validatePropertyData({
    String? propertyname,
    int? selectedCategoryid,
    String? address1,
    File? profileImage,
    String? sLoc,
    String? managerName,
    String? managerPhone,
    String? managerEmail,
  }) {
    Map<String, String> errors = {};

    if (propertyname == null || propertyname.trim().isEmpty) {
      errors['propertyname'] = 'Property name is required';
    }

    if (selectedCategoryid == null) {
      errors['category'] = 'Please select a category';
    }

    if (address1 == null || address1.trim().isEmpty) {
      errors['address'] = 'Property address is required';
    }

    if (profileImage == null) {
      errors['image'] = 'Property image is required';
    }

    if (sLoc == null || sLoc.trim().isEmpty) {
      errors['location'] = 'Location is required';
    }

    if (managerName == null || managerName.trim().isEmpty) {
      errors['managerName'] = 'Manager name is required';
    }

    if (managerPhone == null || managerPhone.trim().isEmpty) {
      errors['managerPhone'] = 'Manager phone is required';
    } else if (managerPhone.length != 10) {
      errors['managerPhone'] = 'Phone number must be 10 digits';
    }

    if (managerEmail == null || managerEmail.trim().isEmpty) {
      errors['managerEmail'] = 'Manager email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(managerEmail)) {
      errors['managerEmail'] = 'Please enter a valid email address';
    }

    return errors;
  }
}

// Updated provider to pass ref
final propertyNotifierProvider =
StateNotifierProvider<AddPropertyNotifier, Property>((ref) {
  return AddPropertyNotifier(ref);
});

// Loading state provider for UI
final propertyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(propertyNotifierProvider.notifier).isLoading;
});

// New provider to get user properties count
final userPropertyCountProvider = Provider<int>((ref) {
  return ref.watch(propertyNotifierProvider.notifier).getUserPropertyCount();
});

// New provider to get properties by category for current user
final userPropertiesByCategoryProvider = Provider.family<List<Data>, int?>((ref, category) {
  return ref.watch(propertyNotifierProvider.notifier).getPropertiesByCategory(category);
});