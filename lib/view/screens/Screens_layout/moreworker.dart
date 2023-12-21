import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../welcome/welcome_screen.dart';

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
        child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: Colors.white,
      body:
      Screenshot(
        controller:screenshotController ,
        child:Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/profileimage.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zeyad',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: HexColor('3A3939'),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'zzeyadtarek11@gmail.com',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: HexColor('3A3939'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
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
                    onPressed: () {},
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
                      onPressed: () {},
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
                    Ionicons.card_outline,
                    color: Colors.grey[800],
                    size: 27,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  TextButton(
                      onPressed: () {},
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
              Row(
                children: [
                  Icon(
                    Ionicons.help_circle_outline,
                    color: Colors.grey[800],
                    size: 27,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Help',
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
                    Ionicons.settings_outline,
                    color: Colors.grey[800],
                    size: 27,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Setting',
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

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      );
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
              //     primary: Colors.red, // Set the button color to red
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
    );
  }
}
