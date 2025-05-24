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

class EditprofileSceren extends ConsumerStatefulWidget {
  const EditprofileSceren({super.key});

  @override
  ConsumerState<EditprofileSceren> createState() => _EditprofileScerenState();
}

class _EditprofileScerenState extends ConsumerState<EditprofileSceren>
    with TickerProviderStateMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController emailid = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final _validationkey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUserData();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
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
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });
  }

  void _initializeUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userNotifier = ref.read(authprovider);
      final currentUser = userNotifier.data;

      if (currentUser != null) {
        name.text = currentUser.username ?? '';
        emailid.text = currentUser.email ?? '';
        mobile.text = currentUser.mobileNo ?? '';
        setState(() {});
      }
    });
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        final fileSizeInBytes = await imageFile.length();
        final maxFileSize = 2 * 1024 * 1024; // 2MB in bytes

        if (fileSizeInBytes > maxFileSize) {
          _showAlertDialog('Error', 'File size exceeds 2MB. Please select a smaller file.');
        } else {
          setState(() {
            _profileImage = imageFile;
          });
          // Add a subtle bounce animation when image is selected
          _scaleController.reset();
          _scaleController.forward();
        }
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to pick image: $e');
    }
  }

  Widget _buildImageUploadSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
              vertical: 20,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: CoustColors.colrButton1,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
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
                              ? Image.network(
                            '${Bbapi.profilePic}/${currentUser?.userId}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                              : _buildDefaultAvatar();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'Tap to change photo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CoustColors.colrButton3.withOpacity(0.7),
            CoustColors.colrButton3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person_add_alt_1,
        size: MediaQuery.of(context).size.width * 0.15,
        color: Colors.white,
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBottomSheetOption(
                  icon: Icons.camera_alt,
                  title: 'Take a Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: CoustColors.colrButton3),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: _buildAnimatedAppBar(),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: screenHeight -
                          AppBar().preferredSize.height -
                          MediaQuery.of(context).padding.top -
                          keyboardHeight,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 20,
                    ),
                    child: Consumer(
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {
                        return Form(
                          key: _validationkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildImageUploadSection(),
                              SizedBox(height: screenHeight * 0.03),
                              _buildAnimatedFormField(
                                "User Name",
                                name,
                                "Please Enter User Name",
                                ref,
                                0,
                                Icons.person_outline,
                              ),
                              _buildAnimatedFormField(
                                "Email Id",
                                emailid,
                                "Please Enter Email Id",
                                ref,
                                1,
                                Icons.email_outlined,
                              ),
                              _buildAnimatedFormField(
                                "Contact Number",
                                mobile,
                                "Please Enter Contact Number",
                                ref,
                                2,
                                Icons.phone_outlined,
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              _buildAnimatedSaveButton(ref),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      backgroundColor: CoustColors.colrFill,
      elevation: 0,
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: const coustText(
              sName: 'Edit Profile',
              txtcolor: CoustColors.colrEdtxt2,
            ),
          );
        },
      ),
      leading: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: CoustColors.colrHighlightedText,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedFormField(
      String label,
      TextEditingController controller,
      String errorMsg,
      WidgetRef ref,
      int index,
      IconData icon,
      ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        // Clamp the value to ensure it stays within valid range
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: CoustColors.colrButton3,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: CoustColors.colrEdtxt2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CoustTextfield(
                      radius: 12.0,
                      width: 1.0,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSaveButton(WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        // Clamp the value to ensure it stays within valid range
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: clampedValue,
          child: AnimatedBuilder(
            animation: _buttonScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonScaleAnimation.value.clamp(0.5, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CoustColors.colrButton3.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CoustElevatedButton(
                    buttonName: _isLoading ? "Saving..." : "Save Profile",
                    width: double.infinity,
                    bgColor: CoustColors.colrButton3,
                    radius: 12,
                    FontSize: MediaQuery.of(context).size.width * 0.045,
                    onPressed: _isLoading ? null : () async {
                      if (_validationkey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        _buttonController.forward().then((_) {
                          _buttonController.reverse();
                        });

                        try {
                          await ref.read(authprovider.notifier).updateUser(
                            name.text.trim(),
                            emailid.text.trim(),
                            mobile.text.trim(),
                            _profileImage,
                            ref,
                          );

                          // Show success dialog and navigate to settings
                          _showSuccessDialog('Success', 'Profile updated successfully!');
                        } catch (e) {
                          // Show error dialog
                          _showAlertDialog('Error', 'Failed to update profile: $e');
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.3 + (0.7 * value),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    title == 'Error' ? Icons.error : Icons.info,
                    color: title == 'Error' ? Colors.red : CoustColors.colrButton3,
                  ),
                  const SizedBox(width: 10),
                  Text(title),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: CoustColors.colrButton3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        curve: Curves.bounceOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.3 + (0.7 * value),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              elevation: 10,
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              actions: [
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _navigateToSettingsWithAnimation(); // Navigate to settings
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: CoustColors.colrButton3,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Go to Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToSettingsWithAnimation() {
    // Add a small delay for better UX
    Future.delayed(const Duration(milliseconds: 100), () {
      // Pop current screen with custom animation
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // Replace 'SettingsPage()' with your actual settings page widget
            // return SettingsPage();

            // For now, we'll just pop back to previous screen
            // You should replace this with your actual settings page navigation
            Navigator.of(context).pop();
            return Container(); // Placeholder
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
}