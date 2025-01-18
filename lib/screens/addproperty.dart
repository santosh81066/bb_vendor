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
import 'Location.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final TextEditingController propertyname = TextEditingController();
  final TextEditingController category = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController address2 = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();

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
  String selectedCategory = ""; // Default selected category

  void _searchLocation(WidgetRef ref) async {
    if (location.text.isEmpty) {
      _showAlertDialog('Error', 'Please enter a location to search.');
      return;
    }

    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(location.text)}&format=json&addressdetails=1&limit=1'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        ref.read(latlangs.notifier).state = LatLng(lat, lon);

        // Move map to the searched location
        _mapController.move(LatLng(lat, lon), 15.0);

        // Update the location field with the display name
        setState(() {
          location.text = data[0]['display_name'];
        });
      } else {
        _showAlertDialog('Error', 'No results found for the entered location.');
      }
    } else {
      _showAlertDialog('Error', 'Failed to fetch location data.');
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
    // final propertyPic = ref.watch(addPropertyProvider).propertyImage;
    final category = ref.watch(categoryProvider);
    String userid = "2";

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
                                  address,
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
                                  suficonColor: CoustColors.colrMainText,
                                  title: "Location",
                                  controller:
                                      location, // This will be updated with the selected location
                                  onChanged: (value) {
                                    ref
                                        .read(textFieldStateProvider.notifier)
                                        .update(9, false);
                                    _searchLocation(
                                        ref); // Optional, if you want to perform further actions
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

                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Action for selecting on map
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RapidoMapPage(), // Replace with your map page
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.location_pin,
                                  color: Colors.blueAccent,
                                ),
                                label: const Text(
                                  "Select on map",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor:
                                      Colors.white, // Background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                    side: const BorderSide(
                                        color:
                                            Colors.blueAccent), // Border color
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10), // Padding
                                ),
                              ),

                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: Consumer(
                                  builder: (BuildContext context, WidgetRef ref,
                                      Widget? child) {
                                    return CoustElevatedButton(
                                      buttonName: "Add Property",
                                      width: double.infinity,
                                      bgColor: CoustColors.colrButton3,
                                      radius: 8,
                                      FontSize: 20,
                                      onPressed: () {
                                        if (_validationKey.currentState!
                                            .validate()) {
                                          var loc =
                                              ref.read(latlangs.notifier).state;

                                          // Ensure location is available
                                          if (loc.latitude == 0.0 &&
                                              loc.longitude == 0.0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Invalid location. Please select a valid location.")),
                                            );
                                            return;
                                          }

                                          String sLoc =
                                              '${loc.latitude.toStringAsFixed(7)},${loc.longitude.toStringAsFixed(7)}';

                                          if (_profileImage == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Please select a profile image.")),
                                            );
                                            return;
                                          }

                                          ref
                                              .read(propertyNotifierProvider
                                                  .notifier)
                                              .addProperty(
                                                context,
                                                ref,
                                                address.text.trim(),
                                                sLoc,
                                                userid,
                                                propertyname.text.trim(),
                                                selectedCategory,
                                                _profileImage, // New field
                                              );

                                          // Show a loading indicator (optional)
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text("Adding property...")),
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
