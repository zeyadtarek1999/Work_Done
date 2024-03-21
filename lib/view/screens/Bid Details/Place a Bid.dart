import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/screens/Payment%20Method/Payment_method.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Bid details Worker.dart';

class Placebid extends StatefulWidget {
  final int projectId;
  final String clientid;

  Placebid({required this.projectId,required this.clientid   });
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

  Future<ProjectData> fetchProjectDetails(int projectId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final response = await http.post(
      Uri.parse('https://www.workdonecorp.com/api/get_project_details'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({
        'project_id': projectId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Checking if the response body contains 'status' and if it's equal to 'success'.
      if (responseData != null && responseData['status'] == 'success') {
        // Ensure that 'base_data' exists before trying to create a ProjectData object.
        if (responseData.containsKey('base_data')) {
          return ProjectData.fromJson(responseData);
        } else {
          throw Exception('base_data is missing from the response.');
        }
      } else {
        // This else block catches cases where 'status' isn't 'success'.
        final message = responseData != null ? responseData['message'] : 'Unknown error';
        throw Exception('Failed to load project details from API: $message');
      }
    } else {
      // The statusCode is not 200, handle the error here.
      final message = response.body.isNotEmpty ? json.decode(response.body)['message'] : 'No error message provided';
      throw Exception('Failed to load project details. Status code: ${response.statusCode}, Message: $message');
    }
  }
  String paypalvalidation ='';
  void checkPayPalValidation() {
    // Replace the condition with your actual check
    if (paypalvalidation == 'no paypal Email') {
      // Show the PayPal pop-up
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing the pop-up by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Paypal Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You need to set up your PayPal email.'),
                SizedBox(height: 8,),
                ElevatedButton(
                  onPressed: () {
                    // Add your logic to handle setting up PayPal here
Get.to(paymentmethod());
                  },
                  style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFF4D8D6E), // Use the specified color (replace 0xFF4D8D6E with your color)
                  ),
                  child: Text(
                    'Set up PayPal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),

          );
        },
      );
    }
  }

  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/check_paypal_account';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },

        );

        if (response.statusCode == 200) {
          Map<dynamic, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            String profileData = responseData['data'];


            setState(() {
              paypalvalidation = profileData;
              checkPayPalValidation();

            });

            print('Response: $profileData');
            print('paypalvalidation : $paypalvalidation');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to paypalvalidation');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load paypalvalidation');
        }
      }
    } catch (error) {
      // Handle errors
      print('Error getting paypalvalidation: $error');
    }
  }

  final ScreenshotController screenshotController10 = ScreenshotController();

  @override
  void initState() {
    super.initState();
    receive.addListener(updateTotal);
    _getUserProfile();
    int projectId =widget.projectId;
    projectDetailsFuture = fetchProjectDetails(projectId); // Use the projectId in the call
    projectDetailsFuture = fetchProjectDetails(projectId);
  }

  void updateTotal() {
    double value1 = double.tryParse(receive.text) ?? 0.0;
    double value2 = 0.0; // You can change this value as needed
    setState(() {
      total = value1 + value2;
    });
  }
  @override
  void dispose() {
    receive.dispose();
    super.dispose();
  }
