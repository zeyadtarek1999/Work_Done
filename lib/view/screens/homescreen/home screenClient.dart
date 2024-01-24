import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/shimmers/shimmer basic.dart';
import '../Bid Details/Bid details Client.dart';
import '../Explore/Explore Client.dart';
import '../Profile (client-worker)/profilescreenClient.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

import '../Reviews/reviews.dart';
import '../Support Screen/Support.dart';
import '../editProfile/editProfile.dart';
import '../view profile screens/Client profile view.dart';

class Homeclient extends StatefulWidget {
  const Homeclient({super.key});

  @override
  State<Homeclient> createState() => _HomeclientState();
}

bool isLiked = false;
bool isLoading = true; // Initially set to true to show shimmer
int client_id = 0; // Initially set to true to show shimmer

final advancedDrawerController = AdvancedDrawerController();
int currentPage = 1;
bool shouldShowNextButton(List<Item>? nextPageData) {
  // Add your condition to check if the next page is not empty here
  return nextPageData != null && nextPageData.isNotEmpty;
}
late Future<List<Item>> futureProjects;
List<Item> items = [];
TextEditingController searchController = TextEditingController();


Future<List<Item>> fetchProjects() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final response = await http.post(
      Uri.parse('https://www.workdonecorp.com/api/get_all_projects'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: json.encode({
        'filter': 'all',
        'page': currentPage.toString(), // Ensure `currentPage` is defined somewhere
        // Include other parameters as needed
      }),
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        final List<dynamic> projectsJson = responseData['projects'];

        List<Item> projects = projectsJson.map((json) {
          return Item(
            projectId: json['project_id'],
            client_id:  json['client_id'],
            title: json['title'],
            description: json['desc'],
            imageUrl: json['images'] != null ? List<String>.from(json['images']) : [], // This creates a list from the JSON array
            postedFrom: json['posted_from'],
            client_firstname: json['client_firstname'],
            liked: json['liked'],
            numbers_of_likes:  json['numbers_of_likes'],
            isLiked: json['liked'],
            lowest_bids: json['lowest_bid'] ?? 'No Bids', // Assign "No Bids" if null
          );
        }).toList();

        return projects;
      } else {
        throw Exception('Failed to load data from API: ${responseData['msg']}');
      }
    } else {
      throw Exception('Failed to load data from API: Status code ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error retrieving project data: $e');
  }
}

final StreamController<String> _likedStatusController = StreamController<String>();



Stream<String> get likedStatusStream => _likedStatusController.stream;
List<String> likedProjects = []; // List to store liked project IDs
Map<int, bool> likedProjectsMap = {};

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
        _likedStatusController.add("true");

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
final ScreenshotController screenshotController = ScreenshotController();


