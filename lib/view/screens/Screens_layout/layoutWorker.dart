import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Screens_layout/projects%20CLient.dart';
import 'package:http/http.dart' as http;
import '../InboxwithChat/inbox.dart';
import '../InboxwithChat/inboxWorker.dart';
import '../homescreen/homeWorker.dart';
import '../InboxwithChat/inboxClient.dart';
import 'moreclient.dart';
import 'moreworker.dart';
import 'projects Worker.dart';
import 'package:badges/badges.dart' as badges;

class layoutworker extends StatefulWidget {
  final bool showCase;

  const layoutworker({Key? key, required this.showCase}) : super(key: key);

  @override
  State<layoutworker> createState() => _layoutworkerState();
}

int? userId;

Future<void> _getUserid() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('user_token') ?? '';
    print(userToken);
    print('fetching user id');
    if (userToken.isNotEmpty) {
      // Replace the API endpoint with your actual endpoint
      final String apiUrl =
          'https://www.workdonecorp.com/api/get_user_id_by_token';
      print(userToken);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('done  user id');

        if (responseData.containsKey('user_id')) {
          userId = responseData['user_id'];

          // Now, userId contains the extracted user_id value
          print('User ID: $userId');

          // Optionally, save the user_id to SharedPreferences
          prefs.setInt('user_id', userId ?? 0);
        } else {
          print(
              'Error: Response data does not contain the expected structure.');
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

Future<void> _getUserProfile() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('user_token') ?? '';
    print(userToken);
    print('fetching user id');
    if (userToken.isNotEmpty) {
      // Replace the API endpoint with your actual endpoint
      final String apiUrl =
          'https://www.workdonecorp.com/api/get_user_id_by_token';
      print(userToken);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('done  user id');

        if (responseData.containsKey('user_id')) {
          userId = responseData['user_id'];

          // Now, userId contains the extracted user_id value
          print('User ID: $userId');

          // Optionally, save the user_id to SharedPreferences
          prefs.setInt('user_id', userId ?? 0);
        } else {
          print(
              'Error: Response data does not contain the expected structure.');
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

Stream<QuerySnapshot> getNewMessages(
  String userId,
) {
  return FirebaseFirestore.instance
      .collection('messages')
      .doc(userId)
      .collection('messages')
      .where('seen', isEqualTo: false)
      .where('recieverid', isEqualTo: userId)
      .snapshots();
}

final List<PersistentBottomNavBarItem> _navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(
      FontAwesomeIcons.home,
    ),
    title: ('Home'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: Icon(
      FontAwesomeIcons.briefcase,
    ),
    title: ('My Projects'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: FutureBuilder<void>(
      future: _getUserid(), // This is your future that fetches the userId
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
// The userId is now available, so we can build the StreamBuilder
          return StreamBuilder<QuerySnapshot>(
            stream: getNewMessages(
              '${userId}',
            ),
            // Assuming '2' is the user ID and '2_chat_room_3' is the chat room ID
            builder: (context, snapshot) {
              print('id btw ${userId}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Icon(FontAwesomeIcons.inbox, size: 26);
              } else if (snapshot.hasData) {
                // Count the number of new messages
                int newMessageCount = snapshot.data!.docs.length;

                // Display the count of new messages in a badge
                return newMessageCount > 0
                    ? badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                          badgeColor:
                              newMessageCount > 9 ? Colors.red : Colors.orange,
                          shape: badges.BadgeShape.circle,
                        ),
                        position: BadgePosition.topEnd(),
                        badgeContent: Text(
                            newMessageCount > 9 ? '+9' : '${newMessageCount}',
                            style: TextStyle(color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(FontAwesomeIcons.inbox, size: 26),
                        ),
                      )
                    : Icon(FontAwesomeIcons.inbox, size: 26);
              } else {
                return Icon(FontAwesomeIcons.adn, size: 26);
              }
            },
          );
        } else {
// While waiting for the userId, you can show a loading indicator or any other placeholder
          return Icon(FontAwesomeIcons.inbox, size: 26);
        }
      },
    ),
    title: ('Inbox'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: Icon(
      FontAwesomeIcons.bars,
    ),
    title: ('More'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
];

class _layoutworkerState extends State<layoutworker>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PersistentTabController _tabController;
  List<Widget> _screens = [];
  bool _showCase = false;

  void saveDeviceTokenToFirestore(String token) {
    FirebaseFirestore.instance.collection('users').doc(userId.toString()).set({
      'fcmToken': token,
    });
    print(' the token is done sended $token  and the user $userId');
  }

  @override
  void initState() {
    super.initState();

    _getUserProfile()
        .then((value) => FirebaseMessaging.instance.getToken().then((token) {
              // Save the device token to Firestore
              saveDeviceTokenToFirestore(token!);
              print('layout worker firebase token');
            }));
    ;
    _screens = [
      Homescreenworker(showCase: widget.showCase),
      projectsWorker(),
      inboxtest(),
      Moreworker(),
    ];
    _tabController = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _tabController,
      screens: _screens,
      items: _navBarItems,
      confineInSafeArea: true,

      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      // Default is true.
      resizeToAvoidBottomInset: false,
      stateManagement: true,
      navBarHeight: MediaQuery.of(context).size.height * 0.08,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 300),
      ),
      navBarStyle: NavBarStyle.style3,
    );
  }
}
