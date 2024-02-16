import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Register_clientModel.dart';
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
import 'Screens_layout/layoutclient.dart';
import 'login_screen_client.dart';
import 'login_screen_worker.dart';

class SignUpScreen2 extends StatefulWidget {

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final formkeyaddress = GlobalKey<FormState>();
  List<Map<String, dynamic>> languages = [
    {'lang_id': '1', 'lang': 'English'},
    {'lang_id': '2', 'lang': 'Arabic'},
    {'lang_id': '3', 'lang': 'French'},
  ];
  String addressLine = '';
  String addressSt2 = '';
  String city = '';
  String state = '';


  String selectedLanguage = 'Select Language';
  final addressLineController = TextEditingController();
  final addressst2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  bool validateFormaddress() {
    bool isValid = true;

    // Validate address line
    if (addressLineController.text.isEmpty) {
      isValid = false;
      // Show error message or perform error handling for address line
    }

    // Validate other fields as needed

    return isValid;
  }

  TextEditingController _searchController = TextEditingController();
  String selectedState = 'Select State';

  bool _isFormFilled = false;

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

bool isSearchBarVisible =false;
  bool isLanguageListVisible = false; // Add this variable
  String selectedCountryCode = '+1'; // Default country code for the United States

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


  String capturedAddressLine = '';
  String capturedAddressLine2 = '';
  String capturedCity = '';
  String capturedState = '';

  String _email = '';
  String _password = '';
  String _validationMessage = '';
  bool _isEmailValid = true;
  String _selectedCountryCode = '+1';

  final TextEditingController textController = TextEditingController();

  String formattedPhoneNumber2 = ''; // Formatted phone number to display


  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredLanguages = [];


  final TextEditingController phoneNumberController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final licenseController = TextEditingController();
  final zipcodeController = TextEditingController();
  final emailController2 = TextEditingController();


  double defaultPadding = 16.0;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();



  bool isSendingData = false;


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

  bool _passwordsMatch = true;

  bool _isObscured = true;

  // bool _isValidPassword(String password) {
  //   if (password.length < 6) {
  //     return false;
  //   }
  //
  //   final uppercaseRegExp = RegExp(r'[A-Z]');
  //   final lowercaseRegExp = RegExp(r'[a-z]');
  //   final digitRegExp = RegExp(r'\d');
  //
  //   if (!uppercaseRegExp.hasMatch(password) ||
  //       !lowercaseRegExp.hasMatch(password) ||
  //       !digitRegExp.hasMatch(password)) {
  //     return false;
  //   }
  //
  //   return true;
  // }

