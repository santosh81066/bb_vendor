import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stateproviders.dart';

// ignore: must_be_immutable
class Heading extends StatelessWidget {
  final sText1, sText2;
  // final bool bVisibil;

  Heading({
    super.key,
    required this.sText1,
    this.sText2,
    // required this.bVisibil,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        var isPwdVisible = ref.watch(enablepasswaorProvider);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(sText1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(color: Colors.white, fontSize: 30)),
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                print("Keyboard${isKeyboardVisible}, isPwd:${isPwdVisible}");
                return ((isKeyboardVisible) && (isPwdVisible != 0))
                    ? Container()
                    : Column(
                        children: [
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            sText2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      );
              }),
            ],
          ),
        );
      },
    );
  }
}
