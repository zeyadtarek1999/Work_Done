import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import '../../model/PhoneNumberFormatter.dart';
import '../../model/Register_workerModel.dart';
import '../../model/mediaquery.dart';
import '../../model/textinputformatter.dart';
import '../components/page_title_bar.dart';
import '../components/under_part.dart';
import '../components/upside.dart';
import '../stateslectorpopup.dart';
import 'Screens_layout/layoutWorker.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_input_field.dart';
import '../widgets/rounded_password_field.dart';
import 'login_screen_worker.dart';

class SignUpScreen extends StatefulWidget {
  final String addressLine;
  final String addressSt2;
  final String city;
  final String state;

  SignUpScreen({
    required this.addressLine,
    required this.addressSt2,
    required this.city,
    required this.state,
  });
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> languages = [
    {'lang_id': '1', 'lang': 'English'},
    {'lang_id': '2', 'lang': 'Arabic'},
    {'lang_id': '3', 'lang': 'French'},
  ];
  String selectedLanguage = '';
  bool isSearchBarVisible =false;

  List<Map<String, dynamic>> jobTypes = [
    {'type_id': '1', 'type': 'Job Type 1'},
    {'type_id': '2', 'type': 'Job Type 2'},
    {'type_id': '3', 'type': 'Job Type 3'},
    // Add more job types as needed
  ];

  String selectedJobType = '';
  List<Map<String, dynamic>> filteredJobTypes = [];
  File? _image;
  final picker = ImagePicker();
  String profile_pic = '';

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  bool isJobTypeListVisible = false;
  bool isSearchBarVisibleofjobs =false;

  bool isLanguageListVisible = false; // Add this variable
  String selectedCountryCode = '+1'; // Default country code for the United States
  String addressLine = '';
  String addressSt2 = '';
  String city = '';
  String state = '';
  List<String> countryCodes = [
    '+1', '+91', '+44', '+61', // Add more country codes as needed
  ];
  String capturedAddressLine = '';
  String capturedAddressLine2 = '';
  String capturedCity = '';
  String capturedState = '';


  final TextEditingController textController = TextEditingController();
  final TextEditingController expyearcontroller = TextEditingController();

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

  List<String> americanPhoneCodes = ['+1', '+20', '+30', '+40']; // Add more if needed
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


  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredLanguages = [];


  final TextEditingController phoneNumberController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final licenseController = TextEditingController();
  final zipcodeController = TextEditingController();
  final emailController2 = TextEditingController();

  // final TextEditingController addressLineController;
  // final TextEditingController cityController;
  // final TextEditingController stateController;
  // final TextEditingController streetController;
  //
  // final TextEditingController companyController;
  // final TextEditingController SuitenumberController;
  double defaultPadding = 16.0;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();



  bool isSendingData = false;

  bool _isFormFilled = false;

  void _markFormAsFilled() {
    setState(() {
      _isFormFilled = true;
    });
  }

  bool hasUppercase = false;

  bool hasLowercase = false;

  bool hasNumber = false;

  void checkPassword(String password) {
    setState(() {
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
    });
  }


  bool isValidEmail(String email) {
    // Regular expression to validate email addresses
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

    // Check if the email address matches the regular expression
    return emailRegex.hasMatch(email);
  }

  bool isListExpanded = false;

  bool _passwordsMatch = false;

  bool _isObscured = true;

  bool _isValidPassword(String password) {
    if (password.length < 6) {
      return false;
    }

    final uppercaseRegExp = RegExp(r'[A-Z]');
    final lowercaseRegExp = RegExp(r'[a-z]');
    final digitRegExp = RegExp(r'\d');

    if (!uppercaseRegExp.hasMatch(password) ||
        !lowercaseRegExp.hasMatch(password) ||
        !digitRegExp.hasMatch(password)) {
      return false;
    }

    return true;
  }

  bool _validatePasswords() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    return password == confirmPassword;
  }

  String _email = '';

  String _password = '';

  String _validationMessage = '';

  bool _isEmailValid = true;

  String _selectedCountryCode = '+1';
late String user_token='';
  // Default country code
  @override
  void dispose() {
    // Dispose of your controllers here
    textController.dispose();
    phoneNumberController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    licenseController.dispose();
    zipcodeController.dispose();
    emailController2.dispose();
    passwordController.dispose();
    expyearcontroller.dispose();
    super.dispose();
  }


  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize checkedItems with the same length as items, and all values as false
  // }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }
  bool isLoading = false; // Add a loading state

  void _onChanged(String value) {
    setState(() {
      _isEmailValid = _formKey.currentState!.validate();
    });
  }







  // Add other controllers for your form fields

  List<File> licensePicList = [];

  RxBool _isChecked = false.obs;

  void _toggleCheckbox(bool? value) async {
    if (value != null) {
      _isChecked.value = value;
      if (_isChecked.value) {
        Get.defaultDialog(
          title: 'Licence \n Number & Image',
          content: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.newspaper_outlined,
                      color: Colors.grey,
                    ),
                    hintText: 'License Number (optional)',
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#4D8D6E'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedImage != null) {
                      setState(() {
                        _image = File(pickedImage.path);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.white, // Set icon color
                      ),
                      SizedBox(width: 8), // Adjust spacing
                      Text(
                        'Licence image',
                        style: TextStyle(
                          color: Colors.white, // Set text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Save the license number and image if the license number is not empty
                if (textController.text.isNotEmpty) {
                  licenseController.text = textController.text;
                  licensePicList.add(_image!);
                }
                Get.back(result: true); // Close the dialog with result: true
              },
              child: Text(
                'Done',
                style: TextStyle(color: HexColor('#4D8D6E')),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(result: false); // Close the dialog with result: false
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: HexColor('#808080')),
              ),
            ),
          ],
        ).then((value) {
          if (value == false) {
            _isChecked.value = false;
          }
        });
      }
    }
  }
  RegisterWorkerApiClient registerworkerapi = RegisterWorkerApiClient(baseUrl: 'https://workdonecorp.com');

  void _registerWorker() async {
    // Make sure to fill in the values from your text controllers or other sources
    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String email = emailController2.text;
    String password = passwordController.text;
    String phone = phoneNumberController.text;
    String language = selectedLanguage;
    String experience = expyearcontroller.text;
    String jobType = selectedJobType;
    String licenseNumber = licenseController.text;
    String street1 = capturedAddressLine;
    String street2 = capturedAddressLine2;
    String city = capturedCity;
    String state = capturedState;
    String address_zip = zipcodeController.text;
    String imagePath = _image!.path;

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

    try {
      // Call the registerworker method from your registerworkerapi
      final registrationResponse = await registerworkerapi.registerworker(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        jobType: jobType,
        licenseNumber: licenseNumber,
        experience: experience,
        state: state,
        city: city,
        street2: street2,
        street1: street1,
        language: language, addressZip: address_zip, licensePic: imagePath,
      );

      print('Registration Response: $registrationResponse');

      // Check if the registration response contains the token
      if (registrationResponse.containsKey('status') &&
          registrationResponse.containsKey('msg') &&
          registrationResponse.containsKey('token')) {
        final String user_token = registrationResponse['token'];

        // Store the token in shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user_token', user_token);
        Get.offAll(layoutworker());
        // Navigate to the next screen (you may want to do this based on certain conditions)
        // Example: Get.to(layoutworker());
      } else {
        // Handle the case where the expected keys are not present in the response
        print('Invalid registration response format');
      }
    } catch (error) {
      // Print the full error, including the server response
      print('Error during registration: $error');
      // Display a snackbar or toast with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;
    Size size = MediaQuery.of(context).size;
    String selectedPhoneCode = americanPhoneCodes[0]; // Initialize with the first code
    bool isPhoneNumberValid = true; // Add a flag to track phone number validation
    bool validatePhoneNumber(String phoneNumber) {
      final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
      return formattedPhoneNumber.length == 10;
    }
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  const Upside(
                    imgUrl: "assets/images/workers.png",
                  ),
                  const PageTitleBar(title: 'Create New Account'),
                  Padding(
                    padding: const EdgeInsets.only(top: 320.0),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                              height: size.height * 0.099,

                                  width: size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F5F5F5'),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),

                                      SvgPicture.asset(
                                        'assets/icons/firstsecondicon.svg',
                                        width: 33.0,
                                        height: 33.0,
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        child: TextFormField(
                                          controller: firstnameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter first name';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            hintText: 'First Name',
                                            contentPadding: EdgeInsets.all(0), // Remove content padding

                                            border: InputBorder.none,
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              // Customize error message color
                                              fontSize:
                                                  12, // Customize error message font size
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: ScreenUtil.sizeboxheight4),
                                Container(
                                  height: size.height * 0.099,

                                  width: size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F5F5F5'),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: Row(children: [
                                    SizedBox(width: 8,),

                                    SvgPicture.asset(
                                      'assets/icons/firstsecondicon.svg',
                                      // Replace with the path to your SVG file
                                      width: 33.0,
                                      // Replace with the desired width of the icon
                                      height:
                                          33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                    ),
                                    SizedBox(width: 8,),
                                    // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                    Container(
                                      child: Expanded(
                                        child: TextFormField(
                                          controller: lastnameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter Last Name';
                                            }
                                            return null; // Return null if the input is valid
                                          },
                                          // Apply the custom formatter

                                          keyboardType: TextInputType.text,

                                          decoration: InputDecoration(
                                            hintText: 'Last Name',
                                            contentPadding: EdgeInsets.all(0), // Remove content padding

                                            // Replace with the desired hint text
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              height: size.height * 0.09,
                              width: size.width * 0.93,
                              decoration: BoxDecoration(
                                color: HexColor('#F5F5F5'),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/licenseicon.svg',
                                    width: 33.0,
                                    height: 33.0,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: licenseController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              hintText: 'License',
                                              contentPadding: EdgeInsets.all(0), // Remove content padding
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            final pickedImage = await ImagePicker().pickImage(
                                              source: ImageSource.gallery,
                                            );
                                            if (pickedImage != null) {
                                              setState(() {
                                                _image = File(pickedImage.path);
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: HexColor('#509372'), width: 1),
                                            ),
                                            child: _image != null
                                                ? Image.file(
                                              _image!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                                : Center(
                                              child: Icon(
                                                Icons.image,
                                                color: HexColor('#509372'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Obx(() => Checkbox(
                                          value: _isChecked.value,
                                          onChanged: _toggleCheckbox,
                                          activeColor: HexColor('#509372'),
                                          checkColor: Colors.white,
                                        )),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                height: size.height * 0.09,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: HexColor('#F5F5F5'),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/email.svg',
                                      // Replace with the path to your SVG file
                                      width: 33.0,
                                      // Replace with the desired width of the icon
                                      height:
                                          33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                    ),
                                    SizedBox(width: 20.0),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: emailController2,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter an email address';
                                          } else if (!isValidEmail(value)) {
                                            return 'Invalid email address';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _email = value!;
                                        },
                                        onChanged: _onChanged,
                                        decoration: InputDecoration(
                                          hintText: 'E-mail',
                                          contentPadding: EdgeInsets.all(0), // Remove content padding

                                          // Replace with the desired hint text
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            GestureDetector(
                              onTap: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => AddressPickerPopup(
                                  onDonePressed: (addressLine, addressLine2, city, state) {
                                    // Update captured address information
                                    capturedAddressLine = addressLine;
                                    capturedAddressLine2 = addressLine2;
                                    capturedCity = city;
                                    capturedState = state;
                                  },
                                  ),
                                );
                                // After the dialog is closed, update the icon rendering
                                setState(() {
                                  _isFormFilled = true; // Set this based on your validation logic
                                });

                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                height: size.height * 0.09,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: HexColor('#F5F5F5'),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(children: [
                                  SvgPicture.asset(
                                    'assets/icons/addressicon.svg',
                                    // Replace with the path to your SVG file
                                    width: 33.0,
                                    // Replace with the desired width of the icon
                                    height:
                                        33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                  ),
                                  // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                  SizedBox(width: 15.0),
                                  Text(
                                    ' Address',
                                    style:
                                        TextStyle(color: HexColor('#707070') ,fontSize: 16 ,fontWeight: FontWeight.w500),
                                  ),
                                  Spacer(),
                                  if (_isFormFilled)
                                    Icon(Icons.check, color: Colors.green),
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              height: size.height * 0.09,
                              width: size.width * 0.93,
                              decoration: BoxDecoration(
                                color: HexColor('#F5F5F5'),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: Row(children: [
                                SvgPicture.asset(
                                  'assets/icons/zipcode.svg',
                                  // Replace with the path to your SVG file
                                  width: 33.0,
                                  // Replace with the desired width of the icon
                                  height:
                                      33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                ),
                                // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                SizedBox(width: 20.0),

                                Container(
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: zipcodeController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Zip Code';
                                        }
                                        return null; // Return null if the input is valid
                                      },
                                      // Apply the custom formatter

                                      keyboardType: TextInputType.number,

                                      decoration: InputDecoration(
                                        hintText: 'Preferred ZIP Code of Work',
                                        contentPadding: EdgeInsets.all(0), // Remove content padding

                                        // Replace with the desired hint text
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                              Icon(Icons.language),
                                              SizedBox(width: 10),
                                              Text(
                                                'Select Language',
                                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                              ),
                                              Spacer(),
                                              Icon(
                                                isLanguageListVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Search bar
                                      Visibility(
                                        visible: isSearchBarVisible,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: TextField(
                                            onChanged: (query) {
                                              setState(() {
                                                filteredLanguages = languages
                                                    .where((language) => language['lang']
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
                                            final langName = language['lang'];

                                            return ListTile(
                                              title: Text(langName),

                                              leading: Radio(
                                                activeColor: HexColor('#4D8D6E'), // Set the color when the radio button is selected
                                                value: langName,
                                                groupValue: selectedLanguage, // Provide a proper group value here
                                                onChanged: (value) {
                                                  setState(() {

                                                    selectedLanguage = value as String;
                                                    isLanguageListVisible = true; // Hide the list after selecting a language
                                                    isSearchBarVisible = true;
                                                    print (selectedLanguage);// Hide the search bar after selecting a language
                                                  });
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isJobTypeListVisible = !isJobTypeListVisible;

                                      // If the list is visible, show the full list
                                      if (isJobTypeListVisible) {
                                        filteredJobTypes = jobTypes;
                                      }
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
                                        Icon(Icons.work),
                                        SizedBox(width: 10),
                                        Text(
                                          'Select Job Type',
                                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                        ),
                                        Spacer(),
                                        Icon(
                                          isJobTypeListVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Search bar and List of filtered job types
                                Visibility(
                                  visible: isJobTypeListVisible,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: TextField(
                                          onChanged: (query) {
                                            setState(() {
                                              filteredJobTypes = jobTypes
                                                  .where((jobType) => jobType['type']
                                                  .toLowerCase()
                                                  .contains(query.toLowerCase()))
                                                  .toList();
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search job types...',
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // List of filtered job types
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: filteredJobTypes.map((jobType) {
                                          final typeName = jobType['type'];

                                          return ListTile(
                                            title: Text(typeName),
                                            leading: Radio(
                                              value: typeName,
                                              activeColor: HexColor('#4D8D6E'), // Set the color when the radio button is selected
                                              groupValue: selectedJobType,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedJobType = value as String;
                                                  isJobTypeListVisible = true;
                                                  print(selectedJobType);// Hide the list after selecting a job type
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),


                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0 ,vertical: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                height: size.height * 0.103,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(

                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/phonenumber.svg', // Replace with your SVG path
                                      width: 33.0,
                                      height: 33.0,
                                    ),
                                    SizedBox(width: 20.0),
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

                                              controller: phoneNumberController,
                                              decoration: InputDecoration(
                                                hintText: 'Phone Number',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.all(0), // Remove content padding

                                              ),
                                              keyboardType: TextInputType.phone,
                                              onChanged: (value) {
                                                setState(() {
                                                  // Format the phone number using the formatPhoneNumber function
                                                  final formattedPhoneNumber = formatPhoneNumber(value);
                                                  phoneNumberController.value = TextEditingValue(
                                                    text: formattedPhoneNumber,
                                                    selection: TextSelection.collapsed(offset: formattedPhoneNumber.length),

                                                  );
// Add +1 prefix to the formatted phone number
                                                  phoneNumberController.text = '$formattedPhoneNumber';

                                                  // Ensure the cursor position is at the end
                                                  phoneNumberController.selection = TextSelection.fromPosition(
                                                    TextPosition(offset: phoneNumberController.text.length),
                                                  );
                                                  print(phoneNumberController.text);
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
                            ),
                            Text(
                              formattedPhoneNumber, // Display the formatted phone number
                              style: TextStyle(fontSize: 20.0),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, ),
                              height: size.height * 0.09,
                              width: size.width * 0.93,
                              decoration: BoxDecoration(
                                color: HexColor('#F5F5F5'),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: Row(children: [
                                SvgPicture.asset(
                                  'assets/icons/Experience.svg',
                                  // Replace with the path to your SVG file
                                  width: 33.0,
                                  // Replace with the desired width of the icon
                                  height:
                                      33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                ),
                                // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                SizedBox(width: 20.0),

                                Container(
                                  child: Expanded(
                                    child: TextFormField(
                                      // Apply the custom formatter
                                      controller: expyearcontroller,

                                      keyboardType: TextInputType.number,

                                      decoration: InputDecoration(
                                        hintText: 'Years of Experience',
                                        contentPadding: EdgeInsets.all(0), // Remove content padding

                                        // Replace with the desired hint text
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Center(
                                child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              height: size.height * 0.099,
                              width: size.width * 0.93,
                              decoration: BoxDecoration(
                                color: HexColor('#F5F5F5'),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: Row(children: [
                                SvgPicture.asset(
                                  'assets/icons/password.svg',
                                  // Replace with the path to your SVG file
                                  width: 33.0,
                                  // Replace with the desired width of the icon
                                  height:
                                      33.0, // Replace with the desired height of the icon
                                ),
                                // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                SizedBox(width: 20.0),
                                Container(
                                  child: Expanded(
                                    child: TextFormField(
                                      inputFormatters: [
                                        EnglishTextInputFormatter()
                                      ],
                                      // Apply the custom formatter

                                      keyboardType: TextInputType.text,
                                      controller: passwordController,
                                      obscureText: _isObscured,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        } else if (!_isValidPassword(value)) {
                                          return 'required At least 12 characters long,uppercase & lowercase letters,'
                                              ' numbers, and symbols.';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _password = value!;
                                      },
                                      onChanged: (value) {
                                        checkPassword(value);
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                          onTap: _togglePasswordVisibility,
                                          // Call the _togglePasswordVisibility function here
                                          child: Icon(
                                            _isObscured
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                        hintText: 'Password',

                                        // Replace with the desired hint text
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                height: size.height * 0.099,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: HexColor('#F5F5F5'),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/password.svg',
                                      // Replace with the path to your SVG file
                                      width: 33.0,
                                      // Replace with the desired width of the icon
                                      height:
                                          33.0, // Replace with the desired height of the icon
                                    ),
                                    // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
                                    SizedBox(width: 20.0),
                                    Container(
                                      child: Expanded(
                                        child: TextFormField(
                                          inputFormatters: [
                                            EnglishTextInputFormatter()
                                          ],
                                          // Apply the custom formatter

                                          keyboardType: TextInputType.text,
                                          controller: confirmPasswordController,
                                          obscureText: _isObscured,
                                          onChanged: (value) {
                                            setState(() {
                                              _passwordsMatch =
                                                  _validatePasswords();
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please confirm your password';
                                            } else if (value !=
                                                passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            _password = value!;
                                          },
                                          decoration: InputDecoration(
                                            errorText: _passwordsMatch
                                                ? null
                                                : 'Passwords do not match',

                                            suffixIcon: GestureDetector(
                                              onTap: _togglePasswordVisibility,
                                              // Call the _togglePasswordVisibility function here
                                              child: Icon(
                                                color: HexColor('#509372'),
                                                _isObscured
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                            ),
                                            hintText: 'Confirm Password',

                                            // Replace with the desired hint text
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasUppercase
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      hasUppercase ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Uppercase letter',
                                  style: TextStyle(
                                    color: hasUppercase
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasLowercase
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      hasLowercase ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Lowercase letter',
                                  style: TextStyle(
                                    color: hasLowercase
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasNumber ? Icons.check_circle : Icons.cancel,
                                  color: hasNumber ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Number',
                                  style: TextStyle(
                                    color:
                                        hasNumber ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),
                            Container(
                                width: 200,
                                height: 50,
                              child:ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF4D8D6E), // Set the color to 4D8D6E
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0), // Set the border radius to make it circular
                                ),
                              ),
                              onPressed: () async {
                                _registerWorker();
                              },
                              child: Text('Register' ,style: TextStyle(color: Colors.white, fontSize: 16 ),),
                            ),)

                            ,
                            const SizedBox(
                              height: 10,
                            ),
                            UnderPart(
                              title: "Already have an account?",
                              navigatorText: "Login here",
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreenworker()));
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ]),
                          iconButton(context)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddressPickerPopup extends StatefulWidget {
  final Function(String, String, String, String) onDonePressed;

  AddressPickerPopup({
    required this.onDonePressed,

  });

  @override
  State<AddressPickerPopup> createState() => _AddressPickerPopupState();
}

class _AddressPickerPopupState extends State<AddressPickerPopup> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();
  String selectedState = 'Select State';

  bool _isFormFilled = false; // Initialize as false
  // List of states of America
  List<String> statesOfAmerica = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
    'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
    'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
    'Wisconsin', 'Wyoming',
  ];
  _AddressPickerPopupState() {
    assert(statesOfAmerica.toSet().length == statesOfAmerica.length,
    'Duplicate values found in statesOfAmerica list');
  }
  @override
  void initState() {
    super.initState();
  }

  void _filterStates(String query) {
    // Filter the list of states based on the search query
    setState(() {
      selectedState = ''; // Clear the selected state if any
    });
  }
  @override
  Widget build(BuildContext context) {
    // Define TextEditingController variables
    TextEditingController addressLineController = TextEditingController();
    TextEditingController addressst2Controller = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  TextFormField(
                    readOnly: true, // Set this to true to disable editing
                    style: TextStyle(color: HexColor('#4D8D6E')),
                    decoration: InputDecoration(
                      hintText: selectedState ?? 'Select State', // Use selectedState or 'Select State' if it's null
                      hintStyle: TextStyle(color: HexColor('#4D8D6E')),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#707070')),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#4D8D6E')),
                        borderRadius: BorderRadius.circular(15.0),
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
                              states: statesOfAmerica,
                              onSelect: (newlySelectedState) {
                                // Update selectedState when a state is selected
                                setState(() {
                                  selectedState = newlySelectedState;
                                });
                                print('Selected State: $newlySelectedState');
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




              SizedBox(height: 10),

              TextFormField(
                controller: addressLineController,
                style: TextStyle(color: HexColor('#4D8D6E')),
                decoration: InputDecoration(
                  hintText: 'Address Line',

                  hintStyle: TextStyle(color: HexColor('#707070')),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#707070')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#4D8D6E')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter address line';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressst2Controller,
                style: TextStyle(color: HexColor('#4D8D6E')),
                decoration: InputDecoration(
                  hintText: 'Address Line 2',

                  hintStyle: TextStyle(color: HexColor('#707070')),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#707070')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#4D8D6E')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),

              ),
              SizedBox(height: 10),
              TextFormField(
                controller: cityController,
                style: TextStyle(color: HexColor('#4D8D6E')),
                decoration: InputDecoration(
                  hintText: 'City',

                  hintStyle: TextStyle(color: HexColor('#707070')),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#707070')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('#4D8D6E')),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter city';
                  }
                  return null;
                },
              ),


              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    String addressLine = addressLineController.text;
                    String addressLine2 = addressst2Controller.text;
                    String city = cityController.text;
                    String state = selectedState;

                    // Call the onDonePressed function and pass the values
                    widget.onDonePressed(addressLine, addressLine2, city, state);
                    setState(() {
                      _isFormFilled = true;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: HexColor('#4D8D6E'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


