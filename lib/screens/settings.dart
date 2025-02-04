import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:bb_vendor/providers/auth.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
      
  @override

  Widget build(BuildContext context) {
    final logout = ref.watch(authprovider.notifier);
    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 110,
                  // ignore: unnecessary_const
                  decoration: const BoxDecoration(
                      color: CoustColors.colrHighlightedText,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(25),
                          bottomStart: Radius.circular(25))),
                  child: const Padding(
                      padding: EdgeInsets.only(top: 25.0, left: 15),
                      child: coustText(
                        sName: "Settings",
                        txtcolor: CoustColors.colrEdtxt4,
                        textsize: 24,
                        fontweight:FontWeight.bold,
                      )),
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: CoustColors.colrMainbg,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.person,
                                  size: 40, color: CoustColors.colrHighlightedText),
                              SizedBox(width: 16.0),
                              coustText(sName:'Suresh Ramesh',textsize: 18,txtcolor: CoustColors.colrEdtxt2,)
                            
                            ],
                          ),
                        ),
                        const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: const coustText(sName: 'Edit Profile'),
                  onTap: () {Navigator.of(context).pushNamed('/editprofile');
                    // Handle edit profile action
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
               Align(

                 alignment: Alignment.centerLeft, // Aligns to the start (left)
                 child: TextButton(
                      onPressed: () async {
                        final shouldLogout = await _showLogoutConfirmation(context);
                        if (shouldLogout == true) {
                          await logout.logoutUser();  // Call logout function
                          Navigator.of(context).pushReplacementNamed('/login');  // Navigate to the login screen after logout
                        }
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Color(0xff000000), fontSize: 15),
                      ),
                    ),
                   ),

                  ],
                )),
                
              ],
            ),
          );
        },
      ),
    );
  }
}
Future<bool?> _showLogoutConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if canceled
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if confirmed
            },
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

