// Import necessary packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:bb_vendor/Models/registrationstatemodel.dart';
import 'package:bb_vendor/Providers/registrationnotifier.dart';
import 'package:bb_vendor/Colors/coustcolors.dart'; // Import your color scheme
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with TickerProviderStateMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController emailid = TextEditingController();
  final TextEditingController pwd = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  final _validationKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Animation controllers for enhanced UI
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    name.dispose();
    emailid.dispose();
    pwd.dispose();
    mobile.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getTimezoneFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String? country = placemarks.first.country;

      if (country != null) {
        switch (country) {
          case "India":
            return "Asia/Kolkata";
          case "United States":
            return "America/New_York";
          case "United Kingdom":
            return "Europe/London";
          case "Australia":
            return "Australia/Sydney";
          case "Japan":
            return "Asia/Tokyo";
          default:
            print("Unknown country: $country. Defaulting to UTC.");
            return "UTC";
        }
      } else {
        print("Country not found. Defaulting to UTC.");
        return "UTC";
      }
    } catch (e) {
      print("Error determining timezone: $e");
      return "UTC";
    }
  }

  Future<String> getUserTimezone() async {
    try {
      Position position = await _getCurrentLocation();
      return await _getTimezoneFromLocation(position);
    } catch (e) {
      print('Error fetching user timezone: $e');
      return 'UTC';
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final fileSizeInBytes = await imageFile.length();
        final maxFileSize = 2 * 1024 * 1024;

        if (fileSizeInBytes > maxFileSize) {
          if (mounted) {
            _showAlertDialog('Error', 'File size exceeds 2MB. Please select a smaller file.');
          }
        } else {
          if (mounted) {
            setState(() {
              _profileImage = imageFile;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog('Error', 'Failed to pick image: $e');
      }
    }
  }

  Widget _buildProfileImageSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CoustColors.primaryPurple,
                        CoustColors.mediumPurple,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CoustColors.primaryPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _profileImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 50,
                    color: CoustColors.colrMainbg,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: CoustColors.colrMainbg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CoustColors.primaryPurple,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CoustColors.primaryPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: CoustColors.primaryPurple,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Add Profile Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CoustColors.colrMainText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload a clear photo of yourself',
              style: TextStyle(
                fontSize: 14,
                color: CoustColors.colrSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: CoustColors.colrMainbg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: CoustColors.colrStrock1.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: CoustColors.primaryPurple,
                  ),
                  title: Text(
                    'Take a Photo',
                    style: TextStyle(color: CoustColors.colrMainText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: CoustColors.primaryPurple,
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(color: CoustColors.colrMainText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      appBar: AppBar(
        backgroundColor: CoustColors.veryLightPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: CoustColors.colrMainText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: TextStyle(
            color: CoustColors.colrMainText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Form(
              key: _validationKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Text with purple theme
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Join ',
                                  style: TextStyle(color: CoustColors.primaryPurple),
                                ),
                                TextSpan(
                                  text: 'Banquet',
                                  style: TextStyle(color: CoustColors.mediumPurple),
                                ),
                                TextSpan(
                                  text: 'Bookz',
                                  style: TextStyle(color: CoustColors.teal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your vendor account to start managing\nbookings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: CoustColors.colrSubText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Profile Image Section
                  Center(child: _buildProfileImageSection()),

                  const SizedBox(height: 40),

                  // Form Fields with slide animations
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildInputField(
                            label: 'Full Name',
                            hintText: 'Enter your full name',
                            controller: name,
                            icon: Icons.person_outline,
                            iconColor: CoustColors.primaryPurple,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Email Address',
                            hintText: 'Enter your email address',
                            controller: emailid,
                            icon: Icons.email_outlined,
                            iconColor: CoustColors.primaryPurple,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Phone Number',
                            hintText: 'Enter your phone number',
                            controller: mobile,
                            icon: Icons.phone_outlined,
                            iconColor: CoustColors.primaryPurple,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Password',
                            hintText: 'Create a strong password',
                            controller: pwd,
                            icon: Icons.lock_outline,
                            iconColor: CoustColors.primaryPurple,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Create Account Button with purple gradient
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              CoustColors.primaryPurple,
                              CoustColors.mediumPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: CoustColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                            if (_validationKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                String timezone = await getUserTimezone();
                                await ref.read(registrationProvider.notifier).register(
                                  context,
                                  ref,
                                  name.text.trim(),
                                  emailid.text.trim(),
                                  pwd.text.trim(),
                                  mobile.text.trim(),
                                  _profileImage,
                                  timezone,
                                );
                              } catch (e) {
                                if (mounted) {
                                  _showAlertDialog('Error', 'Registration failed: $e');
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: CoustColors.colrMainbg,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CoustColors.colrMainbg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy with purple theme
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'By creating an account, you agree to our\n',
                          style: TextStyle(
                            fontSize: 14,
                            color: CoustColors.colrSubText,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: CoustColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(color: CoustColors.colrSubText),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: CoustColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CoustColors.colrMainText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CoustColors.colrFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CoustColors.colrStrock1.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: CoustColors.primaryPurple.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              color: CoustColors.colrMainText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: CoustColors.colrSubText,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: CoustColors.colrSubText,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAlertDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CoustColors.colrMainbg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CoustColors.colrMainText,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: CoustColors.colrSubText,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: CoustColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>(
      (ref) => RegistrationNotifier(),
);