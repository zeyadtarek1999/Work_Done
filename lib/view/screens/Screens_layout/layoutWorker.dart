import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
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
final List<PersistentBottomNavBarItem> _navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ('Home'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.check_circle),
    title: ('My Projects'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.inbox),
    title: ('Inbox'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.more_vert),
    title: ('More'),
    activeColorPrimary: HexColor('#4D8D6E'),
    inactiveColorPrimary: Colors.grey[700],
  ),
];
class _layoutworkerState extends State<layoutworker> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PersistentTabController _tabController;
  List<Widget> _screens = [
    Homescreenworker(),
    projectsWorker(),
    InboxClient(),
    Moreworker(),
  ];

  @override
  void initState() {
    super.initState();
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

      navBarHeight: 70,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true,
      stateManagement: true,
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