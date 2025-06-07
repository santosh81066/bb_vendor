import 'package:bb_vendor/widgets/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../colors/coustcolors.dart';
import '../providers/auth.dart';
import '../providers/stateproviders.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggedIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Get responsive sizing based on screen width
  double _getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // Get responsive font size based on screen width
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return baseSize * 1.2; // Large screens
    } else if (screenWidth > 600) {
      return baseSize * 1.0; // Medium screens
    } else {
      return baseSize * 0.9; // Small screens
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return CustomNavigation();
    }

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1200;
    final isLargeScreen = size.width >= 1200;

    return Scaffold(
      backgroundColor: CoustColors.colrButton3,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white70,
              Colors.black26,
              CoustColors.colrFill,
              Colors.black26,
             Colors.white70

            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: isSmallScreen ? 100 : 150,
                    height: isSmallScreen ? 100 : 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CoustColors.colrHighlightedText.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -50,
                  child: Container(
                    width: isSmallScreen ? 150 : 200,
                    height: isSmallScreen ? 150 : 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6418C3).withOpacity(0.1),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Vendor branding section
                    SizedBox(height: isSmallScreen ? 60 : 80),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30), // Adjust radius as needed
                      child: Image.asset(
                        "assets/images/app_icon.jpg",
                        width: isSmallScreen ? 80 : 120,
                        height: isSmallScreen ? 80 : 120,
                        fit: BoxFit.cover, // Ensures image fills the container properly
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 15 : 20),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [Colors.white, Color(0xFFFDE68A)],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        "BANQUET BOOKZ",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 10,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFEA5455), Color(0xFFEA5455)],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          "\nSign-in to your vendor account\n \nAccess your vendor dashboard  ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),


                    Expanded(child: Container()),

                    // Login form
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : (isMediumScreen ? 24 : _getResponsiveWidth(context, 0.2)),
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                      width: isLargeScreen ? _getResponsiveWidth(context, 0.4) : double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFCBBDD3),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Consumer(
                          builder: (BuildContext context, WidgetRef ref, Widget? child) {
                            final isLoading = ref.watch(loadingProvider);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child:  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        colors: [Color(0xFF6418C3),Color(0xFF6418C3) ],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      "Vendor Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                        shadows: [
                                          Shadow(
                                            color: Colors.white,
                                            blurRadius: 10,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    "Enter your Email & Password"
                                    ,
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(context, 16),
                                      color: CoustColors.colrStrock2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 24 : 32),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 16),
                                    color: CoustColors.colrMainText,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(color: Colors.black87),
                                    hintText: "Enter your email",
                                    hintStyle: TextStyle(color: Colors.black87),
                                    prefixIcon: Icon(Icons.person_outline, color: CoustColors.colrHighlightedText),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFF6418C3), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Field is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(context, 16),
                                    color: CoustColors.colrMainText,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Colors.black87),
                                    hintText: "Enter your password",
                                    hintStyle: TextStyle(color: Colors.black87),
                                    prefixIcon: Icon(Icons.lock_outline, color: CoustColors.colrHighlightedText),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: CoustColors.colrEdtxt1,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Color(0xFF6418C3), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Field is required';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: isSmallScreen ? 20 : 24),

                                // Login button
                                SizedBox(
                                  height: isSmallScreen ? 50 : 55,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final login = ref.read(authprovider.notifier);
                                        final result = await login.adminLogin(
                                          context,
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          ref,
                                        );

                                        // Add explicit navigation after successful login
                                        if (result.statusCode == 200) {
                                          setState(() {
                                            _isLoggedIn = true;
                                          });
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6418C3),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(context, 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 20 : 24),

                                // Registration option
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: _getResponsiveFontSize(context, 14),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/registration');
                                      },
                                      child: Text(
                                        "Get Started",
                                        style: TextStyle(
                                          color: CoustColors.colrEdtxt2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _getResponsiveFontSize(context, 14),
                                          decoration: TextDecoration.underline,
                                          decorationColor: CoustColors.colrEdtxt2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Social login options
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : (isMediumScreen ? 24 : _getResponsiveWidth(context, 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Or continue with",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _getResponsiveFontSize(context, 16),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialLoginButton(FontAwesomeIcons.google, const Color(0xFFF3F3F3)),
                        const SizedBox(width: 16),
                        _socialLoginButton(FontAwesomeIcons.facebook, const Color(0xFFF3F3F3)),
                        const SizedBox(width: 16),
                        _socialLoginButton(FontAwesomeIcons.apple, const Color(0xFFF3F3F3)),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(IconData icon, Color color) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      width: isSmallScreen ? 50 : 60,
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: isSmallScreen ? 25 : 30),
        onPressed: () {
          // TODO: Implement social login for vendors
        },
      ),
    );
  }
}