import 'dart:convert';
import 'dart:io';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Models/addpropertymodel.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/Providers/textfieldstatenotifier.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:bb_vendor/Providers/addpropertynotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import "package:bb_vendor/providers/categoryprovider.dart";

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

  final addPropertyProvider =
      StateNotifierProvider<AddPropertyNotifier, PropertyModel>(
    (ref) => AddPropertyNotifier(),
  );
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
        _showAlertDialog('Error', 'File size exceeds 2MB. Please select a smaller file.');
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
    final propertyPic = ref.watch(addPropertyProvider).propertyImage;
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
                                  final categoryState = ref.watch(categoryProvider);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          if (category.data == null || category.data!.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("No categories available"),
                                            );
                                          }

                                          return Column(
                                            children: category.data!.map((data) {
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
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        error: (error, stack) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text('Failed to load categories: $error'),
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
                                      initialCenter: ref.watch(latlangs),
                                      initialZoom: 15.0,
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
                                            child: Container(
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 40.0,
                                              ),
                                            ),
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
                                              .read(
                                                  addPropertyProvider.notifier)
                                              .addProperty(
                                                context,
                                                ref,
                                                propertyname.text.trim(),
                                                selectedCategory,
                                                address1.text.trim(),
                                                address2.text.trim(),
                                                sLoc,
                                                state.text.trim(),
                                                city.text.trim(),
                                                pincode.text.trim(),
                                                endTime.text.trim(),
                                                startTime.text.trim(),
                                                propertyPic, // New field
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








// const SizedBox(height: 10),
                              // _buildTextField(
                              //     "Property Address line 2",
                              //     address2,
                              //     "Please Enter Address 2",
                              //     ref,
                              //     3,
                              //     textFieldStates),
                              // const SizedBox(height: 10),
                              // _buildTextField(
                              //     "State",
                              //     state,
                              //     "Please Enter State",
                              //     ref,
                              //     4,
                              //     textFieldStates),
                              // const SizedBox(height: 10),
                              // _buildTextField("City", city, "Please Enter City",
                              //     ref, 5, textFieldStates),
                              // const SizedBox(height: 10),
                              // _buildTextField(
                              //     "Pincode",
                              //     pincode,
                              //     "Please Enter Pin Number",
                              //     ref,
                              //     6,
                              //     textFieldStates),
                              // const SizedBox(height: 10),
                              // _buildTextField(
                              //     "start time",
                              //     startTime,
                              //     "Please Enter Start Time",
                              //     ref,
                              //     7,
                              //     textFieldStates),
                              // _buildTextField(
                              //     "End time",
                              //     endTime,
                              //     "Please Enter End Time",
                              //     ref,
                              //     7,
                              //     textFieldStates),
                              // const SizedBox(height: 10),
                              // const Padding(
                              //   padding: EdgeInsets.only(left: 8.0),
                              //   child: coustText(
                              //     sName: "Location",
                              //   ),
                              // ),







// import 'dart:convert';
// import 'dart:io';
// import 'package:banquetbookz_vendor/Colors/coustcolors.dart';
// import 'package:banquetbookz_vendor/Models/addpropertymodel.dart';
// import 'package:banquetbookz_vendor/Providers/stateproviders.dart';
// import 'package:banquetbookz_vendor/Providers/textfieldstatenotifier.dart';
// import 'package:banquetbookz_vendor/Widgets/elevatedbutton.dart';
// import 'package:banquetbookz_vendor/Widgets/text.dart';
// import 'package:banquetbookz_vendor/Widgets/textfield.dart';
// import 'package:banquetbookz_vendor/Providers/addpropertynotifier.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class AddPropertyScreen extends ConsumerStatefulWidget {
//   const AddPropertyScreen({super.key});

//   @override
//   _AddPropertyScreenState createState() => _AddPropertyScreenState();
// }

// class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
//   final TextEditingController propertyname = TextEditingController();
//   final TextEditingController category = TextEditingController();
//   final TextEditingController address1 = TextEditingController();
//   final TextEditingController address2 = TextEditingController();
//   final TextEditingController state = TextEditingController();
//   final TextEditingController city = TextEditingController();
//   final TextEditingController pincode = TextEditingController();
//   final TextEditingController location = TextEditingController();
//   final TextEditingController startTime = TextEditingController();
//   final TextEditingController endTime = TextEditingController();
//   final GlobalKey<FormState> _validationKey = GlobalKey<FormState>();
//     final addPropertyProvider =
//       StateNotifierProvider<AddPropertyNotifier, PropertyModel>(
//     (ref) => AddPropertyNotifier(),
//   );

//   final MapController _mapController = MapController();
//   final ImagePicker _picker = ImagePicker();
//   XFile? _propertyImage;

//   @override
//   Widget build(BuildContext context) {
//     final textFieldStates = ref.watch(textFieldStateProvider);
//     return Scaffold(
//       appBar: AppBar(
//         title: coustText(
//           sName: "Add Property",
//           txtcolor: Colors.white,
//           textsize: 20,
//         ),
//         backgroundColor: CoustColors.colrButton2,
//       ),
//       body: Form(
//         key: _validationKey,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//               children: [
//                 _buildTextField(
//                   "Property Name",
//                   propertyname,
//                   "Please enter property name",
//                   ref,
//                   0,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Category",
//                   category,
//                   "Please enter category",
//                   ref,
//                   1,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Address 1",
//                   address1,
//                   "Please enter address 1",
//                   ref,
//                   2,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Address 2",
//                   address2,
//                   "Please enter address 2",
//                   ref,
//                   3,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "State",
//                   state,
//                   "Please enter state",
//                   ref,
//                   4,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "City",
//                   city,
//                   "Please enter city",
//                   ref,
//                   5,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Pincode",
//                   pincode,
//                   "Please enter pincode",
//                   ref,
//                   6,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Location",
//                   location,
//                   "Please enter location",
//                   ref,
//                   7,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "Start Time",
//                   startTime,
//                   "Please enter start time",
//                   ref,
//                   8,
//                   textFieldStates,
//                 ),
//                 _buildTextField(
//                   "End Time",
//                   endTime,
//                   "Please enter end time",
//                   ref,
//                   9,
//                   textFieldStates,
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final pickedFile = await _picker.pickImage(
//                       source: ImageSource.gallery,
//                     );
//                     setState(() {
//                       _propertyImage = pickedFile;
//                     });
//                   },
//                   child: Text("Pick Property Image"),
//                 ),
//                 SizedBox(height: 15),
//                 _propertyImage != null
//                     ? Image.file(File(_propertyImage!.path))
//                     : Text("No image selected"),
//                 SizedBox(height: 15),
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: LatLng(51.5, -0.09),
//                     initialZoom: 13.0,
//                   ),
//                   layers: [
//                     TileLayerOptions(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayerOptions(
//                       markers: [
//                         Marker(
//                           width: 80.0,
//                           height: 80.0,
//                           point: LatLng(51.5, -0.09),
//                           builder: (ctx) => Container(
//                             child: Icon(
//                               Icons.location_on,
//                               color: Colors.red,
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15),
//                 CoustElevatedButton(
//                   buttonName: "Add Property",
//                   onPressed: () async {
//                     if (_validationKey.currentState!.validate()) {
//                       // Handle form submission
//                       final property = PropertyModel(
//                         propertyName: propertyname.text,
//                         category: category.text,
//                         address1: address1.text,
//                         address2: address2.text,
//                         state: state.text,
//                         city: city.text,
//                         pincode: pincode.text,
//                         location: location.text,
//                         startTime: startTime.text,
//                         endTime: endTime.text,
//                       propertyImage:,
//                       );

//                       final success = await ref
//                           .read(addPropertyProvider.notifier)
//                           .addProperty(property);

//                       if (success) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("Property added successfully!"),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("Failed to add property."),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String labelText,
//     TextEditingController controller,
//     String validationText,
//     WidgetRef ref,
//     int index,
//     List<bool> textFieldStates,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: CoustTextfield(
//         filled: textFieldStates[index],
//         radius: 8.0,
//         width: 10,
//         isVisible: true,
//         hint: labelText,
//         title: labelText,
//         controller: controller,
//         onChanged: (value) {
//           ref.read(textFieldStateProvider.notifier).update(index, false);
//         },
//         validator: (txtController) {
//           if (txtController == null || txtController.isEmpty) {
//             return validationText;
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }



  // Widget _buildImageUploadSection(
  //     String label, File? imageFile, bool isProfile) {
  //   return Padding(
  //     padding: const EdgeInsets.all(0.0),
  //     child: InkWell(
  //       onTap: () => _pickImage(context, ImageSource.gallery, isProfile),
  //       child: Container(
  //         width: double.infinity,
  //         height: 110,
  //         color: CoustColors.colrButton1,
  //         child: Center(
  //           child: imageFile == null
  //               ? coustText(sName: "Upload photo", align: TextAlign.center)
  //               : Image.file(imageFile),
  //         ),
  //       ),
  //     ),
  //   );
  // }



  
  // Future<void> _pickImage(
  //     BuildContext context, ImageSource source, bool isProfile) async {
  //   final pickedFile = await _picker.pickImage(source: source);

  //   if (pickedFile != null) {
  //     {
  //       ref
  //           .read(addPropertyProvider.notifier)
  //           .setPropertyImage(File(pickedFile.path));
  //     }
  //   }
  // }