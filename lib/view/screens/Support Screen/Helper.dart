
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'Support.dart';

class NavigationHelper {
  String? unique;

  NavigationHelper({required this.unique});

  Future<void> navigateToNextPage(
      BuildContext context, ScreenshotController screenshotController) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(
          screenshotImageBytes: imageBytes,
          unique: unique,
        ),
      ),
    );
  }
}
