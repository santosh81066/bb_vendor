import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bb_vendor/Colors/coustcolors.dart';

import '../providers/addpropertynotifier.dart';
import '../models/get_properties_model.dart';

class PropertyHallScreen extends ConsumerStatefulWidget {
  const PropertyHallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PropertyHallScreen> createState() => PropertyHallScreenState();
}

class PropertyHallScreenState extends ConsumerState<PropertyHallScreen> {

  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _parkingController = TextEditingController();
  final _floatingCapacityController = TextEditingController();
  final _priceController = TextEditingController();

  final _setupTimeController = TextEditingController();
  final _cleanupTimeController = TextEditingController();

  final _staffCountController = TextEditingController();
  final _securityCountController = TextEditingController();
  final _cleaningStaffController = TextEditingController();

  final _audioSystemController = TextEditingController();
  final _lightingSystemController = TextEditingController();

  final _cleaningCostController = TextEditingController();
  final _securityCostController = TextEditingController();
  final _setupCostController = TextEditingController();
  final _additionalServicesCostController = TextEditingController();

  final List<File> _images = [];
  final List<Map<String, TimeOfDay>> _slots = [];
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  // Edit mode variables
  bool isEditMode = false;
  Hall? editingHall;
  List<Hall>? allHallSlots;

  // Attributes
  String propertyname = 'propertyname';

  bool _outsideDecoratorsAllowed = true;
  bool _outsideDJAllowed = true;
  bool _outsideFoodAllowed = true;
  bool _outsideAlcoholAllowed = true;
  bool _valetParking = true;
  String _allowedCuisine = 'Both';
  String _securityLevel = 'Standard';
  bool _cctvAvailable = true;
  bool _emergencyExitsAvailable = true;
  bool _fireAlarmAvailable = true;
  String _powerBackupType = 'Generator';
  bool _soundSystemAvailable = true;
  bool _lightingSystemAvailable = true;

  bool _wifiAvailable = true;
  bool _projectorAvailable = false;
  bool _microphoneAvailable = true;

