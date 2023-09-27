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

class ProfileScreenClient2 extends StatefulWidget {
  @override
  State<ProfileScreenClient2> createState() => _ProfileScreenClient2State();
}

class _ProfileScreenClient2State extends State<ProfileScreenClient2> {
  String firstName = '';
  String lastName = '';
  String phonenumber = '';
  String email = '';
  int? clientId;
  bool isAddressDetailsVisible =
      false; // Initially, address details are not visible

  List<Map<String, dynamic>> languages = [];

  @override
  void initState() {
    super.initState();
    fetchClientData();
    retrieveClientId();
    if (clientId != null) {
      fetchLanguages(clientId!).then((fetchedLanguages) {
        setState(() {
          languages = fetchedLanguages;
        });
      });
    } else {
      // Handle the case when clientId is null
      print('Client ID is null.');
    }
  }

  Future<int?> getSavedClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    print('Fetched Client ID: $clientId');
    return clientId;
  }

  void retrieveClientId() async {
    int? id = await getSavedClientId();
    setState(() {
      clientId = id;
    });
  }

  Future<void> fetchClientData() async {
    int? clientId = await getSavedClientId();

    if (clientId != null) {
      final apiUrl = 'http://172.233.199.17/clients.php';
      final url = Uri.parse(
          '$apiUrl?client_id=$clientId'); // Use string interpolation to build the URL

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Map<String, dynamic> clientData = jsonResponse['data']['client'];

        // Extract specific fields from the client data
        String clientFirstName = clientData['client_firstname'];
        String clientLastName = clientData['client_lastname'];
        String clientphonenumber = clientData['client_phone'];
        String clientemail = clientData['client_email'];
        if (clientId != null) {
          fetchLanguages(clientId!).then((fetchedLanguages) {
            setState(() {
              languages = fetchedLanguages;
            });
          });
        } else {
          // Handle the case when clientId is null
          print('Client ID is null.');
        }
        setState(() {
          firstName = clientFirstName;
          lastName = clientLastName;
          phonenumber = clientphonenumber;
          email = clientemail;
          print('First Name: $firstName'); // Added a label for clarity
          print('Last Name: $lastName'); // Added a label for clarity
          print('phone number: $phonenumber'); // Added a label for clarity
          print('email : $clientemail'); // Added a label for clarity
        });
      } else {
        print(
            'Failed to fetch client data. Status code: ${response.statusCode}');
      }
    } else {
      print('Client ID not found in SharedPreferences.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLanguages(int clientId) async {
    final apiUrl = 'http://172.233.199.17/clients.php';
    final url =
        Uri.parse('$apiUrl?client_id=$clientId'); // Append client_id to the URL

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> languagesData = jsonResponse['data']['languages'];

      // Convert the list of languages to a list of maps
      List<Map<String, dynamic>> languages = languagesData.map((language) {
        return {
          'lang_id': language['lang_id'],
          'lang': language['lang'],
        };
      }).toList();

      return languages;
    } else {
      throw Exception('Failed to fetch languages');
    }
  }

// Future<void> fetchWorkerData() async {
//   int? workerId = await getSavedWorkerId();
//   print('Fetched Worker ID: $workerId'); // Add this line
//
//   if (workerId != null) {
//     final url = Uri.https('172.233.199.17', '/worker.php', {'worker_id': workerId.toString()});
//     print('Fetched Worker ID: $workerId'); // Print the worker ID
//
//     var http;
//     final response = await http.get(url);
//
//
//
//     if (response.statusCode == 200) {
//       final responseData = response.body;
//       final jsonResponse = json.decode(responseData);
//
//       // Extract the data from the response JSON
//       Map<String, dynamic> workerData = jsonResponse['data']['worker'];
//       List<dynamic> languages = jsonResponse['data']['languages'];
//
//       // Now you can access the worker data and languages list
//       print('Worker Data: $workerData');
//       print('Languages: $languages');
//
//       // You can also extract specific fields from the worker data
//       firstName  = workerData['worker_firstname'];
//       lastName  = workerData['worker_lastname'];
//       String workerLicenseNo = workerData['worker_license_no'];
//       String workerEmail = workerData['worker_email'];
//       String workerPhone = workerData['worker_phone'];
//       String workerAddress = workerData['worker_address'];
//       String workerProfilePic = workerData['worker_profile_pic'];
//       String workerJobType = workerData['worker_job_type'];
//       String workerOtherJobType = workerData['worker_other_job_type'];
//       String workerExpYears = workerData['worker_exp_years'];
//       String workerZip = workerData['worker_zip'];
//       String workerRadius = workerData['worker_raduis'];
//       String workerPreferredPay = workerData['worker_prefered_pay'];
//       String workerUsername = workerData['worker_username'];
//       String workerPassword = workerData['worker_password'];
//       String addressId = workerData['address_id'];
//       String street1 = workerData['street1'];
//       String street2 = workerData['street2'];
//       String city = workerData['city'];
//       String state = workerData['state'];
//       String zip = workerData['zip'];
//       // You can also loop through the languages list and extract each language
//       for (var language in languages) {
//         String langId = language['lang_id'];
//         String lang = language['lang'];
//         print('Language ID: $langId, Language: $lang');
//       }
//     } else {
//       print('Failed to fetch worker data. Status code: ${response.statusCode}');
//     }
//   } else {
//     print('Worker ID not found in SharedPreferences.');
//   }
// }
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
                    backgroundImage:
                        AssetImage('assets/images/profileimage.png'),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Zeyad Tarek',
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
                                        '$firstName $lastName',
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
                                child: Image.asset(
                                  'assets/images/profileimage.png',
                                  // Replace with the image URL
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
                                    Expanded(
                                      child: Text(
                                        languages != null
                                            ? languages
                                                .map((language) => language['lang'])
                                                .join(' , ')
                                            : '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
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
                                    'New York ',
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
                          onPressed: () {},
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

