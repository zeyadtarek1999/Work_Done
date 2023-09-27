// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:untitled/view/screens/Screens_layout/layoutWorker.dart';
//
// import '../model/mediaquery.dart';
// import '../model/textinputformatter.dart';
// import 'screens/homescreen/homeWorker.dart';
// import 'loginscreen.dart';
//
// class signupclient extends StatefulWidget {
//   const signupclient({super.key});
//
//   @override
//   State<signupclient> createState() => _signupclientState();
// }
//
// class _signupclientState extends State<signupclient> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _firstnameController = TextEditingController();
//   final _lastnameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _zipcodeController = TextEditingController();
//   TextEditingController _addressLineController = TextEditingController();
//   TextEditingController _cityController = TextEditingController();
//   TextEditingController _stateController = TextEditingController();
//   void _showAddressPicker(BuildContext context) {
//     GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Create a new key
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return AddressPickerForm(
//           formKey: _formKey,
//           onFormFilled: _markFormAsFilled,
//
//           addressLineController: _addressLineController,
//           cityController: _cityController,
//           stateController: _stateController,
//         );
//       },
//     );
//   }
//
//   bool _isFormFilled = false;
//
//   void _markFormAsFilled() {
//     setState(() {
//       _isFormFilled = true;
//     });
//   }
//   bool hasUppercase = false;
//   bool hasLowercase = false;
//   bool hasNumber = false;
//
//   void checkPassword(String password) {
//     setState(() {
//       hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
//       hasLowercase = RegExp(r'[a-z]').hasMatch(password);
//       hasNumber = RegExp(r'[0-9]').hasMatch(password);
//     });
//   }
//   bool isValidEmail(String email) {
//     // Regular expression to validate email addresses
//     final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
//
//     // Check if the email address matches the regular expression
//     return emailRegex.hasMatch(email);
//   }
//
//   List<String> items = [
//     'English',
//     'German',
//     'Arabic',
//     'Spanish',
//     'Italian',
//     'Russian',
//     'French'
//   ];
//   List<bool> checkedItems = List.filled(0, false);
//   bool isListExpanded = false;
//
//
//
//   final _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _confirmPasswordController = TextEditingController();
//   bool _passwordsMatch = false;
//   bool _isObscured = true;
//
//   bool _isValidPassword(String password) {
//     // Define regular expressions for each required character type
//     final uppercaseRegExp = RegExp(r'[A-Z]');
//     final lowercaseRegExp = RegExp(r'[a-z]');
//     final digitRegExp = RegExp(r'\d');
//     final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
//
//     // Check if the password meets all the criteria
//     return password.length >= 12 &&
//         uppercaseRegExp.hasMatch(password) &&
//         lowercaseRegExp.hasMatch(password) &&
//         digitRegExp.hasMatch(password) &&
//         specialCharRegExp.hasMatch(password);
//   }
//
//   bool _validatePasswords() {
//     String password = _passwordController.text;
//     String confirmPassword = _confirmPasswordController.text;
//     return password == confirmPassword;
//   }
//
//   String _email = '';
//   String _password = '';
//   String _validationMessage = '';
//   bool _isEmailValid = true;
//   final TextEditingController _textController = TextEditingController();
//
//   final TextEditingController _phoneNumberController = TextEditingController();
//   String _selectedCountryCode = '+1'; // Default country code
//
//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   final RxBool _isChecked = false.obs;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize checkedItems with the same length as items, and all values as false
//     checkedItems = List.filled(items.length, false);
//   }
//
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       _isObscured = !_isObscured;
//     });
//   }
//
//
//
//
//   void _onChanged(String value) {
//     setState(() {
//       _isEmailValid = _formKey.currentState!.validate();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;
//     return Scaffold(
//       body: Form(
//         key: _formKey,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(children: [
//               Stack(
//                 children: [
//                   Container(
//                       height: ScreenUtil.greenbackgroundheight,
//                       width: ScreenUtil.screenWidth,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                             image: AssetImage(
//                               'assets/images/greenbackground.png',
//                             ),
//                             fit: BoxFit.fitWidth),
//                       )),
//                   Container(
//                       height: ScreenUtil.backgroundheight,
//                       width: ScreenUtil.screenWidth,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                             image: AssetImage(
//                               'assets/images/firstscreen.png',
//                             ),
//                             fit: BoxFit.fitWidth),
//                       )),
//                   Center(
//                     child: Container(
//                         height: ScreenUtil.logoheight,
//                         width: ScreenUtil.fourthscreenwidth,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage(
//                                 'assets/images/test.png',
//                               ),
//                               fit: BoxFit.cover),
//                         )),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           Icons.arrow_back_ios,
//                         ),
//                         // Replace with your desired icon
//                         iconSize: 32.0,
//                         // Adjust the size of the icon
//                         color: Colors.white,
//                         // Set the color of the icon
//                         onPressed: () {
//                           Get.back();
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Container(
//                 width: ScreenUtil.screenWidth,
//                 height: ScreenUtil.containeroftextheight,
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     BoxShadow(
//                       color: HexColor('#707070'),
//                       // Shadow color
//                       offset: Offset(0, 2.0),
//                       // Set the offset (x, y) to control the shadow position
//                       blurRadius: 7.0,
//                       // Set the blur radius to control the spread of the shadow
//                       spreadRadius:
//                       -2.0, // Set the spread radius to control the size of the shadow
//                     ),
//                   ],
//                   color: Colors.white,
//                 ),
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 100.0, // Set the height of the right column
//                           child: Center(
//                             child: TextButton(
//                                 style: TextButton.styleFrom(
//                                   foregroundColor: HexColor('#929191'),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8.0)),
//                                 ),
//                                 // Border radius of the button
//                                 // You can add more customization options here)),
//                                 onPressed: () {
//                                   Get.to(Loginscreen(),
//                                       transition: Transition.rightToLeft);
//                                 },
//                                 child: Text(
//                                   'login',
//                                   style: TextStyle(
//                                       color:
//                                       HexColor('#4D8D6E').withOpacity(0.6)),
//                                 )),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           height: 100.0,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border(
//                                 bottom: BorderSide(
//                                   color: HexColor('#4D8D6E'),
//                                   width: 3,
//                                 )),
//                           ), // Set the height of the right column
//                           child: Center(
//                             child: Text(
//                               'Sign Up ',
//                               style: TextStyle(color: HexColor('#4D8D6E')),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxloginheight,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: ScreenUtil.fifthscreenwidth,
//                     height: ScreenUtil.containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(6.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                           8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(children: [
//                       SvgPicture.asset(
//                         'assets/icons/firstsecondicon.svg',
//                         // Replace with the path to your SVG file
//                         width: 33.0,
//                         // Replace with the desired width of the icon
//                         height:
//                         33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                       ),
//                       // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                       Container(
//                         child: Expanded(
//                           child: TextFormField(
//                             controller: _firstnameController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Enter first name';
//                               }
//                               return null; // Return null if the input is valid
//                             },
//                             keyboardType: TextInputType.text,
//                             decoration: InputDecoration(
//                               hintText: 'First Name',
//                               // Replace with the desired hint text
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ),
//                   SizedBox(width: ScreenUtil.sizeboxheight4),
//                   Container(
//                     width: ScreenUtil.fifthscreenwidth,
//                     height: ScreenUtil.containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(6.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                           8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(children: [
//                       SvgPicture.asset(
//                         'assets/icons/firstsecondicon.svg',
//                         // Replace with the path to your SVG file
//                         width: 33.0,
//                         // Replace with the desired width of the icon
//                         height:
//                         33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                       ),
//                       // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                       Container(
//                         child: Expanded(
//                           child: TextFormField(
//                             controller: _lastnameController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Enter Last Name';
//                               }
//                               return null; // Return null if the input is valid
//                             },
//                             // Apply the custom formatter
//
//                             keyboardType: TextInputType.text,
//
//                             decoration: InputDecoration(
//                               hintText: 'Last Name',
//                               // Replace with the desired hint text
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ],
//               ),
//
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Center(
//                 child: Container(
//                   width: ScreenUtil.halfScreenwidth2,
//                   height: ScreenUtil.containerheight,
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     // Background color of the container
//                     borderRadius: BorderRadius.circular(12.0),
//                     // Border radius of the container
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         // Shadow color
//                         offset: Offset(0, 4.0),
//                         // Set the offset (x, y) to control the shadow position
//                         blurRadius:
//                         8.0, // Set the blur radius to control the spread of the shadow
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(
//                         'assets/icons/email.svg',
//                         // Replace with the path to your SVG file
//                         width: 33.0,
//                         // Replace with the desired width of the icon
//                         height:
//                         33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                       ),
//                       SizedBox(width: 20.0),
//                       Expanded(
//                         child: TextFormField(
//                           keyboardType: TextInputType.emailAddress,
//                           controller: _emailController,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please enter an email address';
//                             } else if (!isValidEmail(value)) {
//                               return 'Invalid email address';
//                             }
//                             return null;
//                           },
//                           onSaved: (value) {
//                             _email = value!;
//                           },
//                           onChanged: _onChanged,
//                           decoration: InputDecoration(
//                             hintText: 'E-mail',
//                             // Replace with the desired hint text
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               GestureDetector(
//                 onTap: (){                _showAddressPicker(context);
//                 },
//
//                 child: Container(
//                   width: ScreenUtil.halfScreenwidth2,
//                   height: ScreenUtil.containerheight,
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     // Background color of the container
//                     borderRadius: BorderRadius.circular(6.0),
//                     // Border radius of the container
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         // Shadow color
//                         offset: Offset(0, 4.0),
//                         // Set the offset (x, y) to control the shadow position
//                         blurRadius:
//                         8.0, // Set the blur radius to control the spread of the shadow
//                       ),
//                     ],
//                   ),
//                   child: Row(children: [
//                     SvgPicture.asset(
//                       'assets/icons/addressicon.svg',
//                       // Replace with the path to your SVG file
//                       width: 33.0,
//                       // Replace with the desired width of the icon
//                       height:
//                       33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                     ),
//                     // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                     SizedBox(width: 20.0),
//                     Text(' Address',style: TextStyle(color: HexColor('#707070')),),
//                     Spacer(),
//                     if (_isFormFilled) Icon(Icons.check, color: Colors.green),
//
//                   ]),
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Column(
//                 children: [
//                   Container(
//                     width: ScreenUtil.halfScreenwidth2,
//                     height: ScreenUtil.containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(6.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                           8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset(
//                           'assets/icons/language.svg',
//                           // Replace with the path to your SVG file
//                           width: 33.0,
//                           // Replace with the desired width of the icon
//                           height:
//                           33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                         ),
//                         SizedBox(width: 16),
//
//                         Expanded(
//                           child: Text(
//                             'Language Spoken',
//                             style: TextStyle(
//                               color: HexColor('#707070'),
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                         // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                         SizedBox(width: 16),
//                         IconButton(
//                           icon: Icon(Icons.keyboard_arrow_down),
//                           onPressed: () {
//                             setState(() {
//                               isListExpanded = !isListExpanded;
//                             });
//                             if (isListExpanded && !hasSelectedItems()) {
//                               // Show an error message or perform any desired action here
//                               // For example, you can use a SnackBar to display the message
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content:
//                                   Text('Please select at least one language.'),
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (isListExpanded) buildExpandableList(),
//                   if (hasSelectedItems()) buildSelectedItemsContainer(),
//                 ],
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Container(
//                 width: ScreenUtil.halfScreenwidth2,
//                 height: ScreenUtil.containerheight,
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   // Background color of the container
//                   borderRadius: BorderRadius.circular(6.0),
//                   // Border radius of the container
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       // Shadow color
//                       offset: Offset(0, 4.0),
//                       // Set the offset (x, y) to control the shadow position
//                       blurRadius:
//                       8.0, // Set the blur radius to control the spread of the shadow
//                     ),
//                   ],
//                 ),
//                 child: Row(children: [
//                   SvgPicture.asset(
//                     'assets/icons/zipcode.svg',
//                     // Replace with the path to your SVG file
//                     width: 33.0,
//                     // Replace with the desired width of the icon
//                     height:
//                     33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                   ),
//                   // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                   SizedBox(width: 20.0),
//
//                   Container(
//                     child: Expanded(
//                       child: TextFormField(
//                         controller: _zipcodeController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Zip Code';
//                           }
//                           return null; // Return null if the input is valid
//                         },
//                         // Apply the custom formatter
//
//                         keyboardType: TextInputType.number,
//
//                         decoration: InputDecoration(
//                           hintText: 'Preferred ZIP Code of Work',
//                           // Replace with the desired hint text
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Container(
//                 width: ScreenUtil.halfScreenwidth2,
//                 height: ScreenUtil.containerheight,
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   // Background color of the container
//                   borderRadius: BorderRadius.circular(6.0),
//                   // Border radius of the container
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       // Shadow color
//                       offset: Offset(0, 4.0),
//                       // Set the offset (x, y) to control the shadow position
//                       blurRadius:
//                       8.0, // Set the blur radius to control the spread of the shadow
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     SvgPicture.asset(
//                       'assets/icons/phonenumber.svg',
//                       // Replace with the path to your SVG file
//                       width: 33.0,
//                       // Replace with the desired width of the icon
//                       height:
//                       33.0, // Replace with the desired height of the icon                      // Replace with the path to your SVG file
//                     ),
//                     SizedBox(width: 20.0),
//
//                     Expanded(
//                       flex: 3,
//                       child: TextFormField(
//                         controller: _phoneNumberController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           hintText: 'Phone Number',
//
//                           border: InputBorder.none,
//                         ),
//                         validator: (value) {
//                           if (_phoneNumberController.text.length != 10) {
//                             return 'Enter your phone number with only 10 numbers';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Center(
//                   child: Container(
//                     width: ScreenUtil.halfScreenwidth2,
//                     height: ScreenUtil.containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(6.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                           8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(children: [
//                       SvgPicture.asset(
//                         'assets/icons/password.svg',
//                         // Replace with the path to your SVG file
//                         width: 33.0,
//                         // Replace with the desired width of the icon
//                         height: 33.0, // Replace with the desired height of the icon
//                       ),
//                       // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                       SizedBox(width: 20.0),
//                       Container(
//                         child: Expanded(
//                           child: TextFormField(
//                             inputFormatters: [EnglishTextInputFormatter()],
//                             // Apply the custom formatter
//
//                             keyboardType: TextInputType.text,
//                             controller: _passwordController,
//                             obscureText: _isObscured,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a password';
//                               } else if (!_isValidPassword(value)) {
//                                 return 'required At least 12 characters long,uppercase & lowercase letters,'
//                                     ' numbers, and symbols.';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) {
//                               _password = value!;
//                             },onChanged:(value) {
//                             checkPassword(value);
//                           },
//                             decoration: InputDecoration(
//                               suffixIcon: GestureDetector(
//                                 onTap: _togglePasswordVisibility,
//                                 // Call the _togglePasswordVisibility function here
//                                 child: Icon(
//                                   _isObscured
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                               ),
//                               hintText: 'Password',
//                               // Replace with the desired hint text
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   )),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Center(
//                 child: Container(
//                   width: ScreenUtil.halfScreenwidth2,
//                   height: ScreenUtil.containerheight,
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     // Background color of the container
//                     borderRadius: BorderRadius.circular(6.0),
//                     // Border radius of the container
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         // Shadow color
//                         offset: Offset(0, 4.0),
//                         // Set the offset (x, y) to control the shadow position
//                         blurRadius:
//                         8.0, // Set the blur radius to control the spread of the shadow
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(
//                         'assets/icons/password.svg',
//                         // Replace with the path to your SVG file
//                         width: 33.0,
//                         // Replace with the desired width of the icon
//                         height:
//                         33.0, // Replace with the desired height of the icon
//                       ),
//                       // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                       SizedBox(width: 20.0),
//                       Container(
//                         child: Expanded(
//                           child: TextFormField(
//                             inputFormatters: [EnglishTextInputFormatter()],
//                             // Apply the custom formatter
//
//                             keyboardType: TextInputType.text,
//                             controller: _confirmPasswordController,
//                             obscureText: _isObscured,
//                             onChanged: (value) {
//                               setState(() {
//                                 _passwordsMatch = _validatePasswords();
//                               });
//                             },
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please confirm your password';
//                               } else if (value != _passwordController.text) {
//                                 return 'Passwords do not match';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) {
//                               _password = value!;
//                             },
//                             decoration: InputDecoration(
//                               errorText: _passwordsMatch
//                                   ? null
//                                   : 'Passwords do not match',
//
//                               suffixIcon: GestureDetector(
//                                 onTap: _togglePasswordVisibility,
//                                 // Call the _togglePasswordVisibility function here
//                                 child: Icon(
//                                   color: HexColor('#509372'),
//                                   _isObscured
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                               ),
//                               hintText: 'Confirm Password',
//                               // Replace with the desired hint text
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     hasUppercase ? Icons.check_circle : Icons.cancel,
//                     color: hasUppercase ? Colors.green : Colors.red,
//                   ),
//                   SizedBox(width: 4),
//                   Text(
//                     'Uppercase letter',
//                     style: TextStyle(
//                       color: hasUppercase ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     hasLowercase ? Icons.check_circle : Icons.cancel,
//                     color: hasLowercase ? Colors.green : Colors.red,
//                   ),
//                   SizedBox(width: 4),
//                   Text(
//                     'Lowercase letter',
//                     style: TextStyle(
//                       color: hasLowercase ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     hasNumber ? Icons.check_circle : Icons.cancel,
//                     color: hasNumber ? Colors.green : Colors.red,
//                   ),
//                   SizedBox(width: 4),
//                   Text(
//                     'Number',
//                     style: TextStyle(
//                       color: hasNumber ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//               Center(
//                 child: Container(
//                   width: ScreenUtil.buttonscreenwidth,
//                   height: 45,
//                   margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         // The form is valid, do something with the input
//                         String inputValue = _textController.text;
//                         print('Input value: $inputValue');
//                         Get.off(layout(),
//                             transition: Transition.circularReveal);
//                         print('Login successful');
//                       } else {
//                         // Show custom validation message inside the container
//                         setState(() {
//                           Fluttertoast.showToast(
//                               msg: "Error",
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.SNACKBAR,
//                               timeInSecForIosWeb: 1,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                               fontSize: 16.0);
//                         });
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: HexColor('#4D8D6E'),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                         // Adjust the value to change the corner radius
//                         side: BorderSide(
//                             width:
//                             buttonscreenwidth // Adjust the value to change the width of the narrow edge
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       'Sign Up',
//                       style: TextStyle(fontSize: 16.0, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: ScreenUtil.sizeboxheight,
//               ),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildExpandableList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         return CheckboxListTile(
//           title: Text(items[index]),
//           value: checkedItems[index],
//           onChanged: (value) {
//             setState(() {
//               checkedItems[index] = value ?? false;
//             });
//           },
//           controlAffinity: ListTileControlAffinity.leading,
//           activeColor: HexColor('#509372'),
//         );
//       },
//     );
//   }
//
//   bool hasSelectedItems() {
//     return checkedItems.contains(true);
//   }
//
//   Widget buildSelectedItemsContainer() {
//     List<String> selectedItems = [];
//     for (int i = 0; i < items.length; i++) {
//       if (checkedItems[i]) {
//         selectedItems.add(items[i]);
//       }
//     }
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//         width: ScreenUtil.halfScreenwidth2,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           // Background color of the container
//           borderRadius: BorderRadius.circular(1.0),
//           // Border radius of the container
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               // Shadow color
//               offset: Offset(0, 4.0),
//               // Set the offset (x, y) to control the shadow position
//               blurRadius:
//               8.0, // Set the blur radius to control the spread of the shadow
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Selected Language:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: selectedItems.map((item) {
//                 return Chip(
//                   label: Text(item),
//                   deleteIconColor: Colors.white,
//                   onDeleted: () {
//                     setState(() {
//                       int index = items.indexOf(item);
//                       checkedItems[index] = false;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
// class AddressPickerForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   double buttonscreenwidth = ScreenUtil.screenWidth! * 0.75;
//
//   final TextEditingController addressLineController;
//   final TextEditingController cityController;
//   final TextEditingController stateController;
//   final VoidCallback onFormFilled; // New callback
//
//   AddressPickerForm({
//     required this.formKey,
//     required this.addressLineController,
//     required this.cityController,
//     required this.stateController,
//     required this.onFormFilled
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Address Line'),
//             controller: addressLineController,
//
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter your address line';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'City'),
//             controller: cityController,
//
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter your city';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'State/Region'),
//             controller: stateController,
//
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter your state/region';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: HexColor('#4D8D6E'),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30.0),
//                 // Adjust the value to change the corner radius
//                 side: BorderSide(
//                     width:
//                     buttonscreenwidth // Adjust the value to change the width of the narrow edge
//                 ),
//               ),
//             ),
//             onPressed: () {
//               if (formKey.currentState!.validate()) {
//                 // Process the form data and close the bottom sheet
//                 Navigator.pop(context);
//                 onFormFilled();
//               }
//
//             },
//             child: Text('Save'),
//           ),
//
//         ],
//       ),
//     );
//   }
// }