import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;

import '../../../model/changePassword.dart';
import '../../../model/getClientProfiledataModel.dart';
import '../../../model/post editprofilemodel.dart';
import '../Edit address.dart';
import '../changePassword.dart';

class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _getUserToken();

    // Fetch user profile information when the screen initializes
    _getUserProfile();
  }
  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }
  void _updateClientProfile() async {
    // Make sure to fill in the values from your text controllers or other sources
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String phone = phoneController.text;
    String imagePath = _image!.path;
    String language = "English";
    if (_image == null) {
      // Show a toast message and return early
      Fluttertoast.showToast(
        msg: "Please select an image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    // Call the API to update the client's profile
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('user_token') ?? '';
      await UpdateClientProfileApi.updateClientProfile(
        token: userToken,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profile_pic: imagePath,
        language: language,
      );
print(_image!.path);
      // Handle success (you can show a success message or navigate to another screen)
    } catch (error) {
      // Handle error (you can show an error message)
      print('Error updating client profile: $error');
    }
  }
  // Function to fetch user profile information

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

  // Test if token is saved
  List<Map<String, dynamic>> languages = [
    {'lang_id': '1', 'lang': 'English'},
    {'lang_id': '2', 'lang': 'Arabic'},
    {'lang_id': '3', 'lang': 'French'},
  ];
  bool isLanguageListVisible = false; // Add this variable
  bool isSearchBarVisible = false;
  List<Map<String, dynamic>> filteredLanguages = [];
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        color: Colors.blue, // Change the color as needed
                        image: _image != null
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image!),
                        )
                            : profile_pic.isNotEmpty
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(profile_pic),
                        )
                            : null,
                      ),
                    ),
                    // Opacity Overlay
                    GestureDetector(
                      onTap: _getImageFromGallery,
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
                    Icon(
                      Icons.camera_alt,
                      size: 35,
                      color: Colors.white,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text('First Name'),
                      ),
                      Container(
                          width: 156,
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
                                    InputBorder.none, // Remove default border
                              ),
                            ),
                          ))
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Text('Last Name'),
                      ),
                      Container(
                          width: 156,
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
                                    InputBorder.none, // Remove default border
                              ),
                            ),
                          ))
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: email,
                                  border:
                                      InputBorder.none, // Remove default border
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: Text('Phone Number'),
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
                              child: TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  hintText: phonenumber,
                                  border:
                                      InputBorder.none, // Remove default border
                                ),
                              ),
                            ))
                      ],
                    )
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
                    primary: Colors.grey[200], // Button background color
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
                      Get.to(editAddressClient(userToken: userToken));
                    } else {
                      // Handle the case where userToken is empty, e.g., show a message
                      print('User token is empty. Cannot navigate to ChangePasswordScreen.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[200], // Button background color
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
              Center(
                child: RoundedButton(
                  text: 'Done',
                  press: () {
                    // Call the method to update the client profile
                    _updateClientProfile();
                  },
                )

              )
            ],
          ),
        ),
      ),
    );
  }
}
