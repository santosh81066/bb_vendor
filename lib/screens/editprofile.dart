import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/textfieldstatenotifier.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:bb_vendor/providers/auth.dart';
import 'package:bb_vendor/utils/bbapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditprofileSceren extends ConsumerStatefulWidget{
  const EditprofileSceren({super.key});

  @override
  ConsumerState<EditprofileSceren> createState() => _EditprofileScerenState();
}

class _EditprofileScerenState extends ConsumerState<EditprofileSceren> {
  
  final TextEditingController name = TextEditingController();
  final TextEditingController emailid = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final _validationkey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  
  
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Fetch user data from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userNotifier = ref.read(authprovider);
      final currentUser = userNotifier.data;

      if (currentUser != null) {
        name.text = currentUser.username ?? '';
        emailid.text = currentUser.email ?? '';
        mobile.text = currentUser.mobileNo ?? '';
        setState(() {
          // Profile image URL initialization (if needed)
          // _profileImage = File.fromUri(Uri.parse(currentUser.profilePic ?? ''));
        });
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



Widget _buildImageUploadSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showImageSourceDialog(context),
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
                    : Consumer(
                        builder: (context, ref, child) {
                          final userNotifier = ref.watch(authprovider);
                          final currentUser = userNotifier.data;

                          return currentUser?.profilePic != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    '${Bbapi.profilePic}/${currentUser?.userId}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                                  ),
                                  radius: 50,
                                )
                              : const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.grey,
                                );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
void _showImageSourceDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    
  return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        backgroundColor: CoustColors.colrFill,
        title: const coustText(
          sName: 'Edit Profile',
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
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return Form(
                    key: _validationkey,
                    child: Column(
                      children: [
                        _buildImageUploadSection(),
                        regform("User Name", name, "Please Enter User Name", ref, 0),
                        regform("Email Id", emailid, "Please Enter Email Id", ref, 1),
                        regform("Contact Number", mobile, "Please Enter Contact Number", ref, 2),
                        SizedBox(
                          width: double.infinity,
                          child: CoustElevatedButton(
                            buttonName: "save",
                            width: double.infinity,
                            bgColor: CoustColors.colrButton3,
                            radius: 8,
                            FontSize: 20,
                            onPressed: () async {
                              if (_validationkey.currentState!.validate()) {
                        
                               await ref.read(authprovider.notifier).updateUser(
                              
                                  
                                  name.text.trim(),
                                  emailid.text.trim(),
                                   mobile.text.trim(),
                                  _profileImage,
                                  ref,
                                  
                                );
                              }
                            },
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

  Widget regform(String label, TextEditingController controller, String errorMsg, WidgetRef ref, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CoustTextfield(
        radius: 8.0,
        width: 10.0,
        isVisible: true,
        hint: label,
        title: label,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
          }
          return null;
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