  @override
  void initState() {
    super.initState();
    _cleaningCostController.addListener(_onCostChanged);
    _securityCostController.addListener(_onCostChanged);
    _setupCostController.addListener(_onCostChanged);
    _additionalServicesCostController.addListener(_onCostChanged);

    // Initialize edit mode after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditMode();
    });
  }

  @override
  void dispose() {
    // Remove listeners
    _cleaningCostController.removeListener(_onCostChanged);
    _securityCostController.removeListener(_onCostChanged);
    _setupCostController.removeListener(_onCostChanged);
    _additionalServicesCostController.removeListener(_onCostChanged);

    // Dispose all controllers
    _propertyNameController.dispose();
    _capacityController.dispose();
    _parkingController.dispose();
    _floatingCapacityController.dispose();
    _priceController.dispose();
    _setupTimeController.dispose();
    _cleanupTimeController.dispose();
    _staffCountController.dispose();
    _securityCountController.dispose();
    _cleaningStaffController.dispose();
    _audioSystemController.dispose();
    _lightingSystemController.dispose();
    _cleaningCostController.dispose();
    _securityCostController.dispose();
    _setupCostController.dispose();
    _additionalServicesCostController.dispose();

    super.dispose();
  }

  void _initializeEditMode() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      propertyname = args['propertyname'] ?? "Property";
      isEditMode = args['isEditing'] ?? false;

      if (isEditMode) {
        editingHall = args['hallData'] as Hall?;
        allHallSlots = args['allHallSlots'] as List<Hall>?;

        if (editingHall != null) {
          _populateFormWithHallData();
        }
      }
    }
  }

  void _populateFormWithHallData() {
    if (editingHall == null) return;

    setState(() {
      // Basic hall info
      _propertyNameController.text = editingHall!.name ?? '';
      _capacityController.text = editingHall!.capacity?.toString() ?? '';
      _parkingController.text = editingHall!.parkingCapacity?.toString() ?? '';
      _floatingCapacityController.text = editingHall!.floatingCapacity?.toString() ?? '';
      _priceController.text = editingHall!.price?.toString() ?? '';

      // Staff info
      _staffCountController.text = editingHall!.staffCount?.toString() ?? '';
      _cleaningStaffController.text = editingHall!.cleaningStaff?.toString() ?? '';
      _securityCountController.text = editingHall!.securityCount?.toString() ?? '';

      // Technical details
      _audioSystemController.text = editingHall!.soundSystemDetails ?? '';
      _lightingSystemController.text = editingHall!.lightingSystemDetails ?? '';

      // Costs
      _cleaningCostController.text = editingHall!.cleaningCost?.toString() ?? '';
      _securityCostController.text = editingHall!.securityCost?.toString() ?? '';
      _setupCostController.text = editingHall!.decorCost?.toString() ?? '';
      _additionalServicesCostController.text = editingHall!.additionalServicesCost?.toString() ?? '';

      // Boolean attributes - Fix: Handle both bool and int types
      _outsideDecoratorsAllowed = _getBoolValue(editingHall!.allowOutsideDecorators);
      _outsideDJAllowed = _getBoolValue(editingHall!.allowOutsideDj);
      _outsideFoodAllowed = _getBoolValue(editingHall!.outsideFood);
      _outsideAlcoholAllowed = _getBoolValue(editingHall!.allowAlcohol);
      _valetParking = _getBoolValue(editingHall!.valetParking);
      _cctvAvailable = _getBoolValue(editingHall!.cctv);
      _fireAlarmAvailable = _getBoolValue(editingHall!.fireAlarm);
      _soundSystemAvailable = _getBoolValue(editingHall!.soundSystem);
      _emergencyExitsAvailable = (editingHall!.emergencyExits == 1);
      _wifiAvailable = _getBoolValue(editingHall!.wifiAvailable);
      _projectorAvailable = _getBoolValue(editingHall!.projectorAvailable);
      _microphoneAvailable = _getBoolValue(editingHall!.microphoneAvailable);

      // String attributes
      _allowedCuisine = _mapFoodType(editingHall!.foodtype);
      _securityLevel = _mapSecurityLevel(editingHall!.securityLevel);

      // Load existing slots
      _loadExistingSlots();
    });
  }

  // Helper method to handle both bool and int types
  bool _getBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  String _mapFoodType(String? foodtype) {
    switch (foodtype?.toLowerCase()) {
      case 'veg':
        return 'Veg';
      case 'non-veg':
        return 'Non-Veg';
      default:
        return 'Both';
    }
  }

  String _mapSecurityLevel(String? securityLevel) {
    switch (securityLevel?.toLowerCase()) {
      case 'basic':
        return 'Basic';
      case 'standard':
        return 'Standard';
      case 'premium':
        return 'Premium';
      case 'high alert':
        return 'High Alert';
      default:
        return 'Standard';
    }
  }

  void _loadExistingSlots() {
    if (allHallSlots == null) return;

    _slots.clear();

    for (var hall in allHallSlots!) {
      if (hall.slots != null) {
        for (var slot in hall.slots!) {
          if (slot.slotFromTime != null && slot.slotToTime != null) {
            final checkInTime = _parseTimeString(slot.slotFromTime!);
            final checkOutTime = _parseTimeString(slot.slotToTime!);

            if (checkInTime != null && checkOutTime != null) {
              _slots.add({
                'check_in_time': checkInTime,
                'check_out_time': checkOutTime,
              });
            }
          }
        }
      }
    }
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      // Handle format "HH:mm:ss" or "HH:mm"
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('Error parsing time: $timeString - $e');
    }
    return null;
  }

  void _onCostChanged() {
    setState(() {});  // Triggers rebuild to update total
  }

  void _addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  bool _isSlotAvailable(TimeOfDay checkIn, TimeOfDay checkOut) {
    for (var slot in _slots) {
      final existingCheckIn = slot['check_in_time'];
      final existingCheckOut = slot['check_out_time'];
      if (existingCheckIn == null || existingCheckOut == null) continue;
      if (!(checkOut.hour < existingCheckIn.hour ||
          (checkOut.hour == existingCheckIn.hour && checkOut.minute <= existingCheckIn.minute) ||
          checkIn.hour > existingCheckOut.hour ||
          (checkIn.hour == existingCheckOut.hour && checkIn.minute >= existingCheckOut.minute))) {
        return false;
      }
    }
    if (checkIn.hour < 0 || checkOut.hour > 23 || (checkOut.hour == 23 && checkOut.minute > 59)) {
      return false;
    }
    return true;
  }

  Future<void> _addSlot() async {
    TimeOfDay? checkInTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CoustColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: CoustColors.darkPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (checkInTime == null) return;

    TimeOfDay? checkOutTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: checkInTime.hour + 4, minute: checkInTime.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CoustColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: CoustColors.darkPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (checkOutTime == null) return;

    if (checkOutTime.hour < checkInTime.hour ||
        (checkOutTime.hour == checkInTime.hour && checkOutTime.minute <= checkInTime.minute)) {
      _showErrorSnackBar('Check-out time must be later than check-in time.');
      return;
    }

    if (!_isSlotAvailable(checkInTime, checkOutTime)) {
      _showErrorSnackBar('The selected slot overlaps with an existing slot.');
      return;
    }

    setState(() {
      _slots.add({'check_in_time': checkInTime, 'check_out_time': checkOutTime});
    });
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  String _calculateTotalAdditionalCost() {
    final cleaning = double.tryParse(_cleaningCostController.text) ?? 0;
    final security = double.tryParse(_securityCostController.text) ?? 0;
    final setup = double.tryParse(_setupCostController.text) ?? 0;
    final additional = double.tryParse(_additionalServicesCostController.text) ?? 0;
    return (cleaning + security + setup + additional).toStringAsFixed(2);
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields correctly.');
      return false;
    }

    if (_slots.isEmpty) {
      _showErrorSnackBar('Please add at least one time slot.');
      return false;
    }

    // Only require images for new halls, not when editing
    if (!isEditMode && _images.isEmpty) {
      _showErrorSnackBar('Please add at least one image.');
      return false;
    }

    if (_capacityController.text.isEmpty) {
      _showErrorSnackBar('Please enter hall capacity.');
      return false;
    }

    if (_priceController.text.isEmpty) {
      _showErrorSnackBar('Please enter price.');
      return false;
    }

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      _showErrorSnackBar('Please enter a valid capacity.');
      return false;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showErrorSnackBar('Please enter a valid price.');
      return false;
    }

    return true;
  }

  // Fixed: Add the missing _handleSubmit method
  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    int propertyid = args?['propertyid'] ?? 0;

    if (propertyid == 0) {
      _showErrorSnackBar('Invalid property ID.');
      return;
    }

    try {
      setState(() => isLoading = true);

      // Convert boolean values to integers for API
      final Map<String, dynamic> hallDetails = {
        'property_id': propertyid,
        'name': _propertyNameController.text.trim(),
        'allow_outside_decorators': _outsideDecoratorsAllowed ? 1 : 0,
        'allow_outside_dj': _outsideDJAllowed ? 1 : 0,
        'outside_food': _outsideFoodAllowed ? 1 : 0,
        'allow_alcohol': _outsideAlcoholAllowed ? 1 : 0,
        'valet_parking': _valetParking ? 1 : 0,
        'foodtype': _allowedCuisine.toLowerCase() == 'both' ? 'veg' : _allowedCuisine.toLowerCase(),
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'parking_capacity': int.tryParse(_parkingController.text) ?? 0,
        'floating_capacity': int.tryParse(_floatingCapacityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0,
        'emergency_exits': _emergencyExitsAvailable ? 1 : 0,
        'staff_count': int.tryParse(_staffCountController.text) ?? 0,
        'cleaning_staff': int.tryParse(_cleaningStaffController.text) ?? 0,
        'security_level': _securityLevel.toLowerCase(),
        'security_count': int.tryParse(_securityCountController.text) ?? 0,
        'cctv': _cctvAvailable ? 1 : 0,
        'fire_alarm': _fireAlarmAvailable ? 1 : 0,
        'sound_system': _soundSystemAvailable ? 1 : 0,
        'sound_system_details': _audioSystemController.text.trim(),
        'lighting_system_details': _lightingSystemController.text.trim(),
        'wifi_available': _wifiAvailable ? 1 : 0,
        'projector_available': _projectorAvailable ? 1 : 0,
        'microphone_available': _microphoneAvailable ? 1 : 0,
        'cleaning_cost': double.tryParse(_cleaningCostController.text) ?? 0,
        'security_cost': double.tryParse(_securityCostController.text) ?? 0,
        'decor_cost': double.tryParse(_setupCostController.text) ?? 0,
        'additional_services_cost': double.tryParse(_additionalServicesCostController.text) ?? 0,
      };

      if (isEditMode && editingHall?.hallId != null) {
        // Call update method
        await ref.read(propertyNotifierProvider.notifier).updateHall(
          context,
          editingHall!.hallId!,
          _propertyNameController.text.trim(),
          propertyid,
          _slots.isNotEmpty ? _slots : null,
          _images.isNotEmpty ? _images : null,
          hallDetails,
        );

        _showSuccessSnackBar('Hall updated successfully!');
      } else {
        // Call create method
        await ref.read(propertyNotifierProvider.notifier).addhallproperty(
          _propertyNameController.text.trim(),
          propertyid,
          _slots,
          _images,
          hallDetails,
        );

        _showSuccessSnackBar('Hall added successfully!');
      }

      // Navigate back to previous screen
      Navigator.pop(context);

    } catch (e) {
      print('Hall submission error: $e');
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fixed: Add the missing _showErrorSnackBar method
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: CoustColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Fixed: Add the missing _showSuccessSnackBar method
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: CoustColors.emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPropertyInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                isEditMode ? 'Update Hall Images' : 'Hall Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CoustColors.darkPurple,
                ),
              ),
            ),
            Container(
              height: 170,
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              child: _images.isEmpty
                  ? Center(
                child: Text(
                  isEditMode ? 'No new images added' : 'No images added yet',
                  style: TextStyle(
                    color: CoustColors.darkPurple.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _images[index],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              icon: Icon(
                                Icons.close_rounded,
                                color: CoustColors.rose,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _images.removeAt(index)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CoustColors.primaryPurple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
                  label: Text(
                    isEditMode ? 'Add More Images' : 'Add Image',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoustColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            if (isEditMode) ...[
              const SizedBox(height: 12),
              Text(
                'Note: Adding new images will be in addition to existing ones',
                style: TextStyle(
                  fontSize: 12,
                  color: CoustColors.darkPurple.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Property Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.primaryPurple, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: propertyname ?? 'no name',
                hintStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: CoustColors.veryLightPurple.withOpacity(0.3),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Hall Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _propertyNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.primaryPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CoustColors.rose),
                ),
                hintText: isEditMode ? 'Update hall name' : 'Enter hall name',
                hintStyle: TextStyle(color: CoustColors.darkPurple.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hall name cannot be empty.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Other Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile('Allow Outside Decorators', _outsideDecoratorsAllowed, (val) {
              setState(() {
                _outsideDecoratorsAllowed = val;
              });
            }),
            _buildSwitchTile('Allow Outside DJ', _outsideDJAllowed, (val) {
              setState(() {
                _outsideDJAllowed = val;
              });
            }),
            _buildSwitchTile('Allow Outside Food', _outsideFoodAllowed, (val) {
              setState(() {
                _outsideFoodAllowed = val;
              });
            }),
            _buildSwitchTile('Allow Alcohol', _outsideAlcoholAllowed, (val) {
              setState(() {
                _outsideAlcoholAllowed = val;
              });
            }),
            _buildSwitchTile('Valet Parking Available', _valetParking, (val) {
              setState(() {
                _valetParking = val;
              });
            }),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allowed Food Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CoustColors.veryLightPurple,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _allowedCuisine,
                    onChanged: (newValue) {
                      setState(() {
                        _allowedCuisine = newValue!;
                      });
                    },
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    items: ['Veg', 'Non-Veg', 'Both']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: CoustColors.darkPurple),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CoustColors.veryLightPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoustColors.lightPurple.withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: CoustColors.darkPurple,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: CoustColors.primaryPurple,
        activeTrackColor: CoustColors.lightPurple.withOpacity(0.3),
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildEventAreaCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Area Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CoustColors.darkPurple,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CoustColors.primaryPurple, CoustColors.accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${_priceController.text.isEmpty ? '0' : _priceController.text}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _capacityController,
              label: 'Capacity',
              icon: Icons.people_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _parkingController,
              label: 'Parking Capacity',
              icon: Icons.local_parking_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _floatingCapacityController,
              label: 'Floating Capacity',
              icon: Icons.people_outline_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _priceController,
              label: 'Price (₹)',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: CoustColors.primaryPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CoustColors.lightPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CoustColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CoustColors.rose),
        ),
        labelStyle: TextStyle(color: CoustColors.darkPurple.withOpacity(0.7)),
        hintStyle: TextStyle(color: CoustColors.darkPurple.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Access Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile('Emergency Exits Available', _emergencyExitsAvailable, (val) {
              setState(() {
                _emergencyExitsAvailable = val;
              });
            }),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power Backup Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CoustColors.veryLightPurple,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _powerBackupType,
                    onChanged: (newValue) {
                      setState(() {
                        _powerBackupType = newValue!;
                      });
                    },
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    items: ['None', 'UPS', 'Generator', 'Both UPS & Generator']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: CoustColors.darkPurple),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staffing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _staffCountController,
              label: 'Staff Count',
              icon: Icons.people_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cleaningStaffController,
              label: 'Cleaning Staff',
              icon: Icons.cleaning_services_rounded,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoustColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CoustColors.veryLightPurple,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _securityLevel,
                    onChanged: (newValue) {
                      setState(() {
                        _securityLevel = newValue!;
                      });
                    },
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    items: ['Basic', 'Standard', 'Premium', 'High Alert']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: CoustColors.darkPurple),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _securityCountController,
              label: 'Security Personnel Count',
              icon: Icons.security_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile('CCTV Available', _cctvAvailable, (val) {
              setState(() {
                _cctvAvailable = val;
              });
            }),
            _buildSwitchTile('Fire Alarm System', _fireAlarmAvailable, (val) {
              setState(() {
                _fireAlarmAvailable = val;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalArrangementsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Arrangements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            _buildSwitchTile('Sound System Available', _soundSystemAvailable, (val) {
              setState(() {
                _soundSystemAvailable = val;
              });
            }),
            if (_soundSystemAvailable) ...[
              const SizedBox(height: 12),
              _buildTextField(
                controller: _audioSystemController,
                label: 'Sound System Details',
                icon: Icons.speaker_rounded,
                hintText: 'e.g., JBL 5.1 surround sound, etc.',
              ),
            ],
            const SizedBox(height: 12),
            _buildSwitchTile('Lighting System Available', _lightingSystemAvailable, (val) {
              setState(() {
                _lightingSystemAvailable = val;
              });
            }),
            if (_lightingSystemAvailable) ...[
              const SizedBox(height: 12),
              _buildTextField(
                controller: _lightingSystemController,
                label: 'Lighting System Details',
                icon: Icons.lightbulb_rounded,
                hintText: 'e.g., RGB lights, mood lighting, etc.',
              ),
            ],
            const SizedBox(height: 16),
            _buildSwitchTile('WiFi Available', _wifiAvailable, (val) {
              setState(() {
                _wifiAvailable = val;
              });
            }),
            _buildSwitchTile('Projector Available', _projectorAvailable, (val) {
              setState(() {
                _projectorAvailable = val;
              });
            }),
            _buildSwitchTile('Microphone Available', _microphoneAvailable, (val) {
              setState(() {
                _microphoneAvailable = val;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalCostsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Costs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cleaningCostController,
              label: 'Cleaning Cost (₹)',
              icon: Icons.cleaning_services_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _securityCostController,
              label: 'Security Cost (₹)',
              icon: Icons.security_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _setupCostController,
              label: 'Setup/Decoration Cost (₹)',
              icon: Icons.format_paint_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _additionalServicesCostController,
              label: 'Additional Services Cost (₹)',
              icon: Icons.miscellaneous_services_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CoustColors.veryLightPurple,
                    CoustColors.lightPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Additional Cost:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CoustColors.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final total = _calculateTotalAdditionalCost();
                      return Text(
                        '₹ $total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CoustColors.primaryPurple,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      children: [
        Center(
            child: Text(
              isEditMode ? 'Update Time Slots' : 'Select your Time Slots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoustColors.darkPurple,
              ),
            )
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: _slots.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 48,
                    color: CoustColors.darkPurple.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No time slots added yet',
                    style: TextStyle(
                      color: CoustColors.darkPurple.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _slots.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: CoustColors.lightPurple.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final slot = _slots[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CoustColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: CoustColors.primaryPurple,
                  ),
                ),
                title: Text(
                  'Slot ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CoustColors.darkPurple,
                  ),
                ),
                subtitle: Text(
                  'Check-in: ${_formatTime(slot['check_in_time']!)}, Check-out: ${_formatTime(slot['check_out_time']!)}',
                  style: TextStyle(
                    color: CoustColors.darkPurple.withOpacity(0.7),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: CoustColors.rose.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_rounded, color: CoustColors.rose),
                    onPressed: () => setState(() => _slots.removeAt(index)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CoustColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _addSlot,
              icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
              label: const Text(
                'Add Time Slot',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CoustColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    propertyname = args?['propertyname'] ?? "Property";
    int propertyid = args?['propertyid'] ?? 0;

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Hall' : 'Add Hall',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CoustColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CoustColors.gradientStart,
                CoustColors.gradientMiddle,
                CoustColors.gradientEnd,
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyInfoCard(),
                _buildLogisticsCard(),
                _buildEventAreaCard(),
                _buildStaffingCard(),
                _buildSecurityCard(),
                _buildTechnicalArrangementsCard(),
                _buildAdditionalCostsCard(),
                const SizedBox(height: 16),
                _buildTimeSlotsSection(),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CoustColors.primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: CoustColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                    )
                        : Text(
                        isEditMode ? 'Update Hall' : 'Submit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}