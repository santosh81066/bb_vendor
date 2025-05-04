import 'dart:async'; // Add this import
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

  // Add timer for debouncing
  Timer? _debounceTimer;
  bool _isMapDragging = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    // Initialize with a default location in India (Delhi)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(latlangs) == const LatLng(0, 0)) {
        ref.read(latlangs.notifier).state =
            const LatLng(28.6139, 77.2090); // Delhi
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

  String selectedCategory = ""; // Default selected category
  int? selectedCategoryid;

  // Define a class to represent a location suggestion

// Store location suggestions
  List<LocationSuggestion> _locationSuggestions = [];
  bool _showSuggestions = false;
  Timer? _searchDebounceTimer;

  void _searchLocation(WidgetRef ref) async {
    // Cancel any previous timer
    _searchDebounceTimer?.cancel();

    // Start a new timer that will trigger after 500ms to avoid excessive API calls
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
                '&countrycodes=in' // Restrict to India
                '&format=json'
                '&addressdetails=1'
                '&limit=5'));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data.isNotEmpty) {
            // Convert response to LocationSuggestion objects
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

      // Update the map location
      LatLng newLocation = LatLng(suggestion.lat, suggestion.lon);
      ref.read(latlangs.notifier).state = newLocation;
      _mapController.move(newLocation, 15.0);
    });
  }

  // Function to update location with debounce
  void _updateLocationWithDebounce(LatLng center) {
    // Cancel any previous timer
    _debounceTimer?.cancel();

    // Start a new timer that will trigger after 800ms of inactivity
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      try {
        // First try to get a reverse geocoded address from Nominatim (more detailed for India)
        final response = await http
            .get(Uri.parse('https://nominatim.openstreetmap.org/reverse?'
                'lat=${center.latitude}&lon=${center.longitude}'
                '&format=json'
                '&addressdetails=1'
                '&countrycodes=in' // Restrict to India
                ));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data != null && data['display_name'] != null) {
            String address = data['display_name'];

            // Only update if the text is different
            if (location.text != address && mounted) {
              setState(() {
                location.text = address;
                _showSuggestions = false;
              });
            }
            return;
          }
        }

        // Fallback to local geocoding package if Nominatim fails
        List<Placemark> placemarks = await placemarkFromCoordinates(
          center.latitude,
          center.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          final placemark = placemarks.first;

          // Check if the country is India, if not, ignore this result
          if (placemark.country?.toLowerCase() != 'india') {
            // If outside India, we could set bounds or show message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Location outside India. Please select a location in India.')));
            }
            return;
          }

          final address =
              '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}';

          // Only update if the text is different to avoid unnecessary rebuilds
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

        // Check the file size (maximum 2MB)
        final fileSizeInBytes = await imageFile.length();
        final maxFileSize = 2 * 1024 * 1024; // 2MB in bytes

        if (fileSizeInBytes > maxFileSize) {
          // File size is too large, show an error
          _showAlertDialog(
              'Error', 'File size exceeds 2MB. Please select a smaller file.');
        } else {
          // Valid image size, proceed
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to pick image: $e');
    }
  }

  Widget _buildImageUploadSection(String label) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () => _pickImage(context, ImageSource.gallery),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: CoustColors.colrButton1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: _profileImage != null
                ? Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt, size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      coustText(
                        sName: "Upload Profile Image",
                        txtcolor: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final propertyPic = ref.watch(addPropertyProvider).propertyImage;
    final category = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        backgroundColor: CoustColors.colrFill,
        title: const coustText(
          sName: 'Add Properties',
          txtcolor: CoustColors.colrEdtxt2,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: CoustColors.colrHighlightedText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CoustColors.colrMainbg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const coustText(
                      sName: "Property_pic",
                      textsize: 24,
                      fontweight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        color: CoustColors.colrButton1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildImageUploadSection(
                              "Property Image",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final textFieldStates = ref.watch(textFieldStateProvider);
                  return Form(
                    key: _validationKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CoustColors.colrMainbg,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: coustText(
                                  sName: "Property Details",
                                  textsize: 24,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                  "Property Name",
                                  propertyname,
                                  "Please Enter Property Name",
                                  ref,
                                  0,
                                  textFieldStates),
                              const SizedBox(height: 15),

                              // Category selection using radio buttons
                              Container(
                                decoration: BoxDecoration(
                                  color: CoustColors.colrMainbg,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    // Watch the provider for AsyncValue<Category>
                                    final categoryState =
                                        ref.watch(categoryProvider);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: coustText(
                                            sName: "Category",
                                            textsize: 18,
                                            fontweight: FontWeight.bold,
                                          ),
                                        ),
                                        categoryState.when(
                                          data: (category) {
                                            // Check if data is null or empty
                                            if (category.data == null ||
                                                category.data!.isEmpty) {
                                              return const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                    "No categories available"),
                                              );
                                            }

                                            return Column(
                                              children:
                                                  category.data!.map((data) {
                                                return RadioListTile<String>(
                                                  title: Text(data.name ?? ""),
                                                  value: data.name ?? "",
                                                  groupValue: selectedCategory,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedCategoryid =
                                                          data.id;
                                                      selectedCategory = value!;
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            );
                                          },
                                          loading: () => const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          error: (error, stack) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                  'Failed to load categories: $error'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 10),
                              _buildTextField(
                                  "Property Address",
                                  address1,
                                  "Please Enter Address 1",
                                  ref,
                                  2,
                                  textFieldStates),

                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CoustTextfield(
                                      filled: textFieldStates[9],
                                      radius: 8.0,
                                      width: 10,
                                      isVisible: true,
                                      iconwidget:
                                          const Icon(Icons.location_searching),
                                      suficonColor: CoustColors.colrMainText,
                                      title: "Location",
                                      controller: location,
                                      onChanged: (location) {
                                        ref
                                            .read(
                                                textFieldStateProvider.notifier)
                                            .update(9, false);
                                        _searchLocation(ref);
                                      },
                                      validator: (txtController) {
                                        if (txtController == null ||
                                            txtController.isEmpty) {
                                          return "Enter location or point in maps";
                                        }
                                        return null;
                                      },
                                    ),
                                    // Location suggestions dropdown
                                    if (_showSuggestions &&
                                        _locationSuggestions.isNotEmpty)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        width: double.infinity,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _locationSuggestions.length,
                                          itemBuilder: (context, index) {
                                            final suggestion =
                                                _locationSuggestions[index];
                                            return ListTile(
                                              title: Text(
                                                suggestion.displayName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              onTap: () {
                                                _selectLocation(suggestion);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    if (_showSuggestions &&
                                        _locationSuggestions.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        width: double.infinity,
                                        child: const Text(
                                          "No locations found. Try a different search term.",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      // Initial center is in India (Delhi)
                                      center: ref.watch(latlangs),
                                      zoom: 15.0,
                                      // Restrict to India bounds (approximate)
                                      maxBounds: LatLngBounds(
                                        LatLng(6.0, 68.0), // SW corner of India
                                        LatLng(
                                            37.0, 98.0), // NE corner of India
                                      ),
                                      onMapEvent: (MapEvent event) {
                                        // Track when dragging starts and stops
                                        if (event is MapEventMoveStart) {
                                          setState(() {
                                            _isMapDragging = true;
                                            // Hide suggestions when map is being dragged
                                            _showSuggestions = false;
                                          });
                                        } else if (event is MapEventMoveEnd) {
                                          setState(() {
                                            _isMapDragging = false;
                                          });

                                          // Update the location when user stops dragging
                                          final center = _mapController.center;
                                          ref.read(latlangs.notifier).state =
                                              center;
                                          _updateLocationWithDebounce(center);
                                        }
                                      },
                                      onPositionChanged:
                                          (position, hasGesture) {
                                        // Only update the provider state but not geocode right away
                                        final center = position.center!;
                                        ref.read(latlangs.notifier).state =
                                            center;

                                        // Only update location when user is not actively dragging
                                        if (!_isMapDragging) {
                                          _updateLocationWithDebounce(center);
                                        }
                                      },
                                      // Add interactive flags for better user control
                                      interactiveFlags: InteractiveFlag.all,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        subdomains: const ['a', 'b', 'c'],
                                        userAgentPackageName:
                                            'com.example.bb_vendor',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: ref.watch(latlangs),
                                            width: 80.0,
                                            height: 80.0,
                                            builder: (BuildContext context) {
                                              return const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 40.0,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Consumer(
                                  builder: (BuildContext context, WidgetRef ref,
                                      Widget? child) {
                                    return CoustElevatedButton(
                                      buttonName: "Register",
                                      width: double.infinity,
                                      bgColor: CoustColors.colrButton3,
                                      radius: 8,
                                      FontSize: 20,
                                      onPressed: () {
                                        if (_validationKey.currentState!
                                            .validate()) {
                                          var loc = (ref
                                              .read(latlangs.notifier)
                                              .state);
                                          String sLoc =
                                              '${loc.latitude.toStringAsFixed(7)},${loc.longitude.toStringAsFixed(7)}';
                                          ref
                                              .read(propertyNotifierProvider
                                                  .notifier)
                                              .addProperty(
                                                context,
                                                ref,
                                                propertyname.text.trim(),
                                                selectedCategoryid,
                                                address1.text.trim(),

                                                _profileImage, // New field
                                                sLoc,
                                              );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelText,
    TextEditingController controller,
    String validationText,
    WidgetRef ref,
    int index,
    List<bool> textFieldStates,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CoustTextfield(
        filled: textFieldStates[index],
        radius: 8.0,
        width: 10,
        isVisible: true,
        hint: labelText,
        title: labelText,
        controller: controller,
        onChanged: (value) {
          ref.read(textFieldStateProvider.notifier).update(index, false);
        },
        validator: (txtController) {
          if (txtController == null || txtController.isEmpty) {
            return validationText;
          }
        },
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (title == 'Error') {
                Navigator.of(context).pop();
              }
            },
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

  LocationSuggestion(
      {required this.displayName, required this.lat, required this.lon});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
