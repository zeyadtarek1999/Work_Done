import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Termsandconditions/termsofservice.dart';
import 'package:workdone/view/screens/notifications/notificationscreenworker.dart';
import '../Edit address.dart';
import '../Payment Method/Payment_method.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../welcome/welcome_screen.dart';
import 'package:http/http.dart' as http;

class Moreworker extends StatefulWidget {
  const Moreworker({Key? key}) : super(key: key);

  @override
  State<Moreworker> createState() => _MoreworkerState();
}

class _MoreworkerState extends State<Moreworker> {
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  final ScreenshotController screenshotController = ScreenshotController();
  String profile_pic ='' ;
  String firstname ='' ;
  String secondname ='' ;
  String email ='' ;
  
  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> profileData = responseData['data'];

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }
  String unique= 'moreworker' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    _getUserProfile();



  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
child: Icon(Icons.help ,color: Colors.white,), // Use the support icon
        //        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: Colors.white,
      body:
      Screenshot(
        controller:screenshotController ,
        child:Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
          child:RefreshIndicator(
            color: HexColor('4D8D6E'),
            backgroundColor: Colors.white,

            onRefresh: () async {
              setState(() {
                _getUserProfile();              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),


              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundColor: Colors.transparent,
                        backgroundImage: profile_pic == '' || profile_pic.isEmpty
                            || profile_pic == "https://workdonecorp.com/storage/" ||
                            !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))
            
                            ? AssetImage('assets/images/default.png') as ImageProvider
                            : NetworkImage(profile_pic?? 'assets/images/default.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.03,
                          // Adjust the multiplication factor based on your preference
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${firstname}',
                              style: GoogleFonts.encodeSans(
                                textStyle: TextStyle(
                                  color: HexColor('3A3939'),
                                  fontSize: MediaQuery.of(context).size.width * 0.072,
                                  // Adjust the multiplication factor based on your preference
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.012,
                              // Adjust the multiplication factor based on your preference
                            ),
                            Text(
                              '${email}',
                              style: GoogleFonts.encodeSans(
                                textStyle: TextStyle(
                                  color: HexColor('3A3939'),
                                  fontSize: MediaQuery.of(context).size.width * 0.041,
                                  // Adjust the multiplication factor based on your preference
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('6CA78A'),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(20.0), // Set circular border
                          ),
                        ),
                        onPressed: () {
                          Get.to(ProfileScreenworker());
                        },
                        child: Text(
                          'View Profile',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Icon(
                        Ionicons.location_outline,
                        color: Colors.grey[800],
                        size: 27,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      TextButton(
                          onPressed: () {
                            Get.to(editAddressClient());
            
                          },
                          child: Text(
                            'Address',
                            style: GoogleFonts.encodeSans(
                              textStyle: TextStyle(
                                  color: HexColor('454545'),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Ionicons.notifications_outline,
                        color: Colors.grey[800],
                        size: 27,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(NotificationsPageworker
                            ());
                        },
                        child: Text(
                          'Notifications',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: HexColor('454545'),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                    ],
                  ),
            
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Ionicons.card_outline,
                        color: Colors.grey[800],
                        size: 27,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      TextButton(
                          onPressed: () {
            Get.to(paymentmethod());
            
            },
                          child: Text(
                            'Payment method',
                            style: GoogleFonts.encodeSans(
                              textStyle: TextStyle(
                                  color: HexColor('454545'),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
            
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Ionicons.help_circle_outline,
                  //       color: Colors.grey[800],
                  //       size: 27,
                  //     ),
                  //     SizedBox(
                  //       width: 9,
                  //     ),
                  //     TextButton(
                  //         onPressed: () {},
                  //         child: Text(
                  //           'Help',
                  //           style: GoogleFonts.encodeSans(
                  //             textStyle: TextStyle(
                  //                 color: HexColor('454545'),
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //         )),
                  //   ],
                  // ),
                  SizedBox(
                    height: 8,
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Ionicons.settings_outline,
                  //       color: Colors.grey[800],
                  //       size: 27,
                  //     ),
                  //     SizedBox(
                  //       width: 9,
                  //     ),
                  //     TextButton(
                  //         onPressed: () {},
                  //         child: Text(
                  //           'Setting',
                  //           style: GoogleFonts.encodeSans(
                  //             textStyle: TextStyle(
                  //                 color: HexColor('454545'),
                  //                 fontSize: 14,
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //         )),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {                                              Get.to(termsOfService());
                          },
                          child: Text(
                            'Terms of service',
                            style: GoogleFonts.encodeSans(
                              textStyle: TextStyle(
                                  color: HexColor('454545'),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),

                    ],
                  ),

                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'About',
                            style: GoogleFonts.encodeSans(
                              textStyle: TextStyle(
                                  color: HexColor('454545'),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
            
                    ],
                  ),
            
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await clearSharedPreferences(); // Add this line to clear SharedPreferences
            
                          Get.offAll(WelcomeScreen());
            
                        },
                        child:  Text('Log Out',
                            style: GoogleFonts.encodeSans(
                              textStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            )),
                      )
                    ],
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await clearClientID(); // Call the function to clear client_id
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //    backgroundColor: Colors.red, // Set the button color to red
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius:
                  //           BorderRadius.circular(20.0), // Set circular border
                  //     ),
                  //   ),
                  //   child: Text(
                  //     'Logout',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
