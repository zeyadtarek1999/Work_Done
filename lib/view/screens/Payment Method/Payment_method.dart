import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/rounded_button.dart';

class paymentmethod extends StatefulWidget {
  const paymentmethod({super.key});

  @override
  State<paymentmethod> createState() => _paymentmethodState();
}

class _paymentmethodState extends State<paymentmethod> {
  @override
  Widget build(BuildContext context) {    Size size = MediaQuery.of(context).size;

  TextEditingController paypalcontroller = TextEditingController();
  double? containerHeight = size.height * 0.09;

  return  Scaffold(


      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 67,
        backgroundColor: Colors.white,
        title: Text(
          'Payment Method',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('454545'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: Colors.black,
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body:
      SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(

                    children: [
                      Text('Note',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text('You Can Edit Any Field Only and Press Submit',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          decoration: TextDecoration.underline,
                        ),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 8,),


                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10),
                            child: Text('PayPal Email'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            height: size.height * 0.103,
                            width: size.width * 0.89,
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/paypal.svg',
                                  // Replace with your SVG path
                                  width: 33.0,
                                  height: 33.0,
                                ),
                                SizedBox(width: 15.0),
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      // Add some spacing between the dropdown and the text field
                                      Expanded(
                                        child: TextFormField(
                                          controller: paypalcontroller,
                                          decoration: InputDecoration(
                                            hintText:
                                            'Please Enter Paypal Email',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(
                                                0), // Remove content padding
                                          ),

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Center(
                  child:

                  Center(
                    child: ElevatedButton(
                      onPressed: () async{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Edit/Update Payment Method Done'),
                              content: Text('Your Payment Method has been successfully updated.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );                      },
                      child:Text ( 'Submit',style: TextStyle(color: Colors.white),), // Use an elevator icon for demonstration
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF4D8D6E), // Set the button color to 4D8D6E
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Make the button circular
                        ),
                      ),
                    ),
                  ),


                ),
                SizedBox(height: 70,),
                Center(
                  child: InkWell(
                    onTap: () {
  launchUrl(Uri.parse('https://www.paypal.com/signin'),mode: LaunchMode.inAppWebView);
  },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      height: containerHeight,
                      width: size.width * 0.93,
                      decoration: BoxDecoration(
                        color: HexColor('#F5F5F5'),
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [

                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Edit or Modify your Paypal Account',
                                  style: TextStyle(
                                    color: HexColor('#707070'),
                                    fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust the multiplier as needed
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

    );
  }
}
