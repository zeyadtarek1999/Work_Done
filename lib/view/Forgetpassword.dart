import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

import 'OTP screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      appBar: AppBar(
        backgroundColor: Colors.white, // Set the app bar background color
        elevation: 0, // Remove the shadow
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forgot Password',
                style: TextStyle(
                  color: HexColor('#4D8D6E'), // Set the text color
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enter your registered email address below to receive password reset instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black, // Set the text color
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.to(OtpScreen());
                  // Implement your password reset logic here
                },
                style: ElevatedButton.styleFrom(
                  primary: HexColor('#4D8D6E'), // Set the button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}