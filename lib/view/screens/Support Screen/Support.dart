import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class SupportScreen extends StatelessWidget {
  final Uint8List? screenshotImageBytes;

  SupportScreen({required this.screenshotImageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('F5F5F5'),
      appBar: AppBar(
        title: Text('Support',style: GoogleFonts.roboto(
        textStyle: TextStyle(
        color: HexColor('3A3939'),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    ),
        elevation: 3,
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          onPressed: () {Get.back();},
          icon: Icon(
            Icons.arrow_back_sharp,
            color: HexColor('1A1D1E'),
            size: 27,
          ),
        ),
        toolbarHeight: 67,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content of Screen',

              style: GoogleFonts.roboto(
              textStyle: TextStyle(
              color: HexColor('424347'),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
              SizedBox(height: 20),
              if (screenshotImageBytes != null)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[700]!, // Set the desired dark grey color
                        width: 2.0, // Set the desired border width
                      ),
                      borderRadius: BorderRadius.circular(10), // Set the desired border radius
                    ),
                    width: 300, // Set the width to match the image width
                    height: 340, // Set the height to match the image height
                    child: Center(
                      child: Image.memory(
                        screenshotImageBytes!,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                )
,
              SizedBox(height: 20),
              Text(
                'Describe the issue:',

                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: HexColor('424347'),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Please write a detailed message . \nThe support will respond to you shortly.',
                      hintStyle: TextStyle(color: Colors.grey[500]),

                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement the logic to send the support request
                    // You can use the content of the TextFormField and the screenshot image
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4D8D6E), // Set the desired color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Increase the border radius
                    ),
                    minimumSize: Size(200, 50), // Set the minimum size of the button
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18,color: Colors.white), // Set the font size of the button text
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
