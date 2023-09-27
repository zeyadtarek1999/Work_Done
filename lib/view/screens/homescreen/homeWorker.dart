import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';


import '../../../controller/DrawerControllerworker.dart';
import '../../../model/PersistentBottomNavBar.dart';
import '../../../model/customizeappbarworker.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import '../../settingscreen.dart';
class Homescreenworker extends StatefulWidget{
  Homescreenworker ({ Key? key }) : super (key: key);

  @override
  State<Homescreenworker> createState() => _HomescreenworkerState();
}

class _HomescreenworkerState extends State<Homescreenworker> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        endDrawer: MyDrawerworker(),

      appBar: CustomAppBarworker(),
      body: SingleChildScrollView(
        child: Column(
          children: [

          ],
        ),
      ),


    );
  }

}
