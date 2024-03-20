import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:action_slider/action_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';

import '../InboxwithChat/chatbody.dart';
import '../Support Screen/Support.dart';
import 'package:http/http.dart' as http;

import 'Bid details Client.dart';

class completeprojectscreen extends StatefulWidget {
  final int projectId;
  final String selectedworkerid;
  final String projecttitle;

  completeprojectscreen({required this.projectId,required this.selectedworkerid,required this.projecttitle});
  @override
  State<completeprojectscreen> createState() => _completeprojectscreenState();
}

class _completeprojectscreenState extends State<completeprojectscreen> with SingleTickerProviderStateMixin {
  final ScreenshotController screenshotController10 = ScreenshotController();
  String unique = 'completeproject';
  late Future<ProjectData> projectDetailsFuture;
  List<File> _imageFiles = []; // Use File directly
  String rating = '';
  late AnimationController ciruclaranimation;

  Future<void> _pickImages({bool isCamera = false}) async {
    final ImagePicker picker = ImagePicker();

    if (isCamera) {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (_imageFiles != null && _imageFiles.isNotEmpty) {
            _imageFiles.add(File(image.path));
          } else {
            _imageFiles = [File(image.path)];
          }
        });
      }
    } else {
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _imageFiles!.addAll(images.map((xfile) => File(xfile!.path)));
        });
      }
    }
  }
  bool _isUploading = false;
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

  void _toggleUploadingState(bool isUploading) {
    setState(() => _isUploading = isUploading);
  }

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController10.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupportScreen(screenshotImageBytes: imageBytes, unique: unique),
      ),
    );
  }
  final reviewcontroller = TextEditingController();
  String selectedworkername = '';
  String selectedworkerimage = '';

  bool isLoading = false;




  Future<void> completeproject() async {
    print('Fetching user token from SharedPreferences...');


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? '';

    print('Creating request...');
    // Define headers in a map
    final headers = <String, String>{
      'Authorization': 'Bearer $userToken',
      // 'Content-Type': 'multipart/form-data', This is added automatically when adding files to the MultipartRequest.
    };

    var request = http.MultipartRequest('POST', Uri.parse('https://www.workdonecorp.com/api/complete_project'))
      ..headers.addAll(headers)
      ..fields['project_id'] = widget.projectId.toString()
      ..fields['review'] = reviewcontroller.text
      ..fields['rating'] = rating.toString();


    print('Checking for files...');
    // Check if any files are null or empty before proceeding
    if ((_imageFiles?.isEmpty ?? true) ) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please pick at least one image and a video.")));
      return;
    }else{     setState(() {
      _toggleUploadingState(false);
    }); // Start loading
    }

    // Add video if not null


    // Add images if any
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      print('Adding images to the request...');
      for (var imageFile in _imageFiles!) {
        request.files.add(http.MultipartFile(
          'images[]',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageFile.path,
        ));
      }
    }
    print('Request fields: ${request.fields}');
    print('Request files: ${request.files.length}');
    print('Sending request...');
    try {
      setState(() {
        isLoading = true;
      });

      _toggleUploadingState(true); // Start loading

      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      var streamedResponse = await request.send();

      print('Request sent. Status code: ${streamedResponse.statusCode}');
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        DateTime currentTime = DateTime.now();

        // Format the current time into your desired format
        String formattedTime = DateFormat('h:mm a').format(currentTime);
        Map<String, dynamic> newNotification = {
          'title': 'Project Ended',
          'body': 'The client has ended the project (${widget.projecttitle}) and left a review for you🌟 -Now you can review you Client😉',
          'time': formattedTime,
          // Add other notification data as needed
        };
        print('sended notification ${[newNotification]}');


        SaveNotificationToFirebase.saveNotificationsToFirestore(widget.selectedworkerid.toString(), [newNotification]);
        print('getting notification');

        // Get the user document reference
        // Get the user document reference
        // Get the user document reference
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.selectedworkerid.toString());

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

            print('Notifications saved for user ${widget.selectedworkerid}');
          }

          // Display the notifications list in the app
          print('Notifications for user ${widget.selectedworkerid}');
          for (var notification in notifications) {
            String? title = notification['title'];
            String? body = notification['body'];
            print('Title: $title, Body: $body');
            await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
            print('Last notification sent to ${widget.selectedworkerid}');
          }
        } else {
          print('User document not found for user ${widget.selectedworkerid}');
        }
        print('Success: ${response.body}');
        setState(() {
          _toggleUploadingState(false);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => bidDetailsClient(projectId: widget.projectId),
          ),
        );

        // Handle success
      } else {
        print('Failed with status code: ${response.statusCode}');
        _toggleUploadingState(false); // Stop loading regardless of the outcome

        // Handle failure
      }
    } catch (e) {
      print('An exception occurred: $e');
      setState(() {
        isLoading = false;
      });    }
  }
  late Future<ProjectData> futureProjects;

  void initState() {
    super.initState();
    int projectId =widget.projectId;
    futureProjects = fetchProjectDetails(projectId);
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

    projectDetailsFuture = fetchProjectDetails(projectId); // Use the projectId in the call
  }
  @override
  void dispose() {
    super.dispose();

    ciruclaranimation.dispose();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('FFFFFF'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return  Scaffold(

      floatingActionButton: FloatingActionButton(
        heroTag: 'workdone_${unique}',

        onPressed: () {
          _navigateToNextPage(context);
        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
        child: Icon(
          Icons.help,
          color: Colors.white,
        ), // Use the support icon        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: HexColor('ECECEC'),
      appBar: AppBar(
        backgroundColor: HexColor('4D8D6E'),
        title: Text(
          'End Project',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Ionicons.arrow_back,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: Screenshot(
        controller: screenshotController10,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: FutureBuilder<ProjectData>(
                future: projectDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: RotationTransition(
                      turns: ciruclaranimation,
                      child: SvgPicture.asset(
                        'assets/images/Logo.svg',
                        semanticsLabel: 'Your SVG Image',
                        width: 100,
                        height: 130,
                      ),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No data available'));
                  } else {
                    ProjectData projectData = snapshot.data!;

                    selectedworkername=projectData.selectworkerbid.worker_firstname;
                    selectedworkerimage=projectData.selectworkerbid.worker_profile_pic;

                    ;
                    ;
                    ;
                    return  SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [

                          Text(
                            'Review',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: HexColor('424347'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),   ])),
                          SizedBox(height: 7,),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 10.0),
                             child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: TextFormField(
                                    controller: reviewcontroller,
                                    decoration: InputDecoration(
                                      hintText: 'Write a Review ...',
                                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16), // Adjust the font size
                                      contentPadding: EdgeInsets.symmetric(vertical: 16), // Adjust the vertical padding
                                      border: InputBorder.none,
                                    ),
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                           ),


                          SizedBox(height: 8,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [

                                Text(
                                  _imageFiles.isEmpty ? 'Upload Photo' : 'Selected Photo',
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      color: HexColor('424347'),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline, // "i" icon
                                    color: Colors.grey,
                                    size: 22, // Red color
                                  ),
                                  onPressed: () {
                                    // Show a Snackbar with the required text
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          _imageFiles .isEmpty
                                              ? 'Upload photo is Required'
                                              : 'Selected photo information',
                                          style:
                                          TextStyle(color: Colors.white), // Red text color
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('Take a photo'),
                                            onTap: () {
                                              _pickImages(isCamera: true);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.photo),
                                            title: Text('Select from gallery'),
                                            onTap: () {
                                              _pickImages();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Center(
                                  child: Container(
                                      height: 220,
                                      width: 350,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                      child: _imageFiles.isEmpty
                                          ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.file_upload,
                                              color: HexColor('4D8D6E'),
                                              size: 30,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Upload Here',
                                              style: TextStyle(
                                                color: HexColor('4D8D6E'),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 9.0),
                                              child: Text(
                                                'Please upload clear photos of the project (from all sides, if applicable) to help the worker place an accurate bid!',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : Column(
                                        children: [
                                          Expanded(
                                            child: Scrollbar(
                                              controller: ScrollController(),
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: _imageFiles!.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Dialog(
                                                            child: InteractiveViewer(
                                                              panEnabled: true,
                                                              // Set it to false to prevent panning.
                                                              boundaryMargin: EdgeInsets.all(20),
                                                              minScale: 0.5,
                                                              maxScale: 2,
                                                              child: Image.file(_imageFiles[index]!),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                            left: 8.0,
                                                            right: index == _imageFiles!.length - 1 ? 8.0 : 0,
                                                          ),
                                                          child: Image.file(
                                                            _imageFiles[index]!,
                                                            height: 150,
                                                            width: 150,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text('Delete Image'),
                                                                    content: Text('Are you sure you want to delete this image?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text('Cancel'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            _imageFiles!.removeAt(index);
                                                                          });
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text('Delete'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.red,
                                                              ),
                                                              padding: EdgeInsets.all(3),
                                                              child: Icon(Icons.delete, color: Colors.white),
                                                            ),
                                                          ),
                                                        ),                                            ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: Icon(Icons.camera_alt),
                                                        title: Text('Take a photo'),
                                                        onTap: () {
                                                          _pickImages(isCamera: true);
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: Icon(Icons.photo),
                                                        title: Text('Select from gallery'),
                                                        onTap: () {
                                                          _pickImages();
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_circle_outlined, size: 40, color: Colors.grey[400],),
                                                Text('Add More Photos',style: TextStyle(fontSize: 12,color: Colors.grey[500]),),
                                                SizedBox(height: 5,),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          ListTile(
                            title: Text(
                              'Rating',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: HexColor('424347'),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: projectData.selectworkerbid.worker_profile_pic == 'https://workdonecorp.com/images/' ||projectData.selectworkerbid.worker_profile_pic == ''
                                          ? AssetImage('assets/images/default.png') as ImageProvider
                                          : NetworkImage(projectData.selectworkerbid.worker_profile_pic ?? 'assets/images/default.png'),
                                    ),

                                    SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('${selectedworkername}',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              color: HexColor('706F6F'),
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Replace the following with a RatingBar widget
                                        RatingBar.builder(
                                          initialRating: 0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0), // Adjust padding as needed
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: HexColor('4D8D6E'),
                                            size: 14, // Adjust the size of the star icon
                                          ),
                                          onRatingUpdate: (rating2) {
                                            setState(() {
                                              rating=rating2.toString();
                                              print(rating);
                                            });
                                          },
                                        )

                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),

                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
                            child: Center(
                              child: ActionSlider.standard(
                                sliderBehavior: SliderBehavior.stretch,
                                rolling: false,
                                width: double.infinity,
                                backgroundColor: Colors.white,
                                toggleColor: HexColor('4D8D6E'),
                                iconAlignment: Alignment.centerRight,
                                loadingIcon: SizedBox(
                                    width: 55,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0, color: Colors.white))),
                                successIcon: const SizedBox(
                                    width: 55,
                                    child: Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                        ))),
                                icon: const SizedBox(
                                    width: 55,
                                    child: Center(
                                        child: Icon(
                                          Icons.keyboard_double_arrow_right,
                                          color: Colors.white,
                                        ))),
                                action: (controller) async {
                                  if (!isLoading) {
                                    controller.loading();
                                    await completeproject();
                                    controller.success();
                                    await Future.delayed(const Duration(seconds: 1));
                                    controller.reset();
                                  }
                                },
                                child: const Text('Swipe To Confirm'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenheight * 0.01,
                          ),
                        ],
                      ),
                    );
                  }
                }),
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
  final String video;
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
    required this.video,
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
    page_access_data accessData = page_access_data.fromJson(jsonData['page_access_data']);
    var selectWorkerBid = jsonData['select_worker_bid'] as Map<String, dynamic>? ?? {};
    // Bids can be handled inside the call using a cascade operator
    List<Bid> bidsList = (baseData['bids'] as List<dynamic>? ?? [])
        .map((x) => Bid.fromJson(x as Map<String, dynamic>))
        .toList();
    return ProjectData(
      title: baseData['title'] ?? 'No Title',
      images: List<String>.from(baseData['images'] ?? []),
      projectType: baseData['project_type'] ?? 'No Project Type',
      postedFrom: baseData['posted_from'] ?? 'No Post Date',
      status: baseData['status'] ?? 'No Status',
      desc: baseData['desc'] ?? 'No Description',
      liked: baseData['liked'] == 'true',
      numberOfLikes: baseData['number_of_likes'] ?? 0,
      video: baseData['video'] ?? '',
      lowestBid: baseData['lowest_bid'] ?? 'No Bids',
      timeframeStart: baseData['timeframe_start'] ?? 'No Start Time',
      timeframeEnd: baseData['timeframe_end'] ?? 'No End Time',
      bids: bidsList,
      clientData: ClientData.fromJson(clientInfo),
      pageContent: PageContent.fromJson(pageContent),
      pageaccessdata: accessData,
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
      profileImage: json['profle_image'] ?? '', // corrected typo from 'profle_image' to 'profile_image'
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
  final String reviewOnWorker;
  final String ratingOnWorker;
  final String reviewOnClient;
  final String schedule;
  final String ratingOnClient;
  final List<String> imagesAfter;

  PageContent({
    required this.currentUserRole,
    required this.buttons,
    required this.schedule,
    required this.selectedDate,
    required this.selectedInterval,
    required this.scheduleStatus,
    required this.change,
    required this.chat,
    required this.schedule_vc_generate_button,
    required this.complete_vc_generate_button,
    required this.project_complete_button,
    required this.support,
    required this.reviewOnWorker,
    required this.ratingOnWorker,
    required this.reviewOnClient,
    required this.ratingOnClient,
    required this.imagesAfter,
  });

  factory PageContent.fromJson(Map<String, dynamic> json) {
    List<String> imagesAfter = [];
    if (json.containsKey('images_after') && json['images_after'] is List) {
      imagesAfter = List<String>.from(json['images_after'].map((x) => x as String));
    }

    // Other fields can be default to empty strings/lists if they're missing
    return PageContent(
      currentUserRole: json['current_user_role'] ?? '',
      buttons: json['buttons'] ?? '',
      selectedDate: json['selected_date'] ?? '',
      selectedInterval: json['selected_interval'] ?? '',
      scheduleStatus: json['schedule_status'] ?? '',
      schedule: json['schedule'] ?? '',
      change: json['change'] ?? '',
      chat: json['chat'] ?? '',
      schedule_vc_generate_button: json['schedule_vc_generate_button'] ?? '',
      complete_vc_generate_button: json['complete_vc_generate_button'] ?? '',
      project_complete_button: json['project_complete_button'] ?? '',
      support: json['support'] ?? '',
      reviewOnWorker: json['review_on_worker'] ?? '',
      ratingOnWorker: json['rating_on_worker'] ?? '',
      reviewOnClient: json['review_on_client'] ?? '',
      ratingOnClient: json['rating_on_client'] ?? '',
      imagesAfter: imagesAfter,
    );
  }
}
class page_access_data {
  final String chat_ID;
  final String schedule_vc;
  final String finalizing_vc;

  page_access_data({required this.chat_ID, required this.schedule_vc, required this.finalizing_vc});

  // Named constructor for the empty case
  page_access_data.empty()
      : chat_ID = '',
        schedule_vc = '',
        finalizing_vc = '';

  factory page_access_data.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      // Data is a Map, process it
      return page_access_data(
        chat_ID: json['chat_ID'] ?? '',
        schedule_vc: json['schedule_vc'].toString() ?? '',
        finalizing_vc: json['finalizing_vc'].toString() ?? '',
      );
    } else if (json is List && json.isEmpty) {
      // Empty list, use empty constructor
      return page_access_data.empty();
    } else if (json == null) {
      // Handle null case
      return page_access_data.empty();
    } else {
      // Other invalid formats, throw exception
      throw Exception('Invalid format for page_access_data');
    }
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
