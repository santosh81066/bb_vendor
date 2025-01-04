import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/heading.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final TextEditingController _edtxtNum = TextEditingController();
  Color btnColor = CoustColors.colrButton1;
  final _validationkey = GlobalKey<FormState>();
  var isPwdSent;
// Function to check if a string is a valid email
  bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value);
  }

  void _sendPassword(WidgetRef ref) {
    ref.read(isPasswordSent.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Heading(
                  sText1: "Forgot Password",
                  sText2: "",
                  //bVisibil: true,
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
                        key: _validationkey,
                        child: Consumer(
                          builder: (BuildContext context, WidgetRef ref,
                              Widget? child) {
                            btnColor = ref.watch(
                                buttonColorprovider); // get button name from provider
                            isPwdSent = ref.watch(isPasswordSent);
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, bottom: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //set diff designs
                                  isPwdSent
                                      ? _buildSuccessView(ref)
                                      : buildformview(ref),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget buildformview(WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const coustText(
          sName: "Enter your email below to generate a new password",
          overflow: TextOverflow.visible,
          textsize: 16,
          align: TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        CoustTextfield(
          radius: 8.0,
          width: 10,
          isVisible: false,
          hint: "Email",
           iconwidget: iconwidget( Icons.person,(ref.watch(
                                                          buttonColorprovider)),),
          controller: _edtxtNum,
          inputtype: TextInputType.emailAddress,
          onChanged: (_edtxtNum) {
            if (_edtxtNum == null || _edtxtNum.isEmpty) {
              ref.read(enablepasswaorProvider.notifier).state =
                  0; // If num textfield is null invisble pwd field
            } else {
              if (isValidEmail(_edtxtNum)) {
                ref.read(buttonColorprovider.notifier).state =
                    CoustColors.colrButton3;
              } else {
                ref.read(buttonColorprovider.notifier).state =
                    CoustColors.colrButton1;
              }
            }

            return null;
          },
          validator: (_edtxtNum) {
            if (_edtxtNum == null || _edtxtNum.isEmpty) {
              return 'Please enter a valid email address';
            }
            if (!isValidEmail(_edtxtNum)) {
              print("mail:" + "${isValidEmail(_edtxtNum)}");
              return "Pleasee enter valid emial Id";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: CoustElevatedButton(
            buttonName: "Send Password",
            width: double.infinity,
            bgColor: (ref.watch(buttonColorprovider)),
            radius: 8,
            FontSize: 20,
            onPressed: () {
              if (_validationkey.currentState!.validate()) {
                _sendPassword(ref);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: CoustColors.colrScaffoldbg,
          size: 80,
        ),
        const SizedBox(height: 20),
        const coustText(
          sName: 'Password sent successfully',
          txtcolor: CoustColors.colrEdtxt5,
          textsize: 18,
          align: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: const coustText(
            sName:
                'A new password has been sent to your email ID. Use it to sign-in to your account.',
            txtcolor: CoustColors.colrEdtxt5,
            textsize: 14,
            align: TextAlign.center,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 20),
          SizedBox(
          height: 50,
          width: double.infinity,         
           child: CoustElevatedButton(
              buttonName: "Sign In",
              width: double.infinity,
              bgColor: (ref.watch(buttonColorprovider)),
              radius: 8,
              FontSize: 20,
              onPressed: () {
                
              },
            ),
         ),
      ],
    );
  }
   Widget iconwidget(IconData icon,Color suficonColor) {
    return Container(
      padding: EdgeInsets.all(10), // Padding for the circular effect
      child: CircleAvatar(
        radius: 15,
        backgroundColor: suficonColor,
        child: Icon(
          icon,
          color: CoustColors.colrFill,
          size: 20,
        ),
      ),
    );
  }
}