bool _isLoading =false;
  Future<void> insertBid() async {
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://www.workdonecorp.com/api/insert_bid');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      // Prepare the request body
      String commentText = commentController.text.isEmpty ? 'No comment' : commentController.text;

      // Make the API request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $userToken', // Replace with your actual token
        },
        body: {
          'project_id': widget.projectId.toString(),
          'amount': total.toString(),
          'comment': commentText ?? 'no comment',
        },
      );

      // Hide the loading indicator
      setState(() {
        _isLoading = false;
      });

      // Check the response status
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);

        // Check the status in the response
        if (responseBody['status'] == 'success') {
          DateTime currentTime = DateTime.now();
print('first ${widget.clientid}');
print('second ${client_id}');

          // Format the current time into your desired format
          String formattedTime = DateFormat('h:mm a').format(currentTime);
          Map<String, dynamic> newNotification = {
            'title': 'Bid Placed on Your Project 💰',
            'body': 'A worker has placed a bid (${total}) on your project (${projecttitle}). Review the bid details and take action!🔴',
            'time': formattedTime,
            'id' :widget.projectId,
            'type': 'projectclient'

          };
          print('sended notification ${[newNotification]}');


          SaveNotificationToFirebase.saveNotificationsToFirestore(client_id.toString(), [newNotification]);
          print('getting notification');

          // Get the user document reference
          // Get the user document reference
          // Get the user document reference
          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(client_id.toString());

// Get the user document
          DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
          if (doc.exists) {
            // Extract the FCM token and notifications list from the document
            String? receiverToken = doc.get('fcmToken');
            List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

            // Check if the new notification is not null and not already in the list
            if (newNotification != null && !notifications.any((notification) => notification['id'] == newNotification['id'])) {
              // Add the new notification to the beginning of the list
              notifications.insert(0, newNotification);

              // Update the user document with the new notifications list
              await userDocRef.update({
                'notifications': notifications,
              });

              print('Notifications saved for user ${widget.clientid}');
            }

            // Display the notifications list in the app
            print('Notifications for user ${widget.clientid}:');
            for (var notification in notifications) {
              String? title = notification['title'];
              String? body = notification['body'];
              print('Title: $title, Body: $body');
              await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
              print('Last notification sent to ${widget.clientid}');
            }
          } else {
            print('User document not found for user ${widget.clientid}');
          }


          Fluttertoast.showToast(
            msg: 'Bid inserted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.off(bidDetailsWorker(projectId: widget.projectId),
              transition: Transition.fadeIn, // You can choose a different transition
              duration: Duration(milliseconds: 700), // Set the duration of the transition
    );
        } else if (responseBody['status'] == 'success') {
          // Check the specific error message
          String errorMsg = responseBody['msg'];

          if (errorMsg == ' Bid Submitted') {
            // Show a Snackbar with the error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
              ),
            );
            Get.offAll(bidDetailsWorker(projectId: widget.projectId),
    transition: Transition.fadeIn, // You can choose a different transition
    duration: Duration(milliseconds: 700), // Set the duration of the transition
    );

          } else {
            // Handle other error cases as needed
            print('Error: $errorMsg');
          }
        }
      } else {
        print(widget.projectId.toString());
        print(widget.projectId.toString());
        print(total.toString());
        print(commentController.text);
        print(userToken);
        print('Failed to insert bid. Status code: ${response.statusCode}');

        // Show a toast message for the error
        Fluttertoast.showToast(
          msg: 'Failed to insert bid. Status code: ${response.statusCode}',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

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

      // Show a toast message for the error
      Fluttertoast.showToast(
        msg: 'Error inserting bid: $e',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // Handle errors as needed
    }
  }

  final _formKey = GlobalKey<FormState>();

  String unique= 'placebid' ;
  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController10.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold( floatingActionButton:
    FloatingActionButton(    heroTag: 'workdone_${unique}',



      onPressed: () {
        _navigateToNextPage(context);

      },
      backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
      child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
      shape: CircleBorder(), // Make the button circular
    ),

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
      body:
      Screenshot(
        controller:screenshotController10 ,
        child:Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width > 600 ? 40 : 20,
                  horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 20,
                ),
                child: Container(
                width: double.infinity,
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

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Animate(
                          effects: [ScaleEffect(duration: Duration(milliseconds: 500),),],
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                  SizedBox(width: 4,),
                                  Container(
                                    height: 30,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Get.to(ProfilePageClient(userId: projectData.clientData!.clientId.toString()),
                                          transition: Transition.fadeIn, // You can choose a different transition
                                          duration: Duration(milliseconds: 700), // Set the duration of the transition
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        // fixedSize: Size(50, 30), // Adjust the size as needed
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        projectData.clientData!.firstname,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          decoration: TextDecoration.underline,
                                          ),
                                          ),
                                    ),
                                    )
                                    ],
                                    ),
                                        ],
                                        ),
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
                              validator: (value) {
                                // Validate the entered value
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                // Add additional validation as needed

                                // If the validation passes, return null
                                return null;
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

                SizedBox(height: 3,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('(What you will recieve) ',style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),),
                          ],
                        ),
                      ),



                    ],
                  ),
              );}}),
              ),),
          SizedBox(height: 10,),
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
SizedBox(width: 6,),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline, // "i" icon
                          color: Colors.grey,
                          size: 22, // Red color
                        ),
                        onPressed: () {
                          Fluttertoast.showToast(
                            msg: 'Comment is Required',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25.0),
                  child: Container(
                    height: 150,
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
                          hintText:
'Please write your comment to the client. This should include materials you plan to use, etc..',                          border: InputBorder.none,
                          hintMaxLines: 5, // Allows the hint text to take up multiple lines
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),

                        ),
                        validator: (value) {
                          // Validate the entered value
                          if (value == null || value.isEmpty) {
                            return 'Please write a comment';
                          }
                          // Add additional validation as needed

                          // If the validation passes, return null
                          return null;
                        },
                      ),
                    ),
                  ),
                )
                ,
                Padding(
                  padding: const EdgeInsets.only(top: 120, left: 25, right: 25),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: HexColor('4D8D6E'),))  // Show CircularProgressIndicator if isLoading is true
                      : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: HexColor('4D8D6E'),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await insertBid();
                          setState(() {
                            _isLoading = false;
                          });
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please Enter a bid value.",
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        child: Center(
                          child: Text(
                            'Add Bid',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
SizedBox(height: 12,),
              ]),
          ),
        ),
      ),


    );
  }
}
class ProjectData {
  final String title;
  final List<String> images; // Images is now a List<String>
  final String projectType;
  final String postedFrom;
  final String status;
  final String desc;
  final bool liked; // Assuming the 'liked' field should be a boolean
  final int numberOfLikes;
  final dynamic? lowestBid; // Assuming lowest bid could be null
  final String timeframeStart;
  final String timeframeEnd;
  final List<Bid> bids;
  final ClientData clientData;
  final PageContent pageContent;
  final page_access_data pageaccessdata;
  final select_worker_bid selectworkerbid;

