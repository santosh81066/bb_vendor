import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/Providers/textfieldstatenotifier.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import "package:bb_vendor/providers/categoryprovider.dart";

import '../providers/property_provider.dart';

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
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();

  // final addPropertyProvider =
  //     StateNotifierProvider<AddPropertyNotifier, Property>(
  //   (ref) => AddPropertyNotifier(),
  // );
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() {
    ref.read(categoryProvider.notifier).getCategory();
  }

  final _validationKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  // Static category list for now

  // final List<String> categoryList = ["Residential", "Commercial", "Industrial", "Agricultural"];
  String selectedCategory = ""; // Default selected category

  void _searchLocation(WidgetRef ref) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${location.text}&format=json&addressdetails=1&limit=1'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        ref.read(latlangs.notifier).state = LatLng(lat, lon);

        _mapController.move(ref.watch(latlangs), 15.0);
      }
    }
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
                                child: CoustTextfield(
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
                                        .read(textFieldStateProvider.notifier)
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
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      center: ref.watch(latlangs),
                                      zoom: 15.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            width: 80.0,
                                            height: 80.0,
                                            point: (ref.watch(latlangs)),
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
                                  builder: (context, ref, child) {
                                    final propertyState =
                                        ref.watch(addPropertyProvider);

                                    return ElevatedButton(
                                      onPressed: propertyState ==
                                              PropertyState.loading
                                          ? null
                                          : () async {
                                              final attributes = {
                                                'address': address1.text,
                                                'location': location.text,
                                                'userId':
                                                    '66', // Use dynamic values here if required
                                                'propertyName':
                                                    propertyname.text,
                                                'category': selectedCategory,
                                              };

                                              await ref
                                                  .read(addPropertyProvider
                                                      .notifier)
                                                  .addProperty(
                                                      attributes: attributes,
                                                      coverpic: _profileImage);

                                              if (ref
                                                      .read(addPropertyProvider
                                                          .notifier)
                                                      .state ==
                                                  PropertyState.success) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Property added successfully')),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Failed to add property')),
                                                );
                                              }
                                            },
                                      child: propertyState ==
                                              PropertyState.loading
                                          ? const CircularProgressIndicator()
                                          : const Text('Submit Property'),
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
