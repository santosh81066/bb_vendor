import 'package:bb_vendor/screens/wellcome.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'colors/coustcolors.dart';
import 'providers/auth.dart';
import 'screens/login.dart';
import 'widgets/bottomnavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize time zones
  tz.initializeTimeZones();
  // await Firebase.initializeApp();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authprovider);
    print('build main.dart');
    return MaterialApp(
      title: 'Banquetbookz Vendor',
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto', // Set the default font family
          scaffoldBackgroundColor: CoustColors.colrScaffoldbg,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              maximumSize: Size.fromWidth(double.infinity),
              disabledForegroundColor: CoustColors.colrEdtxt4,
              disabledBackgroundColor: CoustColors.colrButton1,
              foregroundColor: CoustColors.colrEdtxt4,
              backgroundColor: CoustColors.colrButton1,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: CoustColors.colrButton3,
            unselectedItemColor: CoustColors.colrSubText,
            type: BottomNavigationBarType.fixed,
          )),
      routes: {
        '/': (context) {
          return Consumer(
            builder: (context, ref, child) {
              print('Auth state updated: ${authState.toJson()}');
              // Debugging logs for understanding the state
              print("Auth state data: ${authState.data}");
              print("User Role: ${authState.data?.userRole}");
              print("User Status: ${authState.data?.userStatus}");

              // Check if the user is authenticated and has a valid role and status
              if (authState.data?.userStatus == true &&
                  authState.data?.userRole == "v") {
                // Navigate to the welcome page if conditions are met
                return const Wellcome(); // Welcome page
              }

              // If the user is not authenticated, attempt auto-login
              return FutureBuilder(
                future: ref.watch(authprovider.notifier).tryAutoLogin(),
                builder: (context, snapshot) {
                  print("Auto-login result: ${snapshot.data}");
                  print(
                      "Snapshot connection state: ${snapshot.connectionState}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show SplashScreen while waiting
                  } else {
                    // Navigate based on the auto-login result
                    return snapshot.data == true
                        ? const Wellcome() // Welcome page
                        : const LoginScreen(); // Login page
                  }
                },
              );
            },
          );
        },
        // '/forgotpwd': (BuildContext context) {
        //   return const ForgotpasswordScreen();
        // },
        // '/registration': (BuildContext context) {
        //   return const RegistrationScreen();
        // },
        '/welcome': (BuildContext context) {
          //welcome page
          return const Wellcome();
        },
        // '/home': (BuildContext context) {
        //   //welcome page
        //   return const DashboardScreen();
        // },
        // '/manage': (BuildContext context) {
        //   //welcome page
        //   return const ManageScreen();
        // },
        // '/sales': (BuildContext context) {
        //   //welcome page
        //   return const SalesScreen();
        // },
        // '/settings': (BuildContext context) {
        //   //welcome page
        //   return const SettingsScreen();
        // },
        // '/managebooking': (BuildContext context) {
        //   return const ManageBookingScreen();
        // },
        // '/bookingdetails': (BuildContext context) {
        //   return const BookingDetailsScreen();
        // },
        // '/manageproperty': (BuildContext context) {
        //   return const ManagePropertyScreen();
        // },
        // '/addproperty': (BuildContext context) {
        //   return const AddPropertyScreen();
        // },
        // '/alltransactions': (BuildContext context) {
        //   return const TransactionsScreen();
        // },
        // '/editprofile': (BuildContext context) {
        //   return const EditprofileSceren();
        // },
        // '/subscriptionScreen': (BuildContext context) {
        //   return const Subscription();
        // },
        // '/manageCalendar': (BuildContext context) {
        //   return const ManageCalendarScreen();
        // },
        // '/calendarPropertiesList': (BuildContext context) {
        //   return const CalendarPropertiesList();
        // },
        '/login': (BuildContext context) {
          return const LoginScreen();
        }
      },
    );
  }
}
