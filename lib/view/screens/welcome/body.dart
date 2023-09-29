import 'package:workdone/model/mediaquery.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/widgets/bottomsheetlogin.dart';

import '../../widgets/bottomsheet.dart';
import '../../loginscreen.dart';
import '../../widgets/rounded_button.dart';
import '../login_screen_worker.dart';
import '../signup_screenworker.dart';
import 'background.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double buttonscreenwidth=ScreenUtil.screenWidth! * 0.75;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ChooseRoleBottomSheet();
      },
    );
  }
  void _showBottomSheetlogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ChooseRoleBottomSheetlogin();
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SizedBox(height: size.height * 0.05),
            SvgPicture.asset(
              "assets/images/welcomescreen.svg",
              height: size.height * 0.45,
            ),

            Text(
              "Work Made Easy!",
              style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,fontSize: 25,color: Colors.grey[700]),
            ),
            SizedBox(height: size.height * 0.05),

        Column(
          children: [

            Container(
          width: ScreenUtil.buttonscreenwidth,
          height: 45,
          margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
          child: ElevatedButton(
            onPressed:() {
              _showBottomSheetlogin(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#FFFFFF'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the corner radius
                side: BorderSide(
                  // width: buttonscreenwidth,
                    color: HexColor('#4D8D6E')// Adjust the value to change the width of the narrow edge
                ),
              ),
            ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16.0,color: HexColor('#4D8D6E')),
                ),
              ),
            ),
            Container(
              width: ScreenUtil.buttonscreenwidth,
              height: 45,
              margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed:() {
                  _showBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#4D8D6E'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the corner radius
                    side: BorderSide(
                      width: buttonscreenwidth, // Adjust the value to change the width of the narrow edge
                    ),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16.0,color: Colors.white),

                ),
              ),
            ),
          ],
        ),
      ]),)
    );
  }
}