import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:workdone/view/stateslectorpopup.dart';
import 'package:workdone/view/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;


import '../../../model/post editprofilemodel.dart';
import '../Edit address.dart';
import '../Support Screen/Support.dart';
import '../changePassword.dart';
import '../homescreen/home screenClient.dart';

class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  List<String> americanPhoneCodes = ['+1', '+20', '+30', '+40']; // Add more if needed
  List<String> languages = [
    'English',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Chinese (Mandarin)',
    'Hindi',
    'Russian',
    'Japanese',
    'Portuguese',
    'Italian',
    'Korean',
    'Dutch',
    'Turkish',
    'Swedish',
    'Polish',
    'Vietnamese',
    'Greek',
    'Hebrew',
    'Thai',
  ];
  String ? selectedLanguage;


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
    _getUserProfile();
  }
  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }
  Future<void> sendprofile() async {
    final url = Uri.parse('https://workdonecorp.com/api/update_client_profile');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print (userToken);
      // Make the API request
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $userToken'
        ..fields['language'] = 'english';

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
      if (selectedLanguage != '' ||selectedLanguage != null ) {
        request.fields['language'] = selectedLanguage.toString();
      } else {
        request.fields['language'] = selectedLanguage .toString();
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

        // Check the status in the response
        if (responseBody['status'] == 'success') {
          print(responseBody);
          // Show a toast message
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
            MaterialPageRoute(builder: (context) => layoutclient()),
          );
        } else if (responseBody['status'] == 'success') {
          // Check the specific error message
          String errorMsg = responseBody['msg'];

          if (errorMsg == ' Bid Submitted') {
            // Show a Snackbar with the error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
              ),
            );

          } else {
            // Handle other error cases as needed
            print('Error: $errorMsg');
          }
        }
      }
      else {

        print('Failed to insert bid. Status code: ${response.statusCode}');

        // Print the response body for more details
        print('Response body: ${await response.stream.transform(utf8.decoder).join()}');

      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      print('Error inserting bid: $e');
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
              selectedLanguage = profileData['language'] ?? 'Select Language';
            });
            // setState(() {
            //   firstNameController.text = firstname;
            //   lastNameController.text=  secondname;
            //   emailController.text= email;
            //   phoneController.text = phonenumber;
            // });
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

  bool isLanguageListVisible = false; // Add this variable
  bool isSearchBarVisible = false;
  List<Map<String, dynamic>> filteredLanguages = [];

  final ScreenshotController screenshotController = ScreenshotController();



  String unique= 'editprofile' ;
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
    Size size = MediaQuery.of(context).size;
    String selectedPhoneCode = americanPhoneCodes[0]; // Initialize with the first code
    bool isPhoneNumberValid = true; // Add a flag to track phone number validation
    bool validatePhoneNumber(String phoneNumber) {
      final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
      return formattedPhoneNumber.length == 10;
    }
    return Scaffold( floatingActionButton:
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
        controller:screenshotController ,
        child: SingleChildScrollView(
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
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                            child: Text('Language'),
                          ),
                          Container(
                            width: size.width * 0.90,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background color
                              borderRadius: BorderRadius.circular(
                                  20), // Circular border radius
                            ),
                            child:                                             Stack(
                              children: [
                                TextFormField(
                                  readOnly: true, // Set this to true to disable editing
                                  style: TextStyle(color: HexColor('#4D8D6E')),
                                  decoration: InputDecoration(
                                    hintText: selectedLanguage ?? 'Select language', // Use selectedState or 'Select State' if it's null
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StateSelectorPopup(
                                            states: languages,
                                            onSelect: (newlySelectedjob) {
                                              // Update selectedState when a state is selected
                                              setState(() {
                                                selectedLanguage = newlySelectedjob;
                                              });
                                              print('Selected jobtype : $newlySelectedjob');
                                            },
                                          );
                                        },
                                      );
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),

                          ),

                        ],
                      )
                    ],
                  ),
                ),
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
                            DropdownButton<String>(
                              value: selectedPhoneCode,
                              onChanged: (newValue) {
                                setState(() {
                                  // Update the selected phone code
                                  selectedPhoneCode = newValue!;
                                });
                              },
                              items: americanPhoneCodes.map((code) {
                                return DropdownMenuItem<String>(
                                  value: code,
                                  child: Text(code),
                                );
                              }).toList(),
                            ),
                            SizedBox(width: 8), // Add some spacing between the dropdown and the text field
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
                Center(
                  child: RoundedButton(
                    text: 'Submit',
                    press: () {
                      // Call the method to update the client profile
                      sendprofile();
                    },
                  )

                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
