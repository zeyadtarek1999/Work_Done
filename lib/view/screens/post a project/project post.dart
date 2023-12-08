import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/NotificationController.dart';
import '../../../main.dart';
import '../../../model/getprojecttypesmodel.dart';
import '../../../model/notificationmodel.dart';
import '../../../model/postProjectmodel.dart';
import '../../widgets/rounded_button.dart';
import '../Screens_layout/layoutWorker.dart';
import '../Screens_layout/layoutclient.dart';

class projectPost extends StatefulWidget {
  projectPost({super.key});

  @override
  State<projectPost> createState() => _projectPostState();
}

class _projectPostState extends State<projectPost> {
  File? _image;
  final picker = ImagePicker();
  String profile_pic = '';
  String project_type_id = '';

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
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
    String timeframe_start = timeframeControllerstart.text;
    String timeframe_end = timeframeControllerend.text;
    String primary_image = _image!.path;

    if (_image == null) {
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

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('user_token') ?? '';

      await PostProjectApi.PostnewProject(
        token: userToken,
        project_type_id: selectedProjectType != null
            ? selectedProjectType!['id'] ?? "1"
            : "1",
        title: title,
        desc: desc,
        timeframe_start: timeframe_start,
        timeframe_end: timeframe_end,
        primary_image: primary_image,
      );

      print(_image!.path);
      print(userToken);
      AwesomeNotifications().createNotification(
        content:
        NotificationContent(id: 1, channelKey: 'postProject',title: 'hello test',body:'its only test '),

      );
      // Display a success toast message
      Fluttertoast.showToast(
        msg: "Project Posted Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate to layoutclient

      Get.to(layoutclient());
    } catch (error) {
      // Print the full error, including the server response
      print('Error during post project: $error');
      // Display a snackbar or toast with the error message
      print(_image!.path);
      print(timeframe_start);
      print(timeframe_end);
      print(primary_image);
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('ECECEC'),
      // Change this color to the desired one
      statusBarIconBrightness:
          Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 10, right: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Text(
                  _image == null ? 'Upload Photo' : 'Selected Photo',
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
                          _image == null
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
                  height: _image == null ? 150 : null,
                  // Adjust height based on image selection
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload Here',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: HexColor('4D8D6E'),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5),
                              child: Center(
                                child: Text(
                                  'Please upload clear photos of the project (from all sides, if applicable) to help the worker place an accurate bid!',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: HexColor('888C8A'),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Icon(
                              Icons.file_upload,
                              color: HexColor('4D8D6E'),
                              size: 30,
                            ),
                          ],
                        )
                      : Image.file(
                          _image!,
                          height: 150,
                          width:
                              150, // Set width and height to make it circular
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
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
    );
  }
}
