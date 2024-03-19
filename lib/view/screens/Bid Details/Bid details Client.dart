import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:action_slider/action_slider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';
import 'package:workdone/view/screens/InboxwithChat/chat.dart';
import 'package:workdone/view/screens/notifications/notificationScreenclient.dart';
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';
import '../InboxwithChat/ChatClient.dart';
import '../Screens_layout/layoutclient.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../check out client/checkout.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

import '../view profile screens/Worker profile .dart';
import '../view profile screens/Worker profile view.dart';
import 'complete project.dart';
import 'package:badges/badges.dart' as badges;
class bidDetailsClient extends StatefulWidget {
  final int projectId;

  bidDetailsClient({required this.projectId});

  @override
  State<bidDetailsClient> createState() => _bidDetailsClientState();
}

class _bidDetailsClientState extends State<bidDetailsClient>  with SingleTickerProviderStateMixin {
  bool showAdditionalContent = false;
  bool showprojectcomplete = false;
  bool accessprojectcomplete = false;
  bool disableverfication = false;
  List<File> _imageFiles = []; // Use File directly

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
          _imageFiles!.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    }
  }


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
  final StreamController<String> _likedStatusController = StreamController<String>();

  Map<int, bool> likedProjectsMap = {};


  Stream<String> get likedStatusStream => _likedStatusController.stream;
  Future<Map<String, dynamic>> addProjectToLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/add_project_to_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          // Project added to likes successfully
          print('Project added to likes successfully');
          _likedStatusController.add("true");

        } else if (responseBody['msg'] == 'This Project is Already in Likes !') {
          // Project is already liked
          print('Project is already liked');
        } else {
          // Handle other error scenarios
          print('Error: ${responseBody['msg']}');
        }

        return responseBody;
      } else {
        // Handle other status codes
        print('Failed to add project to likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to add project to likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }
  Future<Map<String, dynamic>> removeProjectFromLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('user_token') ?? '';
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/remove_project_from_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        // Successful request, you can handle the response here if needed
        print('Project removed from likes successfully');
        return {'status': 'success', 'msg': 'Project removed from likes successfully'};
      } else {
        // Handle error
        print('Failed to remove project from likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to remove project from likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }


  int notificationnumber =0 ;
  Future<void> Notificationnumber() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/unread_notification_number';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('counter')) {
            int profileData = responseData['counter'];

            setState(() {
              notificationnumber= profileData;
            });

            print('Response of notification number : $profileData');
            print('notification number: $notificationnumber');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load notification number');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load notification number');
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting notification number: $error');
    }
  }


  String rating = '';
  final reviewcontroller = TextEditingController();
  void _getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token') ?? '';
  }
  bool _isUploading = false;
  List<int> selectedIndices = [];
  int activeStep = 0;

  late String userToken;
  void _toggleUploadingState(bool isUploading) {
    setState(() => _isUploading = isUploading);
  }

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
        });

