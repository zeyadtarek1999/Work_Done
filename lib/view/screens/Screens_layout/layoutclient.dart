import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../payment.dart';
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
    // You can implement your navigation logic here
    // For example, using Navigator.push() to navigate to different screens
    // based on the screenName parameter.
  }
  int _currentIndex = 0;
  List<Widget> _screens = [
    Homeclient(),
    projectsClient(),
    CreditCardPage(),
    Moreclient(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: Container(
        width: 56.0,
        height: 56.0,
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
        notchMargin: 8.0,
        color: Colors.white,
        child: Container(
          height: 56.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildBottomNavItem(0, Icons.home, 'Home'),
              buildBottomNavItem(1, Icons.check_circle, 'Projects'),
              SizedBox(), // Empty space in the center
              buildBottomNavItem(2, Icons.inbox, 'Inbox'),
              buildBottomNavItem(3, Icons.more_vert, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavItem(int index, IconData icon, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? HexColor('#4D8D6E') : Colors.grey[700],
          ),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index ? HexColor('#4D8D6E') : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}