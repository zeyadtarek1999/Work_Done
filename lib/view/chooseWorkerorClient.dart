import 'package:workdone/view/screens/signup_screenworker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import '../model/mediaquery.dart';
import 'SignupWorker.dart';

class Chooseworkerorclient extends StatefulWidget {
  const Chooseworkerorclient({super.key});

  @override
  State<Chooseworkerorclient> createState() => _ChooseworkerorclientState();
}

class _ChooseworkerorclientState extends State<Chooseworkerorclient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Stack(
            children: [
              Container(
                  height: ScreenUtil.greenbackgroundheight,
                  width: ScreenUtil.screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/images/greenbackground.png',
                        ),
                        fit: BoxFit.fitWidth),
                  )),
              Container(
                  height: ScreenUtil.backgroundheight,
                  width: ScreenUtil.screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/images/firstscreen.png',
                        ),
                        fit: BoxFit.fitWidth),
                  )),
              Center(
                child: Container(
                    height: ScreenUtil.logoheight,
                    width: ScreenUtil.fourthscreenwidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/test.png',
                          ),
                          fit: BoxFit.cover),
                    )),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                    ),
                    // Replace with your desired icon
                    iconSize: 32.0,
                    // Adjust the size of the icon
                    color: Colors.white,
                    // Set the color of the icon
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: ScreenUtil.screenWidth,
            height: ScreenUtil.containeroftextheight,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: HexColor('#707070'),
                  // Shadow color
                  offset: Offset(0, 2.0),
                  // Set the offset (x, y) to control the shadow position
                  blurRadius: 7.0,
                  // Set the blur radius to control the spread of the shadow
                  spreadRadius:
                      -2.0, // Set the spread radius to control the size of the shadow
                ),
              ],
              color: Colors.white,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ), // Set the height of the right column
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                          color: HexColor('#4D8D6E'),
                          width: 3,
                        )),
                      ), // Set the height of the right column
                      child: Center(
                        child: Text(
                          'Sign in ',
                          style: TextStyle(color: HexColor('#4D8D6E')),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ), // Set the height of the right column
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil.sizeboxheight2,
          ),
          GestureDetector(onTap: () => Get.to(SignUpScreen()),
            child: Container(
              height: ScreenUtil.cardheight,
              width: ScreenUtil.cardwidth,
              child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: ScreenUtil.imageheight,
                        width: ScreenUtil.imagewidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage('assets/images/client.png'),
                            fit: BoxFit.cover,
                          ),
                        ), // Set the height of the right column
                        // Set the height of the right column
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                          height: 26,
                          width: 3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/line.png'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.white,
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ), // Set the height of the right column
                        child: Text(
                            style: TextStyle(
                                fontSize: 27, color: HexColor('#3F3D56')),
                            'Client'),
                      )
                    ],
                  )),
            ),
          ),
          SizedBox(height: ScreenUtil.sizeboxloginheight,),
          GestureDetector(onTap: () => Get.to(SignUpScreen()),
            child: Container(
              height: ScreenUtil.cardheight,
              width: ScreenUtil.cardwidth,
              child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: ScreenUtil.imageheight,
                        width: ScreenUtil.imagewidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage('assets/images/workerlogo.png'),
                            fit: BoxFit.cover,
                          ),
                        ), // Set the height of the right column
                        // Set the height of the right column
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                          height: 26,
                          width: 3,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/line.png'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.white,
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ), // Set the height of the right column
                        child: Text(
                            style: TextStyle(
                                fontSize: 27, color: HexColor('#3F3D56')),
                            'Worker'),
                      )
                    ],
                  )),
            ),
          )
        ]),
      ),
    );
  }
}
