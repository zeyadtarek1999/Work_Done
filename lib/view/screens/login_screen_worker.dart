import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/textinputformatter.dart';
import '../bottomsheet.dart';
import '../components/page_title_bar.dart';
import '../components/under_part.dart';
import '../components/upside.dart';
import 'Screens_layout/layoutWorker.dart';
import '../widgets/rounded_button.dart';
import 'package:http/http.dart' as http;
class LoginScreenworker extends StatefulWidget {
  const LoginScreenworker({Key? key}) : super(key: key);

  @override
  State<LoginScreenworker> createState() => _LoginScreenworkerState();
}

class _LoginScreenworkerState extends State<LoginScreenworker> {
  final formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isObscured = true;

  String _email = '';

  String _password = '';
  Future<void> loginUser(BuildContext context, String email, String password) async {

    final apiUrl = 'http://172.233.199.17/worker.php';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'type': 'worker',
        'email': email,
        'password': password,
        'action': 'login',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['worker_id'] != null) {
        String workerId = jsonResponse['worker_id'];

        // Save the worker ID using the saveWorkerId function
        await saveWorkerId(int.parse(workerId));

        print('Worker ID: $workerId');

        // Navigate to the next screen
        // For example:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => layoutworker()),
        );
      } else {
        print('Worker ID not found in response.');
        // Display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
    } else {
      print('Failed to post login data. Status code: ${response.statusCode}');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  Future<void> saveWorkerId(int workerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('worker_id', workerId);
  }


  Future<int?> getSavedWorkerId() async {
    int workerIdStr = await getWorkerId(); // Get the worker ID as a String
    int? workerId = int.tryParse(workerIdStr as String); // Convert to int if possible

    print('Fetched Worker ID: $workerId');
    return workerId;
  }


  Future<int> getWorkerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? 0;
    return workerId;
  }

  String _validationMessage = '';

  bool _isEmailValid = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
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
      key: formKey,
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
                                          controller: _emailController,
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
                                            controller: _passwordController,
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
                              RoundedButton(
                                text: 'LOGIN',
                                press: () async {
                                  if (formKey.currentState!.validate()) {
                                    String email = _emailController.text;
                                    String password = _passwordController.text;

                                    // Pass the BuildContext to loginUser function
                                    await loginUser(context, email, password);
                                    print('Login successful');
                                  } else {
                                    // Show custom validation message inside the container
                                    setState(() {
                                      Fluttertoast.showToast(
                                        msg: 'Error',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.SNACKBAR,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    });
                                  }
                                },
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
                              Text(
                                'Forgot password?',
                                style: TextStyle(
                                    color: HexColor("#4D8D6E"),
                                    fontFamily: 'OpenSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
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
