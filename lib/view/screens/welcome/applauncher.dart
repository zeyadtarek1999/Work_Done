import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens_layout/layoutWorker.dart';
import '../Screens_layout/layoutclient.dart';
import '../login_screen_worker.dart';
import '../login_screen_client.dart'; // Import the login screen for clients
import 'welcome_screen.dart';
import 'package:http/http.dart' as http;

class AppLauncher extends StatefulWidget {
  @override
  _AppLauncherState createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  String connectionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getusertype();
    _getUserToken();
    checkConnectivity();

  }
  late String userToken;
  Future<void> _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      connectionStatus =
      connectivityResult == ConnectivityResult.none ? 'No Internet Connection' : 'Connected';
      if (connectionStatus == 'No Internet Connection'){
        print('No Internet Connection');
      }
    });
  }

  Future<void> _getusertype() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_user_type';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('user_type')) {
            String userType = responseData['user_type'];

            // Navigate based on user type
            if (userType == 'client') {
              Get.off(layoutclient());
            } else if (userType == 'worker') {
              Get.off(layoutworker());
            } else {
              print('Error: Unknown user type.');
              Get.off(WelcomeScreen());

            }
          } else {
            print('Error: Response data does not contain user_type.');
            Get.off(WelcomeScreen());
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      } else {
        // No token in SharedPreferences, navigate to WelcomeScreen
        Get.off(WelcomeScreen());
      }
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }
  Future<void> _handleRefresh() async {
    await checkConnectivity();
    if (connectionStatus == 'Connected') {
      _getusertype();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 90,

        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title:  SvgPicture.asset(
          'assets/images/Logo.svg',
          width: 100.0,
          height: 100.0,
        ),

      ),
      backgroundColor: Colors.white,
      body: Center(
        child: connectionStatus == 'No Internet Connection'
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/internetconnection.jpg'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _handleRefresh();
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF4D8D6E), // Set the background color
                onPrimary: Colors.white,   // Set the text color
              ),
              child: Text('Refresh'),
            ),

          ],
        )
            : RefreshIndicator(
          onRefresh: () async {
            await _handleRefresh();
          },
          child: CircularProgressIndicator(color: Colors.green),
        ),
      ),
    );
  }
}