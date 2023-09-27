import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';

import 'screens/welcome/welcome_screen.dart';


class firstscreen2 extends StatefulWidget {
  @override
  firstscreen2State createState() => firstscreen2State();
}

class firstscreen2State extends State<firstscreen2> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData appTheme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        Container(
          height: size.height * 0.55,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36))),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36)),
            child: Image(
              image: AssetImage('assets/images/firstscreen2.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          height: size.height * 0.45,
          padding: EdgeInsets.all(30),
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  "find your ideal worker and jobs".toUpperCase(),
                  style: TextStyle(fontSize: 30),
                ),
              ),
              SizedBox(height: 18),
              Text(
                '"Welcome to a world of possibilities! Discover skilled workers and job opportunities through seamless bidding, Your journey to success begins here."',
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: TextStyle(color: Colors.grey[650]),
              ),
              SizedBox(height: 18),
              Center(
                child: ElevatedButton(
                    onPressed: () {
Get.to(WelcomeScreen());
                    },
                    style: ElevatedButton.styleFrom(
backgroundColor: HexColor('#4D8D6E'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'PlayFair',
                            fontWeight: FontWeight.bold)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Let's Go! "),
                    )),
              )
            ],
          ),
        )
      ]),
    );
  }
}
