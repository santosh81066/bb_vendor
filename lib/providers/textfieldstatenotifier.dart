import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier to manage the filled states of text fields
class TextFieldStateNotifier extends StateNotifier<List<bool>> {
  TextFieldStateNotifier(int count) : super(List.filled(count, true));

  void update(int index, bool value) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) value else state[i],
    ];
  }

  void reset(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) true else state[i],
    ];
  }
}

// Create a StateNotifierProvider
final textFieldStateProvider =
    StateNotifierProvider<TextFieldStateNotifier, List<bool>>((ref) {
  return TextFieldStateNotifier(
      15); // Initialize with the number of text fields
});
