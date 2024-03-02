import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../InboxwithChat/inbox.dart';
import '../InboxwithChat/inboxClient.dart';
import '../check out client/payment.dart';
import '../homescreen/home screenClient.dart';
import '../homescreen/homeWorker.dart';
import '../post a project/project post.dart';
import 'moreclient.dart';
import 'projects CLient.dart';

class layoutclient  extends StatefulWidget {

  final bool showCase;

  const layoutclient({Key? key, required this.showCase}) : super(key: key);

  @override
  _layoutclientState  createState() => _layoutclientState ();
}

class _layoutclientState  extends State<layoutclient > {
  int _currentIndex = 0;
  List<Widget> _screens = [

  ];

  List<PersistentBottomNavBarItem> _navBarItems = [
    PersistentBottomNavBarItem(
      icon: FaIcon(FontAwesomeIcons.home),
      title: ("Home"),
      activeColorPrimary: HexColor('#4D8D6E'),
      inactiveColorPrimary: Colors.grey[700]!,
    ),
    PersistentBottomNavBarItem(
      icon: FaIcon(FontAwesomeIcons.briefcase),
      title: ("Projects"),
      activeColorPrimary: HexColor('#4D8D6E'),
      inactiveColorPrimary: Colors.grey[700]!,
    ),
    PersistentBottomNavBarItem(
      icon: Center(
        child: FaIcon(

          FontAwesomeIcons.add,
          color: Colors.white,
        ),
      ),
      title: ("Post"),
      activeColorPrimary: HexColor('#4D8D6E'),
      inactiveColorPrimary: Colors.grey[700]!,
      activeColorSecondary: HexColor('#4D8D6E'), // Icon color when active
      inactiveColorSecondary: Colors.grey[700]!, // Icon color when inactive
      textStyle: TextStyle(fontSize: 14), // Adjust the title font size
    )
,
    PersistentBottomNavBarItem(
      icon: FaIcon(FontAwesomeIcons.inbox),

      title: ("Inbox"),
      activeColorPrimary: HexColor('#4D8D6E'),
      inactiveColorPrimary: Colors.grey[700]!,
    ),
    PersistentBottomNavBarItem(
      icon: FaIcon(FontAwesomeIcons.bars),
      title: ("More"),
      activeColorPrimary: HexColor('#4D8D6E'),
      inactiveColorPrimary: Colors.grey[700]!,
    ),
  ];

  final PersistentTabController navigationController = PersistentTabController(initialIndex: 0);

  void initState() {

    super.initState();

    ;
    _screens = [
      Homeclient(showCase: widget.showCase),
      projectsClient(),
      projectPost(),
      inboxtest(),
      Moreclient(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(

        context,
        controller: navigationController,
        screens: _screens,

        items: _navBarItems,
        confineInSafeArea: true,

        navBarHeight: 63,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Increased opacity for more shadow
              blurRadius: 20, // Increased blur radius
              spreadRadius: 10, // Increased spread radius
              offset: Offset(0, 4), // Adjusted offset
            ),
          ],      ),
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
        navBarStyle: NavBarStyle.style16,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        ));
  }
}
