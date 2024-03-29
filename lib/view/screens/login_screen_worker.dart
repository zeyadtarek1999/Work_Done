
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/Forgetpassword.dart';
import '../../model/login_model.dart';
import '../../model/textinputformatter.dart';
import '../widgets/bottomsheet.dart';
import '../components/page_title_bar.dart';
import '../components/under_part.dart';
import '../components/upside.dart';
import 'Screens_layout/layoutWorker.dart';

class LoginScreenworker extends StatefulWidget {
  const LoginScreenworker({Key? key}) : super(key: key);

  @override
  State<LoginScreenworker> createState() => _LoginScreenworkerState();
}

class _LoginScreenworkerState extends State<LoginScreenworker> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController ciruclaranimation;
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  bool isLoading = false;

  bool _isObscured = true;

  String _email = '';

  String _password = '';
  final ApiClient apiClient = ApiClient("https://workdonecorp.com"); // Replace with your actual base URL

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text;
      String password = passwordController.text;

      if (email.isNotEmpty && password.isNotEmpty) {
        final loginResponse = await apiClient.login(email, password);

        // Print the entire response for debugging purposes
        print('Login Response: $loginResponse');

        // Check if 'msg' key exists and is not null in the response
        if (loginResponse.containsKey('msg') && loginResponse['msg'] != null) {
          String errorMessage = loginResponse['msg'];

          if (errorMessage == 'you provided wrong credentials') {
            // Show SnackBar for wrong credentials
            Fluttertoast.showToast(
              msg: 'Login failed: you provided wrong credentials',
              fontSize: 16.0,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          } else {
            // Handle other error messages if needed
            // Display a user-friendly error message or throw an exception if needed
          }
        } else if (loginResponse.containsKey('token') && loginResponse['token'] != null) {
          // Access the token from the response
          String token = loginResponse['token'];
          String status = loginResponse['status'];
          String account_type = loginResponse['account_type'];

          // Save the token, status, and account_type using shared preferences
          await _saveTokenToSharedPreferences(token);

          // Navigate to the next screen or perform other actions after a successful login
          print('Login successful. Token: $token');
          print('Login successful. Status: $status');
          print('Login successful. Account Type: $account_type');

          if (account_type == 'client') {
            // Display a toast and do not navigate to layoutworker()
            Fluttertoast.showToast(
              msg: 'It\'s a client account. Please enter a worker account.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          } else {
            // Navigate to layoutworker() for non-client accounts

            Get.offAll(layoutworker(showCase: false),
              transition: Transition.fadeIn, // You can choose a different transition
              duration: Duration(milliseconds: 700), );          }
        } else {
          // Handle the case when 'token' is null or not present in the response
          print('Login failed. Token is null or not present in the response.');
          // Display a user-friendly error message or throw an exception if needed
        }
      } else {

        // Display an error message if email or password is empty
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ));
        print('Please enter both email and password');
      }
    } catch (error) {
      // Handle errors
      print('Error during login: $error');
      // Display a snackbar or toast with the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: $error'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _checkSavedToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedToken = prefs.getString('user_token') ?? 'Token not found';

    print('Saved Token: $savedToken');
  }
// Function to save data using shared preferences
  Future<void> _saveTokenToSharedPreferences(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_token', token);
    print('Token is ' + token);
  }
  Future<void> _testSavedToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedToken = prefs.getString('user_token') ?? 'Token not found';

    print('Saved Token: $savedToken');
  }
  String _validationMessage = '';

  bool _isEmailValid = true;
  @override
  void initState() {
    super.initState();
    _testSavedToken();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);
// Test the saved token
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    ciruclaranimation.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    }

    // Add email format validation if needed
    return null;
  }

  void _onChanged(String value) {
    setState(() {
      _isEmailValid = formKey.currentState!.validate();
    });
  }void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ChooseRoleBottomSheet();
      },
    );
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    }

    // Add password length validation if needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:         HexColor('4d8d6e'),

      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    double screenWidth = MediaQuery.of(context).size.width;
    double fourthscreenwidth = screenWidth * 0.40;
    double sizeboxwidth = screenWidth * 0.1;
    double halfScreenwidth = screenWidth * 0.83;
    double buttonscreenwidth = screenWidth * 0.75;
    double paddingoftext = screenWidth * 0.1;
    double paddingoflogintext = screenWidth * 0.09;

    double screenHeight = MediaQuery.of(context).size.height;
    double greenbackgroundheight = screenHeight * 0.22;
    double backgroundheight = screenHeight * 0.22;
    double logoheight = screenHeight * 0.22;
    double containeroftextheight = screenHeight * 0.09;
    double sizeboxheight = screenHeight * 0.03;
    double sizeboxloginheight = screenHeight * 0.06;
    double containerheight = screenHeight * 0.1;
    Size size = MediaQuery.of(context).size;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction, // Enable auto-validation

      key: formKey,
      child: SafeArea(
        child:  BlurryModalProgressHUD(
          inAsyncCall: isLoading,
          blurEffectIntensity: 7,
          progressIndicator: Center(child: RotationTransition(
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
                    const PageTitleBar(title: 'Login to your account'),
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
                            iconButton(context),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    width: size.width * 0.8,
                                    decoration: BoxDecoration(
                                      color: HexColor('#F5F5F5'),
                                      borderRadius: BorderRadius.circular(29),
                                    ),
                                    child: Row(
                                      children: [
                                        Opacity(
                                            opacity: 0.5,
                                            child: Icon(
                                              Icons.email_outlined,
                                              color: HexColor('#292929'),
                                            )), // Replace with the desired icon
                                        SizedBox(width: 20.0),
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            controller: emailController,
                                            validator: (value) =>
                                                _validateEmail(value!),
                                            onSaved: (value) {
                                              _email = value!;

                                              // Save email value if needed
                                            },
                                            onChanged: _onChanged,
                                            decoration: InputDecoration(
                                              hintText: 'E-mail',
                                              // Replace with the desired hint text
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.0),
                                // Hide the validation message initially

                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    width: size.width * 0.8,
                                    decoration: BoxDecoration(
                                      color: HexColor('#F5F5F5'),
                                      borderRadius: BorderRadius.circular(29),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/passwordicon.svg',
                                          // Replace with the path to your SVG file
                                          width: 23.0,
                                          // Replace with the desired width of the icon
                                          height:
                                              23.0, // Replace with the desired height of the icon
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
                                              validator: (value) =>
                                                  _validatePassword(value!),
                                              onSaved: (value) {
                                                _password = value!;
                                              },
                                              decoration: InputDecoration(
                                                suffixIcon: GestureDetector(
                                                  onTap:
                                                      _togglePasswordVisibility,
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
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15,),
                                Container(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                     backgroundColor: Color(0xFF4D8D6E), // Set the color to 4D8D6E
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Set the border radius to make it circular
                                      ),
                                    ),
                                    child: isLoading
                                        ? CircularProgressIndicator()
                                        : Text('Login',style: TextStyle(color: Colors.white,fontSize: 16),),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                UnderPart(
                                  title: "Don't have an account?",
                                  navigatorText: "Register here",
                                  onTap: () {
                                    _showBottomSheet(context);
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextButton(
                                  onPressed: (){Get.to(ForgotPasswordScreen());},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                        color: HexColor("#4D8D6E"),
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),),
                                const SizedBox(
                                  height: 40,
                                )
                              ],
                            )
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

iconButton(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      SizedBox(
        width: 20,
      ),
      SizedBox(
        width: 20,
      ),
    ],
  );
}
