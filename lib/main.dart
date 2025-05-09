import 'package:bb_vendor/screens/hallscalendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';
import "package:bb_vendor/widgets/bottomnavigation.dart";
import 'package:bb_vendor/Providers/auth.dart';
import 'package:bb_vendor/screens/addproperty.dart';
import 'package:bb_vendor/Screens/alltransactions.dart';
import 'package:bb_vendor/Screens/bookingdetails.dart';
import 'package:bb_vendor/Screens/editprofile.dart';
import 'package:bb_vendor/Screens/forgotpassword.dart';
import 'package:bb_vendor/Screens/login.dart';
import 'package:bb_vendor/Screens/manage.dart';
import 'package:bb_vendor/Screens/managebookinng.dart';
import 'package:bb_vendor/Screens/manageproperty.dart';
import 'package:bb_vendor/Screens/registration.dart';
import 'package:bb_vendor/Screens/sales.dart';
import 'package:bb_vendor/Screens/settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:bb_vendor/Screens/subscription_screen.dart';
import "package:bb_vendor/Screens/managecalendar.dart";
import "package:bb_vendor/Screens/calendarpropertieslist.dart";
import "package:bb_vendor/screens/addhall.dart";

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
    print('build main.dart');
    print('Building the widget');

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
              final authState = ref.watch(authprovider);
              print('Auth state updated: ${authState.toJson()}');
              // Debugging logs for understanding the state
              print("Auth state data: ${authState.data}");
              print("User Role: ${authState.data?.userRole}");
              print("User Status: ${authState.data?.userStatus}");
              final token = authState.data?.accessToken!;
              print("accesstoken in mainpage:$token");
              // Check if the user is authenticated and has a valid role and status
              if (authState.data?.accessToken != null &&
                  authState.data!.accessToken!.isNotEmpty) {
                // Navigate to the welcome page if conditions are met
                return const CoustNavigation(); // Welcome page
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
                        ? const CoustNavigation() // Welcome page
                        : const LoginScreen(); // Login page
                  }
                },
              );
            },
          );
        },
        '/forgotpwd': (BuildContext context) {
          return const ForgotpasswordScreen();
        },
        '/registration': (BuildContext context) {
          return const RegistrationScreen();
        },
        '/welcome': (BuildContext context) {
          //welcome page
          return const CoustNavigation();
        },
        '/manage': (BuildContext context) {
          //welcome page
          return const ManageScreen();
        },
        '/sales': (BuildContext context) {
          //welcome page
          return const SalesScreen();
        },
        '/settings': (BuildContext context) {
          return const SettingsScreen();
        },
        '/managebooking': (BuildContext context) {
          return const ManageBookingScreen();
        },
        '/bookingdetails': (BuildContext context) {
          return const BookingDetailsScreen();
        },
        '/manageproperty': (BuildContext context) {
          return const ManagePropertyScreen();
        },
        '/addproperty': (BuildContext context) {
          return const AddPropertyScreen();
        },
        '/addhall': (BuildContext context) {
          return const PropertyHallScreen();
        },
        '/alltransactions': (BuildContext context) {
          return const TransactionsScreen();
        },
        '/editprofile': (BuildContext context) {
          return const EditprofileSceren();
        },
        '/subscriptionScreen': (BuildContext context) {
          return const Subscription();
        },
        '/manageCalendar': (BuildContext context) {
          return const ManageCalendarScreen();
        },
        '/hallscalendar': (BuildContext context) {
          return const HallsCalendarScreen();
        },
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
