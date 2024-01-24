import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/NotificationController.dart';
import '../../../main.dart';
import '../../../model/getprojecttypesmodel.dart';
import '../../../model/notificationmodel.dart';
import '../../../model/postProjectmodel.dart';
import '../../widgets/rounded_button.dart';
import '../Screens_layout/layoutclient.dart';
import '../Support Screen/Support.dart';


class projectPost extends StatefulWidget {
  projectPost({super.key});

  @override
  State<projectPost> createState() => _projectPostState();
}

class _projectPostState extends State<projectPost> {

  String profile_pic = '';
  String project_type_id = '';
  List<XFile>? _videos = [];
  List<File?> _images = [];

  final picker = ImagePicker();
  Future<void> _getImageFromGallery() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        for (var pickedFile in pickedFiles) {
          _images.add(File(pickedFile.path));
        }
      }
    });
  }
  bool _isPlaying = false;



// This function is used to control video playback

  void _showVideoDurationTooLongMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Video Too Long'),
          content: Text('Please select a video that is 20 seconds or less.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  late String userToken;

  double _startValue = 0;
  double _endValue = 10;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final project_type_idController = TextEditingController();
  final timeframeControllerstart = TextEditingController();
  final timeframeControllerend = TextEditingController();

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    _getUserToken();
    _fetchProjectTypes();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }

  void _postaproject() async {
    // Make sure to fill in the values from your text controllers or other sources
    String title = titleController.text;
    String project_type_id = project_type_idController.text;
    String desc = descController.text;
    String timeframe_start = timeframeControllerstart.text.isEmpty
        ? '0'
        : timeframeControllerstart.text;
    String timeframe_end = timeframeControllerend.text.isEmpty ? '10' : timeframeControllerend.text;

    if (_images.isEmpty) {
      // Show a toast message and return early
      Fluttertoast.showToast(
        msg: "Please select an image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    // if (_videos!.isEmpty) {
    //   Fluttertoast.showToast(
    //     msg: "Please select a video",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    //   return;
    // }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('user_token') ?? '';
      List<String> imagePaths = _images.map((image) => image!.path).toList();
      List<String> videoPaths = _videos!.map((video) => video.path).toList();
print(imagePaths);
      var response = await PostProjectApi.postNewProject(
        token: userToken,
        projectTypeId:  project_type_id,
        title: title,
        description:  desc,
        timeframeStart: timeframe_start,
        timeframeEnd:   timeframe_end,
        imagesPaths: imagePaths,
        videosPaths: imagePaths,
        // videosPaths: videoPaths, // Add this to include videos in the API call
      );


      print(userToken);
      AwesomeNotifications().createNotification(
        content:
        NotificationContent(id: 1, channelKey: 'postProject',title: 'hello test',body:'its only test '),

      );
      // Display a success toast message
      Fluttertoast.showToast(
        msg:             'Your project is successfully completed. Please allow 48 hours until the bidding process is finalized. Then, the ball is in your court! Select your best worker – please use reviews to finalize your consideration process.',

        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );


      Get.to(layoutclient());
    } catch (error) {
      // Print the full error, including the server response
      print('Error during post project: $error');
      // Display a snackbar or toast with the error message
      print(timeframe_start);
      print(timeframe_end);
      print(desc);
      print(userToken);
      print(title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during post project: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, String>> projectTypes = [];
  Map<String, String>? selectedProjectType;

// Function to fetch project types and update the list
  void _fetchProjectTypes() async {
    try {
      final getAllProjectTypesApi =
          GetAllProjectTypesApi(baseUrl: 'https://workdonecorp.com');
      projectTypes = await getAllProjectTypesApi.getAllProjectTypes();
      setState(() {
        // Update the state to trigger a rebuild with the new data
      });
    } catch (error) {
      print('Error fetching project types: $error');
    }
  }
  final ScreenshotController screenshotController = ScreenshotController();

  String unique= 'Projectpost' ;
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
      statusBarColor: HexColor('ECECEC'),
      // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
        child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: HexColor('ECECEC'),
      appBar: AppBar(
        backgroundColor: HexColor('ECECEC'),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Ionicons.arrow_back,
            size: 30,
            color: HexColor('1A1D1E'),
          ),
        ),
        title: Text(
          'Post New Project',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: HexColor('1A1D1E'),
                fontSize: 22,
                fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body:

      Screenshot(
        controller:screenshotController ,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 10, right: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(
                    _images == null ? 'Upload Photo' : 'Selected Photo',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
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
                            _images == null
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
              SizedBox(
                height: 7,
              ),
                  GestureDetector(
                    onTap: () {
                      _getImageFromGallery(); // Call the function when tapped
                    },
                    child: Center(
                      child: Container(
                        height: 150, // Fixed height for the container
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: _images.isEmpty
                            ? Center(
                          // Show instructions if no images are selected
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_upload,
                                color: Theme.of(context).primaryColor,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload Here',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                            : Scrollbar(
                          controller: ScrollController(),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: InteractiveViewer(
                                          panEnabled: true, // Set it to false to prevent panning.
                                          boundaryMargin: EdgeInsets.all(20),
                                          minScale: 0.5,
                                          maxScale: 2,
                                          child: Image.file(_images[index]!),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 8.0,
                                    right: index == _images.length - 1 ? 8.0 : 0,
                                  ),
                                  child: Image.file(
                                    _images[index]!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                height: 14,
              ),
    //               Row(
    //                 children: [
    //                   Text(
    //                     _videos?.isEmpty ?? true ? 'Upload Video' : 'Selected Video', // Corrected conditional expression
    //                     style: GoogleFonts.poppins(
    //                       textStyle: TextStyle(
    //                         color: HexColor('1A1D1E'),
    //                         fontSize: 17,
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(width: 6),
    //                   IconButton(
    //                     icon: Icon(
    //                       Icons.info_outline,
    //                       color: Colors.grey,
    //                       size: 22,
    //                     ),
    //                     onPressed: () {
    //                       // Show a Snackbar with the required text
    //                       ScaffoldMessenger.of(context).showSnackBar(
    //                         SnackBar(
    //                           backgroundColor: Colors.red,
    //                           content: Text(
    //                             _videos?.isEmpty ?? true // Corrected conditional expression
    //                                 ? 'Upload video is required'
    //                                 : 'Selected video information',
    //                             style: TextStyle(color: Colors.white),
    //                           ),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 ],
    //               ),
    //               SizedBox(height: 7),
    //       GestureDetector(
    //         onTap: _pickVideo,
    //         child: Center(
    //           child: Container(
    //             height: 150,
    //             width: 350,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(15),
    //               color: Colors.white,
    //             ),
    //             child: _videoController == null ||!_videoController!.value.isInitialized
    //           ? // Display upload message if video is not picked or initialized
    //           Center(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Icon(
    //                 Icons.video_call,
    //                 color: Theme.of(context).primaryColor,
    //                 size: 30,
    //               ),
    //               SizedBox(height: 8),
    //               Text(
    //                 'Upload Video Here',
    //                 style: TextStyle(
    //                   color: Theme.of(context).primaryColor,
    //                   fontSize: 16,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               SizedBox(height: 8),
    //               Text(
    //                 'Upload a video that shows your project in detail to help bidders provide an accurate quote!',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   color: Colors.grey[600],
    //                   fontSize: 12,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )
    //             : // If the video is picked and initialized, wrap it with a GestureDetector to play/pause the video
    //         GestureDetector(
    //         onTap: _toggleVideo,
    //         child: AspectRatio(
    //           aspectRatio: _videoController!.value.aspectRatio,
    //           child: VideoPlayer(_videoController!), // Display the video player
    //         ),
    //       ),
    //     ),
    //   ),
    // ),
    //
                  SizedBox(
                    height: 14,
                  ),
              Row(
                children: [
                  Text(
                    'Title of Project',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('1A1D1E'),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
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
                            'Title is Required',
                            style:
                                TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Write a Project Title',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                    border: InputBorder.none, // Remove the underline
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0), // Adjust padding
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Text(
                'Project Type',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: HexColor('1A1D1E'),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Select Project Type',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                      Spacer(),
                      DropdownButton<Map<String, String>>(
                        underline: SizedBox(),
                        // Remove the underline
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                        value: selectedProjectType,
                        // Track the selected value
                        items: projectTypes
                            .map<DropdownMenuItem<Map<String, String>>>(
                                (Map<String, String> type) {
                          return DropdownMenuItem<Map<String, String>>(
                            value: type,
                            child: Text(type['name']!),
                          );
                        }).toList(),
                        onChanged: (Map<String, String>? newValue) {
                          setState(() {
                            selectedProjectType = newValue;
                          });
                          // Handle dropdown value change, you can use the selectedProjectType
                          // to get the selected project type ID and send it to the API
                          if (selectedProjectType != null) {
                            String projectId = selectedProjectType!['id']!;
                            String projectName = selectedProjectType!['name']!;
                            print('Selected Project ID: $projectId');
                            print('Selected Project Name: $projectName');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Row(
                children: [
                  Text(
                    'Preferred Time Frame',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('1A1D1E'),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
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
                            'Time frame is Required',
                            style:
                                TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RangeSlider(
                    values: RangeValues(_startValue, _endValue),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _startValue = values.start;
                        _endValue = values.end;
                        timeframeControllerstart.text =
                            _startValue.toInt().toString();
                        timeframeControllerend.text =
                            _endValue.toInt().toString();
                      });
                    },
                    min: 0,
                    max: 100,
                    divisions: 100,
                    // Divisions set to 1 for two thumbs
                    labels: RangeLabels(
                      _startValue.toInt().toString(),
                      _endValue.toInt().toString(),
                    ),
                    activeColor: Color(0xFF4D8D6E),
                    inactiveColor: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Project period (Range): ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_startValue.toInt()} - ${_endValue.toInt()} days',
                        style: TextStyle(
                          color: Color(0xFF4D8D6E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Job Description',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('1A1D1E'),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
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
                            'Job Description is Required',
                            style:
                                TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 100,
                width: double.infinity, // Set the desired width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: TextFormField(
                    controller: descController,
                    maxLines: null,
                    // Allows the text to take up multiple lines
                    decoration: InputDecoration(
                      hintText:
                          'Please write a detailed description to help the worker place an accurate bid!',
                      border: InputBorder.none,
                      hintMaxLines: 3,
                      // Allows the hint text to take up multiple lines
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Center(
                child: RoundedButton(
                  text: 'Done',
                  press: () {
                    _postaproject();
                  },
                ),
              ),
              SizedBox(
                height: 14,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
class CircularRadiusPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 10),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/Done.svg', // Replace with your SVG path
            width: 50.0,
            height: 50.0,
            color: Colors.blue, // Adjust the color as needed
          ),
          SizedBox(height: 16.0),
          Text(
            'Your project is successfully completed. Please allow 48 hours until the bidding process is finalized. Then, the ball is in your court! Select your best worker – please use reviews to finalize your consideration process.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog when the button is pressed
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}
