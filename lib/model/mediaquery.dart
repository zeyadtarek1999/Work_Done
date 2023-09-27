import 'package:flutter/material.dart';

class ScreenUtil {
  static MediaQueryData? _mediaQueryData;
  static double? fourthscreenwidth;
  static double? sizeboxwidth;
  static double? sizeboxwidth3;

  static double? halfScreenwidth;
  static double? buttonscreenwidth;
  static double? paddingoftext;
  static double? paddingoflogintext;
  static double? screenHeight;
  static double? greenbackgroundheight;
  static double? backgroundheight;
  static double? logoheight;
  static double? containeroftextheight;
  static double? sizeboxheight;
  static double? sizeboxloginheight;
  static double? containerheight;
  static double? screenWidth;
  static double? Infocontainerwidth;
  static double? Infocontainerheight;

  static double? cardheight;
  static double? sizeboxheight2;
  static double? cardwidth;
  static double? imageheight;
  static double? imagewidth;
  static double? fifthscreenwidth;
  static double? sizeboxheight4;
  static double? halfScreenwidth2;
  static double? sizeboxheight3;
  static double? containerheight2;
  static double? sizeboxwidth2;
  static double? containerheight3;
  static double? containerheight7;
  static double? opacitycontainerheight1;
  static double? opacitycontainerwidth1;
  static double? opacitycontainerwidth2;
  static double? opacitycontainerwidth3;
  static double? opacitycontainerheight2;
  static double? opacitycontainerheight3;
  static double? profileimagewidth;
  static double? profileimageheight;
  static double? insidecontainerleftwidth;
  static double? insidecontainerleftheight;
  static double? insidecontainerrightwidth;
  static double? insidecontainerrightheight;
  static double? buttonscreenwidth2 ;
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData?.size.width;
    fourthscreenwidth = screenWidth! * 0.40;
    sizeboxwidth = screenWidth! * 0.1;
    sizeboxwidth2 = screenWidth! * 0.08;
    sizeboxwidth3 = screenWidth! * 0.01;

    halfScreenwidth = screenWidth! * 0.83;
    halfScreenwidth2 = screenWidth! * 0.93;
    buttonscreenwidth = screenWidth! * 0.75;
    paddingoftext = screenWidth! * 0.1;
    paddingoflogintext = screenWidth! * 0.09;
    cardwidth =screenWidth! * 0.9;
    imagewidth=screenWidth! * 0.21;
    fifthscreenwidth = screenWidth! * 0.45;
    sizeboxheight4 =screenWidth! * 0.03;
    opacitycontainerwidth1 =screenWidth! * 0.8;
    opacitycontainerwidth2 =screenWidth! * 0.88;
    opacitycontainerwidth3=screenWidth! * 0.95;
profileimagewidth =screenWidth! * 0.37;
     insidecontainerleftwidth =screenWidth! * 0.47;
    insidecontainerrightwidth =screenWidth! * 0.47;
    Infocontainerwidth=screenWidth! * 0.9;
    buttonscreenwidth2 =screenWidth! * 0.75;

    screenHeight = _mediaQueryData?.size.height;
    greenbackgroundheight = screenHeight! * 0.22;
    backgroundheight = screenHeight! * 0.22;
    logoheight = screenHeight! * 0.22;
    containeroftextheight = screenHeight! * 0.09;
    sizeboxheight = screenHeight! * 0.03;
    sizeboxheight2 = screenHeight! * 0.17;
    sizeboxloginheight = screenHeight! * 0.06;
    containerheight = screenHeight! * 0.1;
    cardheight= screenHeight! * 0.14;
    imageheight= screenHeight! * 0.13;
    sizeboxheight3 = screenHeight! * 0.02;
    containerheight2 =screenHeight! * 0.12;
    containerheight3 =screenHeight! * 0.34;
    containerheight7 =screenHeight! * 0.40;
    opacitycontainerheight1 = screenHeight! * 0.2;
    opacitycontainerheight2 = screenHeight! * 0.33;
    opacitycontainerheight3 = screenHeight! * 0.24;

    profileimageheight =screenHeight! * 0.2;
    insidecontainerleftheight =screenHeight! * 0.107;
    insidecontainerrightheight =screenHeight! * 0.107;
    Infocontainerheight =screenHeight! * 0.37;

  }
}