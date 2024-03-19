import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workdone/controller/MoreClientController.dart';
import 'package:workdone/view/screens/Edit%20address.dart';
import 'package:workdone/view/screens/Profile%20(client-worker)/profilescreenClient.dart';
import 'package:workdone/view/screens/Support%20Screen/Support.dart';
import 'package:workdone/view/screens/homescreen/home%20screenClient.dart';
import 'package:workdone/view/screens/notifications/notificationScreenclient.dart';
import 'package:workdone/view/screens/welcome/welcome_screen.dart';

class Moreclient extends StatelessWidget {
  final MoreClientController moreClientController = Get.put(MoreClientController());

  final ScreenshotController screenshotController1000 = ScreenshotController();

  String unique= 'moreclient' ;

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController1000.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupportScreen(screenshotImageBytes: imageBytes, unique: unique),
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
        child: Icon(Icons.help ,color: Colors.white,), // Use the support icon
      ),
      backgroundColor: Colors.white,
      body: Obx(() => moreClientController.isLoading.value
          ? CircularProgressIndicator()
          :   Screenshot(
        controller:screenshotController1000 ,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Animate(
                effects: [ShimmerEffect(duration: Duration(milliseconds: 500),),],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundColor: Colors.transparent,
                      backgroundImage: moreClientController.profile_pic.value == '' || moreClientController.profile_pic.value.isEmpty
                          || moreClientController.profile_pic.value == "https://workdonecorp.com/storage/" ||
                          !(moreClientController.profile_pic.value.toLowerCase().endsWith('.jpg') ||moreClientController. profile_pic.value.toLowerCase().endsWith('.png'))

                          ? AssetImage('assets/images/default.png') as ImageProvider
                          : NetworkImage(moreClientController.profile_pic.value?? 'assets/images/default.png'),
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
                            '${moreClientController.firstname.value}',
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
                            '${moreClientController.email.value}',
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
                      Get.to(ProfileScreenClient2());
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
                        Get.to(NotificationsPageclient());
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
                        launchUrl(Uri.parse('https://www.paypal.com/signin'),mode: LaunchMode.inAppWebView);
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

              SizedBox(
                height: 8,
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
                      await clearSharedPreferences(); // Call the function to clear client_id
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

            ],
          ),
        ),
          )),
    );
  }
}
