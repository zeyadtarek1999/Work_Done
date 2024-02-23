import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import '../InboxwithChat/inbox.dart';
import '../InboxwithChat/inboxClient.dart';
import '../check out client/payment.dart';
import '../homescreen/home screenClient.dart';
import '../homescreen/homeWorker.dart';
import '../post a project/project post.dart';
import 'moreclient.dart';
import 'projects CLient.dart';

class layoutclient extends StatefulWidget {
  const layoutclient({super.key});

  @override
  State<layoutclient> createState() => _layoutclientState();
}

class _layoutclientState extends State<layoutclient> {
  void navigateToScreen(BuildContext context, String screenName) {
    // Navigation logic here
  }

  int _currentIndex = 0;
  List<Widget> _screens = [
    Homeclient(),
    projectsClient(),
    inboxtest(),
    Moreclient(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: Container(
        width: 55.0,
        height: 55.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [HexColor('#4D8D6E'), HexColor('#4D8D6E')],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: HexColor('#4D8D6E').withOpacity(0.4),
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(projectPost());
            // FAB onPressed action
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0, // No shadow on the FloatingActionButton
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        elevation: 5,
        height: 75.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Add padding to the left and right of the Row widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: buildBottomNavItem(0, Icons.home, 'Home'),
            ),
            buildBottomNavItem(1, Icons.check_circle, 'My Projects'),
            buildBottomNavItem(2, Icons.inbox, 'Inbox'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: buildBottomNavItem(3, Icons.more_vert, 'More'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem(int index, IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(
                icon,
                color: _currentIndex == index ? HexColor('#4D8D6E') : Colors.grey[700],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: _currentIndex == index ? HexColor('#4D8D6E') : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}