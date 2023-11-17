import 'dart:convert';
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


import '../../../controller/DrawerControllerworker.dart';
import '../../../model/mediaquery.dart';
import '../editProfile/editProfile.dart';

class ProfileScreenClient2 extends StatefulWidget {
  @override
  State<ProfileScreenClient2> createState() => _ProfileScreenClient2State();
}

class _ProfileScreenClient2State extends State<ProfileScreenClient2> {
  String phonenumber = '';
  String email = '';
  int? clientId;
  bool isAddressDetailsVisible =
      false; // Initially, address details are not visible

  List<Map<String, dynamic>> languages = [];


  String firstname = '';
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
              phonenumber = profileData['phone'] ?? '';
              language = profileData['language'] ?? '';
            });

            print('Response: $profileData');
            print('prifole pic: $profile_pic');
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






  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;

  @override
  Widget build(BuildContext context) {
    EdgeInsets mediaQueryPadding = MediaQuery.of(context).padding;
    double topPadding = mediaQueryPadding.top + 93;
    double topPadding2 = mediaQueryPadding.top + 113;
    double topPadding3 = mediaQueryPadding.top + 150;
    double topPadding4 = mediaQueryPadding.top + 70;
    double topPadding5 = mediaQueryPadding.top + 53;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('4D8D6E'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return AdvancedDrawer(
          openRatio: 0.5,

          backdropColor: HexColor('ECEDED'),
          controller: advancedDrawerController,
          rtlOpening: false,
          openScale: 0.89,
          childDecoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20)),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 1000),
          drawer: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                backgroundImage: profile_pic.isNotEmpty
                    ? NetworkImage(profile_pic)
                    : AssetImage('assets/images/profileimage.png') as ImageProvider,
              ),

                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "$firstname $secondname" ,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('1A1D1E'),
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Text(
                    'zzeyadtarek11@gmail.com',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('6A6A6A'),
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/time.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Projects',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/notification.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/portfolioicon.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Portfolio',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/logout.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: HexColor('F5F5F5'),
            body : SafeArea(
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
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    drawerControl();
                                  },
                                  icon: Icon(
                                    Icons.menu,
                                    size: 32,
                                    color: Colors.white,
                                  )),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                'Profile',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    size: 29,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
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
                                            'Client',

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
                              child: ClipOval(
                                child:  profile_pic.isNotEmpty
                                    ? Image.network(
                                  profile_pic,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  'assets/images/profileimage.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 19, horizontal: 20),
                      child: Text(
                        'Personal Info'.toUpperCase(),
                        style: TextStyle(
                            color: HexColor('#022C43'),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
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
                                )),
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

                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Center(
                      child: Container(
                        width: ScreenUtil.buttonscreenwidth,
                        height: 45,
                        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                        child: ElevatedButton(
                          onPressed: () {Get.to(editProfile());},
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

