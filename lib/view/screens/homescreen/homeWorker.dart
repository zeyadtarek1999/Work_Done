import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Explore/Explore%20Worker.dart';
import '../Bid Details/Bid details Worker.dart';
import '../Explore/Explore Client.dart';
import '../Profile (client-worker)/profilescreenClient.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

import '../editProfile/editProfile.dart';
import '../view profile screens/Client profile view.dart';


class Homescreenworker extends StatefulWidget {
  Homescreenworker({Key? key}) : super(key: key);

  @override
  State<Homescreenworker> createState() => _HomescreenworkerState();
}

class _HomescreenworkerState extends State<Homescreenworker> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  String truncateText(String text, int numberOfWords) {
    List<String> words = text.split(' ');

    if (words.length <= numberOfWords) {
      return text; // No need to truncate
    } else {
      // Take the first 'numberOfWords' words and concatenate with ellipsis
      return '${words.take(numberOfWords).join(' ')}...';
    }
  }

  final advancedDrawerController = AdvancedDrawerController();

  Map<int, bool> likedProjectsMap = {};
  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = fetchProjects();

      // Wait for the future to complete
      List<Item> items = await futureProjects;

      // Iterate through the list of items and check if each project is liked
      items.forEach((item) {
        checkIfProjectIsLiked(item);
      });
    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    initializeProjects();



  }
  late Future<List<Item>> futureProjects;
  List<Item> items = [];
  TextEditingController searchController = TextEditingController();
  bool isLiked = false;

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
            liked: json['liked'],
            numbers_of_likes: json['numbers_of_likes'],     isLiked: isLiked,

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

  List<String> likedProjects = []; // List to store liked project IDs

  Future<Map<String, dynamic>> addProjectToLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/add_project_to_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          // Project added to likes successfully
          print('Project added to likes successfully');
        } else if (responseBody['msg'] == 'This Project is Already in Likes !') {
          // Project is already liked
          print('Project is already liked');
        } else {
          // Handle other error scenarios
          print('Error: ${responseBody['msg']}');
        }

        return responseBody;
      } else {
        // Handle other status codes
        print('Failed to add project to likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to add project to likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }


  Future<Map<String, dynamic>> removeProjectFromLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('user_token') ?? '';
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/remove_project_from_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        // Successful request, you can handle the response here if needed
        print('Project removed from likes successfully');
        return {'status': 'success', 'msg': 'Project removed from likes successfully'};
      } else {
        // Handle error
        print('Failed to remove project from likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to remove project from likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }


  Future<void> checkIfProjectIsLiked(Item item) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await addProjectToLikes(item.projectId.toString());

      if (response['status'] == 'success') {
        // Project is already liked
        setState(() {
          likedProjectsMap[item.projectId] = true;
        });
        print('Project is already liked');
      } else if (response['msg'] == 'This Project is Already in Likes !') {
        // Project is not liked
        setState(() {
          likedProjectsMap[item.projectId] = false;
          print(          likedProjectsMap
          );

        });
        print('Project is not liked');
      } else {
        // Handle other error scenarios
        print('Error: ${response['msg']}');
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
    }
  }  List<Item> filteredItems = [];
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
                      onPressed: () {Get.to(editProfile());},
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
                              Get.to(ProfileScreenworker());
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
                      child:                  FutureBuilder<List<Item>>(
                        future: futureProjects,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No projects found.');
                          } else {
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal, // Set shrinkWrap to true
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return buildListItem(snapshot.data![index]);
                              },
                            );
                          }
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

                    FutureBuilder<List<Item>>(
                      future: futureProjects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
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
                              return buildListItemNewProjects(snapshot.data![index]);
                            },
                          );
                        }
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

  Widget buildListItem(Item project) {
    return GestureDetector(
      onTap: (){Get.to(Get.to(
            () => bidDetailsWorker(projectId: project.projectId)));},
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
            Stack(
              children: [
                Container(
                  width: 250,  // Adjust the width of the image container as needed
                  height: 135.0, // Adjust the height of the image container as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: NetworkImage(project.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(),
                Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 5),
                        child: Text(
                          "${project.numbers_of_likes}" ,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        iconSize: 22,
                        icon: Icon(
                          likedProjectsMap[project.projectId] ?? project.liked == "true"
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: likedProjectsMap[project.projectId] ?? project.liked == "true"
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          try {
                            if (likedProjectsMap[project.projectId] ?? project.liked == "true") {
                              // If liked, remove like
                              final response = await removeProjectFromLikes(project.projectId.toString());

                              if (response['status'] == 'success') {
                                // If successfully removed from likes
                                setState(() {
                                  likedProjectsMap[project.projectId] ?? project.liked == "false";
                                  likedProjectsMap[project.projectId] = false;
                                });
                                print('Project removed from likes');
                              } else {
                                // Handle the case where the project is not removed from likes
                                print('Error: ${response['msg']}');
                              }
                            } else {
                              // If not liked, add like
                              final response = await addProjectToLikes(project.projectId.toString());

                              if (response['status'] == 'success') {
                                // If successfully added to likes
                                setState(() {
                                  likedProjectsMap[project.projectId] = true;
                                });
                                print('Project added to likes');
                              } else if (response['msg'] == 'This Project is Already in Likes !') {
                                // If the project is already liked, switch to Icons.favorite_border
                                setState(() {
                                  likedProjectsMap[project.projectId] = false;
                                });
                                print('Project is already liked');
                              } else {
                                // Handle the case where the project is not added to likes
                                print('Error: ${response['msg']}');
                              }
                            }
                          } catch (e) {
                            print('Error: $e');
                          }
                        },
                      ),                      ],
                  ),
                ),
        ],
      ),
    ),
              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        truncateText(project.title, 2),
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
                        project.client_firstname,
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
                        '2',
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
                        project.postedFrom,
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
                          onPressed: () {Get.to(
                                () => bidDetailsWorker(projectId: project.projectId),  );},
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


  Widget buildListItemNewProjects(Item item) {
    return GestureDetector(
      onTap: () {
        Get.to(
              () => bidDetailsWorker(projectId: item.projectId),  );    },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16),
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
            Stack(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(), // Pushes the container to the right
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 5),
                              child: Text(
                                "${item.numbers_of_likes}",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                likedProjectsMap[item.projectId] ?? item.liked == "true"
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: likedProjectsMap[item.projectId] ?? item.liked == "true"
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                try {
                                  if (likedProjectsMap[item.projectId] ?? item.liked == "true") {
                                    // If liked, remove like
                                    final response = await removeProjectFromLikes(item.projectId.toString());

                                    if (response['status'] == 'success') {
                                      // If successfully removed from likes
                                      setState(() {
                                        likedProjectsMap[item.projectId] ?? item.liked == "false";
                                        likedProjectsMap[item.projectId] = false;
                                      });
                                      print('Project removed from likes');
                                    } else {
                                      // Handle the case where the project is not removed from likes
                                      print('Error: ${response['msg']}');
                                    }
                                  } else {
                                    // If not liked, add like
                                    final response = await addProjectToLikes(item.projectId.toString());

                                    if (response['status'] == 'success') {
                                      // If successfully added to likes
                                      setState(() {
                                        likedProjectsMap[item.projectId] = true;
                                      });
                                      print('Project added to likes');
                                    } else if (response['msg'] == 'This Project is Already in Likes !') {
                                      // If the project is already liked, switch to Icons.favorite_border
                                      setState(() {
                                        likedProjectsMap[item.projectId] = false;
                                      });
                                      print('Project is already liked');
                                    } else {
                                      // Handle the case where the project is not added to likes
                                      print('Error: ${response['msg']}');
                                    }
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                }
                              },
                            ),                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
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
                            Get.to(
                                  () => bidDetailsWorker(projectId: item.projectId),  );
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
  final String liked;
  final String description;
  final String imageUrl;
  final int numbers_of_likes;
  final String postedFrom;
  bool isLiked;

  Item({
    required this.projectId,
    required this.title,
    required this.client_firstname,
    required this.description,
    required this.liked,
    required this.numbers_of_likes,
    required this.imageUrl,
    required this.postedFrom,
    bool? isLiked,
  }) : isLiked = isLiked ?? liked.toLowerCase() == 'true';
}