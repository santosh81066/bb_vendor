import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/Providers/textfieldstatenotifier.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import "package:bb_vendor/providers/categoryprovider.dart";
import 'package:geocoding/geocoding.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final TextEditingController propertyname = TextEditingController();
  final TextEditingController category = TextEditingController();
  final TextEditingController address1 = TextEditingController();
  final TextEditingController address2 = TextEditingController();
  final TextEditingController location = TextEditingController();

  Timer? _debounceTimer;
  bool _isMapDragging = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(latlangs) == const LatLng(0, 0)) {
        ref.read(latlangs.notifier).state = const LatLng(28.6139, 77.2090);
        _mapController.move(const LatLng(28.6139, 77.2090), 10.0);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _fetchCategories() {
    ref.read(categoryProvider.notifier).getCategory();
  }

  final _validationKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  String selectedCategory = "";
  int? selectedCategoryid;

  List<LocationSuggestion> _locationSuggestions = [];
  bool _showSuggestions = false;
  Timer? _searchDebounceTimer;

  void _searchLocation(WidgetRef ref) async {
    _searchDebounceTimer?.cancel();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (location.text.length < 2) {
        setState(() {
          _locationSuggestions = [];
          _showSuggestions = false;
        });
        return;
      }

      try {
        final response = await http
            .get(Uri.parse('https://nominatim.openstreetmap.org/search?'
            'q=${location.text}'
            '&countrycodes=in'
            '&format=json'
            '&addressdetails=1'
            '&limit=5'));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data.isNotEmpty) {
            List<LocationSuggestion> suggestions =
            List<LocationSuggestion>.from(
                data.map((item) => LocationSuggestion.fromJson(item)));

            setState(() {
              _locationSuggestions = suggestions;
              _showSuggestions = true;
            });
          } else {
            setState(() {
              _locationSuggestions = [];
              _showSuggestions = true;
            });
          }
        }
      } catch (e) {
        print('Error searching for location: $e');
        setState(() {
          _locationSuggestions = [];
          _showSuggestions = false;
        });
      }
    });
  }

  void _selectLocation(LocationSuggestion suggestion) {
    setState(() {
      location.text = suggestion.displayName;
      _showSuggestions = false;

      LatLng newLocation = LatLng(suggestion.lat, suggestion.lon);
      ref.read(latlangs.notifier).state = newLocation;
      _mapController.move(newLocation, 15.0);
    });
  }

  void _updateLocationWithDebounce(LatLng center) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      try {
        final response = await http
            .get(Uri.parse('https://nominatim.openstreetmap.org/reverse?'
            'lat=${center.latitude}&lon=${center.longitude}'
            '&format=json'
            '&addressdetails=1'
            '&countrycodes=in'
        ));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data != null && data['display_name'] != null) {
            String address = data['display_name'];

            if (location.text != address && mounted) {
              setState(() {
                location.text = address;
                _showSuggestions = false;
              });
            }
            return;
          }
        }

        List<Placemark> placemarks = await placemarkFromCoordinates(
          center.latitude,
          center.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          final placemark = placemarks.first;

          if (placemark.country?.toLowerCase() != 'india') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Location outside India. Please select a location in India.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            return;
          }

          final address =
              '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}';

          if (location.text != address && mounted) {
            setState(() {
              location.text = address;
              _showSuggestions = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            location.text = "Unable to fetch address";
            _showSuggestions = false;
          });
        }
      }
    });
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        final fileSizeInBytes = await imageFile.length();
        final maxFileSize = 2 * 1024 * 1024;

        if (fileSizeInBytes > maxFileSize) {
          _showAlertDialog('Error', 'File size exceeds 2MB. Please select a smaller file.');
        } else {
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to pick image: $e');
    }
  }

  Widget _buildImageUploadSection() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Property Image",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showImageSourceDialog(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: _profileImage != null
                    ? null
                    : const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _profileImage != null
                    ? Stack(
                  children: [
                    Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _showImageSourceDialog(),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Add Property Image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap to upload from gallery or camera",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Image Source",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.gallery);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF667eea)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add New Property',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4A5568),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: 16, color: Color(0xFF667eea)),
                SizedBox(width: 4),
                Text(
                  "Help",
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _validationKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.home_work,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "List Your Property",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fill in the details below to add your property to our platform",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Image Upload Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildImageUploadSection(),
              ),

              const SizedBox(height: 24),

              // Property Details Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      final textFieldStates = ref.watch(textFieldStateProvider);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Property Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildEnhancedTextField(
                            "Property Name",
                            propertyname,
                            "Please enter property name",
                            ref,
                            0,
                            textFieldStates,
                            Icons.home,
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Category Selection
                          _buildCategorySection(category),

                          const SizedBox(height: 20),

                          _buildEnhancedTextField(
                            "Property Address",
                            address1,
                            "Please enter property address",
                            ref,
                            2,
                            textFieldStates,
                            Icons.location_on,
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Location Section
                          _buildLocationSection(ref, textFieldStates),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validationKey.currentState!.validate()) {
                      var loc = ref.read(latlangs.notifier).state;
                      String sLoc = '${loc.latitude.toStringAsFixed(7)},${loc.longitude.toStringAsFixed(7)}';
                      ref.read(propertyNotifierProvider.notifier).addProperty(
                        context,
                        ref,
                        propertyname.text.trim(),
                        selectedCategoryid,
                        address1.text.trim(),
                        _profileImage,
                        sLoc,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_business, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "List Property",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField(
      String labelText,
      TextEditingController controller,
      String validationText,
      WidgetRef ref,
      int index,
      List<bool> textFieldStates,
      IconData icon,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: (value) {
            ref.read(textFieldStateProvider.notifier).update(index, false);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationText;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Enter $labelText",
            prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(AsyncValue category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Property Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: category.when(
            data: (categoryData) {
              if (categoryData.data == null || categoryData.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No categories available"),
                );
              }

              return Column(
                children: categoryData.data!.map<Widget>((data) {
                  final isSelected = selectedCategory == (data.name ?? "");
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        data.name ?? "",
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF667eea) : const Color(0xFF2D3748),
                        ),
                      ),
                      value: data.name ?? "",
                      groupValue: selectedCategory,
                      activeColor: const Color(0xFF667eea),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryid = data.id;
                          selectedCategory = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text('Failed to load categories: $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(WidgetRef ref, List<bool> textFieldStates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Location",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),

        // Location Search Field
        TextFormField(
          controller: location,
          onChanged: (value) {
            ref.read(textFieldStateProvider.notifier).update(9, false);
            _searchLocation(ref);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter location or point on map";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Search for location",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
            suffixIcon: const Icon(Icons.my_location, color: Color(0xFF667eea)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),

        // Location Suggestions
        if (_showSuggestions && _locationSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _locationSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _locationSuggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF667eea), size: 20),
                  title: Text(
                    suggestion.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _selectLocation(suggestion),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // Enhanced Map Section
        const Text(
          "Pin Location on Map",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ref.watch(latlangs),
                initialZoom: 15.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(6.0, 68.0),
                    const LatLng(37.0, 98.0),
                  ),
                ),
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveStart) {
                    setState(() {
                      _isMapDragging = true;
                      _showSuggestions = false;
                    });
                  } else if (event is MapEventMoveEnd) {
                    setState(() {
                      _isMapDragging = false;
                    });

                    final center = _mapController.camera.center;
                    ref.read(latlangs.notifier).state = center;
                    _updateLocationWithDebounce(center);
                  }
                },
                onPositionChanged: (position, hasGesture) {
                  final center = position.center!;
                  ref.read(latlangs.notifier).state = center;

                  if (!_isMapDragging) {
                    _updateLocationWithDebounce(center);
                  }
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.bb_vendor',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ref.watch(latlangs),
                      width: 60.0,
                      height: 60.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF667eea)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Drag the map to adjust the pin location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (title == 'Error') {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF667eea),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}