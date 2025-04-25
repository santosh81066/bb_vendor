import 'package:bb_vendor/widgets/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors/coustcolors.dart';
import '../providers/auth.dart';
import '../providers/stateproviders.dart';
import '../widgets/customelevatedbutton.dart';
import '../widgets/customtextfield.dart';
import '../widgets/heading.dart';
import '../widgets/text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggedIn = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return CoustNavigation();
    }
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Heading(
                  sText1: "Welcome to BanquetBookz",
                  sText2:
                      "Enter your Email&password to Sign-in to your vendor account",
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  color: CoustColors.colrFill,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            applyDecoration: true,
                            width: screenWidth * 0.8,
                            hintText: "Email",
                            keyBoardType: TextInputType.emailAddress,
                            suffixIcon: Icons.person_outline,
                            textController: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            applyDecoration: true,
                            width: screenWidth * 0.8,
                            hintText: "Password",
                            keyBoardType: TextInputType.text,
                            suffixIcon: Icons.lock_outline,
                            textController: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Consumer(builder: (context, ref, child) {
                            final login = ref.watch(authprovider.notifier);
                            final isLoading = ref.watch(loadingProvider);

                            return CustomElevatedButton(
                              text: "Login",
                              borderRadius: 10,
                              width: 300,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
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
                              isLoading: isLoading,
                              backGroundColor: const Color(0xFF6418C3),
                              foreGroundColor: Colors.white,
                            );
                          }),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const coustText(
                                sName: "Don't have an account?",
                                textsize: 15,
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/registration'),
                                child: const coustText(
                                  sName: "Get Started",
                                  decoration: TextDecoration.underline,
                                  txtcolor: CoustColors.colrEdtxt2,
                                  textsize: 15,
                                  decorationcolor: CoustColors.colrEdtxt2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
