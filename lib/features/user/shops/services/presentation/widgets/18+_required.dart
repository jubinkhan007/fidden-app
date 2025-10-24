// NEW: dialog
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> ensure18PlusAcknowledged() async {
  final completer = Completer<bool>();
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false, // force an explicit choice
      child: AlertDialog(
        title: const Text('18+ Content'),
        content: const Text(
          'This service is restricted to customers aged 18 or older. '
              'By continuing, you confirm that you are at least 18 years old.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              completer.complete(false);
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              completer.complete(true);
              Get.back();
            },
            child: const Text("I'm 18+"),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
  return completer.future;
}