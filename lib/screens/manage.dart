import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
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
                      padding: EdgeInsets.only(top: 32.0, left: 15),
                      child: coustText(
                        sName: "Manage",
                        txtcolor: CoustColors.colrEdtxt4,
                        textsize: 24,
                        fontweight:FontWeight.bold,
                        
                      )),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        items(
                          "Manage Bookings",
                          Icons.person,
                          onTap: () { Navigator.of(context).pushNamed('/managebooking');},
                        ),
                        const SizedBox(height: 10,),
                        items(
                          "Manage Properties",
                          Icons.store,
                          onTap: () {Navigator.of(context).pushNamed('/manageproperty');},
                        ),
                        const SizedBox(height: 10,),
                        items(
                          "Manage Transactions",
                          Icons.currency_rupee,
                          onTap: () {Navigator.of(context).pushNamed('/alltransactions');},
                        ),
                        const SizedBox(height: 10,),
                        items(
                          "Manage Calander",
                          Icons.calendar_today,
                          onTap: () {Navigator.of(context).pushNamed('/manageCalendar');},
                        ),
                        const SizedBox(height: 10,),
                      ],
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

  Widget items(String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CoustColors.colrMainbg,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: CoustColors.colrHighlightedText,
        ),
        title: coustText(
          sName: title,
          textsize: 16,
          txtcolor: CoustColors.colrEdtxt2,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 10,
        ),
      ),
    );
  }
}
