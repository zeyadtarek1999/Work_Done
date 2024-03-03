import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/onBoard/OnboardClient.dart';
import 'package:workdone/view/screens/onBoard/onboardWorker.dart';
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';
import 'package:workdone/view/screens/welcome/welcome_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import 'model/mediaquery.dart';
import 'view/screens/Screens_layout/layoutWorker.dart';
import 'view/screens/Screens_layout/moreworker.dart';
import 'view/screens/splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_admin/firebase_admin.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

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

Future<void> fetchDataAndShowNotifications() async {
  final String apiUrl = 'https://www.workdonecorp.com/api/get_new_notification';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    print('Starting fetching');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Fetched');

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> data = jsonResponse['data'];
        print('Success fetching');
print (userId);
        // Loop through each notification in the data list
        for (final dynamic notification in data) {
          final int userIdR = notification['user_id'];
          final String message = notification['msg'];

          // Check if the user is the target user
          if (userId == userIdR) {
            await showLocalNotification(message);
          }
        }

        print('Notifications shown successfully');
      } else {
        print('Error: ${jsonResponse['msg']}');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Function to show a local notification


void callbackDispatcher() async {
  print('Fetching user profile...');

  try {
    print('Fetching user profile...');
    await _getUserProfile();
    print('User profile fetched successfully.');

    print('Fetching data and showing notifications...');
    await fetchDataAndShowNotifications();
    print('Notifications shown successfully.');

    print('Background task completed successfully');
  } catch (e) {
    print('Error in background task: $e');
  }
}
void startPeriodicSync() {
  const Duration fetchInterval = Duration(minutes: 15);
  Timer.periodic(fetchInterval, (Timer timer) {
    callbackDispatcher();
  });
}


Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  print("Handling background message: ${message.notification?.body}");

    // showLocalNotification('${message.notification?.body}');
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);

  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
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

      // Get the token
      String? token = await messaging.getToken();
      print("Firebase Messaging Token: $token");

      // Handle incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received foreground message: ${message.notification?.body}");
        // You can handle the message as needed
        // For example, show a local notification using Awesome Notifications
        // showLocalNotification(message.notification?.body ?? '');
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) {
        print("Opened app from notification: ${message.notification?.body}");
        // Handle navigation or additional logic when the app is opened from a notification
      });

      // Define the background message handler function here


      // Set the background message handler
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }
  await initFirebaseMessaging();
  const Duration fetchdata = Duration(seconds: 15);
  Timer.periodic(fetchdata, (Timer timer) {
    // Fetch data at each interval
    fetchDataAndShowNotifications();

  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basick group channel',
        channelKey: 'postProject',
        channelName: 'basic notification',
        channelDescription: 'hello test only test',
      ),
      NotificationChannel(
        channelGroupKey: 'basick group channel',
        channelKey: 'support',
        channelName: 'basic notification',
        channelDescription: 'hello test only test',
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




  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received foreground message: ${message.notification?.body}");
    // Extract data and perform actions
    String title = message.notification?.title ?? '';
    String body = message.notification?.body ?? '';
    showLocalNotification(body);
    // You can customize the handling based on your notification payload
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Opened app from notification: ${message.notification?.body}");
    // Extract data and perform actions when the app is opened from a notification
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Opened app from notification: ${message.notification?.body}");
    // Extract data and navigate to a specific screen
    Get.toNamed('/WelcomeScreen', arguments: message.data);
  });

  // Add the background message handler function
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Disable debug notifications
  );

  Workmanager().registerOneOffTask(
    "1", // unique task name
    "backgroundFetchTask",
  );

  await _getUserProfile();
  startPeriodicSync();

  bool isAllowedToSendNotification =
  await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  const Duration fetchInterval = Duration(minutes: 15);
  Timer.periodic(fetchInterval, (Timer timer) {
    callbackDispatcher();
  });

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return     WillPopScope(
      onWillPop: () async {
        return await Get.defaultDialog(
          title: 'Exit App?',
          content: Text('Do you want to close the app?'),
          confirm: TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Close'),
          ),
          cancel: TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Stay'),
          ),
        ) ?? false;
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
        // You can define your initial route here

        getPages: [
          GetPage(name: '/Moreworker', page: () => Moreworker()),
          GetPage(name: '/CustomSplashScreen', page: () => CustomSplashScreen()),
          GetPage(name: '/OnBoardingClient', page: () => OnBoardingClient()),
          GetPage(name: '/OnBoardingWorker', page: () => OnBoardingWorker()),
          GetPage(name: '/projectPost', page: () => projectPost()),
          GetPage(name: '/WelcomeScreen', page: () => WelcomeScreen()),

          // GetPage(name: '/Homescreen', page: () => Homescreen()),
          // GetPage(name: '/From firstpage', page: () => Firstpage()),
        ],
      ),
    );

  }
}
