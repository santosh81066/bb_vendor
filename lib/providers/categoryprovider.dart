import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bb_vendor/utils/bbapi.dart';
import 'package:bb_vendor/models/category.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<Category>> {
  CategoryNotifier() : super(const AsyncValue.loading());

  Future<void> getCategory() async {
    try {
      final response = await http.get(
        Uri.parse(Bbapi.getcategory),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final category = Category.fromJson(decodedResponse);

        // Update state with data
        state = AsyncValue.data(category);
      } else {
        // Handle HTTP error
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Update state with error
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<Category>>(
  (ref) => CategoryNotifier(),
);
