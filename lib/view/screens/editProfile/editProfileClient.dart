import 'dart:convert';
import 'dart:io';

import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:workdone/view/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;


import '../Edit address.dart';
import '../Support Screen/Support.dart';
import '../changePassword.dart';

class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  List<String> americanPhoneCodes = ['+1', '+20', '+30', '+40']; // Add more if needed
  String ? selectedLanguage;
  List<Map<String, dynamic>> languages = [];
  List<int> selectedLanguages = [];
  List<String> selectedLanguagename = [];

  int ?userId ;
  String usertype='';



  Future<void> Languagedata() async {
    const String url = "https://workdonecorp.com/api/get_all_languages";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List data = jsonResponse['data'];
        // Process the fetched language data as needed
        print(data);
        setState(() {
          languages = data.map((lang) => {'id': lang['id'], 'name': lang['name']}).toList();
        });
      } else {
        print('Error: ${jsonResponse['msg']}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }


  List <int>  selectedLanguageids=[];


  TextEditingController firstNameController = TextEditingController();
   TextEditingController lastNameController = TextEditingController();
   TextEditingController emailController = TextEditingController();
   TextEditingController paypalcontroller = TextEditingController();
   TextEditingController phoneController = TextEditingController();
   bool isPhoneNumberValid = true; // Add a flag to track phone number validation
   bool validatePhoneNumber(String phoneNumber) {
     final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
     return formattedPhoneNumber.length == 10;
   }
  TextEditingController formattedPhoneNumberController = TextEditingController();

  String formattedPhoneNumber = ''; // Store the formatted phone number
  String formattedPhoneNumber2 = ''; // Formatted phone number to display
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 12) {
      // Format the phone number as "(XXX) XXX-XXXX"
      return '(${phoneNumber.substring(2, 5)}) ${phoneNumber.substring(5, 8)}-${phoneNumber.substring(8, 12)}';
    }
    return phoneNumber;
  }

  String formatPhoneNumber(String input) {
    if (input.isEmpty) return '';

    input = input.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
    final formattedText = StringBuffer();
    int index = 0;

    // Add the country code, if present
    if (input.startsWith('+')) {
      formattedText.write(input[0]);
      index++;
    }

    // Add the opening parenthesis, if needed
    if (input.length >= 4) {
      formattedText.write('(${input.substring(index, index + 3)}) ');
      index += 3;
    } else if (input.length > 3) {
      formattedText.write('(' + input.substring(index));
      return formattedText.toString();
    } else {
      formattedText.write('(' + input.substring(index));
      return formattedText.toString();
    }

    // Add the middle part, if needed
    if (input.length >= 7) {
      formattedText.write('${input.substring(index, index + 3)}-');
      index += 3;
    } else if (input.length > index) {
      formattedText.write(input.substring(index));
      return formattedText.toString();
    } else {
      return formattedText.toString();
    }

    // Add the remaining part
    if (input.length > index) {
      formattedText.write(input.substring(index));
    }

    return formattedText.toString();
  }


  File? _image;
  final picker = ImagePicker();

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  String firstname = '';
  String secondname = '';
  String email = '';
  String password = '';
  String profile_pic = '';
  String language = '';
  String phonenumber = '';
  late String userToken;
  late String languagesString;

  @override
  void initState() {
    super.initState();
    _getUserToken();
// setState(() {
//   firstNameController.text = firstname;
//   lastNameController.text=  secondname;
//   emailController.text= email;
//   phoneController.text = phonenumber;
// });
    // Fetch user profile information when the screen initializes
    Languagedata();
    getuserid();
    languagesString = selectedLanguagename.join(', ');

    filteredLanguages = languages;

    _getUserProfile();
  }
  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }

  bool _isLoading = false;
  Future<void> getuserid() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      print ('fetching user id');
      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/get_user_id_by_token';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          print ('done  user id');

          if (responseData.containsKey('user_id')) {

            userId = responseData['user_id'];

            // Now, userId contains the extracted user_id value
            print('User ID: $userId');

            // Optionally, save the user_id to SharedPreferences
            prefs.setInt('user_id', userId ?? 0);
          } else {
            print('Error: Response data does not contain the expected structure.');
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

  Future<void> sendprofile() async {
    final url = Uri.parse('https://workdonecorp.com/api/update_client_profile');
    try {
      setState(() {
        _isLoading = true;
      });
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
      if (firstNameController.text.isNotEmpty) {
        request.fields['firstname'] = firstNameController.text;
      } else {
        request.fields['firstname'] = firstname;
      }
      if (lastNameController.text.isNotEmpty) {
        request.fields['lastname'] = lastNameController.text;
      } else {
        request.fields['lastname'] = secondname;
      }
      if (selectedLanguages .isNotEmpty) {
        for (var i = 0; i < selectedLanguages.length; i++) {
          request.fields['language[$i]'] = selectedLanguages[i].toString();
        }
      }else {
        for (var i = 0; i < selectedLanguageids.length; i++) {
          request.fields['language[$i]'] = selectedLanguageids[i].toString();
        }
      }
      if (phoneController.text.isNotEmpty) {
        request.fields['phone'] = phoneController.text;
      } else {
        request.fields['phone'] = phonenumber;
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
            'title': 'Profile Updated',
            'body': 'Your profile information has been successfully updated 😊',
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
            msg: "Profile updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Navigate to the layout screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => layoutclient(showCase: false,)),
          );
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

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
              phonenumber = profileData['phone'] ?? '';
              List<dynamic> languages = profileData['language'] ?? [];
              selectedLanguageids = languages.map<int>((language) => language['id']).toList();
              List<String> languageNames = languages.map<String>((language) => language['name']).toList();
              languageString = languageNames.join(', ');
              selectedLanguage = languageString;
              selectedLanguages = selectedLanguageids;

              selectedLanguagename=languageNames;
              languagesString = selectedLanguagename.join(', ');

              List<dynamic> languagesnumber = profileData['language'] ?? [];
              selectedLanguageids = languagesnumber.map<int>((language) => language['id']).toList();

              // Add this line
            });
            print('selected language  :: ${selectedLanguage}');
            print('selected languageid  :: ${selectedLanguageids}');
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
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }

  // Test if token is saved

  bool isLanguageListVisible = false; // Add this variable
  bool isSearchBarVisible = false;
  List<Map<String, dynamic>> filteredLanguages = [];

  final ScreenshotController screenshotController90 = ScreenshotController();



  String unique= 'editprofileclient' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController90.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selectedPhoneCode = americanPhoneCodes[0]; // Initialize with the first code
    bool isPhoneNumberValid = true; // Add a flag to track phone number validation
    bool validatePhoneNumber(String phoneNumber) {
      final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
      return formattedPhoneNumber.length == 10;
    }
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      blurEffectIntensity: 7,
      progressIndicator: CircularProgressIndicator(),


      dismissible: false,
      opacity: 0.4,
      child: Scaffold( floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
        child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
        shape: CircleBorder(), // Make the button circular
      ),

        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 67,
          backgroundColor: Colors.white,
          title: Text(
            'Edit Profile',
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
              Navigator.pop(context);
            },
          ),
        ),
        body:
        Screenshot(
          controller:screenshotController90 ,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
                                fontSize: 16 ,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 3,),
                        Text('You Can Edit Any Field Only and Press Submit',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                color: Colors.black45,
                                fontSize: 13 ,
                                fontWeight: FontWeight.w600),
                            decoration: TextDecoration.underline,

                          ),
                        ),
                      ],
                    ),
                  ),
      SizedBox(height: 8,),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular Image
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _image != null
                                ? DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(_image!),
                            )
                                : profile_pic == '' || profile_pic.isEmpty
                                || profile_pic == "https://workdonecorp.com/storage/" ||
                                !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))
                                ? DecorationImage(
                              fit: BoxFit.cover,
                              image:AssetImage('assets/images/default.png') ,

                            )
                                : DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(profile_pic),
                            ) ,
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
                              color: Colors.grey.withOpacity(0.4),
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
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: Text('First Name'),
                            ),
                            Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Background color
                                  borderRadius: BorderRadius.circular(
                                      20), // Circular border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    controller: firstNameController,
                                    decoration: InputDecoration(
                                      hintText: firstname,
                                      border:
                                          InputBorder.none,
                                      counterText: "", // Hide the counter
                        
                                      // Remove default border
                                    ),
                                    maxLength: 12, // Limit the input to 12 characters
                        
                                  ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: Text('Last Name'),
                            ),
                            Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Background color
                                  borderRadius: BorderRadius.circular(
                                      20), // Circular border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    controller: lastNameController,
                                    decoration: InputDecoration(
                                      hintText: secondname,
                                      border:
                                          InputBorder.none,
                                      counterText: "", // Hide the counter
                        // Remove default border
                                    ),
                                    maxLength: 12, // Limit the input to 12 characters

                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Text('Email'),
                  ),
                  Container(
                      width: size.width * 0.90,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color
                        borderRadius: BorderRadius.circular(
                            20), // Circular border radius
                      ),
                      child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(email,style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[800], // Button text color
                              ),
                              ),
                            ],
                          )
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10),
                                  child: Text('language'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLanguageListVisible = !isLanguageListVisible;
                                      isSearchBarVisible = isLanguageListVisible;
                                      // Remove the condition to update filteredLanguages regardless of the search bar visibility
                                      filteredLanguages = languages;

                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    height: size.height * 0.09,
                                    width: size.width * 0.93,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(29),
                                    ),
                                    child: Row(
                                      children: [
                                        languagesString.isNotEmpty ?
                                        Expanded(
                                          child: Text(
                                            '${languagesString?? 'select language'}',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.grey[700]),
                                          ),
                                        )
                                            :                                      Expanded(

                                          child: Text(
                                            'Select language',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.grey[700]),
                                          ),
                                        )
                                        ,
                                        Icon(
                                          isLanguageListVisible
                                              ? Icons.arrow_drop_up
                                              : Icons.arrow_drop_down,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Validation error message
                                // if (isLanguageListVisible && selectedLanguages.isEmpty)
                                //   Padding(
                                //     padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                //     child: Text(
                                //       'Please select a language',
                                //       style: TextStyle(color: Colors.red),
                                //     ),
                                //   ),

                                // Search bar
                                Visibility(
                                  visible: isSearchBarVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: TextField(
                                      onChanged: (query) {
                                        setState(() {
                                          filteredLanguages = languages
                                              .where((language) =>
                                              language['name']
                                                  .toLowerCase()
                                                  .contains(query.toLowerCase()))
                                              .toList();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search languages...',
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // List of filtered languages
                                Visibility(
                                  visible: isLanguageListVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: filteredLanguages.map((language) {
                                      final langName = language['name'];
                                      final langId = language['id'];
                                      languagesString = selectedLanguagename.join(', ');

                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(langName),
                                            leading: Checkbox(
                                              activeColor: HexColor('#4D8D6E'),
                                              value: selectedLanguages.contains(langId),
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value!) {
                                                    selectedLanguages.add(langId);
                                                    selectedLanguagename.add((langName));
                                                    languagesString = selectedLanguagename.join(', ');
                                                    print('selected languages add ${selectedLanguages}'); // Print the selected language IDs



                                                  } else {
                                                    print('selected languages remove ${selectedLanguages}'); // Print the selected language IDs
                                                    selectedLanguagename.remove((langName));
                                                    languagesString = selectedLanguagename.join(', ');
                                                    selectedLanguages.remove(langId);


                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),


                              ]))),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Text('Phone Number'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    height: size.height * 0.103,
                    width: size.width * 0.93,
                    decoration: BoxDecoration(

                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(

                                decoration: BoxDecoration(

                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/uslogo.svg',
                                        width: 27.0,
                                        height: 27.0,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '+1',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Add some spacing between the dropdown and the text field/ Add some spacing between the dropdown and the text field
                              Expanded(
                                child: TextFormField(

                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    hintText: phonenumber,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(0), // Remove content padding

                                  ),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    setState(() {
                                      // Format the phone number using the formatPhoneNumber function
                                      final formattedPhoneNumber = formatPhoneNumber(value);
                                      phoneController.value = TextEditingValue(
                                        text: formattedPhoneNumber,
                                        selection: TextSelection.collapsed(offset: formattedPhoneNumber.length),

                                      );
                  // Add +1 prefix to the formatted phone number
                                      phoneController.text = '$formattedPhoneNumber';

                                      // Ensure the cursor position is at the end
                                      phoneController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: phoneController.text.length),
                                      );
                                      print(phoneController.text);
                                      // Validate the phone number
                                      isPhoneNumberValid = validatePhoneNumber(formattedPhoneNumber);
                                    });
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10), // Limit the input length to 10 digits
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a phone number';
                                    }

                                    // Basic validation: Check if the formatted phone number has 10 digits
                                    final formattedPhoneNumber = formatPhoneNumber(value);
                                    if (formattedPhoneNumber.replaceAll(RegExp(r'\D'), '').length != 10) {
                                      return 'Invalid phone number';
                                    }

                                    return null; // Return null if the input is valid
                                  },
                                ),
                              ),
                            ],
                          ),
                        ), if (!isPhoneNumberValid)
                          Text(
                            'Please enter a valid phone number.',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
          SizedBox(height: 13,)
           ,             Container(
                    width: size.width * 0.90,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Background color
                      borderRadius:
                          BorderRadius.circular(20), // Circular border radius
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        final userToken = prefs.getString('user_token') ?? '';
                        print(userToken);

                        // Check if userToken is not empty before navigating
                        if (userToken.isNotEmpty) {
                          Get.to(changePasswordscreen(userToken: userToken));
                        } else {
                          // Handle the case where userToken is empty, e.g., show a message
                          print('User token is empty. Cannot navigate to ChangePasswordScreen.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200], // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Circular border radius
                        ),
                      ),
                      child: Text(
                        'Change Password', // Button text
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800], // Button text color
                        ),
                      ),
                    ),

                  ),
                  SizedBox(height: 20,),
                  Container(
                    width: size.width * 0.90,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Background color
                      borderRadius:
                      BorderRadius.circular(20), // Circular border radius
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        final userToken = prefs.getString('user_token') ?? '';
                        print(userToken);

                        // Check if userToken is not empty before navigating
                        if (userToken.isNotEmpty) {
                          Get.to(editAddressClient());
                        } else {
                          // Handle the case where userToken is empty, e.g., show a message
                          print('User token is empty. Cannot navigate to ChangePasswordScreen.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200], // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Circular border radius
                        ),
                      ),
                      child: Text(
                        'Edit Address', // Button text
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[800], // Button text color
                        ),
                      ),
                    ),

                  ),

                  SizedBox(
                    height: 12,
                  ),
                 SizedBox(height: 15,),
                  _isLoading == false ?
                  Center(
                    child: RoundedButton(
                      text: 'Submit',
                      press: () {
                        // Call the method to update the client profile
                        sendprofile();
                      },
                    )

                  ) :Center(child: CircularProgressIndicator())

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
