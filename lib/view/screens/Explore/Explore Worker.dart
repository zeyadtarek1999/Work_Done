import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Bid%20Details/Bid%20details%20Worker.dart';
import '../Bid Details/Bid details Client.dart';
import '../Support Screen/Helper.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

class exploreWorker extends StatefulWidget {
  exploreWorker({super.key});

  @override
  State<exploreWorker> createState() => _exploreWorkerState();
}

class _exploreWorkerState extends State<exploreWorker> {
  TextEditingController searchController = TextEditingController();
  late Future<List<Item>> futureProjects;
  int currentPage = 0;
  void refreshProjects() {
    futureProjects = fetchProjects();
  }
  bool shouldShowNextButton(List<Item>? nextPageData) {
    // Add your condition to check if the next page is not empty here
    return nextPageData != null && nextPageData.isNotEmpty;
  }
  Timer? searchDebouncer;

  Future<List<Item>> fetchProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_all_projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'filter': 'search', // Set filter to 'search'
          'search_key': searchController.text, // Include the search key
          'page': currentPage.toString(),
          // Include other parameters as needed
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> projectsJson = responseData['projects'];

          List<Item> projects = projectsJson.map((json) {
            return Item(
              client_id: json['client_id'],
              projectId: json['project_id'],
              title: json['title'],
              description: json['desc'],
              imageUrl: json['images'] != null
                  ? json['images']
                  : 'https://eod-grss-ieee.com/uploads/science/1655561736_noimg_-_Copy.png',
              postedFrom: json['posted_from'],
              client_firstname: json['client_firstname'],
              liked: json['liked'],
              numbers_of_likes: json['numbers_of_likes'],
              isLiked: json['liked'],
            );
          }).toList();

          print(projectsJson);
          print(Item);
          print(projects);
          return projects;
        } else {
          throw Exception('Failed to load data from API: ${responseData['msg']}');
        }
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
        floatingActionButton:
        FloatingActionButton(
          onPressed: () {
            NavigationHelper.navigateToNextPage(context, screenshotController);
          },
          backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
          child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
          shape: CircleBorder(), // Make the button circular
        ),
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
                onTap: (){

                },
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

        body:                   SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
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
                                      // Use a debounce mechanism to delay the refresh and avoid unnecessary API calls
                                      if (searchDebouncer?.isActive ?? false) {
                                        searchDebouncer!.cancel();
                                      }

                                      searchDebouncer = Timer(Duration(milliseconds: 500), () {

                                        setState(() {
                                          refreshProjects();

                                        }); // Trigger the refresh after a delay (e.g., 500 milliseconds)
                                      });
                                    },
                                    onSubmitted: (query) {
                                      // Trigger the refresh when the user presses "Done" on the keyboard
                                      setState(() {
                                        refreshProjects();

                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: TextStyle(color: HexColor('878A8E')),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.black),
                                  )


                                  ,

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
                      return Column(
                        children: [
                          SizedBox(height: 80,),       Center(child: CircularProgressIndicator()),SizedBox(height: 80,)
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                      // If projects list is empty, reset current page to 0 and refresh
                      currentPage = 0;
                      refreshProjects();
                      return Text('No projects found.');
                    } else {
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return buildListItem(snapshot.data![index]);
                        },
                      );
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (currentPage > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            currentPage--;
                            refreshProjects(); // Use refreshProjects instead of fetchProjects
                          });
                        },
                        style: TextButton.styleFrom(

                          primary: Colors.redAccent,

                        ),
                        child: Text(
                          'Previous Page',
                          style: TextStyle(fontSize: 16, ),
                        ),
                      ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          currentPage++;
                          refreshProjects();
                        });

                        // Fetch the projects for the next page
                        List<Item>? nextPageProjects = await fetchProjects();

                        // Check if the next page is empty or no data and hide the button accordingly
                        if (!shouldShowNextButton(nextPageProjects)) {
                          setState(() {
                            currentPage = 0;
                            refreshProjects();
                          });
                        } else {
                          // Update the futureProjects with the fetched projects
                          futureProjects = Future.value(nextPageProjects);
                        }
                      },
                      style: TextButton.styleFrom(

                        primary: Colors.black45,

                      ),
                      child: Text(
                        'Next Page',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        )



    );
  }

  Widget buildListItem(Item item) {
    return GestureDetector(
      onTap: () {
        Get.to(bidDetailsWorker(projectId: item.projectId,));
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
                          children: _buildTextSpans(
                            item.title.length > 17
                                ? '${item.title.substring(0, 16)}...' // Truncate to 14 characters and add ellipsis
                                : item.title,
                            searchController.text,
                          ),
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
                            Get.to(ProfilePageClient(userId: item.client_id.toString()));
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
                        width: 85,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(bidDetailsWorker(projectId: item.projectId,));
                          },
                          child: Text('Bid',style: TextStyle(color: Colors.white,fontSize: 12),),
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
  final int client_id;

  final String liked;
  final String description;
  final String imageUrl;
  final int numbers_of_likes;
  final String postedFrom;
  String isLiked;

  Item({
    required this.projectId,
    required this.title,
    required this.client_id,
    required this.client_firstname,
    required this.description,
    required this.liked,
    required this.numbers_of_likes,
    required this.imageUrl,
    required this.postedFrom,
    required this. isLiked,
  }) ;
}