class _HomeclientState extends State<Homeclient> {


  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  @override
  void initState() {
    super.initState();
    initializeProjects();
    _getUserProfile();
    likedProjectsMap= {};



  }
  String profile_pic ='' ;
  String firstname ='' ;
  String secondname ='' ;
  String email ='' ;
  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> profileData = responseData['data'];

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }


  void refreshProjects() {
    futureProjects = fetchProjects();
  }
  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = fetchProjects();
      refreshProjects();

    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }

  Future<void> handleLikeAction(Item item) async {
    try {
      if (item.isLiked == "true") {
        // If liked, remove like
        final response = await removeProjectFromLikes(item.projectId.toString());

        if (response['status'] == 'success') {
          // If successfully removed from likes
          print('Project removed from likes');
        } else {
          // Handle the case where the project is not removed from likes
          print('Error: ${response['msg']}');
        }
      } else {
        // If not liked, add like
        final response = await addProjectToLikes(item.projectId.toString());

        if (response['status'] == 'success') {
          // If successfully added to likes, fetch updated data for the project
          print('Project added to likes');
        } else if (response['msg'] == 'This Project is Already in Likes !') {
          // If the project is already liked, switch to Icons.favorite_border
          print('Project is already liked');
        } else {
          // Handle the case where the project is not added to likes
          print('Error: ${response['msg']}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Item> fetchUpdatedProject(int projectId) async {
    // Fetch updated data for the specific project
    // You may need to adjust the API endpoint and request parameters
    final updatedProjects = await fetchProjects();
    return updatedProjects.firstWhere((project) => project.projectId == projectId);
  }



  List<Item> filteredItems = [];
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

  String unique= 'homescreenclient' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }

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
                backgroundImage: profile_pic != null && profile_pic.isNotEmpty
                    ? (profile_pic == "https://workdonecorp.com/images/"
                    ? NetworkImage("http://s3.amazonaws.com/37assets/svn/765-default-avatar.png")
                    : NetworkImage(profile_pic))
                    : AssetImage('assets/images/profileimage.png') as ImageProvider,

              ),
              SizedBox(
                height: 12,
              ),
          isLoading
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 24,
              width: 200,
              color: Colors.white,
            ),
          )
              : Text(
            '$firstname $secondname',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: HexColor('1A1D1E'),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),),
              SizedBox(
                height: 9,
              ),
              isLoading
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 24,
                  width: 200,
                  color: Colors.white,
                ),
              )
                  : Text(
                '$email',
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


                    onPressed: () {Get.to(Reviews());},
                    child: Text(
                      'Review',
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
            ],
          ),
        ),
      ),

      child: Scaffold(
          backgroundColor: HexColor('F0EEEE'),
          floatingActionButton:
          FloatingActionButton(    heroTag: 'workdone_${unique}',



            onPressed: () {
              _navigateToNextPage(context);

            },
            backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
            child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
            shape: CircleBorder(), // Make the button circular
          ),

          body: Screenshot(
            controller:screenshotController ,
            child: SingleChildScrollView(
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
                              backgroundImage: profile_pic != null && profile_pic.isNotEmpty
                                  ? (profile_pic == "https://workdonecorp.com/images/"
                                  ? NetworkImage("http://s3.amazonaws.com/37assets/svn/765-default-avatar.png")
                                  : NetworkImage(profile_pic))
                                  : AssetImage('assets/images/profileimage.png') as ImageProvider,


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
                  FutureBuilder<List<Item>>(
                    future: futureProjects,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Replace CircularProgressIndicator with Shimmer.fromColors
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: YourShimmerWidget(), // Your custom shimmer widget
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data found.');
                      } else {
                        // Update the items list
                        items = snapshot.data!;

                        return CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index, int realIndex) {
                            Item currentItem = items[index];
                            return buildListItem2(currentItem);
                          },
                          options: CarouselOptions(
                            height: 230,
                            aspectRatio: 16 / 7,
                            viewportFraction: 0.84,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                            animateToClosest: true,
                            enlargeFactor: 0.27,
                            padEnds: true,
                            enlargeCenterPage: true,
                            autoPlayInterval: Duration(seconds: 5),
                            autoPlayAnimationDuration: Duration(milliseconds: 1000),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                    Column(
                      children: [
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
                            if (currentPage > 1)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    currentPage--;
                                    refreshProjects(); // Use refreshProjects instead of fetchProjects
                                  });
                                },
                                style: TextButton.styleFrom(

                                  foregroundColor: Colors.redAccent,

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
                                    currentPage = 1;
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
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
  Widget buildListItem2(Item item) {

    return GestureDetector(onTap: (){Get.to(bidDetailsClient(projectId: item.projectId));},
      child: Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 170,
                  aspectRatio: 16/9,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  scrollDirection: Axis.horizontal,
                ),
                items: item.imageUrl.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: double.infinity,
                        ),
                      );
                    },
                  );
                }).toList(),
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
                                      likedProjectsMap[item.projectId] = false;
                                      item.numbers_of_likes = (item.numbers_of_likes ?? 0) - 1;
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
                                      item.numbers_of_likes = (item.numbers_of_likes ?? 0) + 1;
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
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title.length > 18
                              ? item.title.substring(0, 18) + '...' // Display first 14 letters and add ellipsis
                              : item.title,
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: HexColor('398048'),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
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
                          maxLines: 2, // Set the maximum number of lines
                          overflow: TextOverflow.ellipsis, // Display ellipsis (...) for overflow
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
      }

  Widget buildListItem(Item item) {
    return GestureDetector(
      onTap: () {
        Get.to(
                () => bidDetailsClient(projectId: item.projectId),  );    },
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: PageView.builder(
                      pageSnapping: true
                      ,

                      itemCount: item.imageUrl.length, // The count of total images
                      controller: PageController(viewportFraction: 1), // PageController for full-page scrolling
                      itemBuilder: (_, index) {
                        return Image.network(
                          item.imageUrl[index], // Access each image by index
                          fit: BoxFit.cover, // Cover the entire area of the container
                        );
                      },
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
                                        likedProjectsMap[item.projectId] = false;
                                        item.numbers_of_likes = (item.numbers_of_likes ?? 0) - 1;
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
                                        item.numbers_of_likes = (item.numbers_of_likes ?? 0) + 1;
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
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item.title.length > 16
                            ? item.title.substring(0, 16) + '...' // Display first 14 letters and add ellipsis
                            : item.title,
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
                        height: 33,
                        width: 60,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(ProfilePageClient(userId:item.client_id.toString()));
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
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
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
                      ),
                      SizedBox(width: 7,),
                      Column(
                        children: [
                          Text(
                            'lowest bid',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'), // Adjust color as needed
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 6,),
                          item.lowest_bids != 'No Bids'
                              ? Text('\$ '+
                            item.lowest_bids.toString() , // Use 'N/A' or any preferred default text
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                              : Text(
                            'No Bids Yet',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
,
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
                        width: 93,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                                  () => bidDetailsClient(projectId: item.projectId),  );
                            // Handle button press
                          },
                          child: Text('Details',style: TextStyle(color: Colors.white),),
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


class Item {
  final int projectId;
  final int client_id;
  final String title;
  final String client_firstname;
  late  String liked;
  final String description;
  final List<String> imageUrl;
   int numbers_of_likes;
  final String postedFrom;
  String isLiked;
   dynamic? lowest_bids;


  Item({
    required this.projectId,
    required this.client_id,
    required this.lowest_bids,
    required this.title,
    required this.client_firstname,
    required this.description,
    required this.liked,
    required this.numbers_of_likes,
    required this.imageUrl,
    required this.postedFrom,
    required this. isLiked,
  }): assert(lowest_bids != null);
}