setState(() {
  futureProjects = fetchProjectDetails(widget.projectId);

});
        // Handle success
      } else {
        print('Failed with status code: ${response.statusCode}');
        _toggleUploadingState(false); // Stop loading regardless of the outcome

        // Handle failure
      }
    } catch (e) {
      print('An exception occurred: $e');
      // Handle exception
    }
  }

  late ChewieController _chewieController;

  void projectcomplete() async {
    // Make sure to fill in the values from your text controllers or other sources
    String review = reviewcontroller.text;

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


    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString('user_token') ?? '';
      List<String> imagePaths = _images.map((image) => image!.path).toList();
      List<String> videoPaths = _videos!.map((video) => video.path).toList();
      print(imagePaths);
      var response = await ProjectComplete.projectcomplete(
        token: userToken,
        project_id: widget.projectId.toString(),
       rating:rating ,
        imagesPaths: imagePaths,
        videosPaths: imagePaths,
        // videosPaths: videoPaths, // Add this to include videos in the API call
      );


      print(userToken);

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


    } catch (error) {
      // Print the full error, including the server response
      print('Error during post project: $error');
      // Display a snackbar or toast with the error message
      print(rating);


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during post project: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  SfRangeValues _values = SfRangeValues(
      DateTime(2000, 01, 01, 07, 00, 00), DateTime(2000, 01, 01, 17, 00, 00));
  DateTime dateTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  late Future<ProjectData> projectDetailsFuture;
  String client_id = '';
  String worker_id = '';
   List<String> projectimage=[];
  String projecttitle = '';
  String projectdesc = '';
  String owner = '';
  String selectedworkername = '';
  String selectedworkerimage = '';

  int currentStep = 0;
  List<EasyStep> steps = [
    EasyStep(
      title: 'Step 1',
      icon: Icon(Icons.circle, color: Colors.grey),

    ),
    EasyStep(
      title: 'Step 2',
      icon: Icon(Icons.circle, color: Colors.grey),
    ),
    // Add more steps as needed
  ];
  late ScrollController scrollController;
  late ScrollController scrollController2;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();
  SlidingUpPanelController panelController2 = SlidingUpPanelController();

  double minBound = 0;

  double upperBound = 1.0;
  Future<void> scheduleProject(int projectId, String selectedDay, String selectedInterval) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';
    final url = Uri.parse('https://www.workdonecorp.com/api/schedule_project'); // Replace with actual URL
    final body = jsonEncode({
      'project_id': projectId,
      'selected_day': selectedDay.toString(),
      'selected_interval': selectedInterval.toString()
    });

    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: body
    );

    if (response.statusCode == 200) {
      // Handle successful response
      await fetchProjectDetails(projectId);
setState(() {
  futureProjects = fetchProjectDetails(widget.projectId);

});

      // Call fetchProjectDetails here
      Fluttertoast.showToast(
        msg: 'Schedule sent successfully!\n selected day: ${selectedDay.toString()} , Selected interval: ${selectedInterval.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Schedule sent successfully!');
    } else {
      // Handle error
      print('Schedule failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
  late Future<ProjectData> futureProjects;
  // void refreshProjects() async{
  //   futureProjects = fetchProjectDetails(widget.projectId);
  // }
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
  String video ='';
  bool _videoInitialized = false;
  int _currentPageIndex = 0;
  final CarouselController _carouselController = CarouselController();

  String? buttonsValue;
  Future<void> fetchData() async {
    // Assuming you have a function to fetch project details
    final ProjectData projectData = await fetchProjectDetails(widget.projectId);

    // Access the 'buttons' value
     buttonsValue = projectData.pageContent.buttons;
    print('Buttons Value: $buttonsValue');
  }
  bool _controllerInitialized = false;

  Future<void> fetchvideo() async {
    // Assuming you have a function to fetch project details
    final ProjectData projectData = await fetchProjectDetails(widget.projectId);

  video = projectData.video;
    if (projectData.pageContent.scheduleStatus == "reject") {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          double screenHeight = MediaQuery.of(context).size.height;

          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use minimum space necessary
                children: [
                  Image.asset(
                    'assets/images/reject.png',
                    width: 200,
                    height: 200,
                    // You can adjust width and height according to your design
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Schedule Rejected',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'The Schedule is Rejected by Worker \n You can discuss and propose a new schedule \n in the chat and You Can Change The Schedule.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.06,
                        width: screenHeight * 0.20,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                          },
                          style: ElevatedButton.styleFrom(
                            primary: HexColor('4D8D6E'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenHeight * 0.02,
                              ),
                            ),
                          ),
                          child: Text(
                            'Okay',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          );
        },
      );
    }

    print('this is url'+video);

    _controller = VideoPlayerController.networkUrl(Uri.parse(
        '${video}'))      ..initialize().then((_) {
        setState(() {
          _controllerInitialized = true;
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            aspectRatio: 16 / 9, // Adjust as needed
            autoPlay: false, // Set to true if you want the video to play automatically
            looping: false, // Set to true if you want the video to loop
            // ... Other ChewieController configurations
          );
        });
      }).catchError((error) {
        print(video);
        print(error);
      });
    print(video);
  }
  late VideoPlayerController _controller;
  late AnimationController ciruclaranimation;
   Duration fetchdata = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
      // Fetch data at each interval
      Notificationnumber();

    int projectId =widget.projectId;
    futureProjects = fetchProjectDetails(projectId);
    likedProjectsMap= {};

    projectDetailsFuture = fetchProjectDetails(projectId); // Use the projectId in the call
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });
    scrollController2 = ScrollController();
    scrollController2.addListener(() {
      if (scrollController2.offset >=
              scrollController2.position.maxScrollExtent &&
          !scrollController2.position.outOfRange) {
        panelController2.expand();
      } else if (scrollController2.offset <=
              scrollController2.position.minScrollExtent &&
          !scrollController2.position.outOfRange) {
        panelController2.anchor();
      } else {}
    });
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

    fetchvideo();
    fetchData();
    Notificationnumber();

  }

  String currentbid = '24';
  final ScreenshotController screenshotController8 = ScreenshotController();

  String unique = 'biddetailsclient';
  bool showConfirmDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              }, // Return false (don't exit)
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);

              }, // Return true (exit)
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
    return false; // Default return value (can be improved)
  }

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController8.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupportScreen(screenshotImageBytes: imageBytes, unique: unique),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
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

    return Stack(children: <Widget>[
      WillPopScope(
        onWillPop: () async {
          Get.offAll(layoutclient(showCase: false,));
          return false; // Return false to indicate that the back button was handled
        },
        child: Scaffold(
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

          backgroundColor: HexColor('FFFFFF'),
          appBar: AppBar(
            backgroundColor: HexColor('FFFFFF'),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
            toolbarHeight: 60,
            leading: IconButton(
              onPressed: () {
        Get.to(layoutclient(showCase: false,));            },
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
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child:
                  notificationnumber!=0?

                  badges.Badge(
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                      shape: badges.BadgeShape.circle,
                    ),
                    position: BadgePosition.topEnd(),
                    badgeContent: Text('$notificationnumber',style: TextStyle(color: Colors.white),),
                    badgeAnimation: badges.BadgeAnimation.rotation(
                      animationDuration: Duration(seconds: 1),
                      colorChangeAnimationDuration: Duration(seconds: 1),
                      loopAnimation: false,
                      curve: Curves.fastOutSlowIn,
                      colorChangeAnimationCurve: Curves.easeInCubic,
                    ),
                    child: GestureDetector(
                      onTap:
                          (){Get.to(NotificationsPageclient());
                      }
                      ,
                      child: SvgPicture.asset(
                        'assets/icons/iconnotification.svg',
                        width: 41.0,
                        height:41.0,
                      ),

                    ),
                  ):GestureDetector(
                    onTap:
                        (){Get.to(NotificationsPageclient());
                    }
                    ,
                    child: SvgPicture.asset(
                      'assets/icons/iconnotification.svg',
                      width: 41.0,
                      height:41.0,
                    ),

                  ),

                )

              ],
          ),
          body: RefreshIndicator(
            color: HexColor('4D8D6E'),
            backgroundColor: Colors.white,
            onRefresh: () async {
              setState(() {
                futureProjects = fetchProjectDetails(widget.projectId);
              });
            },
            child:  Screenshot(
              controller: screenshotController8,
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
                          currentbid = projectData.lowestBid.toString();
                          client_id = projectData.clientData!.clientId.toString();
                          projectimage = projectData.images;
                          selectedworkername=projectData.selectworkerbid.worker_firstname;
                          selectedworkerimage=projectData.selectworkerbid.worker_profile_pic;

                          print(projectimage)
                          ;
                          projecttitle = projectData.title.toString();
                          ;
                          projectdesc = projectData.desc.toString();;
                          video = projectData.video;
                          ;
                          owner = projectData.clientData!.firstname.toString();
                          print(projectData.video);
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    CarouselSlider(
                                      options: CarouselOptions(
                                        pageSnapping: true,
                                        height: 210,
                                        viewportFraction: 1.0,
                                        initialPage: 0,
                                        enableInfiniteScroll: true,
                                        reverse: false,
                                        autoPlay: false,
                                        autoPlayInterval: Duration(seconds: 3),
                                        autoPlayAnimationDuration: Duration(milliseconds: 500),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        scrollDirection: Axis.horizontal,
                                        onPageChanged: (index, reason) {
                                          // Update the current page index
                                          setState(() {
                                            _currentPageIndex = index;
                                          });
                                        },
                                      ),
                                      carouselController: _carouselController,
                                      items: [
                                        if (video != '')
                                          Builder(
                                            builder: (BuildContext context) {
                                              return Stack(
                                                children: [
                                                  Center(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (_controllerInitialized) {
                                                          if (_controller.value.isPlaying) {
                                                            _controller.pause();
                                                            _chewieController!.pause();
                                                          } else {
                                                            _controller.play();
                                                            _chewieController!.play();
                                                          }
                                                        }
                                                      },
                                                      child: Icon(
                                                        _controllerInitialized
                                                            ? _controller.value.isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow
                                                            : Icons.play_arrow, // Show play icon while initializing
                                                        size: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: 210,
                                                    child: _controllerInitialized
                                                        ? Chewie(controller: _chewieController!)
                                                        : Center(child: CircularProgressIndicator(
                                                      color: Colors.green,
                                                      strokeWidth: 2,
                                                    )),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        if (projectData.video.isEmpty)
                                          Center(child: CircularProgressIndicator(
                                            color: Colors.green,
                                            strokeWidth: 2,
                                          )),
                                        ...projectData.images.map((image) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (_) => Scaffold(
                                                      backgroundColor: Colors.black,
                                                      appBar: AppBar(
                                                        backgroundColor: Colors.black,
                                                        elevation: 0,
                                                      ),
                                                      body: Center(
                                                        child: InteractiveViewer(
                                                          child: Image.network(
                                                            image,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ));
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(30),
                                                  child: Image.network(
                                                    image,
                                                    fit: BoxFit.cover,
                                                    width: MediaQuery.of(context).size.width,
                                                    height: double.infinity,
                                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Center(child: CircularProgressIndicator(
                                                        color: Colors.green,
                                                        strokeWidth: 2,
                                                      ));
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Spacer(),
                                          Container(
                                            height: 50,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0, left: 5),
                                                  child: Text(
                                                    "${projectData.numberOfLikes}",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  iconSize: 22,
                                                  icon: Icon(
                                                    likedProjectsMap[widget.projectId] ?? projectData.liked == "true"
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: likedProjectsMap[widget.projectId] ?? projectData.liked == "true"
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      if (likedProjectsMap[widget.projectId] ?? projectData.liked == "true") {
                                                        // If liked, remove like
                                                        final response = await removeProjectFromLikes(widget.projectId.toString());

                                                        if (response['status'] == 'success') {
                                                          // If successfully removed from likes
                                                          setState(() {
                                                            likedProjectsMap[widget.projectId] = false;
                                                            projectData.numberOfLikes = (projectData.numberOfLikes ?? 0) - 1;
                                                          });
                                                          print('Project removed from likes');
                                                        } else {
                                                          // Handle the case where the project is not removed from likes
                                                          print('Error: ${response['msg']}');
                                                        }
                                                      } else {
                                                        // If not liked, add like
                                                        final response = await addProjectToLikes(widget.projectId.toString());

                                                        if (response['status'] == 'success') {
                                                          // If successfully added to likes
                                                          setState(() {
                                                            likedProjectsMap[widget.projectId] = true;
                                                            projectData.numberOfLikes = (projectData.numberOfLikes ?? 0) + 1;
                                                          });
                                                          print('Project added to likes');
                                                        } else if (response['msg'] == 'This Project is Already in Likes !') {
                                                          // If the project is already liked, switch to Icons.favorite_border
                                                          setState(() {
                                                            likedProjectsMap[widget.projectId] = false;
                                                          });
                                                          print('Project is already liked');
                                                        } else {
                                                          // Handle the case where the project is not added to likes
                                                          print('Error: ${response['msg']}');
                                                        }
                                                      }
                                                    } catch (e) {
                                                      print('Error: $e');
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
// Add the
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
    projectData.images.length + (video != '' ? 1 : 0),
    (index) {
    return GestureDetector(        onTap: () {
      _carouselController.animateToPage(index);
    },
      child: Container(
        width: 10,
        height: 10,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentPageIndex == index ? Colors.green : Colors.grey[300],
        ),
      ),
    );
    },
    ),
    ),

    SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 45,
                                      width: MediaQuery.of(context).size.width * 0.26, // Adjust the width as needed
                                      decoration: BoxDecoration(
                                        color: HexColor('4D8D6E'),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            projectData.projectType,
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),

                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: HexColor('4d8c8d'),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.badge,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              projectData.status,
                                              style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: HexColor('777778'),
                                          size: 18,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${projectData.postedFrom}',
                                          style: GoogleFonts.openSans(
                                            color: HexColor('777778'),
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                        Animate(
                        effects: [FadeEffect(duration: Duration(milliseconds: 500),),],
                                                          child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 23,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: projectData.clientData.profileImage == '' || projectData.clientData.profileImage.isEmpty
                                          || projectData.clientData.profileImage == "https://workdonecorp.com/storage/" ||
                                          !(projectData.clientData.profileImage.toLowerCase().endsWith('.jpg') || projectData.clientData.profileImage.toLowerCase().endsWith('.png'))

                                          ? AssetImage('assets/images/default.png') as ImageProvider
                                          : NetworkImage(projectData.clientData.profileImage?? 'assets/images/default.png'),
                                    ),

                                    SizedBox(
                                      width: 12,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>  ProfilePageClient(
                                              userId: projectData
                                                  .clientData!.clientId
                                                  .toString())),
                                        ).then((_) {
                                          // Fetch data here after popping the second screen
                                          futureProjects = fetchProjectDetails(widget.projectId);
                                        });

                                      },

                                      child: Text(
                                        projectData.clientData!.firstname,
                                        //client first name
                                        style: TextStyle(
                                          color: HexColor('4D8D6E'),
                                          fontSize: MediaQuery.of(context).size.width > 400 ? 25 : 16,
                                          fontWeight: FontWeight.bold,
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
                                                '${projectData.lowestBid?.toString() ?? "No Bid"}',
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
                                Animate(
                                  effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                  child: Padding(
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
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Row(
                                    children: [

                                      Text(
                                        projectData.selectworkerbid.worker_firstname != ''
                                            ? 'Selected Worker'
                                            : '',
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
              SizedBox(height: 8,),
                                //accepted worker
                                Visibility(
                                  visible: projectData.selectworkerbid.worker_firstname != '', // Check if select_worker_bid exists

                                  child: Visibility(
                                    visible: projectData.selectworkerbid.worker_firstname.isNotEmpty,
                                    // Check if select_worker_bid exists and has a non-empty worker_firstname

                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 28,
                                                backgroundColor: Colors.transparent,
                                                backgroundImage:  projectData.selectworkerbid.worker_profile_pic  == '' || projectData.selectworkerbid.worker_profile_pic .isEmpty
                                                    || projectData.selectworkerbid.worker_profile_pic  == "https://workdonecorp.com/storage/" ||
                                                    !(projectData.selectworkerbid.worker_profile_pic .toLowerCase().endsWith('.jpg') || projectData.selectworkerbid.worker_profile_pic .toLowerCase().endsWith('.png'))

                                                    ? AssetImage('assets/images/default.png') as ImageProvider
                                                    : NetworkImage(projectData.selectworkerbid.worker_profile_pic ?? 'assets/images/default.png'),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Workerprofileother
                        (
                        userId: projectData
                            .selectworkerbid!.worker_id
                            .toString())),
                        ).then((_) {
                          futureProjects = fetchProjectDetails(widget.projectId);
                        });
                        },
                                                        child: Text(
                                                          projectData.selectworkerbid.worker_firstname,
                                                          style: GoogleFonts.openSans(
                                                            textStyle: TextStyle(
                                                              color: HexColor('4D8D6E'),
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
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
                                                      Text('${projectData.selectworkerbid.avg_rating}'),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                                    children: [

                                                      Text(
                                                        '\$  ' + projectData.selectworkerbid.amount.toString(),
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
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          backgroundColor: Colors.white,
                                                          title:    Center(
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  'Comment',
                                                                  style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  color: Colors.black, // Adjust the color of the underline
                                                                  thickness: 1.0, // Adjust the thickness of the underline
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          content: SingleChildScrollView( // Allows the dialog content to be scrollable
                                                            child: ListBody( // Use ListBody for better handling of the space inside scroll view
                                                              // Refrain from using MainAxisSize if you have dynamic content and wrap it with SingleChildScrollView
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    projectData.selectworkerbid.comment,
                                                                    style: GoogleFonts.openSans(
                                                                      textStyle: TextStyle(
                                                                        color: HexColor('4D8D6E'),
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 23,),
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context); // Close the dialog
                                                                  },
                                                                  child: Text('Close',style: TextStyle(fontSize: 15, color: Colors.white), // Adjust the font size
                                                                  ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary: Colors.transparent,
                                                                    backgroundColor: HexColor('4D8D6E'),
                                                                    elevation: 0,
                                                                    textStyle: TextStyle(color: Colors.white),
                                                                    padding: EdgeInsets.symmetric(vertical:12, horizontal: 12), // Adjust padding
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30.0), // Adjust the border radius
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: HexColor('4D8D6E'), // Set the button color to 4D8D6E
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0), // Adjust the border radius
                                                    ),
                                                    minimumSize: Size(30, 20), // Set the minimum size
                                                    padding: EdgeInsets.all(8), // Set the padding
                                                  ),
                                                  child: Text(
                                                    'Comment',
                                                    style: GoogleFonts.openSans(
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20,),
                                FutureBuilder<ProjectData>(
                                  future: futureProjects,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return    Center(child: RotationTransition(
                                        turns: ciruclaranimation,
                                        child: SvgPicture.asset(
                                          'assets/images/Logo.svg',
                                          semanticsLabel: 'Your SVG Image',
                                          width: 100,
                                          height: 130,
                                        ),
                                      ));
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

                                      if (projectData.status ==
                                          'bid_accepted' && projectData.pageContent.schedule ==
                                    'mftoo7' )   {
                                        activeStep=1;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                child: Text(
                                                  'Progress',
                                                  style: GoogleFonts.openSans(
                                                    textStyle: TextStyle(
                                                      color: HexColor('454545'),
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 17,),

                                              Container(
                                                height:150,
                                                child: Center(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                    child: EasyStepper(
                                                      activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                      activeStepIconColor: Colors.white,
                                                      activeStepBorderColor:HexColor('4D8D6E')  ,
                                                      activeStepTextColor: HexColor('4D8D6E'),

                                                      showScrollbar: true,
                                                      enableStepTapping: false,
                                                      maxReachedStep: 6,
                                                      activeStep: activeStep,
                                                      stepShape: StepShape.circle,
                                                      stepBorderRadius: 15,
                                                      borderThickness: 1,
                                                      internalPadding: 15,
                                                      stepRadius: 32,
                                                      finishedStepBorderColor: HexColor('8d4d6c'),
                                                      finishedStepTextColor: HexColor('8d4d6c'),
                                                      finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                      finishedStepIconColor: Colors.white,
                                                      finishedStepBorderType: BorderType.normal,
                                                      showLoadingAnimation: false,
                                                      showStepBorder: true,
                                                      lineStyle: LineStyle(
                                                        lineLength: 45,
                                                        lineType: LineType.dashed,

                                                        activeLineColor: HexColor('#8d4d6c'),
                                                        defaultLineColor: HexColor('#8d4d6c'),
                                                        unreachedLineColor: HexColor('#172a21'),
                                                        lineThickness: 3,
                                                        lineSpace: 2,
                                                        lineWidth: 10,

                                                        unreachedLineType: LineType.dashed,

                                                      ),

                                                      steps: [
                                                        EasyStep(


                                                          icon: Icon(
                                                            FluentIcons.money_16_regular,
                                                          ),
                                                          title: 'Under Bidding',

                                                        ),
                                                        EasyStep(


                                                          icon: Icon(
                                                            Icons.check_circle,
                                                          ),
                                                          title: 'Accepted',

                                                        ),
                                                        EasyStep(


                                                          icon: Icon(
                                                            FluentIcons.calendar_12_filled ,
                                                          ),
                                                          title: 'Schedule',

                                                        ),
                                                        EasyStep(


                                                          icon: Icon(
                                                            FluentIcons.spinner_ios_16_filled ,
                                                          ),
                                                          title: 'Processing',

                                                        ),
                                                        EasyStep(


                                                          icon: Icon(
                                                            FluentIcons.checkmark_circle_square_16_filled ,
                                                          ),
                                                          title: 'Finilizing',

                                                        ),
                                                        EasyStep(


                                                          icon: Icon(
                                                            FluentIcons.flag_16_filled  ,
                                                          ),
                                                          title: 'Completed',

                                                        ),

                                                      ],
                                                      onStepReached: (index) => setState(() => activeStep = index),
                                                    ),
                                                  ),

                                                ),
                                              ),
                                              Padding(
                                                padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                child: Text(
                                                  'Details',
                                                  style: GoogleFonts.openSans(
                                                    textStyle: TextStyle(
                                                      color: HexColor('454545'),
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                          true,
                                                          builder: (BuildContext
                                                          context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext
                                                              context,
                                                                  StateSetter
                                                                  setState) {
                                                                return Container(
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                        children: [
                                                                          Text(
                                                                            'Schedule',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: Colors
                                                                                    .grey [900],
                                                                                fontSize: 22,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.03),

                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            'Choose a day',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: Colors
                                                                                    .black,
                                                                                fontSize: 20,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator
                                                                                  .pop(
                                                                                  context);
                                                                            },
                                                                            icon:
                                                                            Icon(
                                                                              Icons
                                                                                  .cancel,
                                                                              size:
                                                                              25,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.02),

                                                                      EasyDateTimeLine(
                                                                        initialDate:
                                                                        _selectedDate,
                                                                        onDateChange:
                                                                            (
                                                                            selectedDate) {
                                                                          setState(
                                                                                  () {
                                                                                _selectedDate =
                                                                                    selectedDate;
                                                                              });
                                                                        },
                                                                        activeColor:
                                                                        HexColor(
                                                                            '4D8D6E'),
                                                                        headerProps:
                                                                        const EasyHeaderProps(
                                                                          showSelectedDate:
                                                                          true,
                                                                          monthPickerType:
                                                                          MonthPickerType
                                                                              .dropDown,
                                                                          selectedDateFormat:
                                                                          SelectedDateFormat
                                                                              .fullDateDMY,
                                                                        ),
                                                                        dayProps:
                                                                        const EasyDayProps(
                                                                          activeDayStyle:
                                                                          DayStyle(
                                                                            borderRadius:
                                                                            32.0,
                                                                          ),
                                                                          inactiveDayStyle:
                                                                          DayStyle(
                                                                            borderRadius:
                                                                            32.0,
                                                                          ),
                                                                        ),
                                                                        timeLineProps:
                                                                        const EasyTimeLineProps(
                                                                          hPadding:
                                                                          16.0,
                                                                          // padding from left and right
                                                                          separatorPadding:
                                                                          16.0, // padding between days
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.03),

                                                                      Text(
                                                                        'Choose Time',
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.02),

                                                                      Center(
                                                                        child:
                                                                        SfRangeSlider(
                                                                          activeColor: HexColor(
                                                                              '4D8D6E'),
                                                                          min: DateTime(
                                                                              2000,
                                                                              01,
                                                                              01, 6,
                                                                              00,
                                                                              00),
                                                                          // Set min to 6 AM
                                                                          max: DateTime(
                                                                              2000,
                                                                              01,
                                                                              01,
                                                                              22,
                                                                              00,
                                                                              00),
                                                                          // Set max to 10 PM
                                                                          values: _values,
                                                                          interval: 4,
                                                                          showLabels: true,
                                                                          showTicks: true,
                                                                          dateFormat: DateFormat(
                                                                              'h a'),
                                                                          // Display hours in AM/PM format
                                                                          dateIntervalType: DateIntervalType
                                                                              .hours,
                                                                          onChanged: (
                                                                              SfRangeValues newValues) {
                                                                            if (newValues
                                                                                .end
                                                                                .difference(
                                                                                newValues
                                                                                    .start)
                                                                                .inHours <
                                                                                4) {
                                                                              // Prevent range smaller than 4 hours
                                                                              return;
                                                                            }
                                                                            setState(() {
                                                                              _values =
                                                                                  newValues;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.04),

                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            'Selected Time Range:',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: Colors
                                                                                    .grey [800],
                                                                                fontSize: 16,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            ' ${formatTime(
                                                                                _values
                                                                                    .start)} - ${formatTime(
                                                                                _values
                                                                                    .end)}',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: HexColor(
                                                                                    '4D8D6E'),
                                                                                fontSize: 16,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .normal,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.03),

                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            'Selected Date:',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: Colors
                                                                                    .grey [800],
                                                                                fontSize: 16,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            ' ${DateFormat(
                                                                                'EEEE,  d, MM, yyyy')
                                                                                .format(
                                                                                _selectedDate
                                                                                    .toLocal())}',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle: TextStyle(
                                                                                color: HexColor(
                                                                                    '4D8D6E'),
                                                                                fontSize: 16,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .normal,
                                                                              ),
                                                                            ),
                                                                          ),


                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.06),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                            20.0),
                                                                        child:
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              height: 50,
                                                                              // Set the desired height
                                                                              width: 120,
                                                                              // Set the desired width
                                                                              child: ElevatedButton(
                                                                                onPressed:
                                                                                    () {
                                                                                  Navigator
                                                                                      .pop(
                                                                                      context);
                                                                                },
                                                                                style:
                                                                                ElevatedButton
                                                                                    .styleFrom(
                                                                                  primary: HexColor(
                                                                                      'B6212A'),
                                                                                  onPrimary: Colors
                                                                                      .white,
                                                                                  elevation: 5,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius
                                                                                        .circular(
                                                                                        12),
                                                                                  ),
                                                                                ),
                                                                                child:
                                                                                Text(
                                                                                    'Cancel',
                                                                                    style: TextStyle(
                                                                                        fontSize: 18)),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: 50,
                                                                              // Set the desired height
                                                                              width: 120,
                                                                              // Set the desired width
                                                                              child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  setState(() async {
                                                                                    await scheduleProject(
                                                                                        widget
                                                                                            .projectId,
                                                                                        DateFormat(
                                                                                            'EEEE,  d, MM, yyyy')
                                                                                            .format(
                                                                                            _selectedDate
                                                                                                .toLocal())
                                                                                            .toString(),
                                                                                        "${formatTime(
                                                                                            _values
                                                                                                .start)
                                                                                            .toString() +
                                                                                            ' - ' +
                                                                                            formatTime(
                                                                                                _values
                                                                                                    .end)
                                                                                                .toString()}");
                                                                                    Navigator.pop(context);

                                                                                  });

                                                                                },
                                                                                style: ElevatedButton
                                                                                    .styleFrom(
                                                                                  primary: HexColor(
                                                                                      '4D8D6E'),
                                                                                  onPrimary: Colors
                                                                                      .white,
                                                                                  elevation: 5,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius
                                                                                        .circular(
                                                                                        12),
                                                                                  ),
                                                                                ),
                                                                                child: Text(
                                                                                  'Apply',
                                                                                  style: TextStyle(
                                                                                      fontSize: 18), // Adjust the fontSize as needed
                                                                                ),
                                                                              ),
                                                                            ),

                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('34446F'),
                                                        onPrimary: Colors.white,
                                                        elevation: 5,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Schedule',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Expanded(
                                                    child: Container(
                                                      width: 220.0,
                                                      height: 50,
                                                      // Set the desired width
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Get.to(chat(
                                                            worker_id:projectData
                                                                .selectworkerbid.worker_id ,
                                                            myside_image:projectData
                                                                .clientData.profileImage ,
                                                            myside_firstname: projectData
                                                                .clientData.firstname,
                                                            client_id: projectData
                                                                .clientData!.clientId ,

                                                            seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                            chatId: projectData
                                                                .pageaccessdata!.chat_ID,
                                                            currentUser:
                                                            'client',
                                                            secondUserName:
                                                            projectData
                                                                .selectworkerbid.worker_firstname,
                                                            userId: projectData
                                                                .clientData!
                                                                .clientId
                                                                .toString(),
                                                          ));
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary:
                                                          HexColor('ED6F53'),
                                                          // Background color
                                                          onPrimary: Colors.white,
                                                          // Text color
                                                          elevation: 8,
                                                          // Elevation
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                12), // Rounded corners
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(12.0),
                                                          child: Text(
                                                            'Chat',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                              TextStyle(
                                                                color:
                                                                Colors.white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),

                                              Row(
                                                children: [
                                                  Container(
                                                    width: 195.0,
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: projectData
                                                          .pageContent
                                                          .project_complete_button ==
                                                          "maftoo7"
                                                          ? () {
                                                        showModalBottomSheet(
                                                          elevation: 5,

                                                          context: context,
                                                          isScrollControlled: true,
                                                          //Add this for full screen modal
                                                          backgroundColor: Colors
                                                              .white,
                                                          builder: (context) {
                                                            // Here, you can include your custom slider content
                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 15.0),
                                                              decoration: ShapeDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shadows: [
                                                                  BoxShadow(
                                                                      blurRadius: 5.0,
                                                                      spreadRadius: 2.0,
                                                                      color: const Color(
                                                                          0x11000000))
                                                                ],
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius
                                                                      .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                        10.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                        10.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize
                                                                    .min,
                                                                crossAxisAlignment: CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: screenheight *
                                                                        0.02,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                          onPressed: () {
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          icon: Icon(
                                                                            Icons
                                                                                .expand_circle_down,
                                                                            color: Colors
                                                                                .grey[700],
                                                                          )),
                                                                      Text(
                                                                        'End Project',
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors
                                                                                .grey[900],
                                                                            fontSize: 23,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(
                                                                      'Upload Photo ',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle: TextStyle(
                                                                          color: HexColor(
                                                                              '424347'),
                                                                          fontSize: 18,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 10.0),
                                                                    child: Container(
                                                                      height: 90,
                                                                      // Set the desired height
                                                                      width: double
                                                                          .infinity,
                                                                      // Take the full width
                                                                      decoration: BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          color: Colors
                                                                              .grey,
                                                                          // Set the desired border color
                                                                          width: 1.0, // Set the desired border width
                                                                        ),
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            10), // Set the desired border radius
                                                                      ),
                                                                      child: ListTile(
                                                                        title: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons
                                                                                  .image,
                                                                              color: HexColor(
                                                                                  '4D8D6E'),
                                                                            ),
                                                                            // Replace with the appropriate icon
                                                                            SizedBox(
                                                                                height: 8),
                                                                            Text(
                                                                              'Upload here',
                                                                              style: TextStyle(
                                                                                  color: Colors
                                                                                      .grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        onTap: () {
                                                                          // Handle image or video selection
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(
                                                                      'Upload Video ',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle: TextStyle(
                                                                          color: HexColor(
                                                                              '424347'),
                                                                          fontSize: 18,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 10.0),
                                                                    child: Container(
                                                                      height: 90,
                                                                      // Set the desired height
                                                                      width: double
                                                                          .infinity,
                                                                      // Take the full width
                                                                      decoration: BoxDecoration(
                                                                        border: Border
                                                                            .all(
                                                                          color: Colors
                                                                              .grey,
                                                                          // Set the desired border color
                                                                          width: 1.0, // Set the desired border width
                                                                        ),
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            10), // Set the desired border radius
                                                                      ),
                                                                      child: ListTile(
                                                                        title: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons
                                                                                  .video_camera_back,
                                                                              color: HexColor(
                                                                                  '4D8D6E'),
                                                                            ),
                                                                            // Replace with the appropriate icon
                                                                            SizedBox(
                                                                                height: 8),
                                                                            Text(
                                                                              'Upload here',
                                                                              style: TextStyle(
                                                                                  color: Colors
                                                                                      .grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        onTap: () {
                                                                          // Handle image or video selection
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: screenheight *
                                                                        0.02,
                                                                  ),
                                                                  ListTile(
                                                                    title: Text(
                                                                      'Rating',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle: TextStyle(
                                                                          color: HexColor(
                                                                              '424347'),
                                                                          fontSize: 18,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ListTile(
                                                                    title: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            CircleAvatar(
                                                                              radius: 50,
                                                                              backgroundColor: Colors.transparent,
                                                                              backgroundImage: selectedworkerimage== 'https://workdonecorp.com/images/' ||selectedworkerimage== ''
                                                                                  ? AssetImage('assets/images/default.png') as ImageProvider
                                                                                  : NetworkImage(selectedworkerimage?? 'assets/images/default.png'),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment
                                                                                  .center,
                                                                              children: [
                                                                                Text(
                                                                                  '${selectedworkername}',
                                                                                  style: GoogleFonts
                                                                                      .roboto(
                                                                                    textStyle: TextStyle(
                                                                                      color: HexColor(
                                                                                          '706F6F'),
                                                                                      fontSize: 17,
                                                                                      fontWeight: FontWeight
                                                                                          .bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                    width: 8),
                                                                                // Replace the following with a RatingBar widget
                                                                                RatingBar
                                                                                    .builder(
                                                                                  initialRating: 0,
                                                                                  minRating: 1,
                                                                                  direction: Axis
                                                                                      .horizontal,
                                                                                  allowHalfRating: true,
                                                                                  itemCount: 5,
                                                                                  itemPadding: EdgeInsets
                                                                                      .symmetric(
                                                                                      horizontal: 2.0),
                                                                                  // Adjust padding as needed
                                                                                  itemBuilder: (
                                                                                      context,
                                                                                      _) =>
                                                                                      Icon(
                                                                                        Icons
                                                                                            .star,
                                                                                        color: HexColor(
                                                                                            '4D8D6E'),
                                                                                        size: 14, // Adjust the size of the star icon
                                                                                      ),
                                                                                  onRatingUpdate: (
                                                                                      rating) {
                                                                                    print(
                                                                                        rating);
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
                                                                    height: screenheight *
                                                                        0.02,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                      horizontal: 12.0,
                                                                    ),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            15),
                                                                        color: Colors
                                                                            .grey[100],
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 16),
                                                                        child: TextFormField(
                                                                          controller: reviewcontroller,
                                                                          decoration: InputDecoration(

                                                                            hintText: 'Write a Review ...',
                                                                            hintStyle: TextStyle(
                                                                                color: Colors
                                                                                    .grey[500]),
                                                                            border: InputBorder
                                                                                .none,
                                                                          ),
                                                                          maxLines: 4,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 12.0,
                                                                        vertical: 20),
                                                                    child: Center(
                                                                      child: ActionSlider
                                                                          .standard(
                                                                        sliderBehavior: SliderBehavior
                                                                            .stretch,
                                                                        rolling: false,
                                                                        width: double
                                                                            .infinity,
                                                                        backgroundColor: Colors
                                                                            .white,
                                                                        toggleColor: HexColor(
                                                                            '4D8D6E'),
                                                                        iconAlignment: Alignment
                                                                            .centerRight,
                                                                        loadingIcon: SizedBox(
                                                                            width: 55,
                                                                            child: Center(
                                                                                child: SizedBox(
                                                                                  width: 24.0,
                                                                                  height: 24.0,
                                                                                  child: CircularProgressIndicator(
                                                                                      strokeWidth: 2.0,
                                                                                      color: Colors
                                                                                          .white),
                                                                                ))),
                                                                        successIcon: const SizedBox(
                                                                            width: 55,
                                                                            child: Center(
                                                                                child: Icon(
                                                                                  Icons
                                                                                      .check_rounded,
                                                                                  color: Colors
                                                                                      .white,
                                                                                ))),
                                                                        icon: const SizedBox(
                                                                            width: 55,
                                                                            child: Center(
                                                                                child: Icon(
                                                                                  Icons
                                                                                      .keyboard_double_arrow_right,
                                                                                  color: Colors
                                                                                      .white,
                                                                                ))),
                                                                        action: (
                                                                            controller) async {
                                                                          controller
                                                                              .loading(); //starts loading animation
                                                                          await Future
                                                                              .delayed(
                                                                              const Duration(
                                                                                  seconds: 3));
                                                                          controller
                                                                              .success(); //starts success animation
                                                                          await Future
                                                                              .delayed(
                                                                              const Duration(
                                                                                  seconds: 1));
                                                                          controller
                                                                              .reset(); //resets the slider
                                                                        },
                                                                        child: const Text(
                                                                            'Swipe To Confirm'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: screenheight *
                                                                        0.01,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                          : null,
                                                      // Set onPressed to null if the condition is not met
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            ('66C020')),
                                                        onPrimary: Colors.white,
                                                        elevation: 8,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(8),
                                                        ),
                                                        fixedSize: Size(
                                                            double.infinity,
                                                            50), // Set the desired height
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 8.0),
                                                        // Adjust padding as needed
                                                        child: Text(
                                                          'Project Completed',
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight: FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Hero(
                                                      tag: 'workdone_${unique}',
                                                      child: Container(
                                                        height: 50,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _navigateToNextPage(
                                                                context);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: HexColor(
                                                                '777031'),
                                                            onPrimary:
                                                            Colors.white,
                                                            elevation: 8,
                                                            shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  21),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Support',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                              TextStyle(
                                                                color:
                                                                Colors.white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15,),

                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                ],
                                              ),
                                              SizedBox(height: 12,),
                                              Animate(
                                                effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                                child: ListView.builder(
                                                  physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: projectData.bids.length,
                                                  itemBuilder: (context, index) {
                                                    Bid bid = projectData.bids[index];
                                                    return buildListItem(bid);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'scheduled'&& projectData.pageContent.scheduleStatus ==
                                          'pending' ) {
                                        activeStep =2;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                          child: Text(
                                                            'Details',
                                                            style: GoogleFonts.openSans(
                                                              textStyle: TextStyle(
                                                                color: HexColor('454545'),
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),

                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Date:',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${projectData.pageContent.selectedDate}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Time (Interval): ',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${projectData.pageContent.selectedInterval}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),


                                                      ],),

                                                  ],
                                                ),
                                                SizedBox(width: 3,),
                                                ElevatedButton(

                                                  onPressed: (projectData.pageContent.change == 'mftoo7')
                                                      ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState) {
                                                            return Container(
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                        'Schedule',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [900],
                                                                            fontSize: 22,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Choose a day',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon:
                                                                        Icon(
                                                                          Icons.cancel,
                                                                          size:
                                                                          25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  EasyDateTimeLine(
                                                                    initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                    onDateChange:
                                                                        (selectedDate) {
                                                                      setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                selectedDate;
                                                                          });
                                                                    },
                                                                    activeColor:
                                                                    HexColor(
                                                                        '4D8D6E'),
                                                                    headerProps:
                                                                    const EasyHeaderProps(
                                                                      showSelectedDate:
                                                                      true,
                                                                      monthPickerType:
                                                                      MonthPickerType.switcher,
                                                                      selectedDateFormat:
                                                                      SelectedDateFormat.fullDateDMY,
                                                                    ),
                                                                    dayProps:
                                                                    const EasyDayProps(
                                                                      activeDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                      inactiveDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                    ),
                                                                    timeLineProps:
                                                                    const EasyTimeLineProps(
                                                                      hPadding:
                                                                      16.0,
                                                                      // padding from left and right
                                                                      separatorPadding:
                                                                      16.0, // padding between days
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Text(
                                                                    'Choose Time',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  Center(
                                                                    child:
                                                                    SfRangeSlider(
                                                                      activeColor: HexColor('4D8D6E'),
                                                                      min: DateTime(2000, 01, 01, 6, 00, 00), // Set min to 6 AM
                                                                      max: DateTime(2000, 01, 01, 22, 00, 00), // Set max to 10 PM
                                                                      values: _values,
                                                                      interval: 4,
                                                                      showLabels: true,
                                                                      showTicks: true,
                                                                      dateFormat: DateFormat('h a'), // Display hours in AM/PM format
                                                                      dateIntervalType: DateIntervalType.hours,
                                                                      onChanged: (SfRangeValues newValues) {
                                                                        if (newValues.end.difference(newValues.start).inHours < 4) {
                                                                          // Prevent range smaller than 4 hours
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _values = newValues;
                                                                        });
                                                                      },
                                                                    ),                                                                ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Time Range:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Date:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal())}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context).size.height *
                                                                          0.06),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        20.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              primary: HexColor('B6212A'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            Text('Cancel',
                                                                                style: TextStyle(fontSize: 18)),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              setState(() async {
                                                                                await scheduleProject(widget.projectId,
                                                                                    DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal()).toString(),
                                                                                    "${formatTime(_values.start).toString() +' - ' + formatTime(_values.end).toString()}");
                                                                                Navigator.pop(context);
                                                                              });

                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Apply',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null, // Set onPressed to null when the condition is false
                                                  style: ElevatedButton.styleFrom(
                                                    primary:  projectData.pageContent.change == 'maftoo7' ?Colors.blueAccent.withOpacity(0.5): Colors.blueAccent,
                                                    onPrimary: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Opacity(
                                                    opacity: (projectData.pageContent.change == 'mftoo7') ? 1.0 : 1.0, // Adjust the opacity based on the condition
                                                    child: Text(
                                                      'Change',

                                                      style: TextStyle(fontSize: 10 ,color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                              ],

                                            ),
                                            SizedBox(height:10,),

                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Note',
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                        color: HexColor('#890C0A'),
                                                        fontSize: MediaQuery.of(context).size.width > 400 ? 15 : 13,
                                                        fontWeight: FontWeight.bold,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4,),

                                                  Text(
                                                    'Wait the Worker to Accept or Reject the Schedule...',
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                        color: HexColor('#0c343d'),
                                                        fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 12,
                                                        fontWeight: FontWeight.bold,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                                                               SizedBox(height: 10,),


                                            Row(
                                              children: [

                                                Expanded(
                                                  child: Container(
                                                    width: 220.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(chat(
                                                          worker_id:projectData
                                                              .selectworkerbid.worker_id ,
                                                          myside_image:projectData
                                                              .clientData.profileImage ,
                                                          myside_firstname: projectData
                                                              .clientData.firstname,
                                                          client_id: projectData
                                                              .clientData!.clientId ,

                                                          seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                          chatId: projectData
                                                              .pageaccessdata!.chat_ID,
                                                          currentUser:
                                                          'client',
                                                          secondUserName:
                                                          projectData
                                                              .selectworkerbid.worker_firstname,
                                                          userId: projectData
                                                              .clientData!
                                                              .clientId
                                                              .toString(),
                                                        ));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('ED6F53'),
                                                        // Background color
                                                        onPrimary: Colors.white,
                                                        // Text color
                                                        elevation: 8,
                                                        // Elevation
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Rounded corners
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12.0),
                                                        child: Text(
                                                          'Chat',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                            TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 7,),
                                                Hero(
                                                  tag: 'workdone_${unique}',
                                                  child: Container(
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _navigateToNextPage(
                                                            context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            '777031'),
                                                        onPrimary:
                                                        Colors.white,
                                                        elevation: 8,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              21),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Support',
                                                        style: GoogleFonts
                                                            .roboto(
                                                          textStyle:
                                                          TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),  SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.schedule_vc_generate_button != 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.schedule_vc_generate_button != 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on next button to generate verification code to access project complete.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Start work on project',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.schedule_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : HexColor('2E6070'), // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'With the worker. Generate the Verification Code',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.complete_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.complete_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on with the worker button to generate verification code to access start work on project.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'access project Complete',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.finalizing_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.complete_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : Colors.grey, // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Generate the Code to access project complete',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.complete_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                        ? () {
                                                      showModalBottomSheet(
                                                        elevation: 5,

                                                        context: context,
                                                        isScrollControlled: true, //Add this for full screen modal
                                                        backgroundColor: Colors.white,
                                                        builder: (context) {
                                                          // Here, you can include your custom slider content
                                                          return Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                                                            decoration: ShapeDecoration(
                                                              color: Colors.white,
                                                              shadows: [
                                                                BoxShadow(
                                                                    blurRadius: 5.0,
                                                                    spreadRadius: 2.0,
                                                                    color: const Color(0x11000000))
                                                              ],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10.0),
                                                                  topRight: Radius.circular(10.0),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: screenheight * 0.02,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon: Icon(
                                                                          Icons.expand_circle_down,
                                                                          color: Colors.grey[700],
                                                                        )),
                                                                    Text(
                                                                      'End Project',
                                                                      style: GoogleFonts.roboto(
                                                                        textStyle: TextStyle(
                                                                          color: Colors.grey[900],
                                                                          fontSize: 23,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      _imageFiles == null ? 'Upload Photo' : 'Selected Photo',
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
                                                                              _imageFiles == null
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
                                                                Column(children: [
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
                                                                                      horizontal: 12.0),
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
                                                                            radius: 50,
                                                                            backgroundColor: Colors.transparent,
                                                                            backgroundImage: selectedworkerimage== 'https://workdonecorp.com/images/' ||selectedworkerimage== ''
                                                                                ? AssetImage('assets/images/default.png') as ImageProvider
                                                                                : NetworkImage(selectedworkerimage?? 'assets/images/default.png'),
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
                                                                                allowHalfRating: true,
                                                                                itemCount: 5,
                                                                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0), // Adjust padding as needed
                                                                                itemBuilder: (context, _) => Icon(
                                                                                  Icons.star,
                                                                                  color: HexColor('4D8D6E'),
                                                                                  size: 14, // Adjust the size of the star icon
                                                                                ),
                                                                                onRatingUpdate: (rating) {
                                                                                  print(rating);
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
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12.0,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      color: Colors.grey[100],
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                      child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Write a Review ...',
                                                                          hintStyle: TextStyle(color: Colors.grey[500]),
                                                                          border: InputBorder.none,
                                                                        ),
                                                                        maxLines: 4,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                              child: SizedBox(
                                                                                width: 24.0,
                                                                                height: 24.0,
                                                                                child: CircularProgressIndicator(
                                                                                    strokeWidth: 2.0, color: Colors.white),
                                                                              ))),
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
                                                                        controller.loading(); //starts loading animation
                                                                        await Future.delayed(const Duration(seconds: 3));
                                                                        controller.success(); //starts success animation
                                                                        await Future.delayed(const Duration(seconds: 1));
                                                                        controller.reset(); //resets the slider
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
                                                        },
                                                      );
                                                    }
                                                        : null, // Set onPressed to null if the condition is not met
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor(('66C020')),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50), // Set the desired height
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                      child: Text(
                                                        'Project Completed',
                                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 17,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'scheduled'&& projectData.pageContent.scheduleStatus ==
                                          'accepted' ) {
                                        activeStep =2;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Details',
                                                            style: GoogleFonts.openSans(
                                                              textStyle: TextStyle(
                                                                color: HexColor('454545'),
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 20),
                                                          projectData.pageContent.scheduleStatus == "accepted"?
                                                          Container(
                                                            height: 35,
                                                            width: 70
                                                            ,
                                                            decoration: BoxDecoration(
                                                             borderRadius: BorderRadius.circular(15),color: HexColor('#3e861f')

                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Accepted',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ):
                                                          Container(),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Date:',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${projectData.pageContent.selectedDate}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Time (Interval): ',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${projectData.pageContent.selectedInterval}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),


                                                      ],)
                                                  ],
                                                ),
                                                SizedBox(width: 3,),
                                                ElevatedButton(

                                                  onPressed: (projectData.pageContent.change == 'mftoo7')
                                                      ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState) {
                                                            return Container(
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                        'Schedule',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [900],
                                                                            fontSize: 22,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Choose a day',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon:
                                                                        Icon(
                                                                          Icons.cancel,
                                                                          size:
                                                                          25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  EasyDateTimeLine(
                                                                    initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                    onDateChange:
                                                                        (selectedDate) {
                                                                      setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                selectedDate;
                                                                          });
                                                                    },
                                                                    activeColor:
                                                                    HexColor(
                                                                        '4D8D6E'),
                                                                    headerProps:
                                                                    const EasyHeaderProps(
                                                                      showSelectedDate:
                                                                      true,
                                                                      monthPickerType:
                                                                      MonthPickerType.switcher,
                                                                      selectedDateFormat:
                                                                      SelectedDateFormat.fullDateDMY,
                                                                    ),
                                                                    dayProps:
                                                                    const EasyDayProps(
                                                                      activeDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                      inactiveDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                    ),
                                                                    timeLineProps:
                                                                    const EasyTimeLineProps(
                                                                      hPadding:
                                                                      16.0,
                                                                      // padding from left and right
                                                                      separatorPadding:
                                                                      16.0, // padding between days
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Text(
                                                                    'Choose Time',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  Center(
                                                                    child:
                                                                    SfRangeSlider(
                                                                      activeColor: HexColor('4D8D6E'),
                                                                      min: DateTime(2000, 01, 01, 6, 00, 00), // Set min to 6 AM
                                                                      max: DateTime(2000, 01, 01, 22, 00, 00), // Set max to 10 PM
                                                                      values: _values,
                                                                      interval: 4,
                                                                      showLabels: true,
                                                                      showTicks: true,
                                                                      dateFormat: DateFormat('h a'), // Display hours in AM/PM format
                                                                      dateIntervalType: DateIntervalType.hours,
                                                                      onChanged: (SfRangeValues newValues) {
                                                                        if (newValues.end.difference(newValues.start).inHours < 4) {
                                                                          // Prevent range smaller than 4 hours
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _values = newValues;
                                                                        });
                                                                      },
                                                                    ),                                                                ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Time Range:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Date:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal())}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context).size.height *
                                                                          0.06),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        20.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              primary: HexColor('B6212A'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            Text('Cancel',
                                                                                style: TextStyle(fontSize: 18)),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              setState(() async {
                                                                                await scheduleProject(widget.projectId,
                                                                                    DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal()).toString(),
                                                                                    "${formatTime(_values.start).toString() +' - ' + formatTime(_values.end).toString()}");
                                                                                Navigator.pop(context);
                                                                              });

                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Apply',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null, // Set onPressed to null when the condition is false
                                                  style: ElevatedButton.styleFrom(
                                                    primary:  projectData.pageContent.change == 'maftoo7' ?Colors.blueAccent.withOpacity(0.5): Colors.blueAccent,
                                                    onPrimary: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Opacity(
                                                    opacity: (projectData.pageContent.change == 'mftoo7') ? 1.0 : 1.0, // Adjust the opacity based on the condition
                                                    child: Text(
                                                      'Change',

                                                      style: TextStyle(fontSize: 10 ,color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                              ],

                                            ),
                                            SizedBox(height: 9,),
                                            Row(
                                              children: [

                                                Expanded(
                                                  child: Container(
                                                    width: 220.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(chat(
                                                            worker_id:projectData
                                                                .selectworkerbid.worker_id ,
                                                            myside_image:projectData
                                                                .clientData.profileImage ,
                                                            myside_firstname: projectData
                                                                .clientData.firstname,
                                                            client_id: projectData
                                                                .clientData!.clientId ,

                                                            seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                            chatId: projectData
                                                                .pageaccessdata!.chat_ID,
                                                            currentUser:
                                                            'client',
                                                            secondUserName:
                                                            projectData
                                                                .selectworkerbid.worker_firstname,
                                                            userId: projectData
                                                                .clientData!
                                                                .clientId
                                                                .toString(),
                                                          ));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('ED6F53'),
                                                        // Background color
                                                        onPrimary: Colors.white,
                                                        // Text color
                                                        elevation: 8,
                                                        // Elevation
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Rounded corners
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12.0),
                                                        child: Text(
                                                          'Chat',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                            TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 7,),
                                                Hero(
                                                  tag: 'workdone_${unique}',
                                                  child: Container(
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _navigateToNextPage(
                                                            context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            '777031'),
                                                        onPrimary:
                                                        Colors.white,
                                                        elevation: 8,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              21),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Support',
                                                        style: GoogleFonts
                                                            .roboto(
                                                          textStyle:
                                                          TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),  SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on next button to generate verification code to access project complete.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Start work on project',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.schedule_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : HexColor('2E6070'), // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'With the worker. Generate the Verification Code',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.complete_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.complete_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on with the worker button to generate verification code to access start work on project.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'access project Complete',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.finalizing_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.complete_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : Colors.grey, // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Generate the Code to access project complete',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.complete_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                        ? () {
                                                      showModalBottomSheet(
                                                        elevation: 5,

                                                        context: context,
                                                        isScrollControlled: true, //Add this for full screen modal
                                                        backgroundColor: Colors.white,
                                                        builder: (context) {
                                                          // Here, you can include your custom slider content
                                                          return Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                                                            decoration: ShapeDecoration(
                                                              color: Colors.white,
                                                              shadows: [
                                                                BoxShadow(
                                                                    blurRadius: 5.0,
                                                                    spreadRadius: 2.0,
                                                                    color: const Color(0x11000000))
                                                              ],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10.0),
                                                                  topRight: Radius.circular(10.0),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: screenheight * 0.02,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon: Icon(
                                                                          Icons.expand_circle_down,
                                                                          color: Colors.grey[700],
                                                                        )),
                                                                    Text(
                                                                      'End Project',
                                                                      style: GoogleFonts.roboto(
                                                                        textStyle: TextStyle(
                                                                          color: Colors.grey[900],
                                                                          fontSize: 23,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      _imageFiles == null ? 'Upload Photo' : 'Selected Photo',
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
                                                                              _imageFiles == null
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
                                                                Column(children: [
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
                                                                                      horizontal: 12.0),
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
                                                                            radius: 50,
                                                                            backgroundColor: Colors.transparent,
                                                                            backgroundImage: selectedworkerimage== 'https://workdonecorp.com/images/' ||selectedworkerimage== ''
                                                                                ? AssetImage('assets/images/default.png') as ImageProvider
                                                                                : NetworkImage(selectedworkerimage?? 'assets/images/default.png'),
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
                                                                                allowHalfRating: true,
                                                                                itemCount: 5,
                                                                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0), // Adjust padding as needed
                                                                                itemBuilder: (context, _) => Icon(
                                                                                  Icons.star,
                                                                                  color: HexColor('4D8D6E'),
                                                                                  size: 14, // Adjust the size of the star icon
                                                                                ),
                                                                                onRatingUpdate: (rating) {
                                                                                  print(rating);
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
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12.0,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      color: Colors.grey[100],
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                      child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Write a Review ...',
                                                                          hintStyle: TextStyle(color: Colors.grey[500]),
                                                                          border: InputBorder.none,
                                                                        ),
                                                                        maxLines: 4,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                              child: SizedBox(
                                                                                width: 24.0,
                                                                                height: 24.0,
                                                                                child: CircularProgressIndicator(
                                                                                    strokeWidth: 2.0, color: Colors.white),
                                                                              ))),
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
                                                                        controller.loading(); //starts loading animation
                                                                        await Future.delayed(const Duration(seconds: 3));
                                                                        controller.success(); //starts success animation
                                                                        await Future.delayed(const Duration(seconds: 1));
                                                                        controller.reset(); //resets the slider
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
                                                        },
                                                      );
                                                    }
                                                        : null, // Set onPressed to null if the condition is not met
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor(('66C020')),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50), // Set the desired height
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                      child: Text(
                                                        'Project Completed',
                                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 17,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'scheduled'&& projectData.pageContent.scheduleStatus ==
                                          'reject' ) {
                                        activeStep =2;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                          child: Text(
                                                            'Details',
                                                            style: GoogleFonts.openSans(
                                                              textStyle: TextStyle(
                                                                color: HexColor('454545'),
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        projectData.pageContent.scheduleStatus == "reject"?
                                                        Container(
                                                          height: 35,
                                                          width: 70
                                                          ,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(15),color: HexColor('#890C0A')

                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Rejected',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ):
                                                        Container(),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Date:',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${projectData.pageContent.selectedDate}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Time (Interval): ',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${projectData.pageContent.selectedInterval}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),


                                                      ],)
                                                  ],
                                                ),
                                                SizedBox(width: 3,),
                                                ElevatedButton(

                                                  onPressed: (projectData.pageContent.change == 'mftoo7')
                                                      ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState) {
                                                            return Container(
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                        'Schedule',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [900],
                                                                            fontSize: 22,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Choose a day',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon:
                                                                        Icon(
                                                                          Icons.cancel,
                                                                          size:
                                                                          25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  EasyDateTimeLine(
                                                                    initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                    onDateChange:
                                                                        (selectedDate) {
                                                                      setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                selectedDate;
                                                                          });
                                                                    },
                                                                    activeColor:
                                                                    HexColor(
                                                                        '4D8D6E'),
                                                                    headerProps:
                                                                    const EasyHeaderProps(
                                                                      showSelectedDate:
                                                                      true,
                                                                      monthPickerType:
                                                                      MonthPickerType.switcher,
                                                                      selectedDateFormat:
                                                                      SelectedDateFormat.fullDateDMY,
                                                                    ),
                                                                    dayProps:
                                                                    const EasyDayProps(
                                                                      activeDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                      inactiveDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                    ),
                                                                    timeLineProps:
                                                                    const EasyTimeLineProps(
                                                                      hPadding:
                                                                      16.0,
                                                                      // padding from left and right
                                                                      separatorPadding:
                                                                      16.0, // padding between days
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Text(
                                                                    'Choose Time',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  Center(
                                                                    child:
                                                                    SfRangeSlider(
                                                                      activeColor: HexColor('4D8D6E'),
                                                                      min: DateTime(2000, 01, 01, 6, 00, 00), // Set min to 6 AM
                                                                      max: DateTime(2000, 01, 01, 22, 00, 00), // Set max to 10 PM
                                                                      values: _values,
                                                                      interval: 4,
                                                                      showLabels: true,
                                                                      showTicks: true,
                                                                      dateFormat: DateFormat('h a'), // Display hours in AM/PM format
                                                                      dateIntervalType: DateIntervalType.hours,
                                                                      onChanged: (SfRangeValues newValues) {
                                                                        if (newValues.end.difference(newValues.start).inHours < 4) {
                                                                          // Prevent range smaller than 4 hours
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _values = newValues;
                                                                        });
                                                                      },
                                                                    ),                                                                ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Time Range:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Date:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal())}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context).size.height *
                                                                          0.06),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        20.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              primary: HexColor('B6212A'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            Text('Cancel',
                                                                                style: TextStyle(fontSize: 18)),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              setState(() async {
                                                                                await scheduleProject(widget.projectId,
                                                                                    DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal()).toString(),
                                                                                    "${formatTime(_values.start).toString() +' - ' + formatTime(_values.end).toString()}");
                                                                                Navigator.pop(context);
                                                                              });

                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Apply',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null, // Set onPressed to null when the condition is false
                                                  style: ElevatedButton.styleFrom(
                                                    primary:  projectData.pageContent.change == 'maftoo7' ?Colors.blueAccent.withOpacity(0.5): Colors.blueAccent,
                                                    onPrimary: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Opacity(
                                                    opacity: (projectData.pageContent.change == 'mftoo7') ? 1.0 : 1.0, // Adjust the opacity based on the condition
                                                    child: Text(
                                                      'Change',

                                                      style: TextStyle(fontSize: 10 ,color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                              ],

                                            ),
                                            SizedBox(height: 9,),
                                            Row(
                                              children: [

                                                Expanded(
                                                  child: Container(
                                                    width: 220.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(chat(
                                                          worker_id:projectData
                                                              .selectworkerbid.worker_id ,
                                                          myside_image:projectData
                                                              .clientData.profileImage ,
                                                          myside_firstname: projectData
                                                              .clientData.firstname,
                                                          client_id: projectData
                                                              .clientData!.clientId ,

                                                          seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                          chatId: projectData
                                                              .pageaccessdata!.chat_ID,
                                                          currentUser:
                                                          'client',
                                                          secondUserName:
                                                          projectData
                                                              .selectworkerbid.worker_firstname,
                                                          userId: projectData
                                                              .clientData!
                                                              .clientId
                                                              .toString(),
                                                        ));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('ED6F53'),
                                                        // Background color
                                                        onPrimary: Colors.white,
                                                        // Text color
                                                        elevation: 8,
                                                        // Elevation
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Rounded corners
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12.0),
                                                        child: Text(
                                                          'Chat',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                            TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 7,),
                                                Hero(
                                                  tag: 'workdone_${unique}',
                                                  child: Container(
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _navigateToNextPage(
                                                            context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            '777031'),
                                                        onPrimary:
                                                        Colors.white,
                                                        elevation: 8,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              21),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Support',
                                                        style: GoogleFonts
                                                            .roboto(
                                                          textStyle:
                                                          TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),  SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on next button to generate verification code to access project complete.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Start work on project',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.schedule_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : HexColor('2E6070'), // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'With the worker. Generate the Verification Code',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.complete_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.complete_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on with the worker button to generate verification code to access start work on project.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'access project Complete',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.finalizing_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.complete_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : Colors.grey, // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Generate the Code to access project complete',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.complete_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                        ? () {
                                                      showModalBottomSheet(
                                                        elevation: 5,

                                                        context: context,
                                                        isScrollControlled: true, //Add this for full screen modal
                                                        backgroundColor: Colors.white,
                                                        builder: (context) {
                                                          // Here, you can include your custom slider content
                                                          return Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                                                            decoration: ShapeDecoration(
                                                              color: Colors.white,
                                                              shadows: [
                                                                BoxShadow(
                                                                    blurRadius: 5.0,
                                                                    spreadRadius: 2.0,
                                                                    color: const Color(0x11000000))
                                                              ],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10.0),
                                                                  topRight: Radius.circular(10.0),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: screenheight * 0.02,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon: Icon(
                                                                          Icons.expand_circle_down,
                                                                          color: Colors.grey[700],
                                                                        )),
                                                                    Text(
                                                                      'End Project',
                                                                      style: GoogleFonts.roboto(
                                                                        textStyle: TextStyle(
                                                                          color: Colors.grey[900],
                                                                          fontSize: 23,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      _imageFiles == null ? 'Upload Photo' : 'Selected Photo',
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
                                                                              _imageFiles == null
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
                                                                Column(children: [
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
                                                                                      horizontal: 12.0),
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
                                                                            radius: 50,
                                                                            backgroundColor: Colors.transparent,
                                                                            backgroundImage: selectedworkerimage== 'https://workdonecorp.com/images/' ||selectedworkerimage== ''
                                                                                ? AssetImage('assets/images/default.png') as ImageProvider
                                                                                : NetworkImage(selectedworkerimage?? 'assets/images/default.png'),
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
                                                                                allowHalfRating: true,
                                                                                itemCount: 5,
                                                                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0), // Adjust padding as needed
                                                                                itemBuilder: (context, _) => Icon(
                                                                                  Icons.star,
                                                                                  color: HexColor('4D8D6E'),
                                                                                  size: 14, // Adjust the size of the star icon
                                                                                ),
                                                                                onRatingUpdate: (rating) {
                                                                                  print(rating);
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
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12.0,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      color: Colors.grey[100],
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                      child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Write a Review ...',
                                                                          hintStyle: TextStyle(color: Colors.grey[500]),
                                                                          border: InputBorder.none,
                                                                        ),
                                                                        maxLines: 4,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                              child: SizedBox(
                                                                                width: 24.0,
                                                                                height: 24.0,
                                                                                child: CircularProgressIndicator(
                                                                                    strokeWidth: 2.0, color: Colors.white),
                                                                              ))),
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
                                                                        controller.loading(); //starts loading animation
                                                                        await Future.delayed(const Duration(seconds: 3));
                                                                        controller.success(); //starts success animation
                                                                        await Future.delayed(const Duration(seconds: 1));
                                                                        controller.reset(); //resets the slider
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
                                                        },
                                                      );
                                                    }
                                                        : null, // Set onPressed to null if the condition is not met
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor(('66C020')),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50), // Set the desired height
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                      child: Text(
                                                        'Project Completed',
                                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 17,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'processing'&& projectData.pageContent.complete_vc_generate_button ==
                                          'mftoo7' ) {
                                        activeStep=3;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Text(
                                                        'Details',
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
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Date:',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${projectData.pageContent.selectedDate}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Time (Interval): ',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${projectData.pageContent.selectedInterval}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),


                                                      ],)
                                                  ],
                                                ),
                                                SizedBox(width: 3,),
                                                ElevatedButton(

                                                  onPressed: (projectData.pageContent.change == 'mftoo7')
                                                      ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState) {
                                                            return Container(
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                        'Schedule',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [900],
                                                                            fontSize: 22,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Choose a day',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon:
                                                                        Icon(
                                                                          Icons.cancel,
                                                                          size:
                                                                          25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  EasyDateTimeLine(
                                                                    initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                    onDateChange:
                                                                        (selectedDate) {
                                                                      setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                selectedDate;
                                                                          });
                                                                    },
                                                                    activeColor:
                                                                    HexColor(
                                                                        '4D8D6E'),
                                                                    headerProps:
                                                                    const EasyHeaderProps(
                                                                      showSelectedDate:
                                                                      true,
                                                                      monthPickerType:
                                                                      MonthPickerType.switcher,
                                                                      selectedDateFormat:
                                                                      SelectedDateFormat.fullDateDMY,
                                                                    ),
                                                                    dayProps:
                                                                    const EasyDayProps(
                                                                      activeDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                      inactiveDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                    ),
                                                                    timeLineProps:
                                                                    const EasyTimeLineProps(
                                                                      hPadding:
                                                                      16.0,
                                                                      // padding from left and right
                                                                      separatorPadding:
                                                                      16.0, // padding between days
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Text(
                                                                    'Choose Time',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  Center(
                                                                    child:
                                                                    SfRangeSlider(
                                                                      activeColor: HexColor('4D8D6E'),
                                                                      min: DateTime(2000, 01, 01, 6, 00, 00), // Set min to 6 AM
                                                                      max: DateTime(2000, 01, 01, 22, 00, 00), // Set max to 10 PM
                                                                      values: _values,
                                                                      interval: 4,
                                                                      showLabels: true,
                                                                      showTicks: true,
                                                                      dateFormat: DateFormat('h a'), // Display hours in AM/PM format
                                                                      dateIntervalType: DateIntervalType.hours,
                                                                      onChanged: (SfRangeValues newValues) {
                                                                        if (newValues.end.difference(newValues.start).inHours < 4) {
                                                                          // Prevent range smaller than 4 hours
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _values = newValues;
                                                                        });
                                                                      },
                                                                    ),                                                                ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Time Range:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Date:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal())}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context).size.height *
                                                                          0.06),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        20.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              primary: HexColor('B6212A'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            Text('Cancel',
                                                                                style: TextStyle(fontSize: 18)),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              setState(() async {
                                                                                await scheduleProject(widget.projectId,
                                                                                    DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal()).toString(),
                                                                                    "${formatTime(_values.start).toString() +' - ' + formatTime(_values.end).toString()}");

                                                                                Navigator.pop(context);
                                                                              });


                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Apply',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null, // Set onPressed to null when the condition is false
                                                  style: ElevatedButton.styleFrom(
                                                    primary:  projectData.pageContent.change == 'maftoo7' ?Colors.blueAccent.withOpacity(0.5): Colors.blueAccent,
                                                    onPrimary: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Opacity(
                                                    opacity: (projectData.pageContent.change == 'mftoo7') ? 1.0 : 1.0, // Adjust the opacity based on the condition
                                                    child: Text(
                                                      'Change',

                                                      style: TextStyle(fontSize: 10 ,color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                              ],

                                            ),
                                            SizedBox(height: 9,),
                                            Row(
                                              children: [

                                                Expanded(
                                                  child: Container(
                                                    width: 220.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(chat(
                                                            worker_id:projectData
                                                                .selectworkerbid.worker_id ,
                                                            myside_image:projectData
                                                                .clientData.profileImage ,
                                                            myside_firstname: projectData
                                                                .clientData.firstname,
                                                            client_id: projectData
                                                                .clientData!.clientId ,

                                                            seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                            chatId: projectData
                                                                .pageaccessdata!.chat_ID,
                                                            currentUser:
                                                            'client',
                                                            secondUserName:
                                                            projectData
                                                                .selectworkerbid.worker_firstname,
                                                            userId: projectData
                                                                .clientData!
                                                                .clientId
                                                                .toString(),
                                                          ));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('ED6F53'),
                                                        // Background color
                                                        onPrimary: Colors.white,
                                                        // Text color
                                                        elevation: 8,
                                                        // Elevation
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Rounded corners
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12.0),
                                                        child: Text(
                                                          'Chat',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                            TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 7,),
                                                Hero(
                                                  tag: 'workdone_${unique}',
                                                  child: Container(
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _navigateToNextPage(
                                                            context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            '777031'),
                                                        onPrimary:
                                                        Colors.white,
                                                        elevation: 8,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              21),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Support',
                                                        style: GoogleFonts
                                                            .roboto(
                                                          textStyle:
                                                          TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),  SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on next button to generate verification code to access project complete.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Start work on project',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.schedule_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : HexColor('2E6070'), // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'With the worker. Generate the Verification Code',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.complete_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.complete_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on with the worker button to generate verification code to access start work on project.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'access project Complete',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.finalizing_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.complete_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : Colors.grey, // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Generate the Code to access project complete',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.complete_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                        ? () {
                                                      showModalBottomSheet(
                                                        elevation: 5,

                                                        context: context,
                                                        isScrollControlled: true, //Add this for full screen modal
                                                        backgroundColor: Colors.white,
                                                        builder: (context) {
                                                          // Here, you can include your custom slider content
                                                          return Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                                                            decoration: ShapeDecoration(
                                                              color: Colors.white,
                                                              shadows: [
                                                                BoxShadow(
                                                                    blurRadius: 5.0,
                                                                    spreadRadius: 2.0,
                                                                    color: const Color(0x11000000))
                                                              ],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10.0),
                                                                  topRight: Radius.circular(10.0),
                                                                ),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: screenheight * 0.02,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon: Icon(
                                                                          Icons.expand_circle_down,
                                                                          color: Colors.grey[700],
                                                                        )),
                                                                    Text(
                                                                      'End Project',
                                                                      style: GoogleFonts.roboto(
                                                                        textStyle: TextStyle(
                                                                          color: Colors.grey[900],
                                                                          fontSize: 23,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                ListTile(
                                                                  title: Text(
                                                                    'Upload Photo ',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: HexColor('424347'),
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                  child: Container(
                                                                    height: 90, // Set the desired height
                                                                    width: double.infinity, // Take the full width
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                        color: Colors.grey, // Set the desired border color
                                                                        width: 1.0, // Set the desired border width
                                                                      ),
                                                                      borderRadius: BorderRadius.circular(
                                                                          10), // Set the desired border radius
                                                                    ),
                                                                    child: ListTile(
                                                                      title: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.image,
                                                                            color: HexColor('4D8D6E'),
                                                                          ),
                                                                          // Replace with the appropriate icon
                                                                          SizedBox(height: 8),
                                                                          Text(
                                                                            'Upload here',
                                                                            style: TextStyle(color: Colors.grey),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      onTap: () {
                                                                        // Handle image or video selection
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  title: Text(
                                                                    'Upload Video ',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: HexColor('424347'),
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                  child: Container(
                                                                    height: 90, // Set the desired height
                                                                    width: double.infinity, // Take the full width
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                        color: Colors.grey, // Set the desired border color
                                                                        width: 1.0, // Set the desired border width
                                                                      ),
                                                                      borderRadius: BorderRadius.circular(
                                                                          10), // Set the desired border radius
                                                                    ),
                                                                    child: ListTile(
                                                                      title: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.video_camera_back,
                                                                            color: HexColor('4D8D6E'),
                                                                          ),
                                                                          // Replace with the appropriate icon
                                                                          SizedBox(height: 8),
                                                                          Text(
                                                                            'Upload here',
                                                                            style: TextStyle(color: Colors.grey),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      onTap: () {
                                                                        // Handle image or video selection
                                                                      },
                                                                    ),
                                                                  ),
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
                                                                            radius: 50,
                                                                            backgroundColor: Colors.transparent,
                                                                            backgroundImage: selectedworkerimage== 'https://workdonecorp.com/images/' ||selectedworkerimage== ''
                                                                                ? AssetImage('assets/images/default.png') as ImageProvider
                                                                                : NetworkImage(selectedworkerimage?? 'assets/images/default.png'),
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
                                                                                allowHalfRating: true,
                                                                                itemCount: 5,
                                                                                itemPadding: EdgeInsets.symmetric(horizontal: 2.0), // Adjust padding as needed
                                                                                itemBuilder: (context, _) => Icon(
                                                                                  Icons.star,
                                                                                  color: HexColor('4D8D6E'),
                                                                                  size: 14, // Adjust the size of the star icon
                                                                                ),
                                                                                onRatingUpdate: (rating) {
                                                                                  print(rating);
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
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12.0,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(15),
                                                                      color: Colors.grey[100],
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                      child: TextFormField(
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Write a Review ...',
                                                                          hintStyle: TextStyle(color: Colors.grey[500]),
                                                                          border: InputBorder.none,
                                                                        ),
                                                                        maxLines: 4,
                                                                      ),
                                                                    ),
                                                                  ),
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
                                                                              child: SizedBox(
                                                                                width: 24.0,
                                                                                height: 24.0,
                                                                                child: CircularProgressIndicator(
                                                                                    strokeWidth: 2.0, color: Colors.white),
                                                                              ))),
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
                                                                        controller.loading(); //starts loading animation
                                                                        await Future.delayed(const Duration(seconds: 3));
                                                                        controller.success(); //starts success animation
                                                                        await Future.delayed(const Duration(seconds: 1));
                                                                        controller.reset(); //resets the slider
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
                                                        },
                                                      );
                                                    }
                                                        : null, // Set onPressed to null if the condition is not met
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor(('66C020')),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50), // Set the desired height
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                      child: Text(
                                                        'Project Completed',
                                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 17,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'finalizing'&& projectData.pageContent.project_complete_button ==
                                          'maftoo7' ) {
                                        activeStep=4;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Text(
                                                        'Details',
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
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Date:',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 5,),
                                                        Text(
                                                          '${projectData.pageContent.selectedDate}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                    SizedBox(height: 8,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,

                                                      children: [

                                                        Text('Time (Interval): ',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${projectData.pageContent.selectedInterval}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey [800],
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),


                                                      ],)
                                                  ],
                                                ),
                                                SizedBox(width: 3,),
                                                ElevatedButton(

                                                  onPressed: (projectData.pageContent.change == 'mftoo7')
                                                      ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState) {
                                                            return Container(
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                        'Schedule',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [900],
                                                                            fontSize: 22,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Choose a day',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 20,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        icon:
                                                                        Icon(
                                                                          Icons.cancel,
                                                                          size:
                                                                          25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  EasyDateTimeLine(
                                                                    initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                    onDateChange:
                                                                        (selectedDate) {
                                                                      setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                selectedDate;
                                                                          });
                                                                    },
                                                                    activeColor:
                                                                    HexColor(
                                                                        '4D8D6E'),
                                                                    headerProps:
                                                                    const EasyHeaderProps(
                                                                      showSelectedDate:
                                                                      true,
                                                                      monthPickerType:
                                                                      MonthPickerType.switcher,
                                                                      selectedDateFormat:
                                                                      SelectedDateFormat.fullDateDMY,
                                                                    ),
                                                                    dayProps:
                                                                    const EasyDayProps(
                                                                      activeDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                      inactiveDayStyle:
                                                                      DayStyle(
                                                                        borderRadius:
                                                                        32.0,
                                                                      ),
                                                                    ),
                                                                    timeLineProps:
                                                                    const EasyTimeLineProps(
                                                                      hPadding:
                                                                      16.0,
                                                                      // padding from left and right
                                                                      separatorPadding:
                                                                      16.0, // padding between days
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Text(
                                                                    'Choose Time',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                                                  Center(
                                                                    child:
                                                                    SfRangeSlider(
                                                                      activeColor: HexColor('4D8D6E'),
                                                                      min: DateTime(2000, 01, 01, 6, 00, 00), // Set min to 6 AM
                                                                      max: DateTime(2000, 01, 01, 22, 00, 00), // Set max to 10 PM
                                                                      values: _values,
                                                                      interval: 4,
                                                                      showLabels: true,
                                                                      showTicks: true,
                                                                      dateFormat: DateFormat('h a'), // Display hours in AM/PM format
                                                                      dateIntervalType: DateIntervalType.hours,
                                                                      onChanged: (SfRangeValues newValues) {
                                                                        if (newValues.end.difference(newValues.start).inHours < 4) {
                                                                          // Prevent range smaller than 4 hours
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _values = newValues;
                                                                        });
                                                                      },
                                                                    ),                                                                ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Time Range:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Selected Date:',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: Colors.grey [800],
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ' ${DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal())}',
                                                                        style: GoogleFonts.roboto(
                                                                          textStyle: TextStyle(
                                                                            color: HexColor('4D8D6E'),
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                            FontWeight.normal,
                                                                          ),
                                                                        ),
                                                                      ),


                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context).size.height *
                                                                          0.06),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        20.0),
                                                                    child:
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            style:
                                                                            ElevatedButton.styleFrom(
                                                                              primary: HexColor('B6212A'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                            Text('Cancel',
                                                                                style: TextStyle(fontSize: 18)),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height: 50, // Set the desired height
                                                                          width: 120, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              setState(() async {
                                                                                await scheduleProject(widget.projectId,
                                                                                    DateFormat('EEEE,  d, MM, yyyy').format(_selectedDate.toLocal()).toString(),
                                                                                    "${formatTime(_values.start).toString() +' - ' + formatTime(_values.end).toString()}");

                                                                                Navigator.pop(context);

                                                                              });


                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Apply',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null, // Set onPressed to null when the condition is false
                                                  style: ElevatedButton.styleFrom(
                                                    primary:  projectData.pageContent.change == 'maftoo7' ?Colors.blueAccent.withOpacity(0.5): Colors.blueAccent,
                                                    onPrimary: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Opacity(
                                                    opacity: (projectData.pageContent.change == 'mftoo7') ? 1.0 : 1.0, // Adjust the opacity based on the condition
                                                    child: Text(
                                                      'Change',

                                                      style: TextStyle(fontSize: 10 ,color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                              ],

                                            ),
                                            SizedBox(height: 9,),
                                            Row(
                                              children: [

                                                Expanded(
                                                  child: Container(
                                                    width: 220.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(chat(
                                                            worker_id:projectData
                                                                .selectworkerbid.worker_id ,
                                                            myside_image:projectData
                                                                .clientData.profileImage ,
                                                            myside_firstname: projectData
                                                                .clientData.firstname,
                                                            client_id: projectData
                                                                .clientData!.clientId ,

                                                            seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                            chatId: projectData
                                                                .pageaccessdata!.chat_ID,
                                                            currentUser:
                                                            'client',
                                                            secondUserName:
                                                            projectData
                                                                .selectworkerbid.worker_firstname,
                                                            userId: projectData
                                                                .clientData!
                                                                .clientId
                                                                .toString(),
                                                          ));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                        HexColor('ED6F53'),
                                                        // Background color
                                                        onPrimary: Colors.white,
                                                        // Text color
                                                        elevation: 8,
                                                        // Elevation
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Rounded corners
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12.0),
                                                        child: Text(
                                                          'Chat',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                            TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 7,),
                                                Hero(
                                                  tag: 'workdone_${unique}',
                                                  child: Container(
                                                    height: 50,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _navigateToNextPage(
                                                            context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: HexColor(
                                                            '777031'),
                                                        onPrimary:
                                                        Colors.white,
                                                        elevation: 8,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              21),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Support',
                                                        style: GoogleFonts
                                                            .roboto(
                                                          textStyle:
                                                          TextStyle(
                                                            color:
                                                            Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),  SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on next button to generate verification code to access project complete.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Start work on project',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.schedule_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.schedule_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : HexColor('2E6070'), // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'With the worker. Generate the Verification Code',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.schedule_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (projectData.pageContent.complete_vc_generate_button == 'mftoo7')
                                                        ? () {
                                                      if (projectData.pageContent.complete_vc_generate_button == 'ma2fool') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'press on with the worker button to generate verification code to access start work on project.',
                                                          ),
                                                        );
                                                      } else {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter setState) {
                                                                return Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(
                                                                        child: Text(
                                                                          'Your ',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'Verification Code',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 27,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: Text(
                                                                          'Worker Must take this code to',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                          'access project Complete',
                                                                          style: GoogleFonts.roboto(
                                                                            textStyle: TextStyle(
                                                                              color: HexColor('706F6F'),
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Center(
                                                                        child: OTPDisplay(digits: '${projectData.pageaccessdata.finalizing_vc}'.split('')), // Convert the integer to a string and split its digits
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: Container(
                                                                          height: 54, // Set the desired height
                                                                          width: 170, // Set the desired width
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(context); // Close the showModalBottomSheet
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: HexColor('4D8D6E'),
                                                                              onPrimary: Colors.white,
                                                                              elevation: 5,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 18), // Adjust the fontSize as needed
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                        : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: (projectData.pageContent.complete_vc_generate_button == 'mftoo7') ? HexColor('B6B021') : Colors.grey, // Set the color when the condition is false
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Generate the Code to access project complete',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          if (projectData.pageContent.complete_vc_generate_button == 'ma2fool')
                                                            Icon(
                                                              AntDesign.questioncircleo, // Replace with your preferred icon
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                        ? () {
                                                     Get.to(completeprojectscreen(projectId: widget.projectId,));
                                                    }
                                                        : null, // Set onPressed to null if the condition is not met
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor(('66C020')),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50), // Set the desired height
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                      child: Text(
                                                        'Project Completed',
                                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 17,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if ( projectData.status ==
                                          'completed') {

                                          activeStep=5;

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(
                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),

                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Reviews',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 17,),
                                            projectData.pageContent.ratingOnWorker != 0 || projectData.pageContent.reviewOnWorker != ''

                                          ?  Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Client Review :',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('34446F'),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ):Container(),
                                            SizedBox(height: 10,),
                                            projectData.pageContent.ratingOnWorker != 0 || projectData.pageContent.reviewOnWorker != ''
                                                ? Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 23,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: projectData.clientData.profileImage == '' || projectData.clientData.profileImage.isEmpty
                                                      || projectData.clientData.profileImage == "https://workdonecorp.com/storage/" ||
                                                      !(projectData.clientData.profileImage.toLowerCase().endsWith('.jpg') || projectData.clientData.profileImage.toLowerCase().endsWith('.png'))

                                                      ? AssetImage('assets/images/default.png') as ImageProvider
                                                      : NetworkImage(projectData.clientData.profileImage?? 'assets/images/default.png'),
                                                ),
                                                SizedBox(width: 11),
                                    GestureDetector(
                                      onTap:  () {
                                        Get.to(ProfilePageClient(
                                            userId: projectData.clientData!.clientId.toString()));
                                      },

                                                  child:                                                 Text(
                                                      projectData.clientData!.firstname,
                                                      style: TextStyle(
                                                        color: HexColor('4D8D6E'),
                                                        fontSize: MediaQuery.of(context).size.width > 400 ? 20 : 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                ),
                                                Spacer(),
                                                RatingDisplay(rating: projectData.pageContent.ratingOnWorker),
                                              ],
                                            )
                                                : Container(),
                                            SizedBox(height: 8),
                                            projectData.pageContent.reviewOnWorker != ''
                                                ? Padding(
                                              padding: const EdgeInsets.all(16.0), // Consistent padding
                                              child: Text(
                                                '${projectData.pageContent.reviewOnWorker}',
                                                style: GoogleFonts.roboto( // Same font for consistency
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16, // Readable size
                                                    fontWeight: FontWeight.w400, // Slightly emphasized weight
                                                    height: 1.5, // Increased line height for better spacing
                                                  ),
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            )
                                                : SizedBox(height: 1),
                                            SizedBox(height: 8),
                                            Container(
                                              height: 140,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: projectData.pageContent.imagesAfter.length,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => PhotoView(
                                                            imageProvider: NetworkImage(
                                                              projectData.pageContent.imagesAfter[index],
                                                            ),
                                                            heroAttributes: PhotoViewHeroAttributes(
                                                              tag: projectData.pageContent.imagesAfter[index],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Hero(
                                                      tag: projectData.pageContent.imagesAfter[index],
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Image.network(
                                                            projectData.pageContent.imagesAfter[index],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 17,),
                                            projectData.pageContent.ratingOnClient != 0 || projectData.pageContent.reviewOnClient != ''

                                           ? Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Worker Review :',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('34446F'),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ): Padding(
                                              padding: const EdgeInsets.only(top:8.0),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width:double.infinity ,
                                                      color: Colors.grey,
                                                      height: 1,

                                                    ),
                                                    Card(
                                                                                        elevation: 8,
                                                                                        margin: EdgeInsets.all(16),
                                                                                        child: Padding(
                                                                                        padding: EdgeInsets.all(16),
                                                                                        child: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                        Icon(
                                                                                        Icons.hourglass_empty,
                                                                                        size: 64,
                                                                                        color: Colors.orange,
                                                                                        ),
                                                                                        SizedBox(height: 16),
                                                                                        Text(
                                                                                        'The Worker Didnt Rate Yet.',
                                                                                        style: TextStyle(fontSize: 18),
                                                                                        textAlign: TextAlign.center,
                                                                                        ),
                                                                                        ],
                                                                                        ),
                                                                                        ),
                                                                                        ),
                                                    Container(
                                                      width:double.infinity ,
                                                      color: Colors.grey,
                                                      height: 1,

                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            projectData.pageContent.ratingOnClient != 0 || projectData.pageContent.reviewOnClient != ''
                                                ? Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 23,
                                                  backgroundColor: Colors.transparent,
                                                  backgroundImage: projectData.selectworkerbid.worker_profile_pic  == '' || projectData.selectworkerbid.worker_profile_pic .isEmpty
                                                      || projectData.selectworkerbid.worker_profile_pic  == "https://workdonecorp.com/storage/" ||
                                                      !(projectData.selectworkerbid.worker_profile_pic .toLowerCase().endsWith('.jpg') || projectData.selectworkerbid.worker_profile_pic .toLowerCase().endsWith('.png'))

                                                      ? AssetImage('assets/images/default.png') as ImageProvider
                                                      : NetworkImage(projectData.selectworkerbid.worker_profile_pic ?? 'assets/images/default.png'),
                                                ),
                                                SizedBox(width: 11),
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Workerprofileother
                                                          (
                                                            userId: projectData
                                                                .selectworkerbid!.worker_id
                                                                .toString())),
                                                      ).then((_) {
                                                        futureProjects = fetchProjectDetails(widget.projectId);
                                                      });
                                                    },

                                                    style: TextButton.styleFrom(
                                                      fixedSize: Size(50, 30),
                                                      // Adjust the size as needed
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    child: Text(
                                                      projectData.selectworkerbid.worker_firstname,
                                                      //client first name
                                                      style: TextStyle(
                                                        color: HexColor('4D8D6E'),
                                                        fontSize: MediaQuery.of(context).size.width > 400 ? 20 : 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),


                                                Spacer(),
                                                RatingDisplay(rating: projectData.pageContent.ratingOnClient),
                                              ],
                                            )
                                                : Container(),
                                            SizedBox(height: 5),
                                            projectData.pageContent.reviewOnClient != ''
                                                ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0), // Add padding around the text
                                              child: Text(
                                                '${projectData.pageContent.reviewOnClient}',
                                                style: GoogleFonts.roboto( // Use Roboto for a more readable font
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16, // Increased font size for better readability
                                                    fontWeight: FontWeight.w400, // Slightly heavier weight for emphasis
                                                  ),

                                                ),
                                              ),
                                            )
                                                : Container(),





                                            SizedBox(height: 15,),
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Workers Bids',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),

                                          ],
                                        );
                                      }

                                      else if (projectData.bids.isNotEmpty) {

                                        projectData.status ==
                                            'bid_accepted'?
                                        activeStep=1:
                                        projectData.status ==
                                            'scheduled'?
                                        activeStep=2:
                                        projectData.status ==
                                            'processing'?
                                        activeStep=3:
                                        projectData.status ==
                                            'finalizing'?
                                        activeStep=4:
                                        projectData.status ==
                                            'completed'?
                                        activeStep=4:
                                        activeStep=0;

                                        ;
                                        // Render a ListView with bids
                                        return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
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

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                              ],
                                            ),
                                            SizedBox(height: 8,),
                                            Animate(
                                              effects: [SlideEffect(duration: Duration(milliseconds: 500),),],
                                              child: ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: projectData.bids.length,
                                                itemBuilder: (context, index) {
                                                  Bid bid = projectData.bids[index];
                                                  return buildListItem(bid);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        activeStep =0;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                              child: Text(
                                                'Progress',
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Container(
                                              height:150,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                                  child: EasyStepper(
                                                    activeStepBackgroundColor:HexColor('4D8D6E') ,
                                                    activeStepIconColor: Colors.white,
                                                    activeStepBorderColor:HexColor('4D8D6E')  ,
                                                    activeStepTextColor: HexColor('4D8D6E'),

                                                    showScrollbar: true,
                                                    enableStepTapping: false,
                                                    maxReachedStep: 6,
                                                    activeStep: activeStep,
                                                    stepShape: StepShape.circle,
                                                    stepBorderRadius: 15,
                                                    borderThickness: 1,
                                                    internalPadding: 15,
                                                    stepRadius: 32,
                                                    finishedStepBorderColor: HexColor('8d4d6c'),
                                                    finishedStepTextColor: HexColor('8d4d6c'),
                                                    finishedStepBackgroundColor: HexColor('8d4d6c'),
                                                    finishedStepIconColor: Colors.white,
                                                    finishedStepBorderType: BorderType.normal,
                                                    showLoadingAnimation: false,
                                                    showStepBorder: true,
                                                    lineStyle: LineStyle(
                                                      lineLength: 45,
                                                      lineType: LineType.dashed,

                                                      activeLineColor: HexColor('#8d4d6c'),
                                                      defaultLineColor: HexColor('#8d4d6c'),
                                                      unreachedLineColor: HexColor('#172a21'),
                                                      lineThickness: 3,
                                                      lineSpace: 2,
                                                      lineWidth: 10,

                                                      unreachedLineType: LineType.dashed,

                                                    ),

                                                    steps: [
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.money_16_regular,
                                                        ),
                                                        title: 'Under Bidding',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          Icons.check_circle,
                                                        ),
                                                        title: 'Accepted',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.calendar_12_filled ,
                                                        ),
                                                        title: 'Schedule',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.spinner_ios_16_filled ,
                                                        ),
                                                        title: 'Processing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.checkmark_circle_square_16_filled ,
                                                        ),
                                                        title: 'Finilizing',

                                                      ),
                                                      EasyStep(


                                                        icon: Icon(
                                                          FluentIcons.flag_16_filled  ,
                                                        ),
                                                        title: 'Completed',

                                                      ),

                                                    ],
                                                    onStepReached: (index) => setState(() => activeStep = index),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(

                                                'Workers Bids'
                                                                                  ,
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: HexColor('454545'),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 14.0),
                                              child: Center(child: Text('No bids yet')),
                                            ),
                                          ],
                                        );
                                      }
                                    }
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
                                  },
                                )
                              ]);
                        }
                      }),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget buildListItem(Bid item) {

    bool isMoneyLessOrEqual =
        double.parse(item.amount.toString()) <= double.parse(currentbid);

    // Check if Money is less than currentbid, and update currentbid if needed

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: item.workerProfilePic == '' ||item.workerProfilePic .isEmpty
                || item.workerProfilePic  == "https://workdonecorp.com/storage/" ||
                !(item.workerProfilePic .toLowerCase().endsWith('.jpg') || item.workerProfilePic .toLowerCase().endsWith('.png'))

                ? AssetImage('assets/images/default.png') as ImageProvider
                : NetworkImage(item.workerProfilePic?? 'assets/images/default.png'),
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
                          Workerprofileother
                            (userId: item.workerId.toString()));
                    },
                    child: Text(
                      item.workerFirstname.length > 7
                          ? '${item.workerFirstname.substring(0, 7)}...' // Display first 14 letters with ellipsis
                          : item.workerFirstname,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('4D8D6E'),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
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
                  Text('${item.avg_rating}'),
                ],
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title:    Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Comment',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.black, // Adjust the color of the underline
                                      thickness: 1.0, // Adjust the thickness of the underline
                                    ),
                                  ],
                                ),
                              ),
                              content: SingleChildScrollView( // Allows the dialog content to be scrollable
                                child: ListBody( // Use ListBody for better handling of the space inside scroll view
                                  // Refrain from using MainAxisSize if you have dynamic content and wrap it with SingleChildScrollView
                                  children: [
                                    Center(
                                      child: Text(
                                        item.comment,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: HexColor('4D8D6E'),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 23,),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text('Close',style: TextStyle(fontSize: 15, color: Colors.white), // Adjust the font size
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        backgroundColor: HexColor('4D8D6E'),
                                        elevation: 0,
                                        textStyle: TextStyle(color: Colors.white),
                                        padding: EdgeInsets.symmetric(vertical:12, horizontal: 12), // Adjust padding
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0), // Adjust the border radius
                              ),
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.resolveWith((states) => Size(30, 20)), // Set the minimum size
                        padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.all(8)), // Set the padding
                      ),
                      child: Text(
                        'Comment',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('4D8D6E'),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )                  ],
                ),
              ),
            ],
          ),

          Spacer(),
          Visibility(

            visible:
            buttonsValue == "efta7 Zorar el Accept",
            child: ElevatedButton(
              onPressed: () {
                Get.to(checkOutClient(
                  userId: item.clientData.clientId,
                  workerimage: item.workerProfilePic,
                  selectedworkerrating: item.avg_rating,
                  workername: item.workerFirstname,
                  currentbid: item.amount.toString(),
                  projectdesc: projectdesc,
                  projectimage: projectimage,
                  projecttitle: projecttitle,
                  workerId: item.workerId,
                  project_id: widget.projectId.toString(),
                ));
              },
              child: Text(
                'Accept',
                style: TextStyle(fontSize: 10, color: Colors.white), // Adjust the font size
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                backgroundColor: HexColor('4D8D6E'),
                elevation: 0,
                textStyle: TextStyle(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjust padding
              ),
            )

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
class ProjectComplete {
  static Future<void> projectcomplete({
    required String token,
    required String project_id,
    // required String review,
    required String rating,
    required List<String> imagesPaths,
    required List<String> videosPaths, // Add this parameter to take video paths
  }) async {
    final String url = 'https://www.workdonecorp.com/api/get_project_details';
    final Uri uri = Uri.parse(url);

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'project_id': project_id,
      'rating': rating,

    };

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields.addAll(body);

    // Add images to the request
    for (var imagePath in imagesPaths) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    for (var videoPath in videosPaths) {
      request.files.add(await http.MultipartFile.fromPath('video', videoPath));
    }

    // Add videos to the request
    // for (var videoPath in videosPaths) {
    //   request.files.add(await http.MultipartFile.fromPath('videos[]', videoPath));
    // }

    try {
      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post a project. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error during post a project: $error');
    }
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
  final String liked; // Assuming the 'liked' field should be a boolean
   int numberOfLikes;
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
      liked: baseData['liked'] ?? 'true',
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
  final String avg_rating;

  ClientData({
    required this.clientId,
    required this.firstname,
    required this.lastname,
    required this.avg_rating,
    required this.profileImage,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['client_id'] as int? ?? 0,
      firstname: json['firstname'] ?? '',
      avg_rating: json['avg_rating'] ?? '',
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
  final int ratingOnWorker;
  final String reviewOnClient;
  final String schedule;
  final int ratingOnClient;
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
      ratingOnWorker: json['rating_on_worker'] ?? 0,
      reviewOnClient: json['review_on_client'] ?? '',
      ratingOnClient: json['rating_on_client'] ?? 0,
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
  final String avg_rating;

  select_worker_bid({required this.worker_id
  ,required this.worker_firstname
    ,required this.worker_profile_pic
    ,required this.amount
    ,required this.comment
    ,required this.avg_rating

  });

  factory select_worker_bid.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return select_worker_bid(
        worker_id: 0,
        worker_firstname: '',
        worker_profile_pic: '',
        amount: 0,
        comment: '',
        avg_rating: '',
      );
    }

    return select_worker_bid(worker_id: json['worker_id'] ?? 0,
        worker_firstname: json['worker_firstname']?? ''
        ,worker_profile_pic: json['worker_profile_pic']?? '',
        avg_rating: json['avg_rating']?? '',
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
  final String avg_rating;
  final ClientData clientData;
  final PageContent pageContent;

  Bid({
    required this.workerId,
    required this.clientData,
    required this.pageContent,
    required this.workerFirstname,
    required this.workerProfilePic,
    required this.avg_rating,
    required this.amount,
    required this.comment,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    var pageContent = json['page_content'] as Map<String, dynamic>? ?? {};

    return Bid(
      workerId: json['worker_id'] as int? ?? 0,
      workerFirstname: json['worker_firstname'] ?? '',
      avg_rating: json['avg_rating'] ?? '',
      workerProfilePic: json['worker_profile_pic'] ?? 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      comment: json['comment'] ?? '',
      clientData: ClientData.fromJson(json['client_info'] as Map<String, dynamic>? ?? {}),
      pageContent: PageContent.fromJson(pageContent),
    );
  }}

class OTPDisplay extends StatelessWidget {
  final List<String> digits;

  OTPDisplay({required this.digits});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (String digit in digits) ...[
          Container(
            width: 73,
            height: 100,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color:HexColor('DFE2E8')),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                digit,
    style: GoogleFonts.ibmPlexSans(
    textStyle: TextStyle(
    color: HexColor('454545'),
    fontSize: 50,
    fontWeight: FontWeight.w400,
    ),
    ),

              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ModernPopup extends StatelessWidget {
  final String text;

  const ModernPopup({
    Key? key,
    required

    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 200,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,

          style: GoogleFonts
              .roboto(
          textStyle:
          TextStyle(
          color:
          Colors.black,
          fontSize: 19,
          fontWeight:
          FontWeight
          .bold,
        ),
      ),

            ),
            Container(
              width: 100.0,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: HexColor('1AA251'), // Adjust opacity here
                  onPrimary: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Okay',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final int rating;

  const RatingDisplay({  required this.rating}) ;

  @override
  Widget build(BuildContext context) {
    final int ratingInt = rating.clamp(0.0, 5.0).toInt();
    final int ratingFrac = rating - ratingInt;
    return Row(
      children: List.generate(5, (index) {
        if (index < ratingInt) {
          return Icon(
            Icons.star,
            color: Colors.yellow,
          );
        } else if (index == ratingInt && ratingFrac > 0) {
          return Icon(
            Icons.star_half , color: Colors.yellow,

          );
        } else {
          return Icon(
            Icons.star_border,
            color: Colors.yellow,
          );
        }
      }),
    );
  }
}