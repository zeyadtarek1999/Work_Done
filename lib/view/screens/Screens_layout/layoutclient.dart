import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:workdone/view/screens/Screens_layout/projects%20CLient.dart';
import '../homescreen/home screenClient.dart';
import '../InboxwithChat/inboxClient.dart';
import '../post a project/project post.dart';
import 'moreclient.dart';


class layoutclient extends StatefulWidget {
  const layoutclient({super.key});

  @override
  State<layoutclient> createState() => _layoutclientState();
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
    icon: Icon(Icons.add,color: Colors.white,),
    title: ('Post'),
activeColorSecondary: HexColor('#4D8D6E'),
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
class _layoutclientState extends State<layoutclient> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PersistentTabController _tabController;
  List<Widget> _screens = [
    Homeclient(),
    projectsClient(),
    projectPost(),
    InboxClient(),
    Moreclient(),

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

      navBarHeight: 60,
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
      navBarStyle: NavBarStyle.style15,
    );
  }
}