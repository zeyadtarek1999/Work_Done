import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import '../view profile screens/Client profile view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Bid details Worker.dart';

class Placebid extends StatefulWidget {
  final int projectId;

  Placebid({required this.projectId});
  @override
  State<Placebid> createState() => _PlacebidState();
}

class _PlacebidState extends State<Placebid> {
  TextEditingController receive = TextEditingController();
double total =0;
  void calculateAndSave() {
    // Get the value from the controller
    double originalValue = double.tryParse(receive.text) ?? 0.0;

    // Calculate 10% of the original value
    double tenPercent = 0.10 * originalValue;

    // Add 10% to the original value
    double result = originalValue + tenPercent;

    // Save the result in the controller or a variable
    total = result;
  }
  TextEditingController calculate = TextEditingController();
  final commentController = TextEditingController();
  late Future<ProjectData> projectDetailsFuture;

  String client_id = '';
  String worker_id = '';
  String projectimage = '';
  String projecttitle = '';
  String projectdesc = '';
  String owner = '';

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
    receive.addListener(updateTotal);
    fetchProjectDetails();
    projectDetailsFuture = fetchProjectDetails();
  }

  void updateTotal() {
    double value1 = double.tryParse(receive.text) ?? 0.0;
    double value2 = 10.0; // You can change this value as needed
    setState(() {
      total = value1 + value2;
    });
  }
  @override
  void dispose() {
    receive.dispose();
    super.dispose();
  }

  Future<void> insertBid() async {
    final url = Uri.parse('https://workdonecorp.com/api/insert_bid');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print (userToken);
      // Prepare the request body


      // Make the API request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken', // Replace with your actual token
        },
        body: {
          'project_id': widget.projectId.toString(),
          'amount': total.toString(),
          'comment': commentController.text,

        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        // Check the status in the response
        if (responseBody['status'] == 'success') {
          print('Bid inserted successfully');
          Get.off(bidDetailsWorker(projectId: widget.projectId));
        } else if (responseBody['status'] == 'error') {
          // Check the specific error message
          String errorMsg = responseBody['msg'];

          if (errorMsg == 'Already Submited Before') {
            // Show a Snackbar with the error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
              ),
            );
            Get.off(bidDetailsWorker(projectId: widget.projectId));

          } else {
            // Handle other error cases as needed
            print('Error: $errorMsg');
          }
        }
      }
    else {
        print(widget.projectId.toString());
        print(widget.projectId.toString());
        print(total.toString());
        print(commentController.text);
        print(userToken);
        print('Failed to insert bid. Status code: ${response.statusCode}');

        // Print the response body for more details
        print('Response body: ${response.body}');

      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print(widget.projectId.toString());
      print(total.toString());
      print(commentController.text);
      print(userToken);
      print('Error inserting bid: $e');
      // Handle errors as needed
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Place A Bid',style: GoogleFonts.roboto(
          textStyle: TextStyle(
            color: HexColor('454545'),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),),
        centerTitle: true,
        leading: IconButton(onPressed: (){Get.back();},icon: Icon(Icons.arrow_back_sharp ,color: Colors.black,size: 24,),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

          Padding(
            padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
            child: Container(
            width: double.infinity,
            height: 260, // Set the height as needed
            decoration: BoxDecoration(
              color: HexColor('4D8D6E'), // Color
              borderRadius: BorderRadius.circular(30.0), // Circular radius
            ),child:
    FutureBuilder<ProjectData>(
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
    client_id = projectData.clientData!.clientId.toString();
    projectimage = projectData.images.toString();
    projecttitle = projectData.title.toString();
    projectdesc = projectData.desc.toString();
    owner = projectData.access!.owner.toString();

    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You are about to place a bid for ',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('FFFFFF'),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            projecttitle,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('FFFFFF'),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Row(
                            children: [
                              Text(
                                'by',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('FFFFFF'),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 50,
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(ProfilePageClient(userId: projectData.clientData!.clientId.toString()));
                                  },
                                  style: TextButton.styleFrom(
                                    fixedSize: Size(50, 30), // Adjust the size as needed
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    projectData.clientData!.firstname,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      ),
                                      ),
    ),
    )
    ],
    ),
    ],
    ),
    ],
    ),
    ),


    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
                  child: Text('Enter your bid',style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('FFFFFF'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ),
                SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // White background color
                      borderRadius: BorderRadius.circular(12.0), // Circular radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
                      child: TextFormField(
                        controller: receive,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Call the calculateAndSave function when the text field changes
                          calculateAndSave();
                        },
                        decoration: InputDecoration(

                          hintText: 'Enter a value', // Hint text
                          hintStyle: TextStyle(color: Colors.grey), // Hint text color
                          suffixIcon: Icon(Icons.attach_money), // Suffix icon (Dollar sign)
                          border: InputBorder.none, // Remove underline
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 8),
                  child: Row(
                    children: [

                      Text('Service fee ',style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('FFFFFF'),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ),
                      Container(
                        width: 20, // Set the desired width
                        height: 30, // Set the desired height
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Make the container circular
                          color: HexColor('4D8D6E'), // Set the background color
                        ),
                        child: IconButton(
                          iconSize: 17, // Set the desired icon size
                          icon: Icon(Icons.info_outline, color: Colors.white), // Use the 'info' icon
                          onPressed: () {
                            // Show the dialog when the icon is pressed
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Information'),
                                  content: Text('information.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: HexColor('4D8D6E'), // Set the 'Close' button color
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
,
                      Spacer(),
                  Text('10',style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('FFFFFF'),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                    Icon(Icons.percent,size: 17,color: Colors.white,),

                    ],

                  ),
                )
,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [

                      Text('Total ',style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('FFFFFF'),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ),
                      Spacer(),
                      Text(
                        '${total}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('FFFFFF'),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Icon(Icons.attach_money,size: 17,color: Colors.white,),

                    ],

                  ),
                ),





              ],
            );}}),
          ),),
      SizedBox(height: 10,),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('(What you will recieve) ',style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: HexColor('9A9D9C'),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),),
          ],
        ),
      ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Row(
                children: [
                  Text('Comment', style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),

                  ),

                ],
              ),
            ),
            SizedBox(height: 8,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0),
              child: Container(
                height: 100,
                width: double.infinity, // Set the desired width
                decoration: BoxDecoration(
                  color: Colors.grey [100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0,),
                  child: TextFormField(controller: commentController,
                    maxLines: null, // Allows the text to take up multiple lines
                    decoration: InputDecoration(
                      hintText: 'Please write a Comment (Optional)',
                      border: InputBorder.none,
                      hintMaxLines: 3, // Allows the hint text to take up multiple lines
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            )
            ,
            Padding(
              padding: const EdgeInsets.only(top: 150,left: 25,right: 25),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor('4D8D6E'),
                  borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                ),
                child: InkWell(
                  onTap: () {
                    insertBid(
                    );

                    // Handle button tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Add Bid',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )

          ]),
      ),


    );
  }
}
class Access {
  int user;
  String owner;
  String chat_ID;
  String project_status;
  String projectStatus;

  Access({
    required this.user,
    required this.project_status,
    required this.chat_ID,
    required this.owner,
    required this.projectStatus,
  });

  factory Access.fromJson(Map<String, dynamic> json) {
    return Access(
      user: json['user'],
      chat_ID: json['chat_ID'] ?? '0',
      owner: json['owner'].toString(),
      projectStatus: json['project_status'], project_status: json['project_status'],
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


