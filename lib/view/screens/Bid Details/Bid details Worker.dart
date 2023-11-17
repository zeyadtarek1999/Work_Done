import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;

import '../view profile screens/Client profile view.dart';
import '../view profile screens/Worker profile view.dart';
import 'Place a Bid.dart';

class bidDetailsWorker extends StatefulWidget {
  final int projectId;

  bidDetailsWorker({required this.projectId});

  @override
  State<bidDetailsWorker> createState() => _bidDetailsWorkerState();
}

class _bidDetailsWorkerState extends State<bidDetailsWorker> {
  late Future<ProjectDetails> projectDetails;
  String? clientFirstName;
  String? clientLastName;
  String ?projectType;
  String ?title;
  String ?description;
  String ?timeframeStart;
  String ?timeframeEnd;
  String ?imageUrl;
  int  lowest_bid = 0;
  String ?postedFrom;
  bool ?liked;
  int ?numberOfLikes;
  final List<Item> items = [
    Item(WorkerName: 'Mahmoud', Money: '22', rate: '4.5'),
    Item(WorkerName: 'Hossam', Money: '30', rate: '3.8'),
    Item(WorkerName: 'John', Money: '25', rate: '4.2'),
    Item(WorkerName: 'Mohamed', Money: '9', rate: '4.1'),
    Item(WorkerName: 'Mohamed', Money: '10', rate: '4.1'),
    // Add more items as needed
  ];
  Future<List<ProjectBid>> fetchBids(int projectId) async {
    try {
      // Get the token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_project_bids'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': projectId.toString(), // Convert to String if needed
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> projectsJson = json.decode(response.body);

        List<ProjectBid> projects = projectsJson.map((json) {
          return ProjectBid(
            workerFirstName: json['worker_firstname'], workerProfilePic: json['worker_profile_pic'],
            amount: json['amount'],

          );
        }).toList();
        print(projectsJson);
        print(ProjectBid);
        print(projects);
        return projects;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  List<ProjectBid> projectbid = [];
  TextEditingController searchController = TextEditingController();

  String currentbid ='24';
  Future<void> fetchData() async {
    try {
      ProjectDetails details = await getProjectDetails(widget.projectId);

      // Now you can use details in your code
      print('Client First Name: ${details.clientFirstName}');
      print('Title: ${details.title}');
      print('Number of Likes: ${details.numberOfLikes}');
      print('Project ID: ${widget.projectId}');

      // Replace null with '0' if lowest_bid is null
      int lowestBid = details.lowest_bid ?? 0;

      // You can also use details to update your UI or perform other actions
      // For example, updating the state in a StatefulWidget
      setState(() {
        clientFirstName = details.clientFirstName;
        // Use lowestBid in your UI or other logic
      });
    } catch (e) {
      // Handle any errors that might occur during the API call
      print('Error fetching project details: $e');
    }
  }
  static const String baseUrl = 'https://workdonecorp.com/api';

  Future<Map<String, dynamic>> getProjectBids() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final String url = '$baseUrl/get_project_bids';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $userToken',
      },
      body: {
        'project_id': widget.projectId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get project bids. Status Code: ${response.statusCode}');
    }
  }
  @override
  void initState() {
    super.initState();
    projectDetails = getProjectDetails(widget.projectId);
    initializeProjects();

    fetchData();
    // Set currentbid to the lowest Money value when the page opens
  }
  late Future<List<ProjectBid>> futureProjects;

  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = fetchBids(widget.projectId);
      List<ProjectBid> projectbit = await futureProjects;

      // Iterate through the list of items and check if each project is liked
    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }

  bool sortLowest = true;
