// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:untitled/view/loginscreen.dart';
// import 'package:untitled/view/chooseWorkerorClient.dart';
//
// class Firstpage extends StatelessWidget {
//   const Firstpage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fourthscreenwidth=screenWidth * 0.50;
//     double buttonscreenwidth=screenWidth * 0.75;
//
//     double screenHeight = MediaQuery.of(context).size.height;
//     double halfScreenHeight = screenHeight * 0.60;
//     double fourthscreenheight=screenHeight * 0.50;
//     double threescreenheight=screenHeight * 0.62;
//     return Scaffold(
//         body: SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           // crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Stack(children: [
//
//                 Container(
//                   height:halfScreenHeight ,
//                     width: screenWidth,
//                     decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage('assets/images/greenbackground.png',),fit: BoxFit.fitWidth),
//                 )),
//               Container(
//                 height: fourthscreenheight,
//                 width:screenWidth ,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage('assets/images/firstscreen.png',),fit: BoxFit.fitWidth),
//                   )),
//               Center(
//                 child: Container(
//                     height: threescreenheight,
//                     width:fourthscreenwidth ,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image: AssetImage('assets/images/test.png',),fit: BoxFit.fitWidth),
//                     )),
//               ),
//
//
//             ]),
//             Column(
//               children: [
//                 Container(
//                   width: buttonscreenwidth,
//                   height: 45,
//                   margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 42.0),
//                   child: ElevatedButton(
//                     onPressed:() {
//                       Get.to(Chooseworkerorclient(),transition: Transition.zoom);
//
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: HexColor('#4D8D6E'),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the corner radius
//                         side: BorderSide(
//                           width: buttonscreenwidth, // Adjust the value to change the width of the narrow edge
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       'Sign up',
//                       style: TextStyle(fontSize: 16.0,color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: buttonscreenwidth,
//                   height: 45,
//                   margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
//                   child: ElevatedButton(
//                     onPressed:() {
//                       Get.to(() => Loginscreen());
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: HexColor('#FFFFFF'),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0), // Adjust the value to change the corner radius
//                         side: BorderSide(
//                           // width: buttonscreenwidth,
//                           color: HexColor('#4D8D6E')// Adjust the value to change the width of the narrow edge
//                         ),
//                       ),
//                     ),
//                     child: Text(
//                       'Login',
//                       style: TextStyle(fontSize: 16.0,color: HexColor('#4D8D6E')),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     ));
//   }
// }