  ProjectData({
    required this.title,
    required this.images,
    required this.projectType,
    required this.status,
    required this.postedFrom,
    required this.desc,
    required this.selectworkerbid,
    required this.liked,
    required this.clientData,
    required this.numberOfLikes,
    required this.pageaccessdata,
    this.lowestBid,
    required this.pageContent,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.bids,
  });

  factory ProjectData.fromJson(Map<String, dynamic> jsonData) {

    var baseData = jsonData['base_data'] as Map<String, dynamic>? ?? {};
    var clientInfo = baseData['client_info'] as Map<String, dynamic>? ?? {};
    var pageContent = jsonData['page_content'] as Map<String, dynamic>? ?? {};
    var pageAccessData = jsonData['page_access_data'] as Map<String, dynamic>? ?? {};
    var selectWorkerBid = jsonData['select_worker_bid'] as Map<String, dynamic>? ?? {};

    return ProjectData(
      title: baseData['title'] ?? 'No Title',
      images: List<String>.from(baseData['images'] ?? []),
      projectType: baseData['project_type'] ?? 'No Project Type',
      postedFrom: baseData['posted_from'] ?? 'No Post Date',
      status: baseData['status'] ?? 'No Status',
      desc: baseData['desc'] ?? 'No Description',
      liked: baseData['liked'] == 'true',
      numberOfLikes: baseData['number_of_likes'] ?? 0,
      lowestBid: baseData['lowest_bid'] ?? 'No Bids',
      timeframeStart: baseData['timeframe_start'] ?? 'No Start Time',
      timeframeEnd: baseData['timeframe_end'] ?? 'No End Time',
      bids: (baseData['bids'] as List<dynamic>? ?? []).map((x) => Bid.fromJson(x as Map<String, dynamic>)).toList(),
      clientData: ClientData.fromJson(clientInfo),
      pageContent: PageContent.fromJson(pageContent),
      pageaccessdata: page_access_data.fromJson(pageAccessData),
      selectworkerbid: select_worker_bid.fromJson(selectWorkerBid),
    );
  }}

