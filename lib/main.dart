import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workmanager/workmanager.dart';
import 'model/mediaquery.dart';
import 'view/screens/Screens_layout/layoutWorker.dart';
import 'view/screens/Screens_layout/moreworker.dart';
import 'view/screens/splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
int user =14;

Future<void> showLocalNotification(String message) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'background_channel',
      title: 'New Notification',
      body: message,
    ),
  );
}

Future<void> fetchApiData() async {
  try {
    final response = await http.get(Uri.parse('https://www.workdonecorp.com/api/get_new_notification'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];

          // Process the data here
          // ...

          // Optionally, show a notification to indicate that the data has been fetched
          if (data.isNotEmpty) {
          final dynamic notification = data[0];
          final int userId = notification['user_id'];
          final String message = notification['msg'];

          if (user == userId) {
            await showLocalNotification(message);
          }
        }

        print('Data fetched successfully');
      } else {
        print('Error: Failed to fetch data. Status code: ${jsonResponse['status']}');
      }
    } else {
      print('Error: Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: Failed to fetch data. Error: $e');
  }
}
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Fetch API data here
    await fetchApiData();
    return Future.value(true);
  });
}
Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);



  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  Workmanager().registerPeriodicTask(
    "1", // unique task name
    "backgroundFetchTask", // task name
    frequency: Duration(minutes: 15), // set the frequency
  );



  runApp(MyApp());
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelGroupKey: 'basick group channel',
          channelKey: 'postProject',
          channelName: 'basic notification',
          channelDescription: 'hello test only test'),
      NotificationChannel(
          channelGroupKey: 'basick group channel',
          channelKey: 'support',
          channelName: 'basic notification',
          channelDescription: 'hello test only test'),
      NotificationChannel(
        channelKey: 'background_channel',
        channelName: 'Background Notifications',
        channelDescription: 'Use this channel for background notifications',
        importance: NotificationImportance.Min,
        defaultPrivacy: NotificationPrivacy.Private,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: 'basic', channelGroupName: 'basic group'),
    ],
  );

  bool isAllowedtosendNotification =
  await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedtosendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

}
class NotificationModel {
  int id;
  String channelKey;
  String title;
  String body;
  Map<String, dynamic> payload;

  NotificationModel({
    required this.id,
    required this.channelKey,
    required this.title,
    required this.body,
    required this.payload,
  });
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
        scaffoldBackgroundColor: HexColor('#F5F5F5'),
        primaryTextTheme: TextTheme(
          headlineMedium: TextStyle(color: HexColor('#292929')),
        ),
      ),


      initialRoute: '/CustomSplashScreen',
      // You can define your initial route here

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
