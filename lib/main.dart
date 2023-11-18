import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'model/mediaquery.dart';
import 'view/screens/Screens_layout/layoutWorker.dart';
import 'view/screens/Screens_layout/moreworker.dart';
import 'view/screens/splashscreen.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void main() {
  runApp(MyApp());

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Work Done',

      theme: ThemeData(
          primaryColorLight: HexColor('#4D8D6E'),
          appBarTheme: AppBarTheme(color: HexColor('#4D8D6E')),
          buttonTheme: ButtonThemeData(buttonColor: HexColor('#4D8D6E')),
          scaffoldBackgroundColor: HexColor('#F5F5F5') ,
          primaryTextTheme: TextTheme(headlineMedium: TextStyle(color: HexColor('#292929')),
          ),

      ),


      initialBinding: BindingsBuilder(() {
      }),

      initialRoute: '/CustomSplashScreen', // You can define your initial route here

      getPages: [
        GetPage(name: '/layoutclient', page: () => layoutclient()),
        GetPage(name: '/Moreworker', page: () => Moreworker()),
        GetPage(name: '/CustomSplashScreen', page: () => CustomSplashScreen()),

        // GetPage(name: '/Homescreen', page: () => Homescreen()),
        // GetPage(name: '/From firstpage', page: () => Firstpage()),
      ],
    );
  }
}