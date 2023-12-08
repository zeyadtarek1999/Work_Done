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

  late Future<ProjectDetails> projectDetails;
  String clientFirstName ='';
  String? clientLastName;
  String ?projectType;
  String title = '';
  String ?description;
  String ?timeframeStart;
  String ?timeframeEnd;
  String ?imageUrl;
  String ?postedFrom;
  bool ?liked;
  int ?numberOfLikes;
  Future<void> fetchData() async {
    try {
      ProjectDetails details = await getProjectDetails(widget.projectId);

      // Now you can use details in your code
      print('Client First Name: ${details.clientFirstName}');
      print('Title: ${details.title}');
      print('Number of Likes: ${details.numberOfLikes}');
      print('Number of bids: ${details.bids.length}');
      details.bids.forEach((bids) {
        print('Worker: ${bids.workerFirstName}, Amount: ${bids.amount}');
      });

      // You can also use details to update your UI or perform other actions
      // For example, updating the state in a StatefulWidget
      setState(() {
        title=details.title;
        clientFirstName = details.clientFirstName;

      });
    } catch (e) {
      // Handle any errors that might occur during the API call
      print('Error fetching project details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    receive.addListener(updateTotal);
    projectDetails = getProjectDetails(widget.projectId);
    fetchData();

    // Set curren
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
String comment = commentController.text;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
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

  Future<ProjectDetails> getProjectDetails(int projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_project_details'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': projectId.toString(), // Convert to String if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (response.statusCode == 200) {
          // Parse the response into the ProjectDetails model
          ProjectDetails projectDetails = ProjectDetails(
            clientFirstName: responseBody['client_fname'],
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
            bids: (responseBody['bids'] as List<dynamic>).map((bid) {
              return Bid(
                workerFirstName: bid['worker_firstname'],
                workerProfilePic: bid['worker_profile_pic'],
                amount: bid['amount'],
              );
            }).toList(),
          );

          return projectDetails;
        } else {
          print (projectId);
          // Handle other error scenarios
          print('Error: of what ${responseBody['msg']}');
          throw Exception(responseBody['msg']);
        }
      } else {
        print (projectId);

        // Handle other status codes
        print('Failed to get project details. Status code: ${response.statusCode}');
        throw Exception('Failed to get project details');
      }
    } catch (e) {
      print (projectId);

      // Handle exception
      print('Error: $e');
      throw Exception('An error occurred');
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
            Column(
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
                            title,
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
                                    // Get.to(ProfilePageClient());
                                  },
                                  style: TextButton.styleFrom(
                                    fixedSize: Size(50, 30), // Adjust the size as needed
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    clientFirstName,
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
            )),
          ),
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
  final List<Bid> bids;

  ProjectDetails({
    required this.clientFirstName,
    required this.clientLastName,
    required this.projectType,
    required this.title,
    required this.description,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.imageUrl,
    required this.postedFrom,
    required this.liked,
    required this.numberOfLikes,
    required this.bids,
  });
}

class Bid {
  final String workerFirstName;
  final String workerProfilePic;
  final int amount;

  Bid({
    required this.workerFirstName,
    required this.workerProfilePic,
    required this.amount,
  });
}
