import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:workdone/view/screens/Bid%20Details/Bid%20details%20Client.dart';
import 'package:workdone/view/screens/Bid%20Details/Bid%20details%20Worker.dart';
import 'package:workdone/view/screens/Profile%20(client-worker)/profilescreenClient.dart';
import 'package:workdone/view/screens/Profile%20(client-worker)/profilescreenworker.dart';

class NotificationsPageclient extends StatefulWidget {
  @override
  _NotificationsPageclientState createState() => _NotificationsPageclientState();
}

class _NotificationsPageclientState extends State<NotificationsPageclient> {
  List<Notification> notifications = [];
  List<Notification> filteredNotifications = [];

  int userId =0;
  String? usertype;
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
              usertype= 'client';
            } else if (userType == 'worker') {
              usertype= 'worker';

            } else {
              print('Error: Unknown user type.');
              throw Exception('Failed to load profile information');
            }
          } else {
            print('Error: Response data does not contain user_type.');
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
  Future<void> _getUserid() async {
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
  Future<List<Notification>> fetchNotifications(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot documentSnapshot = await firestore.collection('notify').doc(userId).get();
    // Ensure the data is not null and cast it to Map<String, dynamic>
    final Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
    // Safely access the 'notifications' field, providing an empty list as a default
    final List<dynamic> notificationsData = data?['notifications'] ?? [];
    print('notifications ${notificationsData}');
    final List<Notification> notificationsList = notificationsData.map((item) => Notification.fromMap(item)).toList();
    return notificationsList;
  }
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getUserid(),
      _getusertype(),

    ]);
    // Now that userId and usertype are set, fetch notifications
    List<Notification> fetchedNotifications = await fetchNotifications('${userId.toString()}');
    // Reverse the list of notifications
    fetchedNotifications = fetchedNotifications.reversed.toList();
    setState(() {
      notifications = fetchedNotifications;
    });
  }
  void _filterNotifications(String query) {
    setState(() {
      filteredNotifications = notifications
          .where((notification) =>
      notification.title.toLowerCase().contains(query.toLowerCase()) ||
          notification.body.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar:

      AppBar(
        elevation: 0, // Set elevation to 0 to remove default shadow
        toolbarHeight: 70,
        backgroundColor: HexColor('4D8D6E'),
        title: Text(
          'Notifications',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.white, size: 27),
          onPressed: () {
Get.back()     ;     },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Your shadow color
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
        ),
      )
,
        body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 10),
            child: SearchBar(
              onChanged: _filterNotifications,

            ),
          ),
          Expanded(
            child: ListView.builder(
          itemCount: filteredNotifications.isNotEmpty
          ? filteredNotifications.length
              : notifications.length,
          itemBuilder: (context, index) {
          final notification = filteredNotifications.isNotEmpty
          ? filteredNotifications[index]
              : notifications[index];



          return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 12),
                  child: Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),

                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Icon(
                            shadows:  [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, 3),
                        ),
                        ],
                            notification.title.toLowerCase().contains('password')
                                ? Icons.lock:
                            notification.title.toLowerCase().contains('profile')?
                            Icons.account_circle_rounded:
                            notification.title.toLowerCase().contains('address')?
                            Icons.location_on:
                            notification.title.toLowerCase().contains('bid')?
                            Icons.monetization_on:
                            notification.title.toLowerCase().contains('support')?
                            Icons.help:
                            notification.title.toLowerCase().contains('schedule')?
                            Icons.watch_later_rounded:
                            notification.title.toLowerCase().contains('meeting')?
                            Icons.people:
                            notification.title.toLowerCase().contains('review')?
                            Icons.star:
                            notification.title.toLowerCase().contains('end')?
                            Icons.check_circle:
                            notification.title.toLowerCase().contains('posted')?
                            Icons.publish



                                : Icons.notifications_active,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      subtitle: Text(
                        notification.body,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.0,
                        ),
                      ),
                      trailing: Text(
                        notification.time,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      dense: false,
                      enabled: true,
                      selected: false,
                      onTap: () {
                        notification.type=='projectworker' &&  usertype=='worker'?
                            Get.to(bidDetailsWorker(projectId: notification.id)):
                        notification.type=='projectclient'&&  usertype=='client'?
                        Get.to(bidDetailsClient(projectId: notification.id)):
                        notification.type=='projectclient'&&  usertype=='client'?
                        Get.to(bidDetailsClient(projectId: notification.id)):
                        notification.type=='postproject'&&  usertype=='client'?
                        Get.to(bidDetailsClient(projectId: notification.id)):
                        notification.title.toLowerCase().contains('bid')
                        &&  usertype=='client'?
                        Get.to(bidDetailsClient(projectId:  notification.id)):
                            usertype=='worker'?
                            Get.to(ProfileScreenworker()):
                            usertype=='client'?
                            Get.to(ProfileScreenClient2()):
                            Get.to(ProfileScreenClient2());



                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }}
class Notification {
  final String body;
  final String time;
  final String title;
  final int id;
  final String? type;

  Notification({
    required this.body,
    required this.time,
    required this.title,
    required this.id,
    this.type,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      body: map['body'] ?? '',
      time: map['time'] ?? '',
      title: map['title'] ?? '',
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      type: map['type'] as String?,
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const SearchBar({required this.onChanged, Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchText = value;
            widget.onChanged(value);
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Search',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          suffixIcon: searchText.isNotEmpty
              ? IconButton(
            onPressed: () {
              setState(() {
                searchText ='';
                widget.onChanged('');
              });
            },
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
            ),
          )
              : null,
        ),
      ),
    );
  }
}