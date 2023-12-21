import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../model/changePassword.dart';
import '../../model/mediaquery.dart';
import '../../model/textinputformatter.dart';
import '../widgets/rounded_button.dart';

class changePasswordscreen extends StatefulWidget {
  final String userToken;

  changePasswordscreen({required this.userToken});

  @override
  State<changePasswordscreen> createState() => _changePasswordscreenState();
}

class _changePasswordscreenState extends State<changePasswordscreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController currentpasswordController = TextEditingController();

  final TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isObscured = true;
  bool _isObscured2 = true;

  bool _passwordsMatch = false;
  String _password = '';
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
  bool hasUppercase = false;

  bool hasLowercase = false;

  bool hasNumber = false;
  bool _isValidPasswordtextform(String password) {
    // Check if the password is at least 12 characters long
    if (password.length < 12) {
      return false;
    }

    // Check if the password contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // Check if the password contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    // Check if the password contains at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    // All conditions passed, so the password is valid
    return true;
  }
  void checkPassword(String password) {
    setState(() {
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
    });
  }

  bool _validatePasswords() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    return password == confirmPassword;
  }
  @override
  void dispose() {
    // Dispose of your controllers here

    passwordController.dispose();
    super.dispose();
  }
  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void _togglePasswordVisibility2() {
    setState(() {
      _isObscured2 = !_isObscured2;
    });
  }
  bool isLoading = false; // Add a loading state

  void _changePassword() async {
    final currentPassword = currentpasswordController.text;
    final newPassword = confirmPasswordController.text;

    // if (currentPassword.isEmpty || newPassword.isEmpty) {
    //   Fluttertoast.showToast(
    //     msg: 'Failed to change password. Please try again.',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // }

    final apiManager = changepasswordapimodel();
    await apiManager.changePassword(currentPassword, newPassword);

    // Optionally, you can add navigation logic or show a message based on the API response.
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Form(
      key: formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 67,
          backgroundColor: Colors.white,
          title: Text(
            'Change Password',
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
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: Text('Current Password'),
                        ),
                        Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              height: size.height * 0.099,
                              width: size.width * 0.90,
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
                                      controller: currentpasswordController,
                                      obscureText: _isObscured2,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        } else if (!_isValidPassword(value)) {
                                          return 'Password must be at least 12 characters long and include uppercase and lowercase letters, and numbers.';
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
                                          onTap: _togglePasswordVisibility2,
                                          // Call the _togglePasswordVisibility function here
                                          child: Icon(
                                            _isObscured2
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                        hintText: 'Current password',

                                        // Replace with the desired hint text
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )),

                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: Text('New Password'),
                        ),
                        Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              height: size.height * 0.099,
                              width: size.width * 0.90,
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
                                        hintText: 'New Password',

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
                            width: size.width * 0.90,
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

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              RoundedButton(text: 'Change Password', press: _changePassword),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                ],
              ),
            ],

          ),
        ),

      ),
    );
  }
}