class ClientData {
  final int clientId;
  final String firstname;
  final String lastname;
  final String profileImage;

  ClientData({
    required this.clientId,
    required this.firstname,
    required this.lastname,
    required this.profileImage,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['client_id'] as int? ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      profileImage: json['profle_image'] ?? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png', // corrected typo from 'profle_image' to 'profile_image'
    );
  }
}
class PageContent {
  final String currentUserRole;
  final String buttons;
  final String selectedDate;
  final String selectedInterval;
  final String scheduleStatus;
  final String change;
  final String chat;
  final String schedule_vc_generate_button;
  final String complete_vc_generate_button;
  final String project_complete_button;
  final String support;



  PageContent({required this.currentUserRole
    , required this.buttons
    , required this.selectedDate
    , required this.selectedInterval
    , required this.scheduleStatus
    , required this.change
    , required this.chat
    , required this.schedule_vc_generate_button
    , required this.complete_vc_generate_button
    , required this.project_complete_button
    , required this.support



  });

  factory PageContent.fromJson(Map<String, dynamic> json) {
    return PageContent(
      currentUserRole: json['current_user_role']?? '',
      buttons: json['buttons']?? '',
      selectedDate: json['selected_date'] ?? '',
      selectedInterval: json['selected_interval'] ?? '',
      scheduleStatus: json['schedule_status'] ?? '',
      change: json['change'] ?? '',
      chat: json['chat'] ?? '',
      schedule_vc_generate_button: json['schedule_vc_generate_button'] ?? '',
      complete_vc_generate_button: json['complete_vc_generate_button'] ?? '',
      project_complete_button: json['project_complete_button'] ?? '',
      support: json['support'] ?? '',
    );

  }
}
class page_access_data {
  final String chat_ID;
  final dynamic schedule_vc;
  final dynamic complete_vc;

  page_access_data({required this.chat_ID
    ,required this.schedule_vc
    ,required this.complete_vc

  });

  factory page_access_data.fromJson(Map<String, dynamic> json) {
    return page_access_data(
      chat_ID: json['chat_ID']?? '',
      schedule_vc: json['schedule_vc']?? '',
      complete_vc: json['complete_vc']?? '',
    );
  }
}
class select_worker_bid {
  final int worker_id;
  final String worker_firstname;
  final String worker_profile_pic;
  final dynamic amount;
  final String comment;

  select_worker_bid({required this.worker_id
    ,required this.worker_firstname
    ,required this.worker_profile_pic
    ,required this.amount
    ,required this.comment

  });

  factory select_worker_bid.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return select_worker_bid(
        worker_id: 0,
        worker_firstname: '',
        worker_profile_pic: '',
        amount: 0,
        comment: '',
      );
    }

    return select_worker_bid(worker_id: json['worker_id'] ?? 0,
        worker_firstname: json['worker_firstname']?? ''
        ,worker_profile_pic: json['worker_profile_pic']?? '',
        amount: json['amount']?? 0
        , comment: json['comment']?? '');
  }
}

class Bid {
  final int workerId;
  final String workerFirstname;
  final String workerProfilePic;
  final dynamic amount;
  final String comment;
  final ClientData clientData;
  final PageContent pageContent;

  Bid({
    required this.workerId,
    required this.clientData,
    required this.pageContent,
    required this.workerFirstname,
    required this.workerProfilePic,
    required this.amount,
    required this.comment,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    var pageContent = json['page_content'] as Map<String, dynamic>? ?? {};

    return Bid(
      workerId: json['worker_id'] as int? ?? 0,
      workerFirstname: json['worker_firstname'] ?? '',
      workerProfilePic: json['worker_profile_pic'] ?? 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      comment: json['comment'] ?? '',
      clientData: ClientData.fromJson(json['client_info'] as Map<String, dynamic>? ?? {}),
      pageContent: PageContent.fromJson(pageContent),
    );
  }}

