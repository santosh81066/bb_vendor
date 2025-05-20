import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/addpropertynotifier.dart';
import '../providers/categoryprovider.dart';

class PropertyHallScreen extends ConsumerStatefulWidget {
  const PropertyHallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PropertyHallScreen> createState() => PropertyHallScreenState();
}

class PropertyHallScreenState extends ConsumerState<PropertyHallScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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
  @override
  void initState() {
    super.initState();
    _cleaningCostController.addListener(_onCostChanged);
    _securityCostController.addListener(_onCostChanged);
    _setupCostController.addListener(_onCostChanged);
    _additionalServicesCostController.addListener(_onCostChanged);
  }


  @override
  void dispose() {
    // Remove listeners
    _cleaningCostController.removeListener(_onCostChanged);
    _securityCostController.removeListener(_onCostChanged);
    _setupCostController.removeListener(_onCostChanged);
    _additionalServicesCostController.removeListener(_onCostChanged);

    _cleaningCostController.dispose();
    _securityCostController.dispose();
    _setupCostController.dispose();
    _additionalServicesCostController.dispose();

    super.dispose();
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
    );
    if (checkInTime == null) return;
    TimeOfDay? checkOutTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: checkInTime.hour + 4, minute: checkInTime.minute),
    );
    if (checkOutTime == null) return;
    if (checkOutTime.hour < checkInTime.hour ||
        (checkOutTime.hour == checkInTime.hour && checkOutTime.minute <= checkInTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out time must be later than check-in time.')),
      );
      return;
    }
    if (!_isSlotAvailable(checkInTime, checkOutTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The selected slot overlaps with an existing slot.')),
      );
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

  Widget _buildInfoItem(String title, String value, {Color checkColor = Colors.pink}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: checkColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title - ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  TextSpan(text: value, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoCard() {
    final categoryState = ref.watch(categoryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Hall Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

      Container(
        height: 170, // Explicit height for the container
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: _images.isEmpty
            ? Center(
          child: Text(
            'No images added yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        )
            :ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_images[index], width: 150, height: 150, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.red, size: 16),
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
              child: ElevatedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6418c3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // optional rounding
                  ),
                ),
              ),
            ),

            const Text(
              'Property Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                hintText: propertyname ?? 'no name',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hall Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _propertyNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter property name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Property name cannot be empty.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Other Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allow Outside Decorators'),
              value: _outsideDecoratorsAllowed,
              onChanged: (val) {
                setState(() {
                  _outsideDecoratorsAllowed = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Allow Outside DJ'),
              value: _outsideDJAllowed,
              onChanged: (val) {
                setState(() {
                  _outsideDJAllowed = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Allow Outside Food'),
              value: _outsideFoodAllowed,
              onChanged: (val) {
                setState(() {
                  _outsideFoodAllowed = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Allow Alcohol'),
              value: _outsideAlcoholAllowed,
              onChanged: (val) {
                setState(() {
                  _outsideAlcoholAllowed = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Valet Parking Available'),
              value: _valetParking,
              onChanged: (val) {
                setState(() {
                  _valetParking = val;
                });
              },
              activeColor: Colors.green,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Allowed Food Type'),
                DropdownButton<String>(
                  value: _allowedCuisine,
                  onChanged: (newValue) {
                    setState(() {
                      _allowedCuisine = newValue!;
                    });
                  },
                  items: ['Veg', 'Non-Veg', 'Both']
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                ),
              ],
            ),
          ],

        ),
      ),
    );
  }
  Widget _buildEventAreaCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Area Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${_priceController.text.isEmpty ? '0' : _priceController.text}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _parkingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Parking Capacity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_parking),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floatingCapacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Floating Capacity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLogisticsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [

              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Access Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Emergency Exits Available'),
                  value: _emergencyExitsAvailable,
                  onChanged: (val) {
                    setState(() {
                      _emergencyExitsAvailable = val;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Power Backup Type'),
                    DropdownButton<String>(
                      value: _powerBackupType,
                      onChanged: (newValue) {
                        setState(() {
                          _powerBackupType = newValue!;
                        });
                      },
                      items: ['None', 'UPS', 'Generator', 'Both UPS & Generator']
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStaffingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Staffing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _staffCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Staff Count',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cleaningStaffController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cleaning Staff',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cleaning_services),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSecurityCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Security Level'),
                DropdownButton<String>(
                  value: _securityLevel,
                  onChanged: (newValue) {
                    setState(() {
                      _securityLevel = newValue!;
                    });
                  },
                  items: ['Basic', 'Standard', 'Premium', 'High Alert']
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _securityCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Security Personnel Count',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('CCTV Available'),
              value: _cctvAvailable,
              onChanged: (val) {
                setState(() {
                  _cctvAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Fire Alarm System'),
              value: _fireAlarmAvailable,
              onChanged: (val) {
                setState(() {
                  _fireAlarmAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTechnicalArrangementsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technical Arrangements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sound System Available'),
              value: _soundSystemAvailable,
              onChanged: (val) {
                setState(() {
                  _soundSystemAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
            _soundSystemAvailable ? Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _audioSystemController,
                    decoration: const InputDecoration(
                      labelText: 'Sound System Details',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speaker),
                      hintText: 'e.g., JBL 5.1 surround sound, etc.',
                    ),
                  ),
                ),
              ],
            ) : Container(),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Sound System Available'),
              value: _lightingSystemAvailable,
              onChanged: (val) {
                setState(() {
                  _lightingSystemAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
            _lightingSystemAvailable ?
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lightingSystemController,
                    decoration: const InputDecoration(
                      labelText: 'Lighting System Details',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lightbulb),
                      hintText: 'e.g., RGB lights, mood lighting, etc.',
                    ),
                  ),
                ),
              ],
            ):
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('WiFi Available'),
              value: _wifiAvailable,
              onChanged: (val) {
                setState(() {
                  _wifiAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Projector Available'),
              value: _projectorAvailable,
              onChanged: (val) {
                setState(() {
                  _projectorAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Microphone Available'),
              value: _microphoneAvailable,
              onChanged: (val) {
                setState(() {
                  _microphoneAvailable = val;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAdditionalCostsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Costs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Cleaning Cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cleaningCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cleaning Cost (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cleaning_services),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Security Cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _securityCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Security Cost (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Setup/Decoration Cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setupCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Setup/Decoration Cost (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_paint),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Services Cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _additionalServicesCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Additional Services Cost (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.miscellaneous_services),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Cost Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Additional Cost:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final total = _calculateTotalAdditionalCost();
                      return Text(
                        '₹ $total',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    propertyname = args?['propertyname'] ?? "Property";
    int propertyid = args?['propertyid'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add Hall'),
        backgroundColor: const Color(0xff6418c3),
        foregroundColor: Colors.white,
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
                Center(child: const Text('Select your Time Slots', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _slots.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      return ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xff6418c3)),
                        title: Text(
                          'Check-in: ${_formatTime(slot['check_in_time']!)}, Check-out: ${_formatTime(slot['check_out_time']!)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _slots.removeAt(index)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('Add Time Slot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6418c3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // optional rounding
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      if (_slots.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one time slot.')));
                        return;
                      }
                      if (_images.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image.')));
                        return;
                      }
                      if (_capacityController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter hall capacity.')));
                        return;
                      }
                      if (_priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter price.')));
                        return;
                      }

                      try {
                        setState(() => isLoading = true);

                        // Format time slots in the required API format
                        List<Map<String, String>> formattedSlots = _slots.map((slot) {
                          return {
                            'check_in_time': '${slot['check_in_time']!.hour.toString().padLeft(2, '0')}:${slot['check_in_time']!.minute.toString().padLeft(2, '0')}:00',
                            'check_out_time': '${slot['check_out_time']!.hour.toString().padLeft(2, '0')}:${slot['check_out_time']!.minute.toString().padLeft(2, '0')}:00',
                          };
                        }).toList();

                        // Convert boolean values to integers for API
                        final int allowOutsideDecorators = _outsideDecoratorsAllowed ? 1 : 0;
                        final int allowOutsideDj = _outsideDJAllowed ? 1 : 0;
                        final int outsideFood = _outsideFoodAllowed ? 1 : 0;
                        final int allowAlcohol = _outsideAlcoholAllowed ? 1 : 0;
                        final int valetParking = _valetParking ? 1 : 0;
                        final int cctv = _cctvAvailable ? 1 : 0;
                        final int fireAlarm = _fireAlarmAvailable ? 1 : 0;
                        final int soundSystem = _soundSystemAvailable ? 1 : 0;
                        final int wifiAvailable = _wifiAvailable ? 1 : 0;
                        final int projectorAvailable = _projectorAvailable ? 1 : 0;
                        final int microphoneAvailable = _microphoneAvailable ? 1 : 0;

                        // Convert food type to lowercase to match API format
                        String foodType = _allowedCuisine.toLowerCase();
                        if (foodType == "both") {
                          foodType = "veg"; // Default to veg if both are selected, change as needed
                        }

                        // Match security level with API format
                        String securityLevel = _securityLevel.toLowerCase();

                        // Map all attributes according to the API schema
                        final Map<String, dynamic> hallDetails = {
                          'property_id': propertyid,
                          'name': _propertyNameController.text.trim(),
                          'allow_outside_decorators': allowOutsideDecorators,
                          'allow_outside_dj': allowOutsideDj,
                          'outside_food': outsideFood,
                          'allow_alcohol': allowAlcohol,
                          'valet_parking': valetParking,
                          'foodtype': foodType,
                          'capacity': int.tryParse(_capacityController.text) ?? 0,
                          'parking_capacity': int.tryParse(_parkingController.text) ?? 0,
                          'floating_capacity': int.tryParse(_floatingCapacityController.text) ?? 0,
                          'price': double.tryParse(_priceController.text) ?? 0,
                          'emergency_exits': _emergencyExitsAvailable ? 1 : 0,
                          'staff_count': int.tryParse(_staffCountController.text) ?? 0,
                          'cleaning_staff': int.tryParse(_cleaningStaffController.text) ?? 0,
                          'security_level': securityLevel,
                          'security_count': int.tryParse(_securityCountController.text) ?? 0,
                          'cctv': cctv,
                          'fire_alarm': fireAlarm,
                          'sound_system': soundSystem,
                          'sound_system_details': _audioSystemController.text,
                          'lighting_system_details': _lightingSystemController.text,
                          'wifi_available': wifiAvailable,
                          'projector_available': projectorAvailable,
                          'microphone_available': microphoneAvailable,
                          'cleaning_cost': double.tryParse(_cleaningCostController.text) ?? 0,
                          'security_cost': double.tryParse(_securityCostController.text) ?? 0,
                          'decor_cost': double.tryParse(_setupCostController.text) ?? 0, // Map setup cost to decor_cost
                          'additional_services_cost': double.tryParse(_additionalServicesCostController.text) ?? 0,
                          'slots': formattedSlots,
                        };

                        await ref.read(propertyNotifierProvider.notifier).addhallproperty(
                          _propertyNameController.text.trim(),
                          propertyid,
                          _slots,
                          _images,
                          hallDetails,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hall added successfully!'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xff6418c3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}