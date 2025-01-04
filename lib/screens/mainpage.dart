// import 'package:bb_vendor/views.dart/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  // Future<void> logoutUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('userData');
  //   await prefs.setBool('isLoggedIn', false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Click for logout"),
            ElevatedButton(
              onPressed: ()  {
                // await logoutUser();
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => LoginPage()),
                //   (Route<dynamic> route) => false,
                // );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
