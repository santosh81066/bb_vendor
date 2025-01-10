import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PropertyHallScreen extends StatefulWidget {
  const PropertyHallScreen({Key? key}) : super(key: key);

  @override
  _PropertyHallScreenState createState() => _PropertyHallScreenState();
}

class _PropertyHallScreenState extends State<PropertyHallScreen> {
  final TextEditingController _propertyNameController = TextEditingController();
  final List<File> _images = [];
  final List<Map<String, String>> _slots = [];
  final ImagePicker _picker = ImagePicker();

  void _addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _addSlot(String checkInTime, String checkOutTime) {
    setState(() {
      _slots.add({'check_in': checkInTime, 'check_out': checkOutTime});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add halls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
       
        child: SingleChildScrollView(
           
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Property Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _propertyNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter property name',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Hall',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: _images.isEmpty
                    ? const Center(child: Text('No images selected'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    icon: const Icon(Icons.close, color: Colors.red),
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
                    backgroundColor:Color(0xff6418c3),
                  ),
                child: const Text('Add Image', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Slots',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  return ListTile(
                    title: Text('Check-in: ${slot['check_in']}, Check-out: ${slot['check_out']}'),
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
                onPressed: () async {
                  final checkInController = TextEditingController();
                  final checkOutController = TextEditingController();

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add Slot'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: checkInController,
                              decoration: const InputDecoration(
                                labelText: 'Check-in Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: checkOutController,
                              decoration: const InputDecoration(
                                labelText: 'Check-out Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addSlot(
                                checkInController.text,
                                checkOutController.text,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Add')
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:Color(0xff6418c3),
                  ),
                child: const Text('Add Slot', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission logic here
                    print('Property Name: ${_propertyNameController.text}');
                    print('Images: ${_images.length}');
                    print('Slots: $_slots');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),backgroundColor: Color(0xff6418c3),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
