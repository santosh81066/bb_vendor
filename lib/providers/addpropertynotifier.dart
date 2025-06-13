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

        // Additional metadata
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0', // Indicate this is the enhanced version
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

  // Rest of your existing methods remain the same...
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
          request.files.add(
              await http.MultipartFile.fromPath('images[]', image.path)
          );
        }
      }

      // Enhanced hall details with timestamp and validation
      Map<String, dynamic> enhancedHallDetails = {
        ...hallDetails,
        'timestamp': DateTime.now().toIso8601String(),
        'propertyId': properid,
        'propertyName': propertyname.trim(),
        'slotsCount': slots?.length ?? 0,
        'imagesCount': images?.length ?? 0,
        'vendorId': currentUserId, // Add vendor ID for additional validation
      };

      request.fields['attributes'] = jsonEncode(enhancedHallDetails);

      final response = await request.send();
      final res = await http.Response.fromStream(response);
      var responseBody = json.decode(res.body);
      var statusCode = res.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        // Refresh properties to show updated hall
        await getproperty();
      } else {
        throw Exception(responseBody['messages'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
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

  String _parseErrorMessage(Map<String, dynamic> responseData) {
    if (responseData['messages'] != null) {
      if (responseData['messages'] is List) {
        return (responseData['messages'] as List).join(", ");
      } else if (responseData['messages'] is String) {
        return responseData['messages'];
      }
    }

    if (responseData['message'] != null) {
      return responseData['message'];
    }

    if (responseData['error'] != null) {
      return responseData['error'];
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