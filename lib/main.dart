import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/firebase_options.dart';
import 'package:workdone/view/screens/onBoard/OnboardClient.dart';
import 'package:workdone/view/screens/onBoard/onboardWorker.dart';
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';
import 'package:workdone/view/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'model/mediaquery.dart';
import 'view/screens/Screens_layout/moreworker.dart';
import 'view/screens/splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> showLocalNotification(String title , String message) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'background_channel',
      title: title,
      body: message,
    ),
  );
}
int? userId;
Future<void> _getUserProfile() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('user_token') ?? '';
    print(userToken);
print ('fetching user id');
    if (userToken.isNotEmpty) {
      // Replace the API endpoint with your actual endpoint
      final String apiUrl = 'https://www.workdonecorp.com/api/get_user_id_by_token';
      print(userToken);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print ('done  user id');

        if (responseData.containsKey('user_id')) {

          userId = responseData['user_id'];

          // Now, userId contains the extracted user_id value
          print('User ID: $userId');

          // Optionally, save the user_id to SharedPreferences
          prefs.setInt('user_id', userId ?? 0);
        } else {
          print('Error: Response data does not contain the expected structure.');
          throw Exception('Failed to load profile information');
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
        throw Exception('Failed to load profile information');
      }
    }
  } catch (error) {
    // Handle errors
    print('Error getting profile information: $error');
  }
}


// Function to show a local notification


// void callbackDispatcher() async {
//   print('Fetching user profile...');
//
//   try {
//     print('Fetching user profile...');
//     await _getUserProfile();
//     print('User profile fetched successfully.');
//
//     print('Fetching data and showing notifications...');
//     await fetchDataAndShowNotifications();
//     print('Notifications shown successfully.');
//
//     print('Background task completed successfully');
//   } catch (e) {
//     print('Error in background task: $e');
//   }
// }
// void startPeriodicSync() {
//   const Duration fetchInterval = Duration(minutes: 15);
//   Timer.periodic(fetchInterval, (Timer timer) {
//     callbackDispatcher();
//   });
// }

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // showLocalNotification(
  //     message.notification?.title  ??'', message.notification?.body ?? '');

  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}


final FirebaseMessaging messaging = FirebaseMessaging.instance;
void saveDeviceTokenToFirestore(String token) {
  FirebaseFirestore.instance.collection('users').doc(userId.toString()).set({
    'fcmToken': token,
  });
  print(' the token is done sended $token  and the user $userId');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);
  String? token = await messaging.getToken();
  print("Firebase Messaging Token: $token");
  // final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
print ('token :: ${apnsToken}' ) ; }
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  Future<void> initFirebaseMessaging() async {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission for iOS devices
      NotificationSettings settings = await messaging.requestPermission(

        alert: true,
        badge: true,
        sound: true,
      );

      print("Notification settings: $settings");



      // Handle incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received foreground message: ${message.notification?.body}");
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
          showLocalNotification(
              message.notification?.title  ??'', message.notification?.body ?? '');
          print('Got a message  in the foreground!');

        });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) {
        print("Opened app from notification again: ${message.notification?.body}");
        showLocalNotification(
            message.notification?.title  ??'', message.notification?.body ?? '');
        // Handle navigation or additional logic when the app is opened from a notification
      });

      // Define the background message handler function here


      // Set the background message handler
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }
  await initFirebaseMessaging();
  // Timer.periodic(fetchdata, (Timer timer) {
  //   // Fetch data at each interval
  //   fetchDataAndShowNotifications();
  //
  // });

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basick group channel',
        channelKey: 'postProject',
        channelName: 'basic notification',
        channelDescription: 'hello test only test',
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
      NotificationChannel(
        channelGroupKey: 'basick group channel',
        channelKey: 'support',
        channelName: 'basic notification',
        channelDescription: 'hello test only test',
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
      NotificationChannel(
        channelKey: 'background_channel',
        channelName: 'Background Notifications',
        channelDescription: 'Use this channel for background notifications',
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic',
        channelGroupName: 'basic group',

      ),
    ],
  );





  // Add the background message handler function
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: false, // Disable debug notifications
  // );
  //
  // Workmanager().registerOneOffTask(
  //   "1", // unique task name
  //   "backgroundFetchTask",
  // );

  await _getUserProfile();
  // FirebaseMessaging.instance.getToken().then((token) {
  //   // Save the device token to Firestore
  //   saveDeviceTokenToFirestore(token!);
  // });

  // startPeriodicSync();

  bool isAllowedToSendNotification =
  await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // const Duration fetchInterval = Duration(minutes: 15);
  // Timer.periodic(fetchInterval, (Timer timer) {
  //   callbackDispatcher();
  // });

  runApp(MyApp());
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
  const MyApp({Key? key}) : super(key: key);

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text('Exit App'),
          content: Text('Are you sure you want to leave the app?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return PopScope(
      canPop: true, // Indicates whether the current route can be popped
      onPopInvoked: (didPop) async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Exit App'),
              content: Text('Are you sure you want to leave the app?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        );
        if (shouldPop ?? false) {
          // Proceed with the back navigation
          didPop;
        }
      },
      child: GetMaterialApp(
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
        getPages: [
          GetPage(name: '/Moreworker', page: () => Moreworker()),
          GetPage(name: '/CustomSplashScreen', page: () => CustomSplashScreen()),
          GetPage(name: '/OnBoardingClient', page: () => OnBoardingClient()),
          GetPage(name: '/OnBoardingWorker', page: () => OnBoardingWorker()),
          GetPage(name: '/projectPost', page: () => projectPost()),
          GetPage(name: '/WelcomeScreen', page: () => WelcomeScreen()),
        ],
      ),
    );
  }
}
