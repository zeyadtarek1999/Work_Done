import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/model/mediaquery.dart';
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

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create a custom curve for a smoother vibration effect
    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Add a listener to trigger rebuild on each animation tick
    _controller.addListener(() {
      setState(() {});
    });

    // Start the animation at initialization
    _controller.repeat(reverse: true);

    // Stop the animation after 2 seconds
    Future.delayed(Duration(seconds: 4), () {
      _controller.stop();
    });
  }

  void _startVibratingAnimation() {
    // Reset the controller and start the animation
    _controller.repeat(reverse: true);
    Future.delayed(Duration(seconds: 4), () {
      _controller.stop();
    });
  }

  double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;
  void _showBottomSheet(BuildContext context) {
    // Define the animation controller
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: Navigator.of(context),
    );

    // Create a custom animation using CurvedAnimation for a smoother effect
    Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // Open the bottom sheet with the custom animation
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: ChooseRoleBottomSheet(),
        );
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );

    // Start the animation
    controller.forward();
  }
  void _showBottomSheetlogin(BuildContext context) {
    // Define the animation controller
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: Navigator.of(context),
    );

    // Create a custom animation using CurvedAnimation for a smoother effect
    Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // Open the bottom sheet with the custom animation
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: ChooseRoleBottomSheetlogin(),
        );
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );

    // Start the animation
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(

      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _startVibratingAnimation,
              child: Transform.translate(
                offset: Offset(_animation.value, 0),
                child: SvgPicture.asset(
                  'assets/images/Logo.svg',
                  width: 150.0,
                  height: 180.0,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/images/welcomescreen.svg",
              height: size.height * 0.45,
            ),
            Container(
              height: 30,
              child: AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Work Made Easy!',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 25,
                      color: Colors.grey[700],
                    ),
                    duration:  const Duration(seconds: 3),
                   ),
                  ScaleAnimatedText(
                    'WorkDone ',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 25,
                      color: Colors.grey[700],
                    ),

                    duration:  const Duration(seconds: 3),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Column(
              children: [
                Container(
                  width: ScreenUtil.buttonscreenwidth,
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showBottomSheetlogin(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('#FFFFFF'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(
                          color: HexColor('#4D8D6E'),
                        ),

                      ),
                      elevation: 5, // Add elevation to create a shadow

                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 16.0, color: HexColor('#4D8D6E'), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  width: ScreenUtil.buttonscreenwidth,
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('#4D8D6E'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(
                          width: buttonscreenwidth,
                        ),
                      ),
                      elevation: 10, // Add elevation to create a shadow
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
