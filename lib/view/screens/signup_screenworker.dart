import 'dart:io';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:workdone/view/screens/Termsandconditions/termsofservice.dart';

import '../../model/Register_workerModel.dart';
import '../../model/mediaquery.dart';
import '../../model/textinputformatter.dart';
import '../components/page_title_bar.dart';
import '../components/under_part.dart';
import '../components/upside.dart';
import '../stateslectorpopup.dart';
import '../widgets/rounded_button.dart';
import 'login_screen_worker.dart';
import 'onBoard/onboardWorker.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final formkeyaddress = GlobalKey<FormState>();

  List<Map<String, dynamic>> languages = [];
  List<Map<String, dynamic>> jobtypes = [];
  List<int> selectedLanguages = [];
  List<String> selectedLanguagesname = [];
  List<int> selectedJobtype = [];
  List<String> selectedJobtypenames = [];

  bool _isCheckedterm = false;
  bool isSearchBarVisible = false;
  bool isSearchBarVisible2 = false;

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
          languages = data
              .map((lang) => {'id': lang['id'], 'name': lang['name']})
              .toList();
          filteredLanguages = languages;
        });
      } else {
        print('Error: ${jsonResponse['msg']}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> Jobtypesdata() async {
    const String url = "https://workdonecorp.com/api/get_all_project_types";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List data = jsonResponse['types_data'];
        // Process the fetched language data as needed
        print('Job types data   $data');
        setState(() {
          jobtypes = data
              .map((job) => {'id': job['id'], 'name': job['name']})
              .toList();
          filteredJobtypes = jobtypes;
        });
      } else {
        print('Error: ${jsonResponse['msg']}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  final addressLineController = TextEditingController();
  final addressst2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  TextEditingController _searchController = TextEditingController();
  String selectedState = 'Select State';

  bool _isFormFilled = false;
  List<String> statesOfAmerica = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  _AddressPickerPopupState() {
    assert(statesOfAmerica.toSet().length == statesOfAmerica.length,
        'Duplicate values found in statesOfAmerica list');
  }

  List<Map<String, dynamic>> jobTypes = [
    {'type_id': '1', 'type': 'Blamping'},
    {'type_id': '2', 'type': 'Painting'},
    // Add more job types as needed
  ];

  List<Map<String, dynamic>> filteredJobTypes = [];
  File? _image;
  final picker = ImagePicker();
  String profile_pic = '';
  bool noPhotoAvailable = false;
  bool noLicenseAvailable = false;

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  bool isJobTypeListVisible = false;
  bool isSearchBarVisibleofjobs = false;

  bool isLanguageListVisible = false; // Add this variable
  String selectedCountryCode =
      '+1'; // Default country code for the United States
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

  TextEditingController formattedPhoneNumberController =
      TextEditingController();

  String formattedPhoneNumber = ''; // Store the formatted phone number
  String formattedPhoneNumber2 = ''; // Formatted phone number to display
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 12) {
      // Format the phone number as "(XXX) XXX-XXXX"
      return '(${phoneNumber.substring(2, 5)}) ${phoneNumber.substring(5, 8)}-${phoneNumber.substring(8, 12)}';
    }
    return phoneNumber;
  }

  List<String> americanPhoneCodes = [
    '+1',
  ]; // Add more if needed
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
  List<Map<String, dynamic>> filteredJobtypes = [];

  final TextEditingController phoneNumberController = TextEditingController();

  // final TextEditingController paypalcontroller = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final licenseController = TextEditingController();
  final licenseandimageController = TextEditingController();
  final zipcodeController = TextEditingController();
  final emailController2 = TextEditingController();
  String? firstNameError;

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

  void _markFormAsFilled() {
    setState(() {
      _isFormFilled = true;
    });
  }

  bool hasUppercase = false;

  bool hasLowercase = false;

  bool hasNumber = false;
  bool charater8 = false;

  void checkPassword(String password) {
    setState(() {
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      charater8 = password.length >= 8;
    });
  }

  bool isValidEmail(String email) {
    // Regular expression to validate email addresses
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

    // Check if the email address matches the regular expression
    return emailRegex.hasMatch(email);
  }

  bool isValidEmail2(String email) {
    // Regular expression to validate email addresses
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

    // Check if the email address matches the regular expression
    return emailRegex.hasMatch(email);
  }

  bool isListExpanded = false;

  bool _passwordsMatch = true;

  bool _isObscured = true;

  bool _isValidPassword(String password) {
    if (password.length < 8) {
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

    if (confirmPassword.isEmpty && password.isEmpty) {
      return true; // Return true if the confirmPassword field is empty
    }

    return password == confirmPassword;
  }

  String _email = '';

  String _password = '';

  String _validationMessage = '';

  bool _isEmailValid = true;

  String _selectedCountryCode = '+1';
  late String user_token = '';
  late AnimationController ciruclaranimation;

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
    // paypalcontroller.dispose();
    addressLineController.dispose();
    addressst2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    ciruclaranimation.dispose();

    super.dispose();
  }

  late String _selectedRadio;
  late String languagesString;
  late String JobtypeString;

  @override
  void initState() {
    super.initState();
    Languagedata();
    Jobtypesdata();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);
    _selectedRadio = ''; // You can set a default value if needed
    languagesString = selectedLanguagesname.join(', ');
    JobtypeString = selectedJobtypenames.join(', ');
  }

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

  bool _validateForm() {
    if (firstnameController.text.isEmpty ||
            lastnameController.text.isEmpty ||
            emailController2.text.isEmpty ||
            passwordController.text.isEmpty ||
            phoneNumberController.text.isEmpty ||
            // selectedLanguage.isEmpty ||
            expyearcontroller.text.isEmpty
        // paypalcontroller.text.isEmpty
        ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  RegisterWorkerApiClient registerworkerapi =
      RegisterWorkerApiClient(baseUrl: 'https://workdonecorp.com');
  bool _isLoading = false;

  void _registerWorker() async {
    // Make sure to fill in the values from your text controllers or other sources

    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String email = emailController2.text;
    String password = passwordController.text;
    String phone = phoneNumberController.text;

    String experience = expyearcontroller.text.isEmpty
        ? 'No Experience year'
        : expyearcontroller.text;
    String licenseNumber = licenseController.text;
    String street1 = addressLineController.text;
    String street2 =
        addressst2Controller.text.isEmpty || addressst2Controller.text == ''
            ? 'No addressline 2'
            : addressst2Controller.text;
    String city = cityController.text;
    String state = selectedState;
    String address_zip = zipcodeController.text;
    // String paypal = paypalcontroller.text;

    print(firstName);
    print(lastName);
    print(email);
    print(password);
    print(phone);
    print(experience);
    print(street1);
    print(street2);
    print(licenseNumber);
    print(city);
    print(state);
    print(address_zip);
    // print(paypal);
    print(
        'selected languages ${selectedLanguages}'); // Print the selected language IDs

    // Show the circular progress indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the registerworker method from your registerworkerapi
      final registrationResponse = await registerworkerapi.registerworker(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        jobType: selectedJobtype,
        experience: experience,
        state: state,
        city: city,
        street2: street2,
        // paypal: paypal,
        street1: street1,
        languageIds: selectedLanguages,

        addressZip: address_zip,
        licenseNumber: licenseNumber,
        licensePic:
            _image?.path, // Use null-aware operator to avoid null errors
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

        Get.offAll(
          OnBoardingWorker(),
          transition: Transition.fadeIn,
          // You can choose a different transition
          duration: Duration(milliseconds: 700),
          fullscreenDialog: true,
        );
        // Navigate to the next screen (you may want to do this based on certain conditions)
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('4d8d6e'),

      // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;
    Size size = MediaQuery.of(context).size;
    String selectedPhoneCode =
        americanPhoneCodes[0]; // Initialize with the first code
    bool isPhoneNumberValid =
        true; // Add a flag to track phone number validation
    bool validatePhoneNumber(String phoneNumber) {
      final formattedPhoneNumber = phoneNumber.replaceAll(
          RegExp(r'\D'), ''); // Remove non-digit characters
      return formattedPhoneNumber.length == 10;
    }

    var addresstext = '';

    if (addressLineController.text.isNotEmpty) {
      addresstext += 'Your Address : \n' + addressLineController.text + ', ';
      addresstext += '\n';
    } else {
      addresstext += addressLineController.text;
      addresstext += 'Enter Address';
    }
    if (addressst2Controller.text.isNotEmpty) {
      addresstext += addressst2Controller.text + ', ';
      addresstext += '\n';
    }
    if (cityController.text.isNotEmpty) {
      addresstext += cityController.text + ', ';
      addresstext += ' ';
    }
    if (selectedState != 'Select State') {
      addresstext += selectedState;
      addresstext += '';
    }

    double? containerHeight = size.height * 0.09;
    if (addresstext != 'Enter Address') {
      containerHeight = null;
    }
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Enable auto-validation

      key: _formKey,
      child: SafeArea(
        child: BlurryModalProgressHUD(
          inAsyncCall: _isLoading,
          blurEffectIntensity: 7,
          progressIndicator: Center(
              child: RotationTransition(
            turns: ciruclaranimation,
            child: SvgPicture.asset(
              'assets/images/Logo.svg',
              semanticsLabel: 'Your SVG Image',
              width: 70,
              height: 80,
            ),
          )),
          dismissible: false,
          opacity: 0.4,
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
                                                firstNameError =
                                                    'Enter first name';
                                                return firstNameError;
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.text,
                                            onChanged: (value) {
                                              if (firstnameController
                                                  .text.isNotEmpty) {
                                                setState(() {
                                                  firstNameError = null;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'First Name',
                                              contentPadding: EdgeInsets.all(0),
                                              border: InputBorder.none,
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                              counterText:
                                                  "", // Hide the counter

                                              // Remove default border
                                            ),
                                            maxLength:
                                                12, // Limit the input to 12 characters
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
                                      SizedBox(
                                        width: 8,
                                      ),

                                      SvgPicture.asset(
                                        'assets/icons/firstsecondicon.svg',
                                        // Replace with the path to your SVG file
                                        width: 33.0,
                                        // Replace with the desired width of the icon
                                        height:
                                            33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
                                      ),
                                      SizedBox(
                                        width: 8,
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
                                              contentPadding: EdgeInsets.all(0),
                                              // Remove content padding

                                              // Replace with the desired hint text
                                              border: InputBorder.none,
                                              counterText:
                                                  "", // Hide the counter

                                              // Remove default border
                                            ),
                                            maxLength:
                                                12, // Limit the input to 12 characters
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
                                height: size.height * 0.38,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: HexColor('#F5F5F5'),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/licenseicon.svg',
                                            width: 25.0,
                                            height: 25.0,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text('Licence ',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Replace TextFormField with your widget
                                              Expanded(
                                                child: TextFormField(
                                                  controller: licenseController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  enabled: !noLicenseAvailable,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          'License Number',
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      border: InputBorder.none,
                                                      icon: Icon(
                                                        FontAwesomeIcons
                                                            .solidIdCard,
                                                        color:
                                                            HexColor('4D8D6E'),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Replace TextFormField with your widget
                                              Text('Licence image ',
                                                  style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),

                                              SizedBox(width: 5),
                                              Visibility(
                                                  visible: _image == null,
                                                  child: SizedBox(
                                                    width: 15,
                                                  )),
                                              ElevatedButton(
                                                onPressed:
                                                    noPhotoAvailable ||
                                                            noLicenseAvailable
                                                        ? null
                                                        : () async {
                                                            final action =
                                                                await showDialog<
                                                                    String>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Choose an option'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      ListTile(
                                                                        leading:
                                                                            Icon(Icons.image),
                                                                        title: Text(
                                                                            'Gallery'),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context,
                                                                              'gallery');
                                                                        },
                                                                      ),
                                                                      ListTile(
                                                                        leading:
                                                                            Icon(Icons.camera),
                                                                        title: Text(
                                                                            'Camera'),
                                                                        onTap:
                                                                            () {
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

                                                            if (action ==
                                                                'gallery') {
                                                              final pickedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                source:
                                                                    ImageSource
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
                                                                source:
                                                                    ImageSource
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      HexColor('4D8D6E'),
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(30, 40),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Photo',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Visibility(
                                                  visible: _image == null,
                                                  child: SizedBox(
                                                    width: 15,
                                                  )),
                                              SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: noPhotoAvailable ||
                                                        noLicenseAvailable
                                                    ? null
                                                    : () {
                                                        if (_image == null) {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                "Please select an License Photo",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0,
                                                          );
                                                          return;
                                                        }
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                FullScreenImage(
                                                                    image:
                                                                        _image!),
                                                          ),
                                                        );
                                                      },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color:
                                                            HexColor('4D8D6E'),
                                                        width: 1),
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
                                                            color: HexColor(
                                                                '4D8D6E'),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Visibility(
                                                visible: _image != null,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _image = null;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    _image == null
                                        ? Row(
                                            children: [
                                              Checkbox(
                                                activeColor: HexColor('4D8D6E'),
                                                value: noPhotoAvailable,
                                                onChanged: (value) {
                                                  setState(() {
                                                    noPhotoAvailable = value!;
                                                  });
                                                },
                                              ),
                                              Text(
                                                'No photo available',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: _image == null
                                                      ? Colors.black45
                                                      : Colors.grey,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  'No photo available',
                                                  style: TextStyle(
                                                    color: _image == null
                                                        ? Colors.black45
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    _image == null
                                        ? Row(children: [
                                            Checkbox(
                                              activeColor: HexColor('4D8D6E'),
                                              value: noLicenseAvailable,
                                              onChanged: (value) {
                                                setState(() {
                                                  noLicenseAvailable = value!;
                                                  if (value) {
                                                    // Clear license number and image if "No license available" is checked
                                                    licenseController.clear();
                                                    _image = null;
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              'No License Available',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ])
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Row(children: [
                                              Icon(
                                                Icons.check_box_outline_blank,
                                                color: _image == null
                                                    ? Colors.black45
                                                    : Colors.grey,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'No License Available',
                                                style: TextStyle(
                                                  color: _image == null
                                                      ? Colors.black45
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ]),
                                          ),
                                    SizedBox(
                                      height: 5,
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
                                              return 'Enter this format @Example.com';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            _email = value!;
                                          },
                                          onChanged: _onChanged,
                                          decoration: InputDecoration(
                                            hintText: 'E-mail',
                                            contentPadding: EdgeInsets.all(0),
                                            // Remove content padding

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
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            content: SingleChildScrollView(
                                              child: StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      StateSetter setState) {
                                                return Form(
                                                  key: formkeyaddress,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Write Your Address',
                                                            style: GoogleFonts
                                                                .encodeSans(
                                                              textStyle: TextStyle(
                                                                  color: HexColor(
                                                                      '454545'),
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'Address ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            addressLineController,
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                '#4D8D6E')),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Street address or P.O. Box',
                                                          hintStyle: TextStyle(
                                                              color: HexColor(
                                                                  '#707070')),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#707070')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#4D8D6E')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Enter address line';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextFormField(
                                                        controller:
                                                            addressst2Controller,
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                '#4D8D6E')),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Apt ,suite ,unit ,building',
                                                          hintStyle: TextStyle(
                                                              color: HexColor(
                                                                  '#707070')),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#707070')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#4D8D6E')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'City ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            cityController,
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                '#4D8D6E')),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'City',
                                                          hintStyle: TextStyle(
                                                              color: HexColor(
                                                                  '#707070')),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#707070')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: HexColor(
                                                                    '#4D8D6E')),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter your city';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'State ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Stack(
                                                        children: [
                                                          TextFormField(
                                                            readOnly: true,
                                                            // Set this to true to disable editing
                                                            style: TextStyle(
                                                                color: HexColor(
                                                                    '#4D8D6E')),
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  selectedState ??
                                                                      'Select State',
                                                              // Use selectedState or 'Select State' if it's null
                                                              hintStyle: TextStyle(
                                                                  color: HexColor(
                                                                      '#4D8D6E')),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: HexColor(
                                                                        '#707070')),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: HexColor(
                                                                        '#4D8D6E')),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned.fill(
                                                            child: InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return StateSelectorPopup(
                                                                      states:
                                                                          statesOfAmerica,
                                                                      onSelect:
                                                                          (newlySelectedState) {
                                                                        // Update selectedState when a state is selected
                                                                        setState(
                                                                            () {
                                                                          selectedState =
                                                                              newlySelectedState;
                                                                        });
                                                                        print(
                                                                            'Selected State: $newlySelectedState');
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              'close',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 15,
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              if (formkeyaddress
                                                                      .currentState!
                                                                      .validate() &&
                                                                  selectedState !=
                                                                      'Select State') {
                                                                // Call the onDonePressed function and pass the values
                                                                setState(() {
                                                                  _isFormFilled =
                                                                      true;
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        'Please fill in all fields.'),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                              'Done',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  HexColor(
                                                                      '#4D8D6E'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                          ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  height: containerHeight,
                                  width: size.width * 0.93,
                                  decoration: BoxDecoration(
                                    color: HexColor('#F5F5F5'),
                                    borderRadius: BorderRadius.circular(29),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/addressicon.svg',
                                          width: 33.0,
                                          height: 33.0,
                                        ),
                                        SizedBox(width: 15.0),
                                        Expanded(
                                          child: Text(
                                            addresstext,
                                            style: TextStyle(
                                                color: HexColor('#707070'),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        if (_isFormFilled == true)
                                          Icon(Icons.check,
                                              color: Colors.green),
                                      ],
                                    ),
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
                                          LengthLimitingTextInputFormatter(5),
                                          // Limit the input length to 5 characters
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
                                          hintText: 'Enter ZIP Code ',
                                          contentPadding: EdgeInsets.all(0),
                                          // Remove content padding

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
                              SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isLanguageListVisible =
                                              !isLanguageListVisible;
                                          isSearchBarVisible =
                                              isLanguageListVisible;
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
                                          borderRadius:
                                              BorderRadius.circular(29),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.language),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                languagesString.isEmpty
                                                    ? 'Select Language'
                                                    : '${languagesString}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[700]),
                                                maxLines: 1,
                                                // Limit the number of lines to 1

                                                overflow: TextOverflow
                                                    .ellipsis, // Add this to handle long text
                                              ),
                                            ),
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
                                    if (isLanguageListVisible &&
                                        selectedLanguages.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 19.0, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Please select a language',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Search bar
                                    Visibility(
                                      visible: isSearchBarVisible,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: TextField(
                                          onChanged: (query) {
                                            setState(() {
                                              filteredLanguages = languages
                                                  .where((language) =>
                                                      language['name']
                                                          .toLowerCase()
                                                          .contains(query
                                                              .toLowerCase()))
                                                  .toList();
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search languages...',
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // List of filtered languages
                                    Visibility(
                                      visible: isLanguageListVisible,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            filteredLanguages.map((language) {
                                          final langName = language['name'];
                                          final langId = language['id'];
                                          languagesString =
                                              selectedLanguagesname.join(', ');

                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Text(langName),
                                                leading: Checkbox(
                                                  activeColor:
                                                      HexColor('#4D8D6E'),
                                                  value: selectedLanguages
                                                      .contains(langId),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value!) {
                                                        selectedLanguages
                                                            .add(langId);
                                                        selectedLanguagesname
                                                            .add((langName));
                                                        languagesString =
                                                            selectedLanguagesname
                                                                .join(', ');

                                                        print(
                                                            'selected languages add ${selectedLanguages}'); // Print the selected language IDs
                                                      } else {
                                                        print(
                                                            'selected languages remove ${selectedLanguages}'); // Print the selected language IDs
                                                        selectedLanguages
                                                            .remove(langId);
                                                        selectedLanguagesname
                                                            .remove((langName));
                                                        languagesString =
                                                            selectedLanguagesname
                                                                .join(', ');
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
                                    )
                                  ])),
                              SizedBox(
                                height: ScreenUtil.sizeboxheight,
                              ),
                              SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isJobTypeListVisible =
                                              !isJobTypeListVisible;
                                          isSearchBarVisible2 =
                                              isJobTypeListVisible;
                                          // Remove the condition to update filteredLanguages regardless of the search bar visibility
                                          filteredJobtypes = jobtypes;
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
                                          borderRadius:
                                              BorderRadius.circular(29),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.work),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                JobtypeString.isEmpty
                                                    ? 'Select Jobtype'
                                                    : '${JobtypeString}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[700]),
                                                maxLines: 1,
                                                // Limit the number of lines to 1
                                                overflow: TextOverflow
                                                    .ellipsis, // Add this to handle long text
                                              ),
                                            ),
                                            Icon(
                                              isJobTypeListVisible
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Validation error message
                                    if (isJobTypeListVisible &&
                                        selectedJobtype.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 19.0, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Please select a Job Type',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Search bar
                                    Visibility(
                                      visible: isSearchBarVisible2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: TextField(
                                          onChanged: (query) {
                                            setState(() {
                                              filteredJobtypes = jobtypes
                                                  .where((jobtype) =>
                                                      jobtype['name']
                                                          .toLowerCase()
                                                          .contains(query
                                                              .toLowerCase()))
                                                  .toList();
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search JobTypes...',
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // List of filtered languages
                                    Visibility(
                                      visible: isJobTypeListVisible,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            filteredJobtypes.map((jobtype) {
                                          final jobname = jobtype['name'];
                                          final jobid = jobtype['id'];

                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Text(jobname),
                                                leading: Checkbox(
                                                  activeColor:
                                                      HexColor('#4D8D6E'),
                                                  value: selectedJobtype
                                                      .contains(jobid),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value!) {
                                                        selectedJobtype
                                                            .add(jobid);
                                                        selectedJobtypenames
                                                            .add(jobname);

                                                        JobtypeString =
                                                            selectedJobtypenames
                                                                .join(', ');

                                                        print(
                                                            'selected jobtype add ${selectedJobtype}'); // Print the selected language IDs
                                                      } else {
                                                        print(
                                                            'selected jobtype remove ${selectedJobtype}'); // Print the selected language IDs
                                                        selectedJobtype
                                                            .remove(jobid);
                                                        selectedJobtypenames
                                                            .remove(jobname);

                                                        JobtypeString =
                                                            selectedJobtypenames
                                                                .join(', ');
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
                                    )
                                  ])),
                              SizedBox(
                                height: ScreenUtil.sizeboxheight,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                height: size.height * 0.103,
                                width: size.width * 0.93,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/phonenumber.svg',
                                      // Replace with your SVG path
                                      width: 33.0,
                                      height: 33.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
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
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black87),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          // Add some spacing between the dropdown and the text field
                                          Expanded(
                                            child: TextFormField(
                                              controller: phoneNumberController,
                                              decoration: InputDecoration(
                                                hintText: 'Phone Number',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.all(
                                                    0), // Remove content padding
                                              ),
                                              keyboardType: TextInputType.phone,
                                              onChanged: (value) {
                                                setState(() {
                                                  // Format the phone number using the formatPhoneNumber function
                                                  final formattedPhoneNumber =
                                                      formatPhoneNumber(value);
                                                  phoneNumberController.value =
                                                      TextEditingValue(
                                                    text: formattedPhoneNumber,
                                                    selection:
                                                        TextSelection.collapsed(
                                                            offset:
                                                                formattedPhoneNumber
                                                                    .length),
                                                  );
                                                  // Add +1 prefix to the formatted phone number
                                                  phoneNumberController.text =
                                                      '$formattedPhoneNumber';

                                                  // Ensure the cursor position is at the end
                                                  phoneNumberController
                                                          .selection =
                                                      TextSelection
                                                          .fromPosition(
                                                    TextPosition(
                                                        offset:
                                                            phoneNumberController
                                                                .text.length),
                                                  );
                                                  print(phoneNumberController
                                                      .text);
                                                  // Validate the phone number
                                                  isPhoneNumberValid =
                                                      validatePhoneNumber(
                                                          formattedPhoneNumber);
                                                });
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                                // Limit the input length to 10 digits
                                              ],
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a phone number';
                                                }

                                                // Basic validation: Check if the formatted phone number has 10 digits
                                                final formattedPhoneNumber =
                                                    formatPhoneNumber(value);
                                                if (formattedPhoneNumber
                                                        .replaceAll(
                                                            RegExp(r'\D'), '')
                                                        .length !=
                                                    10) {
                                                  return 'Invalid phone number';
                                                }

                                                return null; // Return null if the input is valid
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isPhoneNumberValid)
                                      Text(
                                        'Please enter a valid phone number.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
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
                                          contentPadding: EdgeInsets.all(0),
                                          // Remove content padding

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
                                            return 'required At least 8 characters long,uppercase & lowercase letters,'
                                                ' numbers,';
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
                                              color: HexColor('#509372'),
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
                                            controller:
                                                confirmPasswordController,
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
                                                onTap:
                                                    _togglePasswordVisibility,
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
                              SizedBox(
                                height: ScreenUtil.sizeboxheight,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            hasUppercase
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: hasUppercase
                                                ? Colors.green
                                                : Colors.red,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            hasLowercase
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: hasLowercase
                                                ? Colors.green
                                                : Colors.red,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            hasNumber
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: hasNumber
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Number',
                                            style: TextStyle(
                                              color: hasNumber
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            charater8
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: charater8
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'At least 8 characters',
                                            style: TextStyle(
                                              color: charater8
                                                  ? Colors.green
                                                  : Colors.red,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    // Set the container color
                                    borderRadius: BorderRadius.circular(
                                        15), // Set the circular radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: CheckboxListTile(
                                      value: _isCheckedterm,
                                      activeColor: HexColor('#4D8D6E'),
                                      title: Row(
                                        children: [
                                          Text(
                                            'I agree to ',
                                            style: GoogleFonts.roboto(
                                              textStyle: TextStyle(
                                                  color: HexColor('454545'),
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.to(termsOfService());
                                            },
                                            child: Text(
                                              'Terms of Service',
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                  color: HexColor('#4D8D6E'),
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              // Removes padding
                                              minimumSize: Size.zero,
                                              // Sets the minimum size to zero
                                              tapTargetSize: MaterialTapTargetSize
                                                  .shrinkWrap, // Reduces the tap target size
                                            ),
                                          )
                                        ],
                                      ),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isCheckedterm = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
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
                                            width: 70,
                                            height: 80,
                                          ),
                                        ),
                                      )
                                    // Show loading indicator when uploading
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          RoundedButton(
                                              text: 'Register',
                                              press: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  if (selectedLanguages
                                                      .isNotEmpty) {
                                                    if (addressLineController
                                                        .text.isNotEmpty) {
                                                      if (selectedJobtype !=
                                                          'Select JobType') {
                                                        _isCheckedterm
                                                            ? _registerWorker()
                                                            : HapticFeedback
                                                                .vibrate(); // Trigger haptic feedback

                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Please agree to the Terms of Service",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .CENTER,
                                                          timeInSecForIosWeb: 1,
                                                          textColor: Colors.red,
                                                          fontSize: 16.0,
                                                        );
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Please select a job type.");
                                                      }
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Please fill in the address.");
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please select a language.");
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Please fill in all required fields.");
                                                }
                                              }),
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
      ),
    );
  }
}

// class AddressPickerPopup extends StatefulWidget {
//   final Function(String, String, String, String) onDonePressed;
//   final String addressLine;
//   final String addressLine2;
//   final String city;
//   final String state;
//
//   AddressPickerPopup({
//     required this.onDonePressed,
//     this.addressLine = '',
//     this.addressLine2 = '',
//     this.city = '',
//     this.state = '',
//   }) : super();
//
//   @override
//   _AddressPickerPopupState createState() => _AddressPickerPopupState();
// }
//
// class _AddressPickerPopupState extends State<AddressPickerPopup> {
//   late GlobalKey<FormState> formKey;
//   late TextEditingController addressLineController;
//   late TextEditingController addressst2Controller;
//   late TextEditingController cityController;
//   late TextEditingController stateController;
//
//   @override
//   void initState() {
//     super.initState();
//     formKey = GlobalKey<FormState>();
//     addressLineController = TextEditingController(text: widget.addressLine);
//     addressst2Controller = TextEditingController(text: widget.addressLine2);
//     cityController = TextEditingController(text: widget.city);
//     stateController = TextEditingController(text: widget.state);
//   }
//
//   @override
//   void dispose() {
//     addressLineController.dispose();
//     addressst2Controller.dispose();
//     cityController.dispose();
//     stateController.dispose();
//     super.dispose();
//   }
//
//   TextEditingController _searchController = TextEditingController();
//   String selectedState = 'Select State';
//
//   bool _isFormFilled = false;  List<String> statesOfAmerica = [
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
//
//   void _filterStates(String query) {
//     // Filter the list of states based on the search query
//     setState(() {
//       selectedState = ''; // Clear the selected state if any
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     // Define TextEditingController variables
//
//
//     return AlertDialog(
//
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       content: Form(
//         key: formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Stack(
//                 children: [
//                   TextFormField(
//                     readOnly: true, // Set this to true to disable editing
//                     style: TextStyle(color: HexColor('#4D8D6E')),
//                     decoration: InputDecoration(
//                       hintText: selectedState ?? 'Select State', // Use selectedState or 'Select State' if it's null
//                       hintStyle: TextStyle(color: HexColor('#4D8D6E')),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: HexColor('#707070')),
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: HexColor('#4D8D6E')),
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                     ),
//                   ),
//                   Positioned.fill(
//                     child: InkWell(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return StateSelectorPopup(
//                               states: statesOfAmerica,
//                               onSelect: (newlySelectedState) {
//                                 // Update selectedState when a state is selected
//                                 setState(() {
//                                   selectedState = newlySelectedState;
//                                 });
//                                 print('Selected State: $newlySelectedState');
//                               },
//                             );
//                           },
//                         );
//                       },
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                     ),
//                   ),
//                 ],
//               ),
//
//
//
//
//               SizedBox(height: 10),
//
//               TextFormField(
//                 controller: addressLineController,
//                 style: TextStyle(color: HexColor('#4D8D6E')),
//                 decoration: InputDecoration(
//                   hintText: 'Address Line',
//
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
//
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
//
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
//               ElevatedButton(
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     setState(() {
//
//                     });
//                     String addressLine = addressLineController.text;
//                     String addressLine2 = addressst2Controller.text;
//                     String city = cityController.text;
//                     String state = selectedState;
//
//                     // Call the onDonePressed function and pass the values
//                     widget.onDonePressed(addressLine, addressLine2, city, state);
//                     setState(() {
//                       _isFormFilled = true;
//
//                     });
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text(
//                   'Done',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                  backgroundColor: HexColor('#4D8D6E'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class FullScreenImage extends StatelessWidget {
  final File image;

  const FullScreenImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.file(
          image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
