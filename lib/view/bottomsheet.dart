import 'package:workdone/view/screens/signupclient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';


import '../model/mediaquery.dart';
import 'screens/signup_screenworker.dart';

class ChooseRoleBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(onTap: () => Get.to(SignUpScreen2()),
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
          SizedBox(height: 14),
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
          ),          SizedBox(height: 7),

        ],
      ),
    );

  }
}
