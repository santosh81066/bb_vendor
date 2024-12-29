import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../colors/coustcolors.dart';

final loadingProvider = StateProvider<bool>((ref) => false);
final loadingProvider2 = StateProvider<bool>((ref) => false);

final buttonTextProvider = StateProvider<String>((ref) => "Next");
final buttonColorprovider =
    StateProvider<Color>((ref) => CoustColors.colrButton1);
final enablepasswaorProvider = StateProvider<int>((ref) => 0);
final VerifyOtp = StateProvider<bool>((ref) => false);
final isPasswordSent = StateProvider<bool>((ref) => false);
final latlangs = StateProvider<LatLng>((ref) => LatLng(17.3850, 78.4867));
final refundissued = StateProvider<bool>((ref) => false);
final canclebuttonprovider =
    StateProvider<Color>((ref) => CoustColors.colrButton2);
