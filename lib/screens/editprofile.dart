import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/textfieldstatenotifier.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditprofileSceren extends StatefulWidget{
  const EditprofileSceren({super.key});

  @override
  State<EditprofileSceren> createState() => _EditprofileScerenState();
}

class _EditprofileScerenState extends State<EditprofileSceren> {
  
  final TextEditingController name = TextEditingController();
  final TextEditingController emailid = TextEditingController();
  final TextEditingController pwd = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController add1 = TextEditingController();
  final TextEditingController add2 = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController pin = TextEditingController();
  final TextEditingController location = TextEditingController();
  final _validationkey = GlobalKey<FormState>();

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
              Container(
                decoration: BoxDecoration(
                  color: CoustColors.colrMainbg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const coustText(
                      sName: "Profile Photo",
                      textsize: 18,
                      fontweight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        color: CoustColors.colrButton1,
                       
                      ), //set Upload file
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                   
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final textFieldStates = ref.watch(textFieldStateProvider);
                  return Form(
                    key: _validationkey,
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              color: CoustColors.colrMainbg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                regform(
                                    "Full name",
                                    name,
                                    "Please Enter  Name",
                                    ref,
                                    0,
                                    textFieldStates),
                                const SizedBox(
                                  height: 10,
                                ),
                                regform(
                                    "Email Id",
                                    emailid,
                                    "Please Enter Email id",
                                    ref,
                                    1,
                                    textFieldStates),
                                const SizedBox(
                                  height: 10,
                                ),
                                regform(
                                    "Password",
                                    pwd,
                                    "Please Enter Password",
                                    ref,
                                    2,
                                    textFieldStates),
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(onPressed: (){}, child: coustText(sName: "Change password",txtcolor: CoustColors.colrEdtxt2,decoration: TextDecoration.underline,decorationcolor: CoustColors.colrHighlightedText,)),
                        Container(
                           decoration: BoxDecoration(
                              color: CoustColors.colrMainbg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                           child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                regform(
                                    "Current Password",
                                    name,
                                    "Please Enter Current Password",
                                    ref,
                                    0,
                                    textFieldStates),
                                const SizedBox(
                                  height: 10,
                                ),
                                regform(
                                    "New Password",
                                    emailid,
                                    "Please Enter New Password",
                                    ref,
                                    1,
                                    textFieldStates),
                                const SizedBox(
                                  height: 10,
                                ),
                                regform(
                                    "Confirm Password",
                                    pwd,
                                    "Please Enter Confirm Password",
                                    ref,
                                    2,
                                    textFieldStates),
                              ],
                            )),
                        SizedBox(
                          width: double.infinity,
                          child: CoustElevatedButton(
                            buttonName: "Save",
                            width: double.infinity,
                            bgColor: CoustColors.colrButton3,
                            radius: 8,
                            FontSize: 20,
                            onPressed: () {
                              if (_validationkey.currentState!.validate()) {}
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget regform(String name, TextEditingController txtController,
      String erromsg, WidgetRef ref, int index, List<bool> textFieldStates) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CoustTextfield(
        filled: textFieldStates[index],
        radius: 8.0,
        width: 10,
        isVisible: true,
        hint: name,
        title: name,
        controller: txtController,
        onChanged: (txtController) {
          ref.read(textFieldStateProvider.notifier).update(index, false);
          return null;
        },
        validator: (txtController) {
          if (txtController == null || txtController.isEmpty) {
            return erromsg;
          }
          return null;
        },
      ),
    );
  }
}
