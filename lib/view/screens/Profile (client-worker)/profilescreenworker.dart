import 'dart:convert';
import 'package:screenshot/screenshot.dart';
import 'package:workdone/view/screens/homescreen/home%20screenClient.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/homescreen/homeWorker.dart';


import '../../../controller/DrawerControllerworker.dart';
import '../../../model/mediaquery.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../editProfile/editProfileClient.dart';
import '../editProfile/editprofileworker.dart';

class ProfileScreenworker extends StatefulWidget {
  @override
  State<ProfileScreenworker> createState() => _ProfileScreenworkerState();
}

class _ProfileScreenworkerState extends State<ProfileScreenworker> {
  String phonenumber = '';
  String email = '';
  int? clientId;
  bool isAddressDetailsVisible =
  false; // Initially, address details are not visible


  String firstname = '';
  String paypal = '';
  String license_number = '';
  String license_pic = 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
  String job_type = '';
  int experience = 1;
  String secondname = '';
  String password = '';
  String profile_pic = '';
  String language = '';
  late String userToken;
  @override
  void initState() {
    super.initState();
    _getUserProfile();

    getaddressuser();
  }String addressline1 = '';

  String addressline2 = '';

  String city = '';

  String state = '';
  String addressZip = '';

  Future<void> getaddressuser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_address';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('Address_data')) {
            Map<String, dynamic> Addressdata = responseData['Address_data'];

            setState(() {
              addressline1  = Addressdata['street1'] ?? '';
              addressline2  = Addressdata['street2'] ?? '';
              city  = Addressdata['city'] ?? '';
              state  = Addressdata['state'] ?? '';
              addressZip = Addressdata['address_zip']?.toString() ?? '';
            });

