import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/mediaquery.dart';
import '../Bid Details/Bid details Client.dart';
import '../Bid Details/Bid details ClientPost.dart';
import '../view profile screens/Client profile view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class projectsClient extends StatefulWidget {
  projectsClient({super.key});

  @override
  State<projectsClient> createState() => _projectsClientState();
}

class _projectsClientState extends State<projectsClient> {
  List<String> filteredItems = [];
  late Future<List<Item>> futureProjects;
  List<Item> items = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeProjects();
  }

  List<InlineSpan> _buildTextSpans(String text, String query) {
    final spans = <InlineSpan>[];
    final matches =
        RegExp(query, caseSensitive: false).allMatches(text.toLowerCase());

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

  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = getClientProjects();

      // Wait for the future to complete
      List<Item> items = await futureProjects;
    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }

  void filterItems(String query) {
    setState(() {});
  }

  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Item>> getClientProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_client_projects'),
        headers: {'Authorization': 'Bearer $userToken'},
        body: {'filter': 'current'},
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> projectsJson =
            json.decode(response.body)['projects'];

        List<Item> projects = projectsJson.map((json) {
          return Item(
            projectId: json['project_id'],
            title: json['title'],
            desc: json['desc'],
            images: json['images'],
            postedFrom: json['posted_from'],
            client_firstname: json['client_firstname'],
            numbers_of_likes: json['numbers_of_likes'],
            timeframe_start:json['timeframe_start'],
            timeframe_end: json['timeframe_end'],
            project_type_id: json['project_type_id'],
          );
        }).toList();
        print(projectsJson);
        print(Item);
        print(projects);
        return projects;
        // Handle the response as needed
        print('Response: $responseData');
      } else {
        // Handle the error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
        throw Exception('Failed to fetch client projects');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      throw Exception('An error occurred while fetching client projects');
    }
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
      child: Scaffold(
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
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius:
                            BorderRadius.circular(30), // Circular border radius
                      ),
                      child: TextField(
                        controller: _searchController,
              
                        decoration: InputDecoration(
                          hintText: 'Search', // Hint text
                          border: InputBorder.none, // Remove underline
                          prefixIcon: Icon(Icons.search), // Search icon
                        ),
                        onChanged:
                            filterItems, // Call filterItems when the text changes
                      ),
                    ),
                  ),
                  FutureBuilder<List<Item>>(
                      future: futureProjects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color:HexColor('#4D8D6E') ,));
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
                      })
                ],
              ),
            ),
            Padding(
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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Container(
                      width: ScreenUtil.buttonscreenwidth,
                      height: 45,
                      margin:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                      child: ElevatedButton(
                        onPressed: () {},
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
                ],
              ),
            ),
            Padding(
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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Container(
                      width: ScreenUtil.buttonscreenwidth,
                      height: 45,
                      margin:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                      child: ElevatedButton(
                        onPressed: () {},
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
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildListItem(Item item) {
    return GestureDetector(onTap: (){

      Get.to(bidDetailsClientPost(projectId: item.projectId));},
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
                      image: NetworkImage(item.images),
                      // Use the image URL from the fetched data
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
                          children: _buildTextSpans(
                              item.title, searchController.text),
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
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        height: 30,
                        width: 60,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Get.to(ProfilePageClient());
                          },
                          style: TextButton.styleFrom(
                            fixedSize: Size(50, 30),
                            // Adjust the size as needed
                            padding: EdgeInsets.zero,
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: _buildTextSpans(
                                  item.client_firstname, searchController.text),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            // Use the client name from the fetched data
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
                      children:
                          _buildTextSpans(item.desc, searchController.text),
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
                        item.postedFrom,
                        // Use the posted time from the fetched data
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
                            Get.to(bidDetailsClientPost(projectId: item.projectId));
                            // Handle button press
                          },
                          child: Text(
                            'Details',
                            style: TextStyle(color: Colors.white),
                          ),
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
  final int project_type_id;
  final String title;
  final String client_firstname;
  final String desc;
  final String images;
  final String timeframe_start;
  final String timeframe_end;
  final int numbers_of_likes;
  final String postedFrom;

  Item({
    required this.projectId,
    required this.timeframe_start,
    required this.timeframe_end,
    required this.project_type_id,
    required this.title,
    required this.client_firstname,
    required this.desc,
    required this.numbers_of_likes,
    required this.images,
    required this.postedFrom,
  });
}
