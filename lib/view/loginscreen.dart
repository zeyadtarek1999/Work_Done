// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:untitled/view/Forgetpassword.dart';
// import 'package:untitled/view/screens/homescreen/homeWorker.dart';
// import 'package:untitled/view/chooseWorkerorClient.dart';
// import 'package:untitled/view/screens/Screens_layout/layoutWorker.dart';
//
// import '../model/textinputformatter.dart';
//
// class Loginscreen extends StatefulWidget {
//   const Loginscreen({super.key});
//
//   @override
//   State<Loginscreen> createState() => _LoginscreenState();
// }
//
// class _LoginscreenState extends State<Loginscreen> {
//   final formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isObscured = true;
//   String _email = '';
//   String _password = '';
//   String _validationMessage = '';
//   bool _isEmailValid = true;
//
//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       _isObscured = !_isObscured;
//     });
//   }
//
//   String? _validateEmail(String value) {
//     if (value.isEmpty) {
//       return 'Please enter your email';
//     }
//
//     // Add email format validation if needed
//     return null;
//   }
//
//   void _onChanged(String value) {
//     setState(() {
//       _isEmailValid = formKey.currentState!.validate();
//     });
//   }
//
//   String? _validatePassword(String value) {
//     if (value.isEmpty) {
//       return 'Please enter your password';
//     }
//
//     // Add password length validation if needed
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fourthscreenwidth = screenWidth * 0.40;
//     double sizeboxwidth = screenWidth * 0.1;
//     double halfScreenwidth = screenWidth * 0.83;
//     double buttonscreenwidth = screenWidth * 0.75;
//     double paddingoftext = screenWidth * 0.1;
//     double paddingoflogintext = screenWidth * 0.09;
//
//     double screenHeight = MediaQuery.of(context).size.height;
//     double greenbackgroundheight = screenHeight * 0.22;
//     double backgroundheight = screenHeight * 0.22;
//     double logoheight = screenHeight * 0.22;
//     double containeroftextheight = screenHeight * 0.09;
//     double sizeboxheight = screenHeight * 0.03;
//     double sizeboxloginheight = screenHeight * 0.06;
//     double containerheight = screenHeight * 0.1;
//
//     return Scaffold(
//       body: Form(
//         key: formKey,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//                     Container(
//                         height: greenbackgroundheight,
//                         width: screenWidth,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage(
//                                 'assets/images/greenbackground.png',
//                               ),
//                               fit: BoxFit.fitWidth),
//                         )),
//                     Container(
//                         height: backgroundheight,
//                         width: screenWidth,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage(
//                                 'assets/images/firstscreen.png',
//                               ),
//                               fit: BoxFit.fitWidth),
//                         )),
//                     Center(
//                       child: Container(
//                           height: logoheight,
//                           width: fourthscreenwidth,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: AssetImage(
//                                   'assets/images/test.png',
//                                 ),
//                                 fit: BoxFit.cover),
//                           )),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                               Icons.arrow_back_ios,
//                             ),
//                             // Replace with your desired icon
//                             iconSize: 32.0,
//                             // Adjust the size of the icon
//                             color: Colors.white,
//                             // Set the color of the icon
//                             onPressed: () {
//                               Get.back();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   width: screenWidth,
//                   height: containeroftextheight,
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(
//                         color: HexColor('#707070'),
//                         // Shadow color
//                         offset: Offset(0, 2.0),
//                         // Set the offset (x, y) to control the shadow position
//                         blurRadius: 7.0,
//                         // Set the blur radius to control the spread of the shadow
//                         spreadRadius:
//                             -2.0, // Set the spread radius to control the size of the shadow
//                       ),
//                     ],
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 100.0, // Set the height of the left column
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               border: Border(
//                                   bottom: BorderSide(
//                                 color: HexColor('#4D8D6E'),
//                                 width: 3,
//                               )),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Login ',
//                                 style: TextStyle(color: HexColor('#4D8D6E')),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             height: 100.0, // Set the height of the right column
//                             child: Center(
//                               child: TextButton(
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: HexColor('#929191'),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(8.0)),
//                                   ),
//                                   // Border radius of the button
//                                   // You can add more customization options here)),
//                                   onPressed: () {
//                                     Get.to(Chooseworkerorclient(),
//                                         transition: Transition.rightToLeft);
//                                   },
//                                   child: Text(
//                                     'Sign Up ',
//                                     style: TextStyle(
//                                         color: HexColor('#4D8D6E')
//                                             .withOpacity(0.6)),
//                                   )),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: sizeboxheight,
//                 ),
//                 Padding(
//                   padding: EdgeInsetsDirectional.symmetric(
//                       horizontal: paddingoflogintext),
//                   child: Container(
//                     child: Row(
//                       children: [
//                         Text(
//                           'Login in your account',
//                           style: TextStyle(fontSize: 26),
//                         ),
//                         SizedBox(
//                           width: sizeboxwidth,
//                         ),
//                         Image.asset(
//                           'assets/images/greenboxicon.png',
//                           fit: BoxFit.cover,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: sizeboxloginheight,
//                 ),
//                 Center(
//                   child: Container(
//                     width: halfScreenwidth,
//                     height: containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(12.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                               8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Opacity(
//                             opacity: 0.5,
//                             child: Icon(
//                               Icons.email_outlined,
//                               color: HexColor('#292929'),
//                             )), // Replace with the desired icon
//                         SizedBox(width: 20.0),
//                         Expanded(
//                           child: TextFormField(
//                             keyboardType: TextInputType.emailAddress,
//                             controller: _emailController,
//                             validator: (value) => _validateEmail(value!),
//                             onSaved: (value) {
//                               _email = value!;
//
//                               // Save email value if needed
//                             },
//                             onChanged: _onChanged,
//                             decoration: InputDecoration(
//                               hintText: 'E-mail',
//                               // Replace with the desired hint text
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 16.0), // Hide the validation message initially
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Center(
//                   child: Container(
//                     width: halfScreenwidth,
//                     height: containerheight,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       // Background color of the container
//                       borderRadius: BorderRadius.circular(12.0),
//                       // Border radius of the container
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           // Shadow color
//                           offset: Offset(0, 4.0),
//                           // Set the offset (x, y) to control the shadow position
//                           blurRadius:
//                               8.0, // Set the blur radius to control the spread of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset(
//                           'assets/icons/passwordicon.svg',
//                           // Replace with the path to your SVG file
//                           width: 23.0,
//                           // Replace with the desired width of the icon
//                           height:
//                               23.0, // Replace with the desired height of the icon
//                         ),
//                         // Icon(Icons.lock, color: HexColor('#292929')), // Replace with the desired icon
//                         SizedBox(width: 20.0),
//                         Container(
//                           child: Expanded(
//                             child: TextFormField(
//                               inputFormatters: [EnglishTextInputFormatter()],
//                               // Apply the custom formatter
//
//                               keyboardType: TextInputType.text,
//                               controller: _passwordController,
//                               obscureText: _isObscured,
//                               validator: (value) => _validatePassword(value!),
//                               onSaved: (value) {
//                                 _password = value!;
//                               },
//                               decoration: InputDecoration(
//                                 suffixIcon: GestureDetector(
//                                   onTap: _togglePasswordVisibility,
//                                   // Call the _togglePasswordVisibility function here
//                                   child: Icon(
//                                     _isObscured
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                   ),
//                                 ),
//                                 hintText: 'Password',
//                                 // Replace with the desired hint text
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: paddingoftext),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                           onPressed: () {Get.to(ForgotPasswordScreen());},
//                           child: Text(
//                             'Forget password ?',
//                             style: TextStyle(
//                                 color: HexColor('#707070'), fontSize: 13),
//                           )),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: sizeboxheight,
//                 ),
//                 Center(
//                   child: Container(
//                     width: buttonscreenwidth,
//                     height: 45,
//                     margin:
//                         EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (formKey.currentState!.validate()) {
//                           Get.off(layout(),
//                               transition: Transition.circularReveal);
//                           print('Login successful');
//                         } else {
//                           // Show custom validation message inside the container
//                           setState(() {
//                             Fluttertoast.showToast(
//                                 msg: "Error",
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.SNACKBAR,
//                                 timeInSecForIosWeb: 1,
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                                 fontSize: 16.0);
//                           });
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: HexColor('#4D8D6E'),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                           // Adjust the value to change the corner radius
//                           side: BorderSide(
//                             width:
//                                 buttonscreenwidth, // Adjust the value to change the width of the narrow edge
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         'Login',
//                         style: TextStyle(fontSize: 16.0, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