            print('Response: $Addressdata');
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
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }


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
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },

        );

        if (response.statusCode == 200) {
          Map<dynamic, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<dynamic, dynamic> profileData = responseData['data'];

            String languageString;
            String jobtypeString;

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
              phonenumber = profileData['phone'] ?? '';
              paypal = profileData['paypal'] ?? 'no paypal Email';
              license_number = profileData['license_number'] ?? 'No license number';
              license_pic = profileData['license_pic'] ?? 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
              experience = profileData['experience'] ?? '';
              List<dynamic> jobtypes = profileData['job_type'] ?? [];
              List<String> jobtypeNames = jobtypes.map<String>((jobtype) => jobtype['name']).toList();
              jobtypeString = jobtypeNames.join(', ');
              job_type =jobtypeString;
              List<dynamic> languages = profileData['language'] ?? [];
              List<String> languageNames = languages.map<String>((language) => language['name']).toList();
              languageString = languageNames.join(', ');
              language = languageString; // Add this line
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
            print('language : $language');
            print('jobtypes : $job_type');
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
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }



  final ScreenshotController screenshotController = ScreenshotController();



  String unique= 'profilescreenclient' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;

  @override
  Widget build(BuildContext context) {
    EdgeInsets mediaQueryPadding = MediaQuery.of(context).padding;
    double topPadding = mediaQueryPadding.top + 20;
    double topPadding2 = mediaQueryPadding.top + 48;
    double topPadding3 = mediaQueryPadding.top + 80;
    double topPadding4 = mediaQueryPadding.top + 2;
    double topPadding5 = mediaQueryPadding.top + 36;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('4D8D6E'),
      // Change this color to the desired one
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
  child: Icon(Icons.help ,color: Colors.white,), // Use the support icon          shape: CircleBorder(), // Make the button circular
        ),
        key: _scaffoldKey,
        backgroundColor: HexColor('F5F5F5'),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 29,
                color: Colors.white,
              )),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

      ),

      body :Screenshot(
          controller:screenshotController ,
          child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: ScreenUtil.screenWidth,
                          height: ScreenUtil.containerheight3,
                          decoration: BoxDecoration(color: HexColor('#4D8D6E')),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: topPadding),
                          child: Center(
                            child: Container(
                              width: ScreenUtil.opacitycontainerwidth1,
                              height: ScreenUtil.opacitycontainerheight1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                // Set the border radius here

                                color: Colors.white24.withAlpha(80),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: topPadding2),
                          child: Center(
                            child: Container(
                              width: ScreenUtil.opacitycontainerwidth2,
                              height: ScreenUtil.opacitycontainerheight1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                // Set the border radius here

                                color: Colors.white24.withAlpha(50),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: topPadding3),
                          child: Center(
                            child: Container(
                              width: ScreenUtil.opacitycontainerwidth3,
                              height: ScreenUtil.opacitycontainerheight3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                // Set the border radius here
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    // Shadow color
                                    offset: Offset(0, 4.0),
                                    // Set the offset (x, y) to control the shadow position
                                    blurRadius:
                                    8.0, // Set the blur radius to control the spread of the shadow
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: topPadding5),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Worker',

                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  color: HexColor('C9C227'),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$firstname $secondname',
                                        style: TextStyle(
                                            color: HexColor('#022C43'),
                                            fontSize: 26,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: topPadding4),
                          child: Center(
                            child: Container(
                              width: ScreenUtil.profileimagewidth,
                              height: ScreenUtil.profileimageheight,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: HexColor('#B2B1B1'),
                                  width: 5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.transparent,
                                backgroundImage: profile_pic == '' || profile_pic.isEmpty
                                    || profile_pic == "https://workdonecorp.com/storage/" ||
                                    !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))

                                    ? AssetImage('assets/images/default.png') as ImageProvider
                                    : NetworkImage(profile_pic?? 'assets/images/default.png'),
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 19, horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Personal Info'.toUpperCase(),
                            style: TextStyle(
                                color: HexColor('#022C43'),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          ElevatedButton(
                            child: Text('license',style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              // Show the license popup
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Center(child: Text('License',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),)),

                                    content: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                      Text('License Image:',style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 16),),
                                        Center(
                                          child: Container(
                                            width: 200, // Set your preferred width
                                            height: 200, // Set your preferred height
                                            child: (license_pic != null && license_pic.isNotEmpty && license_pic != "https://workdonecorp.com/images/")
                                                ? Image.network(license_pic, fit: BoxFit.contain)
                                                : Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png', fit: BoxFit.contain),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Your license Number:'
                                          ,style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold, fontSize: 16),),
                                        SizedBox(height: 10),
                                        Center(
                                          child: Text(
                                            '${license_number}',
                                            style: TextStyle(fontSize: 16, color: HexColor('4D8D6E')),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        child: Center(
                                          child: ElevatedButton(
                                            child: Text(
                                              'Close',
                                              style: TextStyle(color: Colors.white), // Set the text color to white
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(HexColor('4D8D6E')), // Set the background color
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(HexColor('4D8D6E')), // Set the background color
                            ),
                          ),

                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        height: ScreenUtil.Infocontainerheight,
                        width: ScreenUtil.Infocontainerwidth,
                        decoration: BoxDecoration(
                          color: HexColor('#F9F9F9'),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: HexColor('#707070').withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Phone Number:',
                                        style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.sizeboxwidth3,
                                    ),
                                    Text(
                                      '$phonenumber',
                                      style: TextStyle(
                                          color: HexColor('#404040'), fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: HexColor('#707070').withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Email Address:',
                                        style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.sizeboxwidth3,
                                    ),
                                    Text(
                                      '$email',
                                      style: TextStyle(
                                          color: HexColor('#404040'), fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                height: 50,
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: HexColor('#707070').withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'Language Spoken:',
                                          style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: ScreenUtil.sizeboxwidth3),
                                      Text(
                                        '$language',
                                        style: TextStyle(
                                            color: HexColor('#404040'), fontSize: 15),
                                      )
                                    ],
                                  ),
                                )),
                            Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: HexColor('#707070').withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'Job Types:',
                                          style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: ScreenUtil.sizeboxwidth3),
                                      Text(
                                        '$job_type',
                                        style: TextStyle(
                                            color: HexColor('#404040'), fontSize: 15),
                                      )
                                    ],
                                  ),
                                )),

                            Container(
                              height: 50,
                              width: double.infinity,

                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: HexColor('#707070').withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Address:',
                                        style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.sizeboxwidth3,
                                    ),
                                    Text(
                                      '$addressline1 , $addressline2 , $city , $state  ',
                                      style: TextStyle(
                                          color: HexColor('#404040'), fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: HexColor('#707070').withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Zip Code:',
                                      style: TextStyle(
                                          color: HexColor('#4D8D6E'),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.sizeboxwidth3,
                                  ),
                                  Text(
                                    '$addressZip    ',
                                    style: TextStyle(
                                        color: HexColor('#404040'), fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: HexColor('#707070').withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Experience:',
                                      style: TextStyle(
                                          color: HexColor('#4D8D6E'),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.sizeboxwidth3,
                                  ),
                                  Text(
                                    '${experience.toString()}    ',
                                    style: TextStyle(
                                        color: HexColor('#404040'), fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              width: double.infinity,

                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: HexColor('#707070').withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'PayPal Email:',
                                        style: TextStyle(
                                            color: HexColor('#4D8D6E'),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil.sizeboxwidth3,
                                    ),
                                    Text(
                                      '$paypal',
                                      style: TextStyle(
                                          color: HexColor('#404040'), fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   height: 50,
                    //   decoration: BoxDecoration(
                    //     border: Border(
                    //       bottom: BorderSide(
                    //         color: HexColor('#707070').withOpacity(0.1),
                    //         width: 1,
                    //       ),
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Padding(
                    //         padding: EdgeInsets.symmetric(horizontal: 12),
                    //         child: Text(
                    //           'experience:',
                    //           style: TextStyle(
                    //               color: HexColor('#4D8D6E'),
                    //               fontWeight: FontWeight.w400,
                    //               fontSize: 17),
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: ScreenUtil.sizeboxwidth3,
                    //       ),
                    //       Text(
                    //         '${experience.toString()}    ',
                    //         style: TextStyle(
                    //             color: HexColor('#404040'), fontSize: 15),
                    //       )
                    //     ],
                    //   ),
                    // ),

                    SizedBox(
                      height: 17,
                    ),
                    Center(
                      child: Container(
                        width: ScreenUtil.buttonscreenwidth,
                        height: 45,
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                        child: ElevatedButton(
                          onPressed: () {Get.to(editProfileworker());},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor('#4D8D6E'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              // Adjust the value to change the corner radius
                              side: BorderSide(
                                  width:
                                  buttonscreenwidth // Adjust the value to change the width of the narrow edge
                              ),
                            ),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.sizeboxheight,
                    ),
                  ],
                ),
              )),
        ),
      );

  }void drawerControl() {
    advancedDrawerController.showDrawer();
  }
}

