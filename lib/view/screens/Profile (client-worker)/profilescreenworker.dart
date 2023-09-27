import 'dart:convert';
import 'package:workdone/model/mediaquery.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/DrawerControllerworker.dart';



class ProfileScreenworker extends StatefulWidget {
  @override
  State<ProfileScreenworker> createState() => _ProfileScreenworkerState();
}
class _ProfileScreenworkerState extends State<ProfileScreenworker> {

String firstName = '';

String lastName = '';
int? workerId;

@override
void initState() {
  super.initState();
  fetchWorkerData();
  retrieveWorkerId();
}

Future<int?> getSavedWorkerId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? workerId = prefs.getInt('worker_id');
  print('Fetched Worker ID: $workerId'); // Add this line

  return workerId;
}
void retrieveWorkerId() async {
  int? id = await getSavedWorkerId();
  setState(() {
    workerId = id;
  });
}
Future<void> fetchWorkerData() async {
  int? workerId = await getSavedWorkerId();

  if (workerId != null) {
    final apiUrl = 'http://172.233.199.17/worker.php';
    final url = Uri.parse(apiUrl + '?worker_id=$workerId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Extract worker data and languages
      Map<String, dynamic> workerData = jsonResponse['data']['worker'];
      List<dynamic> languages = jsonResponse['data']['languages'];

      // Now you can access the worker data and languages list
      print('Worker Data: $workerData');
      print('Languages: $languages');

      // Extract specific fields from the worker data
      String workerFirstName = workerData['worker_firstname'];
      String workerLastName = workerData['worker_lastname'];
      // ... other fields

      // Update state variables to display the fetched worker information
      setState(() {
        firstName = workerFirstName;
        lastName = workerLastName;
        // ... update other fields
      });
    } else {
      print('Failed to fetch worker data. Status code: ${response.statusCode}');
    }
  } else {
    print('Worker ID not found in SharedPreferences.');
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

    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerworker(),

      backgroundColor: Colors.white,
      body: SafeArea(
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
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {             _scaffoldKey.currentState?.openDrawer();
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
                          onPressed: () {Get.back();},
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
                      height: ScreenUtil.opacitycontainerheight2,
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
                                  Icon(
                                    Icons.star,
                                    color: HexColor('#EFCE4A'),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '4.2',
                                    style: TextStyle(
                                        color: HexColor('#898A8F'),
                                        fontSize: 18),
                                  )
                                ],
                              ),
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                    color: HexColor('#022C43'),
                                    fontSize: 26,
                                    fontWeight: FontWeight.normal),
                              ),
                           Spacer(),
                           Row(
                             children: [
                               Container(

                             width: ScreenUtil.insidecontainerleftwidth,
                             height: ScreenUtil.insidecontainerleftheight,
                             decoration: BoxDecoration(
                               border: Border(
                                 top: BorderSide(
                                   color: HexColor('#B8B8B8'),
                                   width: 1,
                                 ),
                                 right: BorderSide(
                                   color: HexColor('#B8B8B8'),
                                   width: 1,
                                 ),
                               ),
                             ),
                             child:
                                   Column(mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Center(
                                         child:
                                         Text('3250',style: TextStyle(color: HexColor('#022C43'),fontWeight: FontWeight.bold,fontSize: 20),),

                                       ),
                                       Center(
                                         child:
                                         Text('Total Jobs',style: TextStyle(color: HexColor('#707070'),fontWeight: FontWeight.normal,fontSize: 17),),

                                       )
                                     ],
                                   )
                           ),
                               Container(

                                 width: ScreenUtil.insidecontainerleftwidth,
                                 height: ScreenUtil.insidecontainerleftheight,
                                 decoration: BoxDecoration(
                                   border: Border(
                                     top: BorderSide(
                                       color: HexColor('#B8B8B8'),
                                       width: 1,
                                     ),
                                     left: BorderSide(
                                       color: HexColor('#B8B8B8'),
                                       width: 1,
                                     ),
                                   ),
                                 ),
                                 child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Center(
                                       child:
                                       Text('2.5',style: TextStyle(color: HexColor('#022C43'),fontWeight: FontWeight.bold,fontSize: 20),),

                                     ),
                                     Center(
                                       child:
                                       Text('Years',style: TextStyle(color: HexColor('#707070'),fontWeight: FontWeight.normal,fontSize: 17),),

                                     )
                                   ],
                                 )

                               ),
                             ],
                           )

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
              padding:  EdgeInsets.symmetric(vertical: 19,horizontal: 20),
              child: Text('Personal Info'.toUpperCase(),style: TextStyle(color: HexColor('#022C43'), fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            Center(
              child: Container(
                height: ScreenUtil.Infocontainerheight,
                width: ScreenUtil.Infocontainerwidth,
                decoration: BoxDecoration(
                  color: HexColor('#F9F9F9'),
                  borderRadius: BorderRadius.circular(20),

                ),
                child: Column

                  (
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(top: 20,),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: HexColor('#707070').withOpacity(0.1),
                              width: 1,
                            ),
                        ),),
                        child:
                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Phone Number:',style: TextStyle(color: HexColor('#4D8D6E'),fontWeight: FontWeight.w400,fontSize: 17),),
                            ),

                            SizedBox(width :ScreenUtil.sizeboxwidth3,),
                            Text('+91 931 488 2375',style: TextStyle(color: HexColor('#404040'),fontSize: 15),)

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
                        ),),
                      child:
                      Row(
                        children: [
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Email Address:',style: TextStyle(color: HexColor('#4D8D6E'),fontWeight: FontWeight.w400,fontSize: 17),),
                          ),

                          SizedBox(width :ScreenUtil.sizeboxwidth3,),
                          Text('MyName@gmail.com',style: TextStyle(color: HexColor('#404040'),fontSize: 15),)

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
                        ),),
                      child:
                      Row(
                        children: [
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Language Spoken:',style: TextStyle(color: HexColor('#4D8D6E'),fontWeight: FontWeight.w400,fontSize: 17),),
                          ),

                          SizedBox(width :ScreenUtil.sizeboxwidth3,),
                          Text('English and French ',style: TextStyle(color: HexColor('#404040'),fontSize: 15),)

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
                        ),),
                      child:
                      Row(
                        children: [
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Address:',style: TextStyle(color: HexColor('#4D8D6E'),fontWeight: FontWeight.w400,fontSize: 17),),
                          ),

                          SizedBox(width :ScreenUtil.sizeboxwidth3,),
                          Text('New York ',style: TextStyle(color: HexColor('#404040'),fontSize: 15),)

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            )
          ,
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 23),
            child: Text('Reviews', style: TextStyle( color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
          ),
            Padding(
              padding:  EdgeInsets.symmetric( horizontal: 26),
              child: Row(
                children: [
                  Text('SIVAG',style: TextStyle(fontSize: 17,color: Colors.black,fontWeight: FontWeight.w300),)
                ,
              SizedBox(width: 20,),
                  SvgPicture.asset(
                    'assets/icons/stars.svg',
                    // Replace with the path to your SVG file
                    width: 20.0,
                    // Replace with the desired width of the icon
                    height:
                    20.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                  ),
                ],
              ),
            )
            ,
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 25,vertical: 10),
              child: Text('Good Job',style: TextStyle(color: HexColor('#9A9A9A'),fontSize: 16),),
            ),
        SizedBox(height: 17,),

        Container(
          width: ScreenUtil.buttonscreenwidth,
          height: 45,
          margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
          child: ElevatedButton(
            onPressed: () {
            },
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

      SizedBox(
        height: ScreenUtil.sizeboxheight,
      ),
          ],
        )),
      ),
    );
  }
}
