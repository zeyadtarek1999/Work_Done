import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../Bid Details/Bid details Client.dart';
import '../Explore/Explore Client.dart';
import '../Profile (client-worker)/profilescreenClient.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../view profile screens/Client profile view.dart';

class Homeclient extends StatefulWidget {
  const Homeclient({super.key});

  @override
  State<Homeclient> createState() => _HomeclientState();
}

final advancedDrawerController = AdvancedDrawerController();
List<builder> item2 = [
  builder(
    title: 'Wall Paint',
    description:
    'Lorem ipsum is placeholder text commonly used in the graphic, print',
  ),
  builder(
    title: 'Furniture',
    description:
    'Furniture is the mass noun for the movable objects intended to support various human activities.',
  ),
  builder(
    title: 'Decoration',
    description:
    'Decoration is the furnishing or adorning of a space with decorative elements.',
  ),
];

List<CarouselItem> items = [
  CarouselItem(
    imageUrl: 'assets/images/testimage.jpg',
    title: 'Wall painting',
    description: 'Description for Image 1',
  ),
  CarouselItem(
    imageUrl: 'assets/images/testimage.jpg',
    title: 'Plumping',
    description: 'Description for Image 2',
  ),
  // Add more items as needed
];
final List<Slide> slides = [
  Slide(
    title: 'Slide 1 Title',
    description: 'Slide 1 Description goes here.',
    imageUrl: 'assets/image1.jpg',
  ),
  Slide(
    title: 'Slide 2 Title',
    description: 'Slide 2 Description goes here.',
    imageUrl: 'assets/image2.jpg',
  ),
  Slide(
    title: 'Slide 3 Title',
    description: 'Slide 3 Description goes here.',
    imageUrl: 'assets/image3.jpg',
  ),
];

class _HomeclientState extends State<Homeclient> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('F0EEEE'),
      // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
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
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: SafeArea(
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
                            color:
                                Colors.grey[700], // Change the color as needed
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
                          'Browse Popular Projects',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {Get.to(exploreClient());},
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
                  SizedBox(
                    height: 14,
                  ),
                  Column(
                    children: [
                      CarouselSlider.builder(
                        carouselController: _carouselController,
                        itemCount: items.length,
                        itemBuilder:
                            (BuildContext context, int index, int realIndex) {
                          return CarouselItemWidget(
                            item: items[index],
                            borderRadius: BorderRadius.circular(
                                30), // Rounded border for the item
                          );
                        },
                        options: CarouselOptions(
                          height: 230,
                          aspectRatio: 16 / 7,
                          viewportFraction: 0.84,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          animateToClosest: true,
                          enlargeFactor: 0.27,
                          padEnds: true,
                          enlargeCenterPage: true,
                          autoPlayInterval: Duration(seconds: 5),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 1000),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.map((item) {
                            int itemIndex = items.indexOf(item);
                            return CircularIndicator(
                              itemIndex: itemIndex,
                              currentIndex: _currentIndex,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Projects Around You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700], // Change the color as needed
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {Get.to(exploreClient());},
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
                  SizedBox(
                    height: 7,
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    // Replace with the actual length of your data list
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: buildListItem(item2[index]),
                      );
                    },
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget buildListItem(builder item) {
    return GestureDetector(
      onTap: (){Get.to(bidDetailsClient());},
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 11.0,horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 14),
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
              width: double.infinity,
              height: 170.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: AssetImage('assets/images/testimage.jpg'), // Replace with your image URL
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
                        item.title,
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
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(width: 4,),
                      Container(
                        height: 30,
                        width: 50,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(ProfilePageClient());
                          },
                          style: TextButton.styleFrom(
                            fixedSize: Size(50, 30), // Adjust the size as needed
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'John',
                            style: TextStyle(
                              color: HexColor('4D8D6E'),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 3, // Limit the text to three lines
                    overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('393B3E'),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: HexColor('777778'),
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '22 min',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('777778'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        'ago',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('777778'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {Get.to( bidDetailsClient());},
                          child: Text('Details'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, // Make the button background transparent
                            elevation: 0, // Remove button elevation
                            textStyle: TextStyle(color: Colors.white), // Set text color to white
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


  void drawerControl() {
    advancedDrawerController.showDrawer();
  }
}

class CircularIndicator extends StatelessWidget {
  final int itemIndex;
  final int currentIndex;

  CircularIndicator({
    required this.itemIndex,
    required this.currentIndex, // Default inactive color
    // Default active color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: itemIndex == currentIndex ? Colors.blue : Colors.grey,
      ),
    );
  }
}

class CarouselItem {
  final String imageUrl;
  final String title;
  final String description;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class CarouselItemWidget extends StatelessWidget {
  final CarouselItem item;
  final BorderRadius borderRadius;

  CarouselItemWidget({
    required this.item,
    required this.borderRadius, // Accept the borderRadius as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 170,
          child: ClipRRect(
            borderRadius: borderRadius,
            // Apply the provided borderRadius
            child: Image.asset(
              item.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          bottom: 17,
          left: 30,
          right: 30,
          child: Container(
            height: 122,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius.topLeft.x),
                topRight: Radius.circular(borderRadius.topRight.x),
                bottomLeft: Radius.circular(borderRadius.bottomLeft.x),
                bottomRight: Radius.circular(borderRadius.bottomRight.x),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 5,
                  offset: Offset(3, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#398048'),
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: HexColor('#706F6F'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class CarouselWithDescription extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CarouselSlider.builder(
//       itemCount: items.length,
//       itemBuilder: (BuildContext context, int index, int realIndex) {
//         return CarouselItemWidget(item: items[index]);
//       },
//       options: CarouselOptions(
//         height: 300,
//         aspectRatio: 16 / 9,
//         viewportFraction: 0.8,
//         enableInfiniteScroll: true,
//         autoPlay: true,
//         autoPlayInterval: Duration(seconds: 3),
//         autoPlayAnimationDuration: Duration(milliseconds: 800),
//         autoPlayCurve: Curves.fastOutSlowIn,
//         enlargeCenterPage: true,
//       ),
//     );
//   }
// }
class Slide {
  final String title;
  final String description;
  final String imageUrl;

  Slide({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
class builder {
  final String title;
  final String description;

  builder({
    required this.title,
    required this.description,
  });
}