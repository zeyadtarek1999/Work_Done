import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class NotificationsPageworker extends StatefulWidget {
  @override
  State<NotificationsPageworker> createState() => _NotificationsPageworkerState();
}

class _NotificationsPageworkerState extends State<NotificationsPageworker> {
  Future<List<Item>> fetchnotification() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://www.workdonecorp.com/api/notification_list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> projectsJson = responseData['data'];

          List<Item> projects = projectsJson.map((json) {
            return Item(
              created_at: json['created_at'],
              msg: json['msg'],
              data: json['data'],
              type:  json['type'],
            );
          }).toList();
          print( 'testing the fetch data $projects');
          return projects;
        } else {
          throw Exception(
              'Failed to load data from API: ${responseData['msg']}');
        }
      } else {
        throw Exception(
            'Failed to load data from API: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving project data: $e');
    }
  }

  late Future<List<Item>> futureProjects;

  @override
  void initState() {
    futureProjects = fetchnotification();

    fetchnotification();

    // ciruclaranimation = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 2),
    // );
    // ciruclaranimation.repeat(reverse: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[100],
          elevation: 10,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              )),
          toolbarHeight: 70,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: FutureBuilder<List<Item>>(
              future: futureProjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 80,
                      ),
                      // Center(
                      // child: RotationTransition(
                      // turns: ciruclaranimation,
                      // child: SvgPicture.asset(
                      // 'assets/images/Logo.svg',
                      // semanticsLabel: 'Your SVG Image',
                      // width: 100,
                      // height: 130,
                      // ),
                      // ))
                      // ,
                      SizedBox(
                        height: 80,
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  // If projects list is empty, reset current page to 0 and refresh

                  return Center(
                    child: SvgPicture.asset(
                      'assets/images/empty.svg',
                      semanticsLabel: 'Your SVG Image',
                      width: 150,
                      height: 200,
                    ),
                  );
                } else {
                  return Animate(
                    effects: [MoveEffect(duration: Duration(milliseconds: 800),),],
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final notification = snapshot.data![index];
                        return buildListItem(notification);
                      },
                    ),
                  );

                }
              }),
        )


    );

  }
  Widget buildListItem(Item item) {

    print( 'testing the fetch type ${item.type}');
    print( 'testing the fetch data ${item.data}');

    return

      Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 5),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                item.type == 'profile'?
                Get.to(ProfileScreenworker()):
                item.type == 'project'?
                Get.to(bidDetailsWorker(projectId: item.data,)):
                item.type == 'bid'?
                Get.to(bidDetailsWorker(projectId: item.data,)):
                item.type == 'schedule'?
                Get.to(bidDetailsWorker(projectId: item.data,)):



                null;




              },

              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child:
                    item.type == 'project'?

                    FaIcon(FontAwesomeIcons.briefcase,                     color: Colors.blueGrey,)
                        :
                    item.type == 'profile'?

                    Icon(Icons.account_circle_rounded,                     color: Colors.blueGrey,)
                        :item.type == 'bid'?
                    Icon(Icons.monetization_on,                     color: Colors.blueGrey,)
                        :item.type == 'schedule'?
                    Icon(Icons.access_time_filled,                     color: Colors.blueGrey,)
                        :
                    Icon(
                      Icons.notifications_active,
                      color: Colors.blueGrey,
                    )
                ),
                title: Text(
                  item.msg,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    item.created_at,
                    style: GoogleFonts.poppins(
                        textStyle:
                        TextStyle(color: Colors.black45),
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.grey[300],
              height: 1,
            )
          ],
        ),
      );
  }

}

class Item {
  final String msg;
  final String created_at;
  final dynamic type;
  final dynamic data;

  Item({
    required this.msg,
    required this.created_at,
    required this.type,
    required this.data,
  });
}
