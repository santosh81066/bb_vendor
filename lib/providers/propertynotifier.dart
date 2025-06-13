
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/models/get_properties_model.dart';

import '../utils/bbapi.dart';
class PropertyNotifier extends StateNotifier<AsyncValue<List<Data>>> {

  PropertyNotifier() : super(const AsyncValue.loading());


  void clearProperties() {
    state = const AsyncValue.data([]);
  }

  // Add this method for user-specific refresh
  Future<void> refreshForUser() async {
    clearProperties();
    await getproperty();
  }

  // Make sure your getproperty method handles errors properly
  Future<void> getproperty() async {
    try {
      state = const AsyncValue.loading();

      // Your API call here
      final properties = await Bbapi.addproperty;

      state = AsyncValue.data(properties as List<Data>);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}