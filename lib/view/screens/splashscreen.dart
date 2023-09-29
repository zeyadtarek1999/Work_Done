import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'welcome/applauncher.dart';

class CustomSplashScreen extends StatefulWidget {
  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Set your desired animation duration
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack, // Choose your desired curve
      ),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _controller.forward().whenComplete(() {
      Get.off(AppLauncher());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Transform.rotate(
                    angle: _logoAnimation.value * 2 * pi, // Rotate the logo
                    child: YourLogoWidget(),
                  ),
                );
              },
            ),

            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textAnimation,
                  child: Text(
                    'Work Made Easy!',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class YourLogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your logo or custom widget
    return Image.asset(
      'assets/images/workdonelogo.jpg',
      width: 300, // Specify the desired width
      height: 260, // Specify the desired height
      fit: BoxFit.cover, // Choose an appropriate fit option
    );
  }
}