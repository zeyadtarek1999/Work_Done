import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/screens/Screens_layout/layoutWorker.dart';

import '../Screens_layout/layoutclient.dart';
import '../forshowcaseExplain/showcaseWorker.dart';

class OnBoardingWorker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      // Change this color to the desired one
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor:
      Colors.white, // Change the status bar icons' color (dark or light)
    ));

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardingSlider(
        pageBackgroundColor: Colors.white,
        onFinish: () {
          Get.offAll(showcaseWorker(),
            transition: Transition.fadeIn, // You can choose a different transition
            duration: Duration(milliseconds: 800), fullscreenDialog: true, );
        },
        headerBackgroundColor: Colors.white,
        finishButtonText: 'Let\'s Start',
        finishButtonTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: Color(0xFF4D8D6E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        skipTextButton: Text(
          'Skip',
          style: TextStyle(
            color: Color(0xFF4D8D6E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerBackground: true,
        trailing: Text(
          'Skip',
          style: TextStyle(
            color: Color(0xFF4D8D6E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: [
          Container(
            width: screenWidth,
            height: screenHeight / 2,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/welcomescreen2.svg',
                width: screenWidth * 0.7,
                height: screenHeight * 0.7,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight / 2,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/workerwork.svg',
                width: screenWidth * 0.7,
                height: screenHeight * 0.7,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight / 2,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/Bid.svg',
                width: screenWidth * 0.7,
                height: screenHeight * 0.7,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight / 2,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/letsstart.svg',
                width: screenWidth * 0.7,
                height: screenHeight * 0.7,
              ),
            ),
          ),

        ],
        controllerColor: Color(0xFF4D8D6E),
        totalPage: 4,
        speed: 1,
        pageBodies: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: screenHeight /2,
                  width: double.infinity,
                ),
                Animate(
                  effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                  child: Text(
                    'Welcome to WorkDone! ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HexColor('#01213a'),
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      // Adjust the multiplication factor based on your preference
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Animate(
                    effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                    child: Text(
                      'The platform that connects clients with the right workers for their projects. With WorkDone, you can easily post a project, receive bids from workers, and manage the entire project from start to finish.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: MediaQuery.of(context).size.width * 0.056,
                        // Adjust the multiplication factor based on your preference
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: screenHeight /2,
                  width: double.infinity,
                ),
                Animate(
                  effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                  child: Text(
                    'Discover Opportunities with WorkDone',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HexColor('#01213a'),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Animate(
                    effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                    child: Text(
                    'WorkDone is also the perfect solution for workers who are looking for new projects. With WorkDone, you can browse through available projects, place bids, and communicate with clients. With WorkDone,',                    textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        // Adjust the multiplication factor based on your preference
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),           ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: screenHeight /2,
                  width: double.infinity,
                ),
                Animate(
                  effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                    child: Text(
                    'Join the Competition \n Show off your skills!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HexColor('#01213a'),
                      fontSize: MediaQuery.of(context).size.width * 0.065,
                      // Adjust the multiplication factor based on your preference
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Animate(
                    effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                    child: Text(
                    'Are You A Skilled Professional Looking For New Opportunities? Showcase Your Skills, Receive Project Requests, And Place Bids To Win Jobs. Manage Your Work And Connect With Clients Directly Through The App.',                    textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: MediaQuery.of(context).size.width * 0.051,
                        // Adjust the multiplication factor based on your preference
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: screenHeight /2,
                  width: double.infinity,
                ),
                Animate(
                  effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                  child: Text(
                    'Ready To Get Started?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HexColor('#01213a'),
                      fontSize: MediaQuery.of(context).size.width * 0.065,
                      // Adjust the multiplication factor based on your preference
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Animate(
                    effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                    child: Text(
                      'Start your project journey with WorkDone. Whether you\'re a client or a skilled worker, post projects, place bids, and bring your ideas to life!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: MediaQuery.of(context).size.width * 0.052,
                        // Adjust the multiplication factor based on your preference
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}