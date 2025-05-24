import 'package:bb_vendor/screens/hallscalendar.dart';
import 'package:bb_vendor/screens/registration.dart';
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
import 'package:bb_vendor/Screens/sales.dart';
import 'package:bb_vendor/Screens/settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:bb_vendor/Screens/subscription_screen.dart';
import "package:bb_vendor/Screens/managecalendar.dart";
// ignore: unused_import
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      title: 'Banquetbookz Vendor',
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
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
      home: const AuthWrapper(), // Use a dedicated auth wrapper
      routes: {
        '/forgotpwd': (BuildContext context) => const ForgotpasswordScreen(),
        '/registration': (BuildContext context) => const RegistrationScreen(),
        '/welcome': (BuildContext context) => const CoustNavigation(),
        '/manage': (BuildContext context) => const ManageScreen(),
        '/sales': (BuildContext context) => const SalesScreen(),
        '/settings': (BuildContext context) => const SettingsScreen(),
        '/managebooking': (BuildContext context) => const ManageBookingScreen(),
        '/bookingdetails': (BuildContext context) => const BookingDetailsScreen(),
        '/manageproperty': (BuildContext context) => const ManagePropertyScreen(),
        '/addproperty': (BuildContext context) => const AddPropertyScreen(),
        '/addhall': (BuildContext context) => const PropertyHallScreen(),
        '/alltransactions': (BuildContext context) => const TransactionsScreen(),
        '/editprofile': (BuildContext context) => const EditprofileSceren(),
        '/subscriptionScreen': (BuildContext context) => const Subscription(),
        '/manageCalendar': (BuildContext context) => const ManageCalendarScreen(),
        '/hallscalendar': (BuildContext context) => const HallsCalendarScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
      },
    );
  }
}

// Create a separate AuthWrapper widget
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(authprovider.notifier).tryAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // After auto-login attempt, check the current auth state
        return Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authprovider);
            final hasValidToken = authState.data?.accessToken != null &&
                authState.data!.accessToken!.isNotEmpty;

            if (hasValidToken) {
              return const CoustNavigation();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
