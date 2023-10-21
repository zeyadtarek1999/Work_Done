import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:workdone/view/screens/Explore/Explore%20Worker.dart';
import '../Bid Details/Bid details Worker.dart';
import '../Explore/Explore Client.dart';
import '../Profile (client-worker)/profilescreenClient.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../view profile screens/Client profile view.dart';


class Homescreenworker extends StatefulWidget {
  Homescreenworker({Key? key}) : super(key: key);

  @override
  State<Homescreenworker> createState() => _HomescreenworkerState();
}

class _HomescreenworkerState extends State<Homescreenworker> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  final advancedDrawerController = AdvancedDrawerController();

  List<ProjectData> yourDataList = [
    ProjectData(
      imagePath: 'assets/images/testimage.jpg',
      itemName: 'Wall Painting',
      by: 'John',
      timeAgo: '22 min',
      bidAmount: '50\$',
    ),
    ProjectData(
      imagePath: 'assets/images/pluming.jpg',
      itemName: 'Plumbing',
      by: 'Yousef',
      timeAgo: '30 min',
      bidAmount: '60\$',
    ),
    // Add more data items as needed
  ];
  List<items> Newprojectitems = [
    items(
      imagePath: 'assets/images/testimage.jpg',
      itemName: 'Wall Painting',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'John',
      timeAgo: '22 min',
      bidAmount: '50\$',
    ),
    items(
      imagePath: 'assets/images/pluming.jpg',
      itemName: 'Plumbing',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'Yousef',
      timeAgo: '30 min',
      bidAmount: '60\$',
    ),
    // Add more data items as needed
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('F0EEEE'),
      statusBarIconBrightness:
      Brightness.dark, //Change the status bar ico ns' color (dark or light)
    ));
    return AdvancedDrawer(
        openRatio: 0.5,
        backdropColor: HexColor('ECEDED'),
        controller: advancedDrawerController,
        rtlOpening: false,
        openScale: 0.89,
        childDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 1000),
        drawer: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/profileimage.png'),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Zeyad Tarek',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 9,
                ),
                Text(
                  'zzeyadtarek11@gmail.com',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('6A6A6A'),
                        fontSize: 13,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/user.svg',
                      width: 35.0,
                      height: 35.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/time.svg',
                      width: 35.0,
                      height: 35.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Projects',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/notification.svg',
                      width: 35.0,
                      height: 35.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/portfolioicon.svg',
                      width: 35.0,
                      height: 35.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Portfolio',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logout.svg',
                      width: 35.0,
                      height: 35.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: HexColor('F0EEEE'),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 11),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              drawerControl();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/menuicon.svg',
                              width: 57.0,
                              height: 57.0,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .grey[700], // Change the color as needed
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              Get.to(ProfileScreenClient2());
                              // Handle the tap event here
                            },
                            child: CircleAvatar(
                              radius: 27,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage('assets/images/profileimage.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 23.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Featured Projects',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Get.to(exploreWorker());
                            },
                            child: Text(
                              'See all',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: HexColor('4F815A'),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],

                      ),
                    ),
                    SizedBox(height: 7,),
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: yourDataList.length,
                        itemBuilder: (context, index) {
                          return buildListItem(yourDataList[index]);
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'New Projects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700], // Change the color as needed
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {Get.to(exploreWorker());},
                            child: Text(
                              'See all',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: HexColor('4F815A'),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )

                        ],
                      ),
                    ),

                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: Newprojectitems.length,
                      // Replace with the actual length of your data list
                      itemBuilder: (context, index) {
                        return buildListItemNewProjects(    Newprojectitems[index]);
                      },
                    ),




    ]),
            ),
          ),
        ));
  }
  void drawerControl() {
    advancedDrawerController.showDrawer();
  }

  Widget buildListItem(ProjectData project) {
    return GestureDetector(
      onTap: (){Get.to(bidDetailsWorker());},
      child: Container(
        height: 120, // Adjust the height as needed
        width: 270,  // Adjust the width as needed
        margin: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
        padding: EdgeInsets.symmetric(horizontal: 19.0,vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 250,  // Adjust the width of the image container as needed
              height: 135.0, // Adjust the height of the image container as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: AssetImage(project.imagePath ?? 'assets/image/plumber.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        project.itemName ?? 'No Name',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('131330'),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Start Bid',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 35.5), // Adjust the maximum width as needed
                        child: TextButton(onPressed: () { Get.to(ProfilePageClient()); },
                        child: Text(
                        '  ${project.by ?? 'Unknown'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('43745C'),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))),
                      SizedBox(width: 5),
                      Spacer(),
                      Text(
                        '${project.bidAmount ?? 'N/A'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                      ),
                      Text(
                        '${project.timeAgo ?? 'N/A'} ago',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(width: 5),
                      Spacer(),
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {Get.to(bidDetailsWorker());},
                          child: Text('Bid'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            elevation: 0,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildListItemNewProjects(items item) {
    return GestureDetector(
      onTap: (){Get.to(bidDetailsWorker());},
      child: Container(
        height: 380, // Adjust the height as needed
        width: 270,  // Adjust the width as needed
        margin: EdgeInsets.symmetric(horizontal: 25.0,vertical: 12),
        padding: EdgeInsets.symmetric(horizontal: 13.0,vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 260,  // Adjust the width of the image container as needed
              height: 160.0, // Adjust the height of the image container as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: AssetImage(item.imagePath ?? 'assets/image/plumber.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.itemName ?? 'No Name',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('131330'),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Start Bid :',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),SizedBox(width: 9,),
                      Text(
                        '${item.bidAmount ?? 'N/A'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('4D8D6E'),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 4,),

                  Container(
                    child: Text(
                      item.description ?? 'no description',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('#706F6F'),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
,


                  Row(
                    children: [
                      Text(
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                      ),
                      TextButton(onPressed: () { Get.to(ProfilePageClient()); },
                      child: Text(
                        ' ${item.by ?? 'Unknown'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('43745C'),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      )
                      ),
                      SizedBox(width: 5),
                      ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                      ),
                      Text(
                        '${item.timeAgo ?? 'N/A'} ago',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(width: 5),
                      Spacer(),
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {Get.to(bidDetailsWorker());},
                          child: Text('Bid'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            elevation: 0,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
class ProjectData {
  final String imagePath;
  final String itemName;
  final String by;
  final String timeAgo;
  final String bidAmount;

  ProjectData({
    required this.imagePath,
    required this.itemName,
    required this.by,
    required this.timeAgo,
    required this.bidAmount,
  });
}

class items {
  final String imagePath;
  final String itemName;
  final String description;
  final String by;
  final String timeAgo;
  final String bidAmount;

  items({
    required this.imagePath,
    required this.itemName,
    required this.description,
    required this.by,
    required this.timeAgo,
    required this.bidAmount,
  });
}