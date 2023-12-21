import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';

import '../InboxwithChat/ChatClient.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../check out client/checkout.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

import '../view profile screens/Worker profile view.dart';
import 'Place a Bid.dart';

class bidDetailsWorker extends StatefulWidget {
  final int projectId;

  bidDetailsWorker({required this.projectId});

  @override
  State<bidDetailsWorker> createState() => _bidDetailsWorkerState();
}

class _bidDetailsWorkerState extends State<bidDetailsWorker> {
  late Future<ProjectData> projectDetailsFuture;
  String client_id = '';
  String worker_id = '';
  String projectimage = '';
  String projecttitle = '';
  String projectdesc = '';
  String selected_worker = '';
  String final_bid = '';
  final ScreenshotController screenshotController = ScreenshotController();

  Future<ProjectData> fetchProjectDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_project_details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'project_id': widget.projectId.toString(),
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      print(widget.projectId);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? projectDataJson = responseData['data'];
        final Map<String, dynamic>? clientDataJson =
            responseData['client_data'];
        final Map<String, dynamic>? accessDataJson = responseData['access'];

        if (projectDataJson != null &&
            clientDataJson != null &&
            accessDataJson != null) {
          return ProjectData.fromJson(
              projectDataJson, clientDataJson, accessDataJson);
        } else {
          throw Exception(
              'No project data or client data available in the response');
        }
      } else {
        throw Exception(
            'Failed to load project details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching project details: $error');
      throw error; // rethrow the error to notify the caller
    }
  }

  @override
  void initState() {
    super.initState();
    projectDetailsFuture = fetchProjectDetails();
    fetchProjectDetails();
  }

  String currentbid = '24';


  String unique= 'biddetailsworker' ;
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
      statusBarColor: HexColor('FFFFFF'),
      // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
    ));

    return Scaffold( floatingActionButton:
    FloatingActionButton(    heroTag: 'workdone_${unique}',



      onPressed: () {
        _navigateToNextPage(context);

      },
      backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
      child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
      shape: CircleBorder(), // Make the button circular
    ),

      backgroundColor: HexColor('FFFFFF'),
      appBar: AppBar(
        backgroundColor: HexColor('FFFFFF'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        toolbarHeight: 67,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_sharp),
          color: Colors.black,
        ),
        title: Text(
          'Bid Details',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('454545'),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body:

      Screenshot(
        controller:screenshotController ,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: FutureBuilder<ProjectData>(
                    future: projectDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data available'));
                      } else {
                        ProjectData projectData = snapshot.data!;
                        currentbid = projectData.lowest_bid.toString();
                        client_id = projectData.clientData!.clientId.toString();
                        projectimage = projectData.images.toString();
                        projecttitle = projectData.title.toString();
                        projectdesc = projectData.desc.toString();
                        selected_worker =
                            projectData.access!.selected_worker.toString();
                        final_bid = projectData.access!.final_bid.toString();
                        print(projectData.access!.selected_worker);
                        print(projectData.access!.projectStatus);
                        print("the selected worker${selected_worker}");
        
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 210.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      projectData.images != null
                                          ? projectData.images
                                          : 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                                    ),
                                    // Replace with your image URL
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: HexColor('4D8D6E'),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${projectData.project_type}',
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                            color: HexColor('FFFFFF'),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: HexColor('777778'),
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${projectData.posted_from}',
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
                              SizedBox(
                                height: 12,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Text(
                                  projectData.title,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: HexColor('454545'),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 23,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      projectData.clientData?.profileImage ==
                                              'https://workdonecorp.com/images/'
                                          ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                                          : projectData
                                                  .clientData?.profileImage ??
                                              'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 13,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 70,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Get.to(ProfilePageClient(
                                            userId: projectData
                                                .clientData!.clientId
                                                .toString()));
                                      },
                                      style: TextButton.styleFrom(
                                        fixedSize: Size(50, 30),
                                        // Adjust the size as needed
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        projectData.clientData!.firstname,
                                        //client first name
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
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: HexColor('FFFFFF'),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          // Color of the shadow
                                          spreadRadius: 2,
                                          // Spread radius
                                          blurRadius: 3,
                                          // Blur radius
                                          offset: Offset(0,
                                              2), // Offset in the x and y direction
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
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
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
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text(
                                              '${projectData.lowest_bid?.toString() ?? "No Bid"}',
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Text(
                                  'Description',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: HexColor('454545'),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  projectData.desc,
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
                              SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Workers Bids',
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          color: HexColor('454545'),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 17,
                              ),
                              FutureBuilder<ProjectData>(
                                future: fetchProjectDetails(),
                                // Use the function without awaiting it
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData) {
                                    return Center(
                                      child: Text(
                                        'No data available',
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: HexColor('454545'),
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ProjectData projectData = snapshot.data!;
        
                                    if (projectData.access!.project_status ==
                                            'bid_accepted' &&
                                        projectData.access!.selected_worker ==
                                            'true') {
                                      // Render a row with buttons
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Handle the action for the "End" button
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                                // Background color
                                                onPrimary: Colors.white,
                                                // Text color
                                                elevation: 8,
                                                // Elevation
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Rounded corners
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text('End'),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Get.to(ChatScreen(
                                                    chatId: projectData
                                                        .access!.chat_ID,
                                                    currentUser: 'worker',
                                                    secondUserName: projectData
                                                        .clientData!.firstname,
                                                    userId: projectData
                                                        .clientData!.clientId.toString(),
                                                  ));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.blue,
                                                  // Background color
                                                  onPrimary: Colors.white,
                                                  // Text color
                                                  elevation: 8,
                                                  // Elevation
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Rounded corners
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(12.0),
                                                  child: Text('Chat'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (projectData.bids.isNotEmpty) {
                                      // Render a ListView with bids
                                      return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: projectData.bids.length,
                                        itemBuilder: (context, index) {
                                          Bid bid = projectData.bids[index];
                                          return buildListItem(bid);
                                        },
                                      );
                                    } else {
                                      // Render a message when there are no bids
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14.0),
                                        child: Center(child: Text('No bids yet')),
                                      );
                                    }
                                  }
                                },
                              )
                            ]);
                      }
                    }),
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
                          Get.to(Placebid(
                            projectId: widget.projectId,
                          ));
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          // Make the button transparent
                          elevation: MaterialStateProperty.all(0),
                          // Remove elevation
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
        ),
      ),
    );
  }

  Widget buildListItem(Bid item) {
    bool isMoneyLessOrEqual =
        double.parse(item.amount.toString()) <= double.parse(currentbid);

    // Check if Money is less than currentbid, and update currentbid if needed

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(item.workerProfilePic == ''
                ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                : item.workerProfilePic),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to worker profile page
                      // You can replace this with your navigation logic
                      Get.to(
                          ProfilePageClient(userId: item.workerId.toString()));
                    },
                    child: Text(
                      item.workerFirstname.length > 7
                          ? '${item.workerFirstname.substring(0, 3)}...' // Display first 14 letters with ellipsis
                          : item.workerFirstname,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('9DA2A3'),
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.star,
                    color: HexColor('F3ED51'),
                    size: 20,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text('7'),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Text(
                    '\$',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('353B3B'),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    '${item.amount}',
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

// class ProjectDetailsResponse {
//   String status;
//   String msg;
//   Access access;
//   ClientData clientData;
//   ProjectData data;
//
//   ProjectDetailsResponse({
//     required this.status,
//     required this.msg,
//     required this.access,
//     required this.clientData,
//     required this.data,
//   });

//   factory ProjectDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return ProjectDetailsResponse(
//       status: json['status'],
//       msg: json['msg'],
//       access: Access.fromJson(json['access']),
//       clientData: ClientData.fromJson(json['client_data']),
//       data: ProjectData.fromJson(projectPost['data']),
//     );
//   }
// }

class Access {
  int user;
  int final_bid;
  String selected_worker;
  String chat_ID;
  String project_status;
  String projectStatus;

  Access({
    required this.user,
    required this.project_status,
    required this.chat_ID,
    required this.selected_worker,
    required this.projectStatus,
    required this.final_bid,
  });

  factory Access.fromJson(Map<String, dynamic> json) {
    return Access(
      user: json['user'],
      chat_ID: json['chat_ID'] ?? '0',
      selected_worker: json['selected_worker'].toString(),
      projectStatus: json['project_status'],
      project_status: json['project_status'],
      final_bid: json['final_bid'],
    );
  }
}

class ClientData {
  int clientId;
  String firstname;
  String lastname;
  String profileImage;

  ClientData({
    required this.clientId,
    required this.firstname,
    required this.lastname,
    required this.profileImage,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['client_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      profileImage: json['profle_image'] ??
          'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
    );
  }
}

class ProjectData {
  final String title;
  final String images;
  final String project_type;
  final String posted_from;
  final String desc;
  final String liked;
  final int number_of_likes;
  final dynamic lowest_bid;
  final String timeframeStart;
  final String timeframeEnd;
  final List<Bid> bids;
  final ClientData? clientData;
  final Access? access;

  // Include the client data

  ProjectData({
    required this.title,
    required this.images,
    required this.project_type,
    required this.access,
    required this.posted_from,
    required this.liked,
    required this.clientData,
    required this.number_of_likes,
    required this.lowest_bid,
    required this.desc,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.bids,
  });

  factory ProjectData.fromJson(
    Map<String, dynamic> projectDataJson,
    Map<String, dynamic> clientDataJson,
    Map<String, dynamic> accessDataJson,
  ) {
    List<Bid> bids = [];
    if (projectDataJson['bids'] != null) {
      bids = List<Bid>.from(projectDataJson['bids']
          .map((bid) => Bid.fromJson(bid, accessDataJson)));
    }

    return ProjectData(
      title: projectDataJson['title'] ?? '',
      desc: projectDataJson['desc'] ?? '',
      timeframeStart: projectDataJson['timeframe_start'] ?? '',
      timeframeEnd: projectDataJson['timeframe_end'] ?? '',
      bids: bids,
      images: projectDataJson['images'] ??
          'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
      project_type: projectDataJson['project_type'] ?? '',
      posted_from: projectDataJson['posted_from'] ?? '',
      liked: projectDataJson['liked'] ?? '',
      number_of_likes: projectDataJson['number_of_likes'] ?? 0,
      lowest_bid: projectDataJson['lowest_bid'],
      clientData: ClientData.fromJson(clientDataJson),
      access: Access.fromJson(accessDataJson),
    );
  }
}

class Bid {
  final int workerId;
  final String workerFirstname;
  final String workerProfilePic;
  final int amount;
  final String comment;
  final Access? access;

  Bid({
    required this.workerId,
    required this.workerFirstname,
    required this.workerProfilePic,
    required this.amount,
    required this.access,
    required this.comment,
  });

  factory Bid.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> accessDataJson,
  ) {
    return Bid(
        workerId: json['worker_id'],
        workerFirstname: json['worker_firstname'],
        workerProfilePic: json['worker_profile_pic'] ??
            'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
        amount: json['amount'],
        comment: json['comment'],
        access: Access.fromJson(accessDataJson));
  }
}