// Sorting methods
  void sortLowestMoney() {
    items.sort((a, b) {
      double moneyA = double.parse(a.Money);
      double moneyB = double.parse(b.Money);
      return sortLowest ? moneyA.compareTo(moneyB) : moneyB.compareTo(moneyA);
    });
  }

  void sortHighestMoney() {
    items.sort((a, b) {
      double moneyA = double.parse(a.Money);
      double moneyB = double.parse(b.Money);
      return sortLowest ? moneyB.compareTo(moneyA) : moneyA.compareTo(moneyB);
    });
  }

  void sortLowestRate() {
    items.sort((a, b) {
      double rateA = double.parse(a.rate);
      double rateB = double.parse(b.rate);
      return sortLowest ? rateA.compareTo(rateB) : rateB.compareTo(rateA);
    });
  }

  void sortHighestRate() {
    items.sort((a, b) {
      double rateA = double.parse(a.rate);
      double rateB = double.parse(b.rate);
      return sortLowest ? rateB.compareTo(rateA) : rateA.compareTo(rateB);
    });
  }

  Future<ProjectDetails> getProjectDetails(int projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_project_details'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': widget.projectId.toString(), // Convert to String if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (response.statusCode == 200) {
          // Parse the response into the ProjectDetails model
          ProjectDetails projectDetails = ProjectDetails(
            clientFirstName: responseBody['client_fname'],
            lowest_bid: responseBody['lowest_bid'],
            clientLastName: responseBody['client_lname'],
            projectType: responseBody['project_type'],
            title: responseBody['title'],
            description: responseBody['desc'],
            timeframeStart: responseBody['timeframe_start'],
            timeframeEnd: responseBody['timeframe_end'],
            imageUrl: responseBody['images'],
            postedFrom: responseBody['posted_from'],
            liked: responseBody['liked'] == 'true',
            numberOfLikes: responseBody['number_of_likes'],

          );

          return projectDetails;
        } else {
          print ('this is project id ' + "$projectId");
          // Handle other error scenarios
          print('Error: of what ${responseBody['msg']}');
          throw Exception(responseBody['msg']);
        }
      } else {

        // Handle other status codes
        print('Failed to get project details. Status code: ${response.statusCode}');
        throw Exception('Failed to get project details');
      }
    } catch (e) {

      // Handle exception
      print('Error: $e');
      throw Exception('An error occurred');
    }
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('FFFFFF'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));

    return Scaffold(
      backgroundColor: HexColor('FFFFFF'),
      appBar: AppBar(
        backgroundColor: HexColor('FFFFFF'),
        systemOverlayStyle:SystemUiOverlayStyle.dark,
        elevation: 0,toolbarHeight: 67,

        leading: IconButton(onPressed: (){Get.back();},icon:Icon( Icons.arrow_back_sharp),color: Colors.black,),
        title: Text ( 'Bid Details',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('454545'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true ,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                child:

                FutureBuilder<ProjectDetails>(
                    future: projectDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        ProjectDetails details = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Container(
                              width: double.infinity,
                              height: 210.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                image: DecorationImage(
                                  image: NetworkImage(details.imageUrl), // Replace with your image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 12,),
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: HexColor('4D8D6E'),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      details.projectType,
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                          color: HexColor('FFFFFF'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                ,
                                Spacer(),
                                Icon(
                                  Icons.access_time_rounded,
                                  color: HexColor('777778'),
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  details.postedFrom,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: HexColor('777778'),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2),


                              ],
                            ),
                            SizedBox(height: 12,),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text (details.title,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('454545'),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),

                            Row(

                              children: [

                                CircleAvatar(
                                  radius: 23,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                  NetworkImage(details.imageUrl),
                                ),
                                SizedBox(width: 13,),
                                Container(
                                  height: 30,
                                  width: 70,
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
                                      details.clientFirstName,
                                      style: TextStyle(
                                        color: HexColor('4D8D6E'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 75,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: HexColor('FFFFFF'),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5), // Color of the shadow
                                        spreadRadius: 2, // Spread radius
                                        blurRadius: 3, // Blur radius
                                        offset: Offset(0, 2), // Offset in the x and y direction
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Current lowest Bid',
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                              color: HexColor('898B8D'),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4,),
                                      Row(mainAxisAlignment: MainAxisAlignment.center,
                                        children: [

                                          Text(

                                            "${details.lowest_bid}" ?? '0',
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                color: HexColor('4D8D6E'),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$',
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                color: HexColor('4D8D6E'),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )


                              ],
                            ),


                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text ('Description',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('454545'),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text (details.description,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: HexColor('706F6F'),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                children: [
                                  Text ('Workers Bids',
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                        color: HexColor('454545'),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Spacer(),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.sort), // Change this icon
                                    onSelected: (String value) {
                                      setState(() {
                                        if (value == 'lowestMoney') {
                                          sortLowestMoney();
                                        } else if (value == 'highestMoney') {
                                          sortHighestMoney();
                                        } else if (value == 'lowestRate') {
                                          sortLowestRate();
                                        } else if (value == 'highestRate') {
                                          sortHighestRate();
                                        }
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'lowestMoney',
                                          child: Text('Sort by Lowest Money'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'highestMoney',
                                          child: Text('Sort by Highest Money'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'lowestRate',
                                          child: Text('Sort by Lowest Rate'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'highestRate',
                                          child: Text('Sort by Highest Rate'),
                                        ),
                                      ];
                                    },
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(height: 17,),
                            FutureBuilder<List<ProjectBid>>(
                              future: futureProjects,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Center(child: Text('No Bids Yet'));
                                } else {
                                  // Update the items list
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),

                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    // Replace with the actual length of your data list
                                    itemBuilder: (context, index) {
                                      return buildListItem(snapshot.data![index]); // Pass the Item object to the buildListItem function
                                    },
                                  );
                                }
                              },
                            ),



                          ],
                        );
                      }}),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            decoration: BoxDecoration(
              color: Colors.white, // Adjust the color as needed

              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Adjust the color as needed
                  spreadRadius: 0.6, // Spread radius
                  blurRadius: 7, // Blur radius
                  offset: Offset(0,
                      -2), // Offset in the y direction to create a top shadow
                ),
              ],
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  height: 58,
                  width: double.infinity,
                  // Set the width to match the parent width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    // Adjust the radius as needed
                    color: HexColor('4D8D6E'), // Use the desired hex color
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(Placebid(projectId: widget.projectId,));
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      // Make the button transparent
                      elevation: MaterialStateProperty.all(0),
                      // Remove elevation
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Same radius as above
                        ),
                      ),
                    ),
                    child: Text(
                      'Place A Bid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                )),
          ),

        ],
      ),

    );
  }
  Widget buildListItem(ProjectBid item) {
    bool isMoneyLessOrEqual = double.parse(item.amount.toString()) <= double.parse(currentbid);

    // Check if Money is less than currentbid, and update currentbid if needed

    return          Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0 ,vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: item.workerProfilePic.isNotEmpty
                ? NetworkImage(item.workerProfilePic)
                : AssetImage('assets/images/profileimage.png')as ImageProvider,
          ),
          SizedBox(width: 12,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () { Get.to(ProfilePageWorker()); },
                    child:  Text(item.workerFirstName,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('9DA2A3'),
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Icon(Icons.star,color: HexColor('F3ED51'),size: 20,),
                  SizedBox(width: 2,),
                  Text('7'),

                ],
              ),
              SizedBox(height: 4,),
              Row(
                children: [
                  Text('\$',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('353B3B'),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 3,),
                  Text('${item.amount}',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('353B3B'),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),




            ],
          ),

          Spacer(),
          isMoneyLessOrEqual
              ? SvgPicture.asset(
            'assets/icons/arrowdown.svg',
            width: 39.0,
            height: 39.0,
          )
              : SvgPicture.asset(
            'assets/icons/arrowup.svg',
            width: 39.0,
            height: 39.0,
          ),
        ],
      ),

    );
  }
}
class Item {
  final String WorkerName;
  final String Money;
  final String rate;

  Item({
    required this.WorkerName,
    required this.Money,
    required this.rate,
  });
}
class ProjectDetails {
  final String clientFirstName;
  final String clientLastName;
  final String projectType;
  final String title;
  final String description;
  final String timeframeStart;
  final String timeframeEnd;
  final String imageUrl;
  final String postedFrom;
  final bool liked;
  final int numberOfLikes;
  final int lowest_bid; // Assuming lowestBid is an int

  ProjectDetails({
    required this.clientFirstName,
    required this.clientLastName,
    required this.projectType,
    int? lowest_bid, // Change the type to int?
    required this.title,
    required this.description,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.imageUrl,
    required this.postedFrom,
    required this.liked,
    required this.numberOfLikes,
  }): lowest_bid = lowest_bid ?? 0;
}



class ProjectBid {
  final String workerFirstName;
  final String workerProfilePic;
  final int amount;

  ProjectBid({
    required this.workerFirstName,
    required this.workerProfilePic,
    required this.amount,
  });
}

