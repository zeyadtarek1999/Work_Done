import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';


import '../Bid Details/Bid details Worker.dart';
import '../view profile screens/Client profile view.dart';

class exploreWorker extends StatefulWidget {
  exploreWorker({super.key});

  @override
  State<exploreWorker> createState() => _exploreWorkerState();
}

class _exploreWorkerState extends State<exploreWorker> {
  TextEditingController searchController = TextEditingController();

  List<Item> items = [
    Item(
      title: 'Wall Paint',
      description:
      'Lorem ipsum is placeholder text commonly used in the graphic, print',
    ),
    Item(
      title: 'Furniture',
      description:
      'Furniture is the mass noun for the movable objects intended to support various human activities.',
    ),
    Item(
      title: 'Decoration',
      description:
      'Decoration is the furnishing or adorning of a space with decorative elements.',
    ),
  ];

  List<Item> filteredItems = [];


  @override
  void initState() {
    super.initState();
    filteredItems = List.from(items);
  }

  List<InlineSpan> _buildTextSpans(String text, String query) {
    final spans = <InlineSpan>[];
    final matches = RegExp(query, caseSensitive: false).allMatches(text.toLowerCase());

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    int currentIndex = 0;
    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  void filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(items);
      } else {
        filteredItems = items.where((item) {
          final title = item.title.toLowerCase();
          final description = item.description.toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('F9F9F9'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));


    return Scaffold(
      backgroundColor: HexColor('F9F9F9'),
      appBar: AppBar(systemOverlayStyle:SystemUiOverlayStyle.dark ,
        toolbarHeight: 70,
        backgroundColor: HexColor('F9F9F9'),
        elevation: 0,
        leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_sharp ,color: Colors.black,size: 30,)),
        title: Text('Explore',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
                color: HexColor('393B3E'),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: (){},
              child:
              SvgPicture.asset(
                'assets/icons/iconnotification.svg',
                width: 48.0,
                height:48.0,
              ),
            ),
          )

        ],

      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Color of the shadow
                        spreadRadius: 2, // Spread radius
                        blurRadius: 4, // Blur radius
                        offset: Offset(0, 2), // Offset in the x and y direction
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: HexColor('4D8D6E'),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Center(
                            child: Text(
                              'All',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15 ,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: HexColor('878A8E'),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: TextField(
                                  controller: searchController,

                                  onChanged: (query) {
                                    filterItems(query);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    hintStyle: TextStyle(color: HexColor('878A8E')),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),

                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),

                shrinkWrap: true,
                itemCount: filteredItems.length,
                // Replace with the actual length of your data list
                itemBuilder: (context, index) {
                  return buildListItem(filteredItems[index]);
                },
              ),





            ],
          ),
        ),
      ),

    );
  }

  Widget buildListItem(Item item) {
    return GestureDetector(
      // onTap: (){Get.to(bidDetailsWorker());},

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
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
                      Text.rich(
                        TextSpan(
                          children: _buildTextSpans(item.title, searchController.text),
                        ),
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
                            // Get.to(ProfilePageClient());
                          },
                          style: TextButton.styleFrom(
                            fixedSize: Size(50, 30), // Adjust the size as needed
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'John',
                            style: TextStyle(
                              color: HexColor('4D8D6E'),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: _buildTextSpans(item.description, searchController.text),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                          onPressed: () {
                            // Get.to(bidDetailsWorker());
                            // Handle button press
                          },
                          child: Text('Bid'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            elevation: 0,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
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
class Item {
  final String title;
  final String description;

  Item({
    required this.title,
    required this.description,
  });
}