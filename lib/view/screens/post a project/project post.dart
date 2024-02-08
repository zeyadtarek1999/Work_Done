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
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/NotificationController.dart';
import '../../../main.dart';
import '../../../model/getprojecttypesmodel.dart';
import '../../../model/notificationmodel.dart';
import '../../../model/postProjectmodel.dart';
import '../../widgets/rounded_button.dart';
import '../Screens_layout/layoutclient.dart';
import '../Support Screen/Support.dart';
import 'apimodel.dart';
import 'package:http/http.dart' as http;


class projectPost extends StatefulWidget {
  projectPost({super.key});

  @override
  State<projectPost> createState() => _projectPostState();
}

class _projectPostState extends State<projectPost> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String profile_pic = '';
  String project_type_id = '';
  VideoPlayerController? _videoController;
  XFile? _videoFile;
  // Removed the '?' to avoid null checks

  late AnimationController ciruclaranimation;
  List<File> _imageFiles = []; // Use File directly


  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images?.isNotEmpty ?? false) {
      setState(() {
        _imageFiles = images!.map((xfile) => File(xfile.path)).toList();
      });
    }
  }


  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      File videoFile = File(video.path); // Convert to File
      _videoFile = video; // Keep the XFile if you need it for later use

      _videoController = VideoPlayerController.file(videoFile) // Use File instead of XFile
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }


  // This function is triggered when the button is clicked




  @override
  void dispose() {
    _videoController?.dispose();
    ciruclaranimation.dispose();
    super.dispose();
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
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

  }

  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }
  // Make sure to replace 'YOUR_BEARER_TOKEN' with your actual bearer token
// and 'myListOfImageFiles' with your actual list of image files,
// and 'myVideoFile' with your actual file for the video.
  bool _isUploading = false;
  void _toggleUploadingState(bool isUploading) {
    setState(() => _isUploading = isUploading);
  }

  String selectedprojectid ='nothing';


  Future<void> submitProject() async {
    print('Fetching user token from SharedPreferences...');


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? '';

    print('Creating request...');
    // Define headers in a map
    final headers = <String, String>{
      'Authorization': 'Bearer $userToken',
      // 'Content-Type': 'multipart/form-data', This is added automatically when adding files to the MultipartRequest.
    };

    var request = http.MultipartRequest('POST', Uri.parse('https://www.workdonecorp.com/api/insert_project'))
      ..headers.addAll(headers)
      ..fields['project_type_id'] = selectedprojectid
      ..fields['title'] = titleController.text
      ..fields['desc'] = descController.text
      ..fields['timeframe_start'] = timeframeControllerstart.text.isEmpty ? '0' : timeframeControllerstart.text
    ..fields['timeframe_end'] = timeframeControllerend.text.isEmpty ? '10' : timeframeControllerend.text;


    print('Checking for files...');
    // Check if any files are null or empty before proceeding
    if ((_imageFiles?.isEmpty ?? true) && _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please pick at least one image and a video.")));
      return;
    }else{     setState(() {
      _toggleUploadingState(false);
    }); // Start loading
    }

    // Add video if not null
    if (_videoFile != null) {
      print('Adding video to the request...');
      request.files.add(await http.MultipartFile.fromPath('video', _videoFile!.path));
    }

    // Add images if any
    // Add images if any
    if (_imageFiles != [] && _imageFiles.isNotEmpty) {

      print('Adding images to the request...');
      print(_imageFiles);
      for (var imageFile in _imageFiles) {
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
      _toggleUploadingState(true); // Start loading

      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      var streamedResponse = await request.send();

      print('Request sent. Status code: ${streamedResponse.statusCode}');
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
setState(() {
  _toggleUploadingState(false);
});       String notificationImagePath = _imageFiles.isNotEmpty
            ? _imageFiles.first.path // Using the first image as the notification image
            : ''; // Provide a default or a placeholder image path if no image is available
        String title = titleController.text;

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'postProject',
            title: 'Your project $title is live!',
            body: 'Check it out now!',
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture: _imageFiles.first.path, // Local file path or URL
          ),
        );// Stop loading regardless of the outcome
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => layoutclient(),
          ),
        );

        // Handle success
      } else {
        Fluttertoast.showToast(
          msg: 'Error : ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Failed with status code: ${response.statusCode}');
        _toggleUploadingState(false); // Stop loading regardless of the outcome

        // Handle failure
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error : $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('An exception occurred: $e');
      // Handle exception
    }
  }




  List<Map<String, String>> projectTypes = [];
  Map<String, String>? selectedProjectType;

