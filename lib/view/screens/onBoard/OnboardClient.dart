import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

import '../Screens_layout/layoutclient.dart';
import '../forshowcaseExplain/showcaseclient.dart';

class OnBoardingClient extends StatelessWidget {
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
      Get.offAll(showcaseClient(),
        transition: Transition.zoom, // You can choose a different transition
        duration: Duration(milliseconds: 1100), fullscreenDialog: true, );
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerBackground: true,
        trailing: Text(
          'Skip',
          style: TextStyle(
            color: Color(0xFF4D8D6E),
            fontSize: 14,
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
                'assets/images/client.svg',
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
                'assets/images/projectmonitor.svg',
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
                  effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
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
                    effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
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
                  effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
                  child: Text(
                    'Connecting Clients with Qualified Workers Instantly',
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
                    effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
                    child: Text(
                      'WorkDone is the perfect solution for clients who need help with their projects. Whether you need a painter, plumber, or any other type of worker, you can post your project and receive bids from qualified workers in no time.',
                      textAlign: TextAlign.center,
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
                  effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
                  child: Text(
                    'Effortlessly Manage Your Projects with WorkDone',
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
                    effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
                    child: Text(
                      "Discover the power of WorkDone for efficient project management. Connect with skilled workers, schedule projects, track progress, and achieve success in every endeavor. Start your journey today!",
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
                  effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
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
                    effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
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
