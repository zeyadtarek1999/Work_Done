import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/screens/Screens_layout/projects%20CLient.dart';


import '../InboxwithChat/inboxWorker.dart';
import '../homescreen/homeWorker.dart';
import '../InboxwithChat/inboxClient.dart';
import 'moreclient.dart';
import 'moreworker.dart';
import 'projects Worker.dart';

class layoutworker extends StatefulWidget {
  const layoutworker({super.key});

  @override
  State<layoutworker> createState() => _layoutworkerState();
}

class _layoutworkerState extends State<layoutworker> {
  int _currentIndex = 0;
  List<Widget> _screens = [
    Homescreenworker(),
    projectsClient(),
    InboxClient(),
    Moreworker(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
      ),
    );
  }
}