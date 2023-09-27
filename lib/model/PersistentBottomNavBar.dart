// import 'package:flutter/material.dart';
// import 'package:untitled/view/screens/homescreen/homeWorker.dart';
// import 'package:untitled/view/profilescreenworker.dart';
// import 'package:untitled/view/settingscreen.dart';
//
// class PersistentBottomNavBar extends StatefulWidget {
//   @override
//   _PersistentBottomNavBarState createState() => _PersistentBottomNavBarState();
// }
//
// class _PersistentBottomNavBarState extends State<PersistentBottomNavBar> {
//   int _currentIndex = 0;
//   List<Widget> _screens = [
//     Homescreen(),
//     ProfileScreen(),
//     SettingsScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex] ?? Container(), // Ensure the list element is not null
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           if (index != _currentIndex) {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }
