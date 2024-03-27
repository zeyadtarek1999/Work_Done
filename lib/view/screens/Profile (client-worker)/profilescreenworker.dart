import 'dart:convert';
import 'dart:io';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/screens/homescreen/home%20screenClient.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/homescreen/homeWorker.dart';


import '../../../model/mediaquery.dart';
import '../Support Screen/Support.dart';
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

  File? _image;
  final GlobalKey<State> _dialogprofileworkerKey = GlobalKey<State>();

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
  bool _isLoading = false;

  Future<void> sendprofile() async {
    final url = Uri.parse('https://workdonecorp.com/api/update_profile_image');

    try {

      setState(() {
        _isLoading = true;
      });
      Navigator.pop(context);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print (userToken);
      // Make the API request
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $userToken'
      ;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(await response.stream.transform(utf8.decoder).join());
        setState(() {
          _isLoading = false;
        });



        if (responseBody['status'] == 'success') {
          print(responseBody);
          DateTime currentTime = DateTime.now();

          // Format the current time into your desired format
          String formattedTime = DateFormat('h:mm a').format(currentTime);
          Map<String, dynamic> newNotification = {
            'title': 'Profile image Updated',
            'body': 'Your profile image has been successfully updated 😊',
            'time': formattedTime,
            'isRead':false
            // Add other notification data as needed
          };
          print('sended notification ${[newNotification]}');


          SaveNotificationToFirebase.saveNotificationsToFirestore(userId.toString(), [newNotification]);
          print('getting notification');

          // Get the user document reference
          // Get the user document reference
          // Get the user document reference
          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId.toString());

// Get the user document
          DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
          if (doc.exists) {
            // Extract the FCM token and notifications list from the document
            String? receiverToken = doc.get('fcmToken');
            List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

            // Check if the new notification is not null and not already in the list
            if (!notifications.any((notification) => notification['id'] == newNotification['id'])) {
              // Add the new notification to the beginning of the list
              notifications.insert(0, newNotification);

              // Update the user document with the new notifications list
              await userDocRef.update({
                'notifications': notifications,
              });

              print('Notifications saved for user $userId');
            }

            // Display the notifications list in the app
            print('Notifications for user $userId:');
            for (var notification in notifications) {
              String? title = notification['title'];
              String? body = notification['body'];
              print('Title: $title, Body: $body');
              await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
              print('Last notification sent to $userId');
            }
          } else {
            print('User document not found for user $userId');
          }

          Fluttertoast.showToast(
            msg: "Profile image updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          await  _getUserProfile();
          await  getaddressuser();
        }

      }
      else {

        print('Failed to edit profile. Status code: ${response.statusCode}');

        // Print the response body for more details
        print('Response body: ${await response.stream.transform(utf8.decoder).join()}');

      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      print('Error edit profile: $e');
      // Handle errors as needed
    }
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
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      blurEffectIntensity: 7,
      progressIndicator: CircularProgressIndicator(),


      dismissible: false,
      opacity: 0.4,
      child: Scaffold(
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
                            child:                       Center(
                              child:  Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withOpacity(0.7),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: _image != null
                                          ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_image!),
                                      )
                                          : profile_pic == '' || profile_pic.isEmpty
                                          || profile_pic == "https://workdonecorp.com/storage/" ||
                                          !(profile_pic.toLowerCase().endsWith('.jpg') ||
                                              profile_pic.toLowerCase().endsWith('.png'))
                                          ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/images/default.png'),

                                      )
                                          : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(profile_pic),
                                      ),
                                    ),
                                  ),
                                  // Opacity Overlay
                                  GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Edit Profile',
                                                  style: TextStyle(
                                                    color: Colors.black45,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 10,),

                                                Center(
                                                  child: StatefulBuilder(
                                                      key: _dialogprofileworkerKey,
                                                      builder: (BuildContext context, StateSetter setState) {
                                                        return Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Container(
                                                              width: 140,
                                                              height: 140,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.grey.withOpacity(0.7),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 130,
                                                              height: 130,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                image: _image != null
                                                                    ? DecorationImage(
                                                                  fit: BoxFit.cover,
                                                                  image: FileImage(_image!),
                                                                )
                                                                    : profile_pic == '' || profile_pic.isEmpty
                                                                    || profile_pic ==
                                                                        "https://workdonecorp.com/storage/" ||
                                                                    !(profile_pic.toLowerCase().endsWith(
                                                                        '.jpg') ||
                                                                        profile_pic.toLowerCase().endsWith(
                                                                            '.png'))
                                                                    ? DecorationImage(
                                                                  fit: BoxFit.cover,
                                                                  image: AssetImage(
                                                                      'assets/images/default.png'),

                                                                )
                                                                    : DecorationImage(
                                                                  fit: BoxFit.cover,
                                                                  image: NetworkImage(profile_pic),
                                                                ),
                                                              ),
                                                            ),
                                                            // Opacity Overlay
                                                            GestureDetector(
                                                              onTap: () async {
                                                                final action =
                                                                await showDialog<
                                                                    String>(
                                                                  context: context,
                                                                  builder: (BuildContext
                                                                  context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Choose an option'),
                                                                      content: Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                        children: [
                                                                          ListTile(
                                                                            leading: Icon(
                                                                                Icons
                                                                                    .image),
                                                                            title: Text(
                                                                                'Gallery'),
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                  context,
                                                                                  'gallery');
                                                                            },
                                                                          ),
                                                                          ListTile(
                                                                            leading: Icon(
                                                                                Icons
                                                                                    .camera),
                                                                            title: Text(
                                                                                'Camera'),
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                  context,
                                                                                  'camera');
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );

                                                                if (action == 'gallery') {
                                                                  final pickedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                    source: ImageSource
                                                                        .gallery,
                                                                  );
                                                                  if (pickedImage !=
                                                                      null) {
                                                                    setState(() {
                                                                      _image = File(
                                                                          pickedImage
                                                                              .path);
                                                                    });
                                                                  }
                                                                } else if (action ==
                                                                    'camera') {
                                                                  final pickedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                    source: ImageSource
                                                                        .camera,
                                                                  );
                                                                  if (pickedImage !=
                                                                      null) {
                                                                    setState(() {
                                                                      _image = File(
                                                                          pickedImage
                                                                              .path);
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                width: 150,
                                                                height: 150,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                            ),
                                                            // Camera Logo
                                                            GestureDetector(
                                                              onTap: () async {
                                                                final action =
                                                                await showDialog<
                                                                    String>(
                                                                  context: context,
                                                                  builder: (BuildContext
                                                                  context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Choose an option'),
                                                                      content: Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                        children: [
                                                                          ListTile(
                                                                            leading: Icon(
                                                                                Icons
                                                                                    .image),
                                                                            title: Text(
                                                                                'Gallery'),
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                  context,
                                                                                  'gallery');
                                                                            },
                                                                          ),
                                                                          ListTile(
                                                                            leading: Icon(
                                                                                Icons
                                                                                    .camera),
                                                                            title: Text(
                                                                                'Camera'),
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                  context,
                                                                                  'camera');
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );

                                                                if (action == 'gallery') {
                                                                  final pickedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                    source: ImageSource
                                                                        .gallery,
                                                                  );
                                                                  if (pickedImage !=
                                                                      null) {
                                                                    setState(() {
                                                                      _image = File(
                                                                          pickedImage
                                                                              .path);
                                                                    });
                                                                  }
                                                                } else if (action ==
                                                                    'camera') {
                                                                  final pickedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                    source: ImageSource
                                                                        .camera,
                                                                  );
                                                                  if (pickedImage !=
                                                                      null) {
                                                                    setState(() {
                                                                      _image = File(
                                                                          pickedImage
                                                                              .path);
                                                                    });
                                                                  }
                                                                }
                                                              },

                                                              child: Icon(
                                                                Icons.camera_alt,
                                                                size: 35,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                ),
                                                SizedBox(height: 15,),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  // Center the buttons
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        // Implement your image editing logic here
                                                        Navigator.of(context).pop(); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Set Cancel button color to red
                                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set text color to white
                                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust button padding
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10), // Add spacing between buttons
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if(_image == null){
                                                          Fluttertoast.showToast(
                                                            msg: "You didnt change the image",
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.green,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0,
                                                          );


                                                        }else{                                sendprofile();}
                                                      },
                                                      child: Text('Submit'),
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Set Submit button color to green
                                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set text color to white
                                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust button padding
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  // Camera Logo
                                  // GestureDetector(
                                  //   onTap: () async {
                                  //     final action =
                                  //     await showDialog<
                                  //         String>(
                                  //       context: context,
                                  //       builder: (BuildContext
                                  //       context) {
                                  //         return AlertDialog(
                                  //           title: Text(
                                  //               'Choose an option'),
                                  //           content: Column(
                                  //             mainAxisSize:
                                  //             MainAxisSize
                                  //                 .min,
                                  //             children: [
                                  //               ListTile(
                                  //                 leading: Icon(
                                  //                     Icons
                                  //                         .image),
                                  //                 title: Text(
                                  //                     'Gallery'),
                                  //                 onTap: () {
                                  //                   Navigator.pop(
                                  //                       context,
                                  //                       'gallery');
                                  //                 },
                                  //               ),
                                  //               ListTile(
                                  //                 leading: Icon(
                                  //                     Icons
                                  //                         .camera),
                                  //                 title: Text(
                                  //                     'Camera'),
                                  //                 onTap: () {
                                  //                   Navigator.pop(
                                  //                       context,
                                  //                       'camera');
                                  //                 },
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       },
                                  //     );
                                  //
                                  //     if (action == 'gallery') {
                                  //       final pickedImage =
                                  //       await ImagePicker()
                                  //           .pickImage(
                                  //         source: ImageSource
                                  //             .gallery,
                                  //       );
                                  //       if (pickedImage !=
                                  //           null) {
                                  //         setState(() {
                                  //           _image = File(
                                  //               pickedImage
                                  //                   .path);
                                  //         });
                                  //       }
                                  //     } else if (action ==
                                  //         'camera') {
                                  //       final pickedImage =
                                  //       await ImagePicker()
                                  //           .pickImage(
                                  //         source: ImageSource
                                  //             .camera,
                                  //       );
                                  //       if (pickedImage !=
                                  //           null) {
                                  //         setState(() {
                                  //           _image = File(
                                  //               pickedImage
                                  //                   .path);
                                  //         });
                                  //       }
                                  //     }
                                  //   },
                                  //
                                  //   child: Icon(
                                  //     Icons.camera_alt,
                                  //     size: 35,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                ],

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
                                              child: (license_pic.isNotEmpty && license_pic != "https://workdonecorp.com/images/")
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

                     // editProfileworker
                      Center(
                        child: Container(
                          width: ScreenUtil.buttonscreenwidth,
                          height: 60,
                          margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(editProfileworker());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#4D8D6E'),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
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
        ),
    );

  }void drawerControl() {
    advancedDrawerController.showDrawer();
  }
}

