import 'package:bb_vendor/providers/addpropertynotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PropertyHallScreen extends ConsumerStatefulWidget {
  const PropertyHallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PropertyHallScreen> createState() => PropertyHallScreenState();
}

class PropertyHallScreenState extends ConsumerState<PropertyHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _propertyNameController = TextEditingController();
  final List<File> _images = [];
  final List<Map<String, TimeOfDay>> _slots = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

// @override
// void didChangeDependencies() {
//   super.didChangeDependencies();

//   if (args == null || args['propertyname'] == null || args['propertyid'] == null) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid or missing arguments.')),
//       );
//       Navigator.of(context).pop();
//     });
//     return;
//   }

//   setState(() {

//     _propertyNameController.text = args['hallName']??"";
//   });
// }

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

      // Safeguard against null values
      if (existingCheckIn == null || existingCheckOut == null) continue;

      // Check if the new slot overlaps with an existing slot
      if (!(checkOut.hour < existingCheckIn.hour ||
          (checkOut.hour == existingCheckIn.hour &&
              checkOut.minute <= existingCheckIn.minute) ||
          checkIn.hour > existingCheckOut.hour ||
          (checkIn.hour == existingCheckOut.hour &&
              checkIn.minute >= existingCheckOut.minute))) {
        return false;
      }
    }

    // Ensure the slot is within the daily boundary (12:00 AM to 11:59 PM)
    if (checkIn.hour < 0 ||
        checkOut.hour > 23 ||
        (checkOut.hour == 23 && checkOut.minute > 59)) {
      return false;
    }

    return true;
  }

  Future<void> _addSlot() async {
    TimeOfDay? checkInTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    if (checkInTime == null) return;

    TimeOfDay? checkOutTime = await showTimePicker(
      context: context,
      initialTime: checkInTime,
    );

    if (checkOutTime == null) return;

    // Validate the slot
    if (checkOutTime.hour < checkInTime.hour ||
        (checkOutTime.hour == checkInTime.hour &&
            checkOutTime.minute <= checkInTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-out time must be later than check-in time.'),
        ),
      );
      return;
    }

    if (!_isSlotAvailable(checkInTime, checkOutTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The selected slot overlaps with an existing slot.'),
        ),
      );
      return;
    }

    setState(() {
      _slots
          .add({'check_in_time': checkInTime, 'check_out_time': checkOutTime});
    });
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String propertyname = args!['propertyname'];
    int properid = args!['propertyid'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add halls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                SizedBox(
                  height: 150,
                  child: _images.isEmpty
                      ? const Center(child: Text('No images selected'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _images[index],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6418c3),
                  ),
                  child: const Text('Add Image',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Slots',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _slots.length,
                  itemBuilder: (context, index) {
                    final slot = _slots[index];
                    return ListTile(
                      title: Text(
                          'Check-in: ${_formatTime(slot['check_in_time']!)}, Check-out: ${_formatTime(slot['check_out_time']!)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _slots.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addSlot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6418c3),
                  ),
                  child: const Text('Add Slot',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    //  onPressed: (){
                    //   print("Property Name: ${_propertyNameController.text.trim()}");
                    //     print("Property ID: $properid");
                    //     print("Slots: $_slots");
                    //     print("Images Count: ${_images.length}");

                    //  },
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState == null ||
                                !_formKey.currentState!.validate()) {
                              print("current state is null");
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              if (_slots.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please add at least one slot.'),
                                  ),
                                );
                                return;
                              }

                              try {
                                setState(() => isLoading = true);

                                await ref
                                    .read(propertyNotifierProvider.notifier)
                                    .addhallproperty(
                                      _propertyNameController.text.trim(),
                                      properid,
                                      _slots,
                                      _images,
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hall added successfully!'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                  ),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xff6418c3),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
