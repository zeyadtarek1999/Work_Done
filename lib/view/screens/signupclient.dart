import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/mediaquery.dart';
import '../../model/textinputformatter.dart';
import '../components/page_title_bar.dart';
import '../components/under_part.dart';
import '../components/upside.dart';
import 'Screens_layout/layoutWorker.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_input_field.dart';
import '../widgets/rounded_password_field.dart';
import 'Screens_layout/layoutclient.dart';
import 'login_screen_client.dart';
import 'login_screen_worker.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({Key? key}) : super(key: key);

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  final _formKey = GlobalKey<FormState>();

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

  // Default country code
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
    super.dispose();
  }

  final RxBool _isChecked = false.obs;

  @override
  void initState() {
    super.initState();
    // Initialize checkedItems with the same length as items, and all values as false
    fetchLanguages(); // Call the function to fetch languages
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

  Future<String> getclient_id() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('client_id') ?? '';
  }

  Future<void> saveClientId(int clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('client_id', clientId);
  }

  Future<int?> getSavedClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    print(clientId);
    return clientId;
  }

  List<Map<String, dynamic>> languages = [];
  String? selectedLanguageId;

  Future<void> fetchLanguages() async {
    final response =
    await http.get(Uri.parse('http://172.233.199.17/lang.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        languages = List<Map<String, dynamic>>.from(jsonResponse['languages']);
      });
    } else {
      print('Failed to fetch languages. Status code: ${response.statusCode}');
    }
  }

  String selectedLanguage = ''; // Declare and initialize the variable
  List<String> selectedLanguageIds = [];

  // Example function to handle checkbox click
  void handleLanguageCheckboxClick(String languageId, bool isChecked) {
    if (isChecked) {
      selectedLanguageIds.add(languageId); // Add the language ID to the list
    } else {
      selectedLanguageIds.remove(languageId); // Remove the language ID from the list
    }
  }

  bool isLoading = false; // Add a loading state
  Future<void> postDataToApi(String phoneNumber) async {
    if (selectedLanguageIds.isEmpty) {
      // Check if at least one language is selected
      print('Please select at least one language');
      return;
    }

    final url = Uri.parse('http://172.233.199.17/clients.php');
    final request = http.MultipartRequest('POST', url)
      ..fields['client_firstname'] = firstnameController.text
      ..fields['client_lastname'] = lastnameController.text
      ..fields['client_email'] = emailController2.text
      ..fields['client_phone'] = phoneNumber
      ..fields['client_zip'] = zipcodeController.text
      ..fields['address_st1'] = capturedAddressLine
      ..fields['address_st2'] = capturedAddressLine2
      ..fields['address_city'] = capturedCity
      ..fields['address_state'] = capturedState
      ..fields['address_zip'] = zipcodeController.text
      ..fields['client_password'] = passwordController.text
      ..fields['client_profile_pic'] = ''
      ..fields['action'] = 'add_client';

    // Add selected language IDs with unique keys
    for (int i = 0; i < selectedLanguageIds.length; i++) {
      final languageId = selectedLanguageIds[i];
      request.fields['langs[$i]'] = languageId;
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Data posted successfully');
      // Handle response as needed
      final responseData =
      await response.stream.bytesToString(); // Convert stream to string
      final jsonResponse = json.decode(responseData);
      // Fetch languages again to update the list after adding a language
      // Extract worker_id as a string
      String clientIdString = jsonResponse['client_id'];

      // Convert worker_id string to an integer
      int clientId = int.parse(clientIdString);

      // Save the worker_id to SharedPreferences
      await saveClientId(clientId);

      print('Client ID: $clientId');
    } else {
      print('Failed to post data. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch languages');
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
                                  SizedBox(width: 20.0),
                                  Text(
                                    ' Address',
                                    style:
                                    TextStyle(color: HexColor('#707070')),
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
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isLanguageListVisible = !isLanguageListVisible;
                                          filteredLanguages = languages; // Set filteredLanguages to contain all languages initially
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
                                          color: HexColor('#F5F5F5'),
                                          borderRadius: BorderRadius.circular(29),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/language.svg',
                                              width: 33.0,
                                              height: 33.0,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Select Languages',
                                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                            ),
                                            Spacer(),
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
                                    Visibility(
                                      visible: isLanguageListVisible,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Search bar
                                          Padding(
                                            padding:
                                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: TextField(
                                              controller: searchController,
                                              onChanged: (query) {
                                                setState(() {
                                                  filteredLanguages = languages
                                                      .where((language) =>
                                                      language['lang']
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

                                          // List of languages
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: filteredLanguages.map((language) {
                                              final langId = language['lang_id'];
                                              final langName = language['lang'];
                                              bool isSelected = selectedLanguageIds.contains(langId);

                                              return CheckboxListTile(
                                                activeColor: HexColor('#4D8D6E'),
                                                title: Text(langName),
                                                value: selectedLanguageIds.contains(langId),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value!) {
                                                      selectedLanguageIds.add(langId);
                                                    } else {
                                                      selectedLanguageIds.remove(langId);
                                                    }
                                                  });
                                                },
                                              );


                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )

                        ,Padding(
                    padding: const EdgeInsets.all(16.0),
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
                            RoundedButton(
                              loading: isLoading,
                              text: 'REGISTER',
                              press: () async {
                                if (_formKey.currentState!.validate() &&
                                    !isLoading &&
                                    selectedLanguageIds.isNotEmpty) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    // Send the API request to post data
                                    await postDataToApi(formattedPhoneNumber2);

                                    // Fetch languages after successful registration
                                    await fetchLanguages();
                                    print('Data posted successfully');

                                    // Navigate to the layout screen
                                    Get.off(layoutclient());
                                  } catch (error) {
                                    print('An error occurred: $error');
                                    // Show snackbar with error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('An error occurred. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  print('Please fill in all required fields and select a language');
                                  // Show snackbar with validation error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please fill in all required fields and select a language.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please select at least one language.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
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
  String selectedState = 'Alabama'; // or any other valid state from your list

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
              DropdownButtonFormField<String>(
                value: selectedState,
                onChanged: (newValue) {
                  setState(() {
                    selectedState = newValue!;
                  });
                },
                items: statesOfAmerica.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'State',
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
                    return 'Select a state';
                  }
                  return null;
                },
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

