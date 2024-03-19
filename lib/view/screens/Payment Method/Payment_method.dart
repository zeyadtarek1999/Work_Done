import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../widgets/rounded_button.dart';

class paymentmethod extends StatefulWidget {
  const paymentmethod({super.key});

  @override
  State<paymentmethod> createState() => _paymentmethodState();
}

class _paymentmethodState extends State<paymentmethod> {
  @override
  bool _isLoading =false;
  TextEditingController paypalcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String paypalvalidation ='';

  Future<void> paymentacccount() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/check_paypal_account';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },

        );

        if (response.statusCode == 200) {
          Map<dynamic, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            String profileData = responseData['data'];


            setState(() {
              paypalvalidation = profileData;
              // checkPayPalValidation();

            });

            print('Response: $profileData');
            print('paypalvalidation : $paypalvalidation');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to paypalvalidation');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load paypalvalidation');
        }
      }
    } catch (error) {
      // Handle errors
      print('Error getting paypalvalidation: $error');
    }
  }

  Future<void> submitpaypalemail() async {
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://www.workdonecorp.com/api/update_worker_paypal');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      // Prepare the request body

      // Make the API request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken', // Replace with your actual token
        },
        body: {
          'paypal':  paypalcontroller.text,

        },
      );

      // Hide the loading indicator
      setState(() {
        _isLoading = false;
      });

      // Check the response status
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        // Check the status in the response
        if (responseBody['status'] == 'success') {
          Fluttertoast.showToast(
            msg: 'paypal email submited successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.back( // You can choose a different transition// Set the duration of the transition
          );
        } else if (responseBody['status'] == 'success') {
          // Check the specific error message
          String errorMsg = responseBody['msg'];

        }
      } else {

        print(userToken);
        print('Failed to submit paypal email. Status code: ${response.statusCode}');

        // Show a toast message for the error
        Fluttertoast.showToast(
          msg: 'Failed to submit paypal email. Status code: ${response.statusCode}',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        // Print the response body for more details
        print('Response body: ${response.body}');
      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      print('Error submit paypal email: $e');

      // Show a toast message for the error
      Fluttertoast.showToast(
        msg: 'Error submiting paypal email: $e',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // Handle errors as needed
    }
  }

  @override
  void initState() {
    super.initState();
    paymentacccount ();
  }
  Widget build(BuildContext context) {    Size size = MediaQuery.of(context).size;

  double? containerHeight = size.height * 0.09;

  return  Form(
  key:_formKey ,autovalidateMode:AutovalidateMode.onUserInteraction ,
    child: Scaffold(


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
                                              paypalvalidation == 'no paypal Email'? 'Write a PayPal Email':
                                                  '$paypalvalidation',
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(
                                                  0), // Remove content padding
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your PayPal email';
                                              }
                                              // Use a regex pattern to validate the email format
                                              RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                              if (!emailRegex.hasMatch(value)) {
                                                return "Enter a valid email address";
                                              }
                                              return null;
                                            },

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
                          if (_formKey.currentState!.validate()) {
                            submitpaypalemail();

                          }
                                      },
                        child:Text ( 'Submit',style: TextStyle(color: Colors.white),), // Use an elevator icon for demonstration
                        style: ElevatedButton.styleFrom(
                         backgroundColor: Color(0xFF4D8D6E), // Set the button color to 4D8D6E
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
                                    'Create or Edit your Paypal Account',
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

      ),
  );
  }
}
