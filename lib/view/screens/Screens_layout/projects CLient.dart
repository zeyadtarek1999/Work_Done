import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';
import '../../../model/mediaquery.dart';
import '../Bid Details/Bid details Client.dart';
import '../Bid Details/Bid details ClientPost.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class projectsClient extends StatefulWidget {
  projectsClient({super.key});

  @override
  State<projectsClient> createState() => _projectsClientState();
}

class _projectsClientState extends State<projectsClient> with SingleTickerProviderStateMixin {
  int currentPage = 1;
  bool shouldShowNextButton(List<Item>? nextPageData) {
    // Add your condition to check if the next page is not empty here
    return nextPageData != null && nextPageData.isNotEmpty;
  }
  int currentTabIndex = 0; // Assuming the default tab is Under Bid

  List<String> filteredItems = [];
  late Future<List<Item>> futureProjects;
  List<Item> items = [];
  TextEditingController searchController = TextEditingController();
  void refreshProjects() {
    futureProjects = fetchProjects();
  }

  Future<List<Item>> fetchProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      String filter;

      if (currentTabIndex == 0) {
        filter = 'under_bidding';
      } else if (currentTabIndex == 1) {
        filter = 'accepted';
      } else {
        filter = 'completed';
      }
      final response = await http.post(
        Uri.parse('https://www.workdonecorp.com/api/get_my_profile_projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'filter': filter,

        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> projectsJson = responseData['projects'];

          List<Item> projects = projectsJson.map((json) {
            client_id = json['client_id'];
            print(client_id);
            return Item(
              lowest_bids: json['lowest_bid'] ?? 'No Bids', // Assign "No Bids" if null
              projectId: json['project_id'],
              client_id: json['client_id'],
              title: json['title'],
              description: json['desc'],
              imageUrl: json['images'] != null ? List<String>.from(json['images']) : [], // This creates a list from the JSON array
              postedFrom: json['posted_from'],
              client_firstname: json['client_firstname'],
              liked: json['liked'],
              numbers_of_likes: json['numbers_of_likes'],
              isLiked: json['liked'],

            );
          }).toList();

          print(client_id);

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


  final ScreenshotController screenshotController4 = ScreenshotController();
  late AnimationController ciruclaranimation;
  @override
  void initState() {
    super.initState();
    // Call the function that fetches projects and assign the result to futureProjects
    futureProjects = fetchProjects();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

  }
  @override
  void dispose() {
    ciruclaranimation.dispose();
    super.dispose();
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

 String unique= 'projectclient' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController4.capture();

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
      statusBarColor: Colors.white, // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return DefaultTabController(

      length: 3, // Number of tabs
      initialIndex: currentTabIndex, // Set the initial tab index

      child: Scaffold(

        floatingActionButton:
        FloatingActionButton(    heroTag: 'workdone_${unique}',



          onPressed: () {
            _navigateToNextPage(context);

            },
          backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
  child: Icon(Icons.help ,color: Colors.white,), // Use the support icon          shape: CircleBorder(), // Make the button circular
        ),
        backgroundColor: HexColor('EAEAEE'),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(170.0), // Adjust the height as needed
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(
                      0, 3), // Adjust the offset for desired shadow direction
                ),
              ],
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 125, // Height for the "Project" container
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Text(
                          'Projects',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: HexColor('070821'),
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 335,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: HexColor('E4E3F3'),
                        width: 2 // Set the border color here
                        ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: TabBar(

                    onTap: (index) {
                      setState(() {
                        currentTabIndex = index;
                        refreshProjects();
                      });
                    },
                    tabs: [
                      Tab(
                        text: 'Under Bid',
                      ),
                      Tab(
                        text: 'Accepted',
                      ),
                      Tab(
                        text: 'Completed',
                      )
                    ],
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: HexColor('#4D8D6E'), // Hex color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 4, // Spread radius
                          blurRadius: 9, // Blur radius
                          offset:
                              Offset(6, 5), // Offset in the x and y direction
                        ),
                      ],
                    ),
                    indicatorSize:TabBarIndicatorSize.tab ,
                    labelStyle: GoogleFonts.encodeSans(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Screenshot(
          controller:screenshotController4 ,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),

            children: [

              // Under Bid
              buildTabContent('under_bidding'),

              // Accepted
              buildTabContent('accepted'),

              // Completed
              buildTabContent('completed'),

            ],
          ),
        ),
      ),
    );
  }
  Widget buildTabContent(String filter) {
    return                RefreshIndicator(
      color: HexColor('4D8D6E'),
      backgroundColor: Colors.white,

      onRefresh: () async {
        setState(() {
          futureProjects = fetchProjects();
        });
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),

        child: Column(
          children: [
            FutureBuilder<List<Item>>(
              future: futureProjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      SizedBox(height: 80,),        Center(child: RotationTransition(
                        turns: ciruclaranimation,
                        child: SvgPicture.asset(
                          'assets/images/Logo.svg',
                          semanticsLabel: 'Your SVG Image',
                          width: 100,
                          height: 130,
                        ),
                      ))
                      ,SizedBox(height: 80,)
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                else if (snapshot.data != null && snapshot.data!.isEmpty) {
                  // If projects list is empty, reset current page to 0 and refresh
                  currentPage = 0;
                  refreshProjects();
                  return               Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: SvgPicture.asset(
                            'assets/images/nothing.svg',
                            width: 100.0, // Set the width you want
                            height: 100.0, // Set the height you want
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'No Projects yet',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: HexColor('BBC3CE'),
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80.0),
                          child: Center(
                            child: Container(
                              width: ScreenUtil.buttonscreenwidth,
                              height: 45,

                              child: ElevatedButton(
                                onPressed: () {
                                  Get.offAll(layoutclient(showCase: false,));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor('#4D8D6E'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    // Adjust the value to change the corner radius
                                    side: BorderSide(
                                        width:
                                        130 // Adjust the value to change the width of the narrow edge
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Find a Project',
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                } else {
                  return Animate(
                    effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return buildListItem(snapshot.data![index]);
                      },
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 50,),
          ],
        ),
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