// Function to fetch project types and update the list
  void _fetchProjectTypes() async {
    try {
      final getAllProjectTypesApi =
          GetAllProjectTypesApi(baseUrl: 'https://www.workdonecorp.com');
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
            Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                Row(
                  children: [
                    Text(
                      _imageFiles.isEmpty ? 'Upload Photo' : 'Selected Photo',
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
                        Fluttertoast.showToast(
                          msg: _imageFiles.isEmpty
                              ? 'Upload photo is Required'
                              : 'Selected photo information',
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
                                SizedBox(
                  height: 7,
                                ),
                    Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImages(); // Call the function when tapped
                        },
                        child: Center(
                          child: Container(
                            height: 150, // Fixed height for the container
                            width: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: _imageFiles.isEmpty
                                ? Center(
                              // Show instructions if no images are selected
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                itemCount: _imageFiles!.length,
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
                                              child: Image.file(_imageFiles[index]!),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
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
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                                            ),
                    SizedBox(
                  height: 14,
                                ),
                    Row(
                      children: [
                        Text(
                          _videoFile == null ?'Upload Video' : 'Selected Video', // Corrected conditional expression
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: HexColor('1A1D1E'),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: _videoFile == null  // Corrected conditional expression
                                  ? 'Upload video is required'
                                  : 'Selected video information',
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
                    SizedBox(height: 7),
                    Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                                if (_videoController == null || !_videoController!.value.isInitialized) {
                                                  _pickVideo();
                                                }
                                  },
                                  child: Expanded(
                                                child: Center(
                                                  child: _videoController != null && _videoController!.value.isInitialized
                                                      ? AspectRatio(
                                                    aspectRatio: _videoController!.value.aspectRatio,
                                                    child: VideoPlayer(_videoController!),
                                                  )
                                                      : GestureDetector(
                                                    onTap: _pickVideo,
                                                        child: Container(
                                                height: 150, // Fixed height for the container
                                                width: 350,
                                                decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        color: Colors.white,
                                                ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.video_camera_back,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      'Please upload clear video of the project (from all sides, if applicable) to help the worker place an accurate bid!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                                                        ),
                                                      )

                                                ),
                                  ),
                                                    ),
                            ],
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
                        Fluttertoast.showToast(
                          msg:  'Title is Required',
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
                  child: FormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      builder: (FormFieldState state) {
                        return Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'Write a Project Title',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                              border: InputBorder.none, // Remove the underline
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 15.0), // Adjust padding
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                              }
                              return null;
                            },
                          ),
                        ],
                      );
                    }
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
                        Column(
                        children: [
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
                                selectedprojectid =projectId;
                                String projectName = selectedProjectType!['name']!;
                                print('Selected Project ID: $projectId');
                                print('Selected Project Name: $projectName');
                              }
                            },
                          ),
                        ],
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
                        Fluttertoast.showToast(
                          msg: 'Job Description is Required ',
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
                    child:Column(
                    children: [
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                    ],
                                            ),
                  ),
                                ),
                                SizedBox(
                  height: 14,
                                ),

                    Center(
                      child: _isUploading
                          ? Center(
                        child: RotationTransition(
                          turns: ciruclaranimation,
                          child: SvgPicture.asset(
                            'assets/images/Logo.svg',
                            semanticsLabel: 'Your SVG Image',
                            width: 100,
                            height: 130,
                          ),
                        ),
                      )
                      // Show loading indicator when uploading
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RoundedButton(
                                text: 'Done',
                                press: () {
                                  if (_formKey.currentState!.validate()) {
                                    submitProject();
                                  } else {
                                    Fluttertoast.showToast(msg: "Please fill in all required fields.");
                                  }
                                },
                              ),
                            ],
                          ),
                    ),                                SizedBox(
                  height: 14,
                                ),
                              ]),
                ),
          ),
        ),
      ),
    );
  } Widget _buildVideoPlayerItem(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(controller),
            _PlayPauseOverlay(controller: controller), // Custom play/pause overlay
            VideoProgressIndicator(controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}
class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Center(
        child: AnimatedOpacity(
          opacity: controller.value.isPlaying ? 0 : 1.0,
          duration: Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white54,
            ),
            child: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 90.0,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    )
        : Container(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Center(child: CircularProgressIndicator()),
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
class ProjectPost {
  final int projectTypeId;
  final String title;
  final String desc;
  final int timeframeStart;
  final int timeframeEnd;
  final List<File> images;
  final File? video;

  ProjectPost({
    required this.projectTypeId,
    required this.title,
    required this.desc,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.images,
    this.video,
  });
}
