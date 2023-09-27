import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class Logincontroller extends GetxController {
Rx<Color> textColor = Colors.black.obs;

void changeTextColor() {
  textColor.value = HexColor('#4D8D6E');
}
}