  bool _validatePasswords() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty && password .isEmpty) {
      return true; // Return true if the confirmPassword field is empty
    }

    return password == confirmPassword;
  }


  late AnimationController ciruclaranimation;

  @override
  void dispose() {
    // Dispose of your controllers here
    textController.dispose();
    phoneNumberController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    zipcodeController.dispose();
    emailController2.dispose();
    passwordController.dispose();
    addressLineController.dispose();
    addressst2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    ciruclaranimation.dispose();
    super.dispose();
  }

  final RxBool _isChecked = false.obs;

  @override
  void initState() {
    super.initState();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void _onChanged(String value) {
    setState(() {
      _isEmailValid = _formKey.currentState!.validate();
    });
  }







  RegisterClientApiClient apiClient = RegisterClientApiClient(baseUrl: 'https://workdonecorp.com');

  bool _isLoading = false;



  void _registerClient() async {
    // Make sure to fill in the values from your text controllers or other sources
    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String email = emailController2.text;
    String password = passwordController.text;
    String phone = phoneNumberController.text;
    String language = selectedLanguage;
    String street1 = addressLineController.text;
    String street2 = addressst2Controller.text;
    String city = cityController.text;
    String state = selectedState;
    String address_zip = zipcodeController.text;


    // Show the circular progress indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the registerworker method from your registerworkerapi
      final registrationResponse = await apiClient.registerClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        state: state,
        city: city,
        street2: street2,
        street1: street1,
        language: language,
        addressZip: address_zip,
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

        // Display a toast message with the success message
        Fluttertoast.showToast(
          msg: "Registration successful: ${registrationResponse['msg']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Get.offAll(layoutclient());
        // Navigate to the next screen (you may want to do this based on certain conditions)
        // Example: Get.to(layoutworker());
      } else {
        // Display a toast message with the error message
        Fluttertoast.showToast(
          msg: "Registration failed: ${registrationResponse['msg']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      // Print the full error, including the server response
      print('Error during registration: $error');
      // Display a toast message with the error message
      Fluttertoast.showToast(
        msg: "Registration failed: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Display a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide the circular progress indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print ( 'Saved Token is $token');
  }

// Function to retrieve the token from shared preferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  bool isLoading = false; // Add a loading state

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
                    imgUrl: "assets/images/signup.png",
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
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  width: size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F5F5F5'),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: Row(
                                    children: [
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
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  width: size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F5F5F5'),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: Row(children: [
                                    SvgPicture.asset(
                                      'assets/icons/firstsecondicon.svg',
                                      // Replace with the path to your SVG file
                                      width: 33.0,
                                      // Replace with the desired width of the icon
                                      height:
                                      33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                    ),
                                    SizedBox(width: 5,),
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
                            InkWell(
                              onTap: () async {
                                await showDialog(

                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      content: SingleChildScrollView(
                                        child: StatefulBuilder(

                                            builder: (BuildContext context, StateSetter setState) {
                                              return Form(
                                                key: formkeyaddress,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [

                                                        Text('Write Your Address',
                                                          style: GoogleFonts.encodeSans(
                                                            textStyle: TextStyle(
                                                                color: HexColor('454545'),
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
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
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Please enter your address line 2';
                                                      }
                                                      return null;
                                                    },
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
                                                        return 'Please enter your city';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () {

                                                            Navigator.pop(context);
                                                          } ,
                                                          child: Text(
                                                            'close',
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.red,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15,),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            if (formkeyaddress.currentState!.validate() &&
                                                                selectedState != 'Select State') {
                                                              // Call the onDonePressed function and pass the values
                                                              setState(() {
                                                                _isFormFilled = true;
                                                              });
                                                              Navigator.pop(context);
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text('Please fill in all fields.'),
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                              );
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

                                                  ],
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                height: size.height * 0.09,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: HexColor('#F5F5F5'),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/addressicon.svg',
                                      width: 33.0,
                                      height: 33.0,
                                    ),
                                    SizedBox(width: 15.0),
                                    Text(
                                      ' Address',
                                      style: TextStyle(color: HexColor('#707070'), fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8,),
                                    if (_isFormFilled == true)
                                      Icon(Icons.check, color: Colors.green),
                                  ],
                                ),
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
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(5), // Limit the input length to 5 characters
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Zip Code';
                                        }
                                        if (value.length != 5) {
                                          return 'Zip Code should be 5 digits';
                                        }
                                        return null; // Return null if the input is valid
                                      },
                                      // Apply the custom formatter

                                      keyboardType: TextInputType.number,

                                      decoration: InputDecoration(
                                        hintText: 'Enter your ZIP Code ',
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
                                              selectedLanguage ?? 'Select Language', // Use selectedLanguage as the hint text if it's not null
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
                                                  isLanguageListVisible = false; // Hide the list after selecting a language
                                                  isSearchBarVisible = false; // Hide the search bar after selecting a language
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )                   ,SizedBox(
                      height: ScreenUtil.sizeboxheight,
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
                                            }

                                            // else if (!_isValidPassword(value)) {
                                            //   return 'required At least 12 characters long,uppercase & lowercase letters,'
                                            //       ' numbers, and symbols.';
                                            // }
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Adjusted this line
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start, // Adjusted this line
                                      children: [
                                        Icon(
                                          hasUppercase ? Icons.check_circle : Icons.cancel,
                                          color: hasUppercase ? Colors.green : Colors.red,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Uppercase letter',
                                          style: TextStyle(
                                            color: hasUppercase ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start, // Adjusted this line
                                      children: [
                                        Icon(
                                          hasLowercase ? Icons.check_circle : Icons.cancel,
                                          color: hasLowercase ? Colors.green : Colors.red,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Lowercase letter',
                                          style: TextStyle(
                                            color: hasLowercase ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start, // Adjusted this line
                                      children: [
                                        Icon(
                                          hasNumber ? Icons.check_circle : Icons.cancel,
                                          color: hasNumber ? Colors.green : Colors.red,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Number',
                                          style: TextStyle(
                                            color: hasNumber ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.sizeboxheight,
                            ),

                            Center(
                              child: _isLoading
                                  ? Center(
                                child: RotationTransition(
                                  turns: ciruclaranimation,
                                  child: SvgPicture.asset(
                                    'assets/images/Logo.svg',
                                    semanticsLabel: 'Your SVG Image',
                                    width: 100,
                                    height: 130,
                                  ),
                                ),
                              )
                              // Show loading indicator when uploading
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoundedButton(
                                    text: 'Register',
                                    press: () {
                                      if (_formKey.currentState!.validate() && selectedLanguage != 'select language') {
                                        _registerClient();
                                      } else {
                                        Fluttertoast.showToast(msg: "Please fill in all required fields.");
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),
                            UnderPart(
                              title: "Already have an account?",
                              navigatorText: "Login here",
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LoginScreenclient()));
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

// class AddressPickerPopup extends StatefulWidget {
//   final Function(String, String, String, String) onDonePressed;
//
//   AddressPickerPopup({
//     required this.onDonePressed,
//
//   });
//
//   @override
//   State<AddressPickerPopup> createState() => _AddressPickerPopupState();
// }
//
// class _AddressPickerPopupState extends State<AddressPickerPopup> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   String selectedState = 'Alabama'; // or any other valid state from your list
//
//   bool _isFormFilled = false; // Initialize as false
//   // List of states of America
//   List<String> statesOfAmerica = [
//     'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
//     'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
//     'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
//     'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
//     'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia',
//     'Wisconsin', 'Wyoming',
//   ];
//   _AddressPickerPopupState() {
//     assert(statesOfAmerica.toSet().length == statesOfAmerica.length,
//     'Duplicate values found in statesOfAmerica list');
//   }
//   // Define a callback function to pass data back to SignUpScreen2
//   void _onDonePressed(String addressLine, String addressLine2, String city, String state) {
//     widget.onDonePressed(addressLine, addressLine2, city, state);
//   }
//   @override
//   Widget build(BuildContext context) {
//     // Define TextEditingController variables
//     TextEditingController addressLineController = TextEditingController();
//     TextEditingController addressst2Controller = TextEditingController();
//     TextEditingController cityController = TextEditingController();
//     TextEditingController stateController = TextEditingController();
//
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       content: Form(
//         key: formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 value: selectedState,
//                 onChanged: (newValue) {
//                   setState(() {
//                     selectedState = newValue!;
//                   });
//                 },
//                 items: statesOfAmerica.map((state) {
//                   return DropdownMenuItem<String>(
//                     value: state,
//                     child: Text(state),
//                   );
//                 }).toList(),
//                 decoration: InputDecoration(
//                   hintText: 'State',
//                   hintStyle: TextStyle(color: HexColor('#707070')),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#707070')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#4D8D6E')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Select a state';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),
//
//               TextFormField(
//                 controller: addressLineController,
//                 style: TextStyle(color: HexColor('#4D8D6E')),
//                 decoration: InputDecoration(
//                   hintText: 'Address Line',
//                   hintStyle: TextStyle(color: HexColor('#707070')),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#707070')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#4D8D6E')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter address line';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: addressst2Controller,
//                 style: TextStyle(color: HexColor('#4D8D6E')),
//                 decoration: InputDecoration(
//                   hintText: 'Address Line 2',
//                   hintStyle: TextStyle(color: HexColor('#707070')),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#707070')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#4D8D6E')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                 ),
//
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: cityController,
//                 style: TextStyle(color: HexColor('#4D8D6E')),
//                 decoration: InputDecoration(
//                   hintText: 'City',
//                   hintStyle: TextStyle(color: HexColor('#707070')),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#707070')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: HexColor('#4D8D6E')),
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter city';
//                   }
//                   return null;
//                 },
//               ),
//
//
//               SizedBox(height: 10),
//     ElevatedButton(
//     onPressed: () {
//     if (formKey.currentState!.validate()) {
//     String addressLine = addressLineController.text;
//     String addressLine2 = addressst2Controller.text;
//     String city = cityController.text;
//     String state = selectedState;
//
//     // Call the onDonePressed function and pass the values
//     _onDonePressed(addressLine, addressLine2, city, state);
//     setState(() {
//     _isFormFilled = true;
//     });
//     Navigator.pop(context);
//     }
//     },
//     child: Text(
//     'Done',
//     style: TextStyle(color: Colors.white),
//     ),
//     style: ElevatedButton.styleFrom(
//     primary: HexColor('#4D8D6E'),
//     ),
//     ),
//               ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
