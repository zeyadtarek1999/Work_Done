import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Bid Details/Bid details Client.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

class exploreClient extends StatefulWidget {
   exploreClient({super.key});

  @override
  State<exploreClient> createState() => _exploreClientState();
}

class _exploreClientState extends State<exploreClient> {
  TextEditingController searchController = TextEditingController();
  late Future<List<Item>> futureProjects;

  Future<List<Item>> fetchProjects() async {
    try {
      // Get the token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_all_projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> projectsJson = json.decode(response.body)['projects'];

        List<Item> projects = projectsJson.map((json) {
          return Item(
            projectId: json['project_id'],
            title: json['title'],
            description: json['desc'],
            imageUrl: json['images'],
            postedFrom: json['posted_from'],
            client_firstname: json['client_firstname'],
          );
        }).toList();
print(projectsJson);
print(Item);
print(projects);
        return projects;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  List<Item> filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Call the function that fetches projects and assign the result to futureProjects
    futureProjects = fetchProjects();

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


  void filterProjects(String query, List<Item> projects) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(projects);
      } else {
        filteredItems = projects.where((project) {
          final title = project.title.toLowerCase();
          final description = project.description.toLowerCase();
          final client_firstname = project.client_firstname.toLowerCase();
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
              FutureBuilder<List<Item>>(
                future: futureProjects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No projects found.');
                  } else {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true, // Set shrinkWrap to true
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return buildListItem(snapshot.data![index]);
                      },
                    );
                  }
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
      onTap: () {
        // Get.to(bidDetailsClient());
      },
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
                  image: NetworkImage(item.imageUrl), // Use the image URL from the fetched data
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        width: 60,
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
                          child: Text.rich(
                            TextSpan(
                              children: _buildTextSpans(item.client_firstname, searchController.text),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis, // Use the client name from the fetched data
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
                        item.postedFrom, // Use the posted time from the fetched data
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('777778'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
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
                            // Get.to(bidDetailsClient());
                            // Handle button press
                          },
                          child: Text('Details'),
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
  final int projectId;
  final String title;
  final String client_firstname;
  final String description;
  final String imageUrl;
  final String postedFrom;

  Item({
    required this.projectId,
    required this.title,
    required this.client_firstname,
    required this.description,
    required this.imageUrl,
    required this.postedFrom,
  });
}
