import 'dart:async';
import 'dart:convert';

import 'package:action_slider/action_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';
import 'package:workdone/view/screens/Screens_layout/layoutWorker.dart';
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

class _bidDetailsWorkerState extends State<bidDetailsWorker>  with SingleTickerProviderStateMixin {
  bool showAdditionalContent = false;
  bool showprojectcomplete = false;
  bool accessprojectcomplete = false;
  bool disableverfication = false;
  String rating = '';
  final reviewcontroller = TextEditingController();

  SfRangeValues _values = SfRangeValues(
      DateTime(2000, 01, 01, 07, 00, 00), DateTime(2000, 01, 01, 17, 00, 00));
  DateTime dateTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController otpControlleraccessproject = TextEditingController();

  String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  final StreamController<ProjectData> projectDetailsController = StreamController<ProjectData>();

  late Future<ProjectData> projectDetailsFuture;
  String client_id = '';
  String worker_id = '';
  List<String> projectimage=[];
  String projecttitle = '';
  String projectdesc = '';
  String selectedworkername = '';
  String selectedworkerimage = '';
  String owner = '';

  late ScrollController scrollController;
  late ScrollController scrollController2;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();
  SlidingUpPanelController panelController2 = SlidingUpPanelController();

  double minBound = 0;

  double upperBound = 1.0;
  Future<void> changeScheduleStatus(int projectId, String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final url = Uri.parse('https://www.workdonecorp.com/api/change_schedule_status'); // Replace with the actual base URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: json.encode({
        'project_id': projectId,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => bidDetailsWorker(projectId: projectId)));

      print(responseBody);
    } else {
      // Handle the error; the server didn't return a 200 OK response.
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  void showResponseDialog({required BuildContext context, required bool isSuccess, String message = ''}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView( // Making the AlertDialog scrollable
          child: ListBody(
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: 'assets/loading.gif', // Local asset image as placeholder
                image: isSuccess
                    ? 'https://cdn.pixabay.com/photo/2012/04/23/16/14/correct-38751_1280.png'
                    : 'https://cdn.pixabay.com/photo/2017/02/12/21/29/false-2061131_1280.png',
                width: 150, // Preferred width for the image
                height: 150, // Preferred height for the image
              ),
              SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => bidDetailsWorker(projectId: widget.projectId)));
                  if (isSuccess) {
                    // Navigate to the next page or perform an action if necessary
                  }
                },
                child: Text(isSuccess ? 'Let\'s Start' : 'Okay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  bool showFirstSheet = true;

  Future<void> verify_project_schedule(int projectId, int vc) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final url = Uri.parse('https://www.workdonecorp.com/api/verify_project_schedule'); // Replace with the actual base URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: json.encode({
        'project_id': projectId,
        'vc': vc,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        showResponseDialog(
          context: context,
          isSuccess: true,
          message: 'Nice, Project is Now Processing',
        );

      } else {
        showResponseDialog(
          context: context,
          isSuccess: false,
          message: 'Oops, it looks like the code was not correct. Please try again.',
        );
      }
    } else {
      // Handle the error; the server didn't return a 200 OK response.
      print('Request failed with status: ${response.statusCode}.');
      showResponseDialog(
        context: context,
        isSuccess: false,
        message: 'Something went wrong. Please try again later.',
      );
    }
  }

  Future<void> Reviewproject() async {
    print('Fetching user token from SharedPreferences...');


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? '';

    print('Creating request...');
    // Define headers in a map
    final headers = <String, String>{
      'Authorization': 'Bearer $userToken',
      // 'Content-Type': 'multipart/form-data', This is added automatically when adding files to the MultipartRequest.
    };

    var request = http.MultipartRequest('POST', Uri.parse('https://www.workdonecorp.com/api/worker_make_review_on_client'))
      ..headers.addAll(headers)
      ..fields['project_id'] = widget.projectId.toString()
      ..fields['review'] = reviewcontroller.text
      ..fields['rating'] = rating.toString();


    print('Checking for files...');
    // Check if any files are null or empty before proceeding


    // Add video if not null


    // Add images if any
    print('Request fields: ${request.fields}');
    print('Request files: ${request.files.length}');
    print('Sending request...');
    try {

      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      var streamedResponse = await request.send();

      print('Request sent. Status code: ${streamedResponse.statusCode}');
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        setState(() {
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => layoutworker(),
          ),
        );

        // Handle success
      } else {
        print('Failed with status code: ${response.statusCode}');

        // Handle failure
      }
    } catch (e) {
      print('An exception occurred: $e');
      // Handle exception
    }
  }

  Future<void> verify_Project_complete(int projectId, int vc) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';

    final url = Uri.parse('https://www.workdonecorp.com/api/verify_project_finalizing'); // Replace with the actual base URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: json.encode({
        'project_id': projectId,
        'vc': vc,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        showResponseDialog(
          context: context,
          isSuccess: true,
          message: 'Nice , Verification code is correct \n Now you can access the project complete button to end or finish the project ',
        );

      } else {
        showResponseDialog(
          context: context,
          isSuccess: false,
          message: 'Oops, it looks like the code was not correct. Please try again.',
        );
      }
    } else {
      // Handle the error; the server didn't return a 200 OK response.
      print('Request failed with status: ${response.statusCode}.');
      showResponseDialog(
        context: context,
        isSuccess: false,
        message: 'Something went wrong. Please try again later.',
      );
    }
  }

  Future<void> scheduleProject(
      int projectId, String selectedDay, String selectedInterval) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('user_token') ?? '';
    final url = Uri.parse(
        'https://www.workdonecorp.com/api/schedule_project'); // Replace with actual URL
    final body = jsonEncode({
      'project_id': projectId,
      'selected_day': selectedDay.toString(),
      'selected_interval': selectedInterval.toString()
    });

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: body);

    if (response.statusCode == 200) {
      // Handle successful response
      await fetchProjectDetails(projectId); // Call fetchProjectDetails here
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => bidDetailsWorker(projectId: projectId)));

      print('Schedule sent successfully!');
    } else {
      // Handle error
      print('Schedule failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
  late Future<ProjectData> futureProjects;
  void refreshProjects() async{
    futureProjects = fetchProjectDetails(widget.projectId);
  }
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
        final message =
            responseData != null ? responseData['message'] : 'Unknown error';
        throw Exception('Failed to load project details from API: $message');
      }
    } else {
      // The statusCode is not 200, handle the error here.
      final message = response.body.isNotEmpty
          ? json.decode(response.body)['message']
          : 'No error message provided';
      throw Exception(
          'Failed to load project details. Status code: ${response.statusCode}, Message: $message');
    }
  }
  void fetchAndPushProjectDetails(int projectId) {
    fetchProjectDetails(projectId).then((data) {
      projectDetailsController.add(data);
    }).catchError((error) {
      projectDetailsController.addError(error);
    });
  }
  String video ='';
  bool _videoInitialized = false;
  late ChewieController _chewieController;
  int activeStep = 0;

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

  @override
  void initState() {
    super.initState();
    int projectId =widget.projectId;
      futureProjects = fetchProjectDetails(projectId);

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
    projectDetailsFuture =
        fetchProjectDetails(projectId);
    fetchAndPushProjectDetails(projectId);
    fetchvideo();
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);



    fetchData();
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
    projectDetailsController.close();
    ciruclaranimation.dispose();

  }


  String currentbid = '24';
  final ScreenshotController screenshotController = ScreenshotController();

  String unique = 'biddetailsworker';

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupportScreen(screenshotImageBytes: imageBytes, unique: unique),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    // Define the focus nodes for each text field
    FocusNode focusNode1 = FocusNode();
    FocusNode focusNode2 = FocusNode();
    FocusNode focusNode3 = FocusNode();
    FocusNode focusNode4 = FocusNode();
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double heightAvailable = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    // These functions help to change focus from one text field to the next.
    // They are passed to onChanged property of the text fields.
    void nextField({required String value, FocusNode? focusNode}) {
      if (value.length == 1) {
        focusNode?.requestFocus();
      }
    }
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Stack(children: <Widget>[
      Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true, // This line should be present

        backgroundColor: HexColor('FFFFFF'),
        appBar: AppBar(
          backgroundColor: HexColor('FFFFFF'),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          toolbarHeight: 60,
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
        body: Screenshot(
          controller: screenshotController,
          child: RefreshIndicator(
            color: HexColor('4D8D6E'),
            backgroundColor: Colors.white,
            onRefresh: () async {
              setState(() {
                futureProjects = fetchProjectDetails(widget.projectId);
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: FutureBuilder<ProjectData>(
                    future: projectDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return   Center(child: RotationTransition(
                          turns: ciruclaranimation,
                          child: SvgPicture.asset(
                            'assets/images/Logo.svg',
                            semanticsLabel: 'Your SVG Image',
                            width: 100,
                            height: 130,
                          ),
                        ))
                        ;
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data available'));
                      } else {
                        ProjectData projectData = snapshot.data!;
                        currentbid = projectData.lowestBid.toString();
                        client_id = projectData.clientData!.clientId.toString();
                        projectimage = projectData.images;
                        ;
                        selectedworkername=projectData.selectworkerbid.worker_firstname;
                        selectedworkerimage=projectData.selectworkerbid.worker_profile_pic;
                        projecttitle = projectData.title.toString();
                        ;
                        projectdesc = projectData.desc.toString();
                        video = projectData.video;

                        owner = projectData.clientData!.firstname.toString();
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  scrollDirection: Axis.horizontal,
                                ),
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
                                                  :    Center(child: RotationTransition(
                                                turns: ciruclaranimation,
                                                child: SvgPicture.asset(
                                                  'assets/images/Logo.svg',
                                                  semanticsLabel: 'Your SVG Image',
                                                  width: 100,
                                                  height: 130,
                                                ),
                                              ))
                                              ,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  if (projectData.video.isEmpty)
                                    Center(
                                      child:    Center(child: RotationTransition(
                                        turns: ciruclaranimation,
                                        child: SvgPicture.asset(
                                          'assets/images/Logo.svg',
                                          semanticsLabel: 'Your SVG Image',
                                          width: 100,
                                          height: 130,
                                        ),
                                      ))
                                      ,
                                    ),
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
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40,
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
                                      color: HexColor('A37A29'),
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
                              ),                           SizedBox(
                                height: 12,
                              ),
                              Container(
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
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 23,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: projectData.clientData.profileImage == 'https://workdonecorp.com/images/'
                                        ? AssetImage('assets/images/default.png') as ImageProvider
                                        : NetworkImage(projectData.clientData.profileImage ?? 'assets/images/default.png'),
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
                                          fontSize: 19,
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
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
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
                              SizedBox(
                                height: 17,
                              ),

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
                                              backgroundImage: projectData.selectworkerbid.worker_profile_pic == 'https://workdonecorp.com/images/' ||projectData.selectworkerbid.worker_profile_pic == ''
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
                                                        Get.to(ProfilePageClient(
                                                            userId: projectData
                                                                .selectworkerbid!.worker_id
                                                                .toString()));
                                                      },
                                                      child: Text(
                                                        projectData.selectworkerbid.worker_firstname,
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
                                                    Text('0'),
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

                              SizedBox(
                                height: 20,
                              ),
                              StreamBuilder<ProjectData>(
                                stream: projectDetailsController.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    return Center(child: Text('Error: ${snapshot.error}'));
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

                                    double ratingonclient = double.tryParse(projectData.pageContent.ratingOnClient ?? "0") ?? 0;
                                    double ratingonworker = double.tryParse(projectData.pageContent.ratingOnWorker ?? "0") ?? 0;

                                    if (projectData.pageContent.scheduleStatus == "pending") {

                                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                                        showModalBottomSheet(
                                          context: context,
                                          isDismissible: false, // User must tap a button to dismiss
                                          enableDrag: false, // The bottom sheet cannot be dragged down
                                          builder: (BuildContext context) {
                                            return SafeArea(
                                              child: Column(

                                                mainAxisSize: MainAxisSize.min, // Use minimum space necessary
                                                children: [
                                                  Text('Date',
                                                      style: TextStyle(fontSize: 30,color: HexColor('4D8D6E'), fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 12,),
                                                  Text('${projectData.pageContent.selectedDate}',style: GoogleFonts.openSans(
                                                    textStyle: TextStyle(
                                                      color: HexColor('353B3B'),
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  ),
                                                  SizedBox(height: 20,),

                                                  Text('Time Interval',
                                                      style: TextStyle(fontSize: 30,color: HexColor('4D8D6E'), fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 12,),

                                                  Text('${projectData.pageContent.selectedInterval}',style: GoogleFonts.openSans(
                                                    textStyle: TextStyle(
                                                      color: HexColor('353B3B'),
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  ),
                                                  SizedBox(height: 20,),

                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                    child: Text(
                                                      """Thank you for reviewing the client's schedule. Please confirm your availability for the selected date and time, or choose an alternative slot.\n \nIf you are unable to accept the proposed schedule, kindly click "Decline" and proceed to the chat to discuss a new date or time with the client. Open communication is key to finding a suitable arrangement that works for both parties.""",
                                                      textAlign: TextAlign.center, // Set the text alignment to center
                                                      style: TextStyle(
                                                        // Define your text style here
                                                        fontSize: 13, // Example: setting font size
                                                        // fontWeight: FontWeight.bold, // Example: setting font weight
                                                        // color: Colors.black, // Example: setting text color
                                                      ),
                                                    ),
                                                  ),

                                                  Spacer(), // Puts space between the texts above and the buttons below
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      SizedBox(
                                                        height: 50,
                                                        width: 120,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            // TODO: Handle accept logic
                                                            setState(() {
                                                              changeScheduleStatus(widget.projectId, 'accepted'); // Call the function with the required project_id and status

                                                            });

                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            primary: HexColor('4D8D6E'), // Accept button color
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12), // Adjust the radius to make it circular
                                                            ),
                                                          ),
                                                          child: Text('Accept',style: TextStyle(color: Colors.white),),
                                                        ),
                                                      ),


                                                      SizedBox(
                                                        height: 50,
                                                        width: 120,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            // TODO: Handle decline logic
                                                            Navigator.pop(context); // Close the initial bottom sheet

                                                            // Show a different bottom sheet after declining
                                                            WidgetsBinding.instance?.addPostFrameCallback((_) {
                                                              showModalBottomSheet(
                                                                context: context,
                                                                isScrollControlled: true,
                                                                isDismissible: false,
                                                                enableDrag: false,
                                                                builder: (BuildContext context) {
                                                                  return SafeArea(
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        SizedBox(height: 17,),
                                                                    Row(
                                                                      children: [
                                                                        IconButton(onPressed: (){
                                                                          Navigator.of(context).pop(); // Pops the current bottom sheet
                WidgetsBinding.instance?.addPostFrameCallback((_) {
                                                                            showModalBottomSheet(
                                                                              context: context,
                                                                              isDismissible: false, // User must tap a button to dismiss
                                                                              enableDrag: false, // The bottom sheet cannot be dragged down
                                                                              builder: (BuildContext context) {
                                                                                return SafeArea(
                                                                                  child: Column(

                                                                                    mainAxisSize: MainAxisSize.min, // Use minimum space necessary
                                                                                    children: [
                                                                                      Text('Date',
                                                                                          style: TextStyle(fontSize: 30,color: HexColor('4D8D6E'), fontWeight: FontWeight.bold)),
                                                                                      SizedBox(height: 12,),
                                                                                      Text('${projectData.pageContent.selectedDate}',style: GoogleFonts.openSans(
                                                                                        textStyle: TextStyle(
                                                                                          color: HexColor('353B3B'),
                                                                                          fontSize: 17,
                                                                                          fontWeight: FontWeight.w500,
                                                                                        ),
                                                                                      ),
                                                                                      ),
                                                                                      SizedBox(height: 20,),

                                                                                      Text('Time Interval',
                                                                                          style: TextStyle(fontSize: 30,color: HexColor('4D8D6E'), fontWeight: FontWeight.bold)),
                                                                                      SizedBox(height: 12,),

                                                                                      Text('${projectData.pageContent.selectedInterval}',style: GoogleFonts.openSans(
                                                                                        textStyle: TextStyle(
                                                                                          color: HexColor('353B3B'),
                                                                                          fontSize: 17,
                                                                                          fontWeight: FontWeight.w500,
                                                                                        ),
                                                                                      ),
                                                                                      ),
                                                                                      SizedBox(height: 20,),

                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                                                        child: Text(
                                                                                          """Thank you for reviewing the client's schedule. Please confirm your availability for the selected date and time, or choose an alternative slot.\n \nIf you are unable to accept the proposed schedule, kindly click "Decline" and proceed to the chat to discuss a new date or time with the client. Open communication is key to finding a suitable arrangement that works for both parties.""",
                                                                                          textAlign: TextAlign.center, // Set the text alignment to center
                                                                                          style: TextStyle(
                                                                                            // Define your text style here
                                                                                            fontSize: 13, // Example: setting font size
                                                                                            // fontWeight: FontWeight.bold, // Example: setting font weight
                                                                                            // color: Colors.black, // Example: setting text color
                                                                                          ),
                                                                                        ),
                                                                                      ),

                                                                                      Spacer(), // Puts space between the texts above and the buttons below
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            height: 50,
                                                                                            width: 120,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () {
                                                                                                // TODO: Handle accept logic
                                                                                                setState(() {
                                                                                                  changeScheduleStatus(widget.projectId, 'accepted'); // Call the function with the required project_id and status

                                                                                                });

                                                                                              },
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: HexColor('4D8D6E'), // Accept button color
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(12), // Adjust the radius to make it circular
                                                                                                ),
                                                                                              ),
                                                                                              child: Text('Accept',style: TextStyle(color: Colors.white),),
                                                                                            ),
                                                                                          ),


                                                                                          SizedBox(
                                                                                            height: 50,
                                                                                            width: 120,
                                                                                            child: ElevatedButton(
                                                                                              onPressed: () {
                                                                                                // TODO: Handle decline logic
                                                                                                Navigator.pop(context); // Close the initial bottom sheet

                                                                                                // Show a different bottom sheet after declining
                                                                                                WidgetsBinding.instance?.addPostFrameCallback((_) {
                                                                                                  showModalBottomSheet(
                                                                                                    context: context,
                                                                                                    isScrollControlled: true,
                                                                                                    isDismissible: false,
                                                                                                    enableDrag: false,
                                                                                                    builder: (BuildContext context) {
                                                                                                      return SafeArea(
                                                                                                        child: Column(
                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                          children: [
                                                                                                            SizedBox(height: 17,),
                                                                                                            Row(
                                                                                                              children: [
                                                                                                                IconButton(onPressed: (){
                                                                                                                  Navigator.of(context).pop(); // Pops the current bottom sheet

                                                                                                                }, icon: Icon(AntDesign.arrowleft)),
                                                                                                                Spacer(),
                                                                                                                Text(
                                                                                                                  'Chat with Client',
                                                                                                                  style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
                                                                                                                  textAlign: TextAlign.center,
                                                                                                                ),
                                                                                                                Spacer(),

                                                                                                              ],
                                                                                                            ),
                                                                                                            SizedBox(height: 8),
                                                                                                            Text(
                                                                                                              'Discuss a new date or time with the client through chat.',
                                                                                                              textAlign: TextAlign.center,
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 15,
                                                                                                                color: Colors.black45,
                                                                                                              ),),
                                                                                                            SizedBox(height: 20,),
                                                                                                            Padding(
                                                                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  Expanded(
                                                                                                                    child: ElevatedButton(
                                                                                                                      onPressed: () {
                                                                                                                        Get.to(ChatScreen(
                                                                                                                            seconduserimage: projectData.selectworkerbid.worker_profile_pic,
                                                                                                                            chatId: projectData.pageaccessdata!.chat_ID,
                                                                                                                            currentUser: projectData.selectworkerbid.worker_firstname,
                                                                                                                            secondUserName: projectData.clientData!.firstname,
                                                                                                                            userId: projectData.selectworkerbid.worker_id.toString()
                                                                                                                        ));
                                                                                                                      },
                                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                                        primary: HexColor('ED6F53'),
                                                                                                                        onPrimary: Colors.white,
                                                                                                                        elevation: 5,
                                                                                                                        shape: RoundedRectangleBorder(
                                                                                                                          borderRadius: BorderRadius.circular(12),
                                                                                                                        ),
                                                                                                                        fixedSize: Size(70, 50), // Set the desired width and height
                                                                                                                      ),
                                                                                                                      child: Text(
                                                                                                                        'Chat',
                                                                                                                        style: TextStyle(fontSize: 10),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  SizedBox(width: 12),
                                                                                                                  Expanded(
                                                                                                                    child: Hero(
                                                                                                                      tag: 'workdone_$unique',
                                                                                                                      child: Container(
                                                                                                                        height: 50,
                                                                                                                        width: 80, // Set the desired width
                                                                                                                        child: ElevatedButton(
                                                                                                                          onPressed: () {
                                                                                                                            _navigateToNextPage(context);
                                                                                                                          },
                                                                                                                          style: ElevatedButton.styleFrom(
                                                                                                                            primary: HexColor('777031'),
                                                                                                                            onPrimary: Colors.white,
                                                                                                                            elevation: 8,
                                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                              borderRadius: BorderRadius.circular(21),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                          child: Text(
                                                                                                                            'Support',
                                                                                                                            style: GoogleFonts.roboto(
                                                                                                                              textStyle: TextStyle(
                                                                                                                                color: Colors.white,
                                                                                                                                fontSize: 8.5,
                                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                              ),
                                                                                                                            ), // Add ellipsis (...) for overflow
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),

                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(height: 40,),

                                                                                                          ],
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                  );
                                                                                                });
                                                                                              },

                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: Colors.red, // Accept button color
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(12), // Adjust the radius to make it circular
                                                                                                ),
                                                                                              ),
                                                                                              child: Text('Decline',style: TextStyle(color: Colors.white),),
                                                                                            ),
                                                                                          ),

                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(height: 20,)
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          });
                                                                        }, icon: Icon(AntDesign.arrowleft)),
                                                                        Spacer(),
                                                                        Text(
                                                                          'Chat with Client',
                                                                          style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        Spacer(),

                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 8),
                                                                    Text(
                                                                      'Discuss a new date or time with the client through chat.',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors.black45,
                                                                      ),),
                                                                        SizedBox(height: 20,),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Expanded(
                                                                                child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Get.to(ChatScreen(
                                                                                        seconduserimage: projectData.selectworkerbid.worker_profile_pic,
                                                                                        chatId: projectData.pageaccessdata!.chat_ID,
                                                                                        currentUser: projectData.selectworkerbid.worker_firstname,
                                                                                        secondUserName: projectData.clientData!.firstname,
                                                                                        userId: projectData.selectworkerbid.worker_id.toString()
                                                                                    ));
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    primary: HexColor('ED6F53'),
                                                                                    onPrimary: Colors.white,
                                                                                    elevation: 5,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                    ),
                                                                                    fixedSize: Size(70, 50), // Set the desired width and height
                                                                                  ),
                                                                                  child: Text(
                                                                                    'Chat',
                                                                                    style: TextStyle(fontSize: 10),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 12),
                                                                              Expanded(
                                                                                child: Hero(
                                                                                  tag: 'workdone_$unique',
                                                                                  child: Container(
                                                                                    height: 50,
                                                                                    width: 80, // Set the desired width
                                                                                    child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        _navigateToNextPage(context);
                                                                                      },
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        primary: HexColor('777031'),
                                                                                        onPrimary: Colors.white,
                                                                                        elevation: 8,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(21),
                                                                                        ),
                                                                                      ),
                                                                                      child: Text(
                                                                                        'Support',
                                                                                        style: GoogleFonts.roboto(
                                                                                          textStyle: TextStyle(
                                                                                            color: Colors.white,
                                                                                            fontSize: 8.5,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ), // Add ellipsis (...) for overflow
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 40,),

                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            });
                                                          },

                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.red, // Accept button color
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12), // Adjust the radius to make it circular
                                                            ),
                                                          ),
                                                          child: Text('Decline',style: TextStyle(color: Colors.white),),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  SizedBox(height: 20,)
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      });
                                    }




                                    if (projectData.pageContent.currentUserRole ==
                                            'worker' &&
                                        (projectData.status == 'bid_accepted'
                                    )&&   (projectData.pageContent.schedule_vc== 'ma2foul'
                                    )) {
            activeStep=1;                                    return Column(
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
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Get.to(ChatScreen(
                                                    seconduserimage: projectData.selectworkerbid.worker_profile_pic,
                                                    chatId: projectData.pageaccessdata!.chat_ID,
                                                    currentUser: projectData.selectworkerbid.worker_firstname,
                                                    secondUserName: projectData.clientData!.firstname,
                                                    userId: projectData.selectworkerbid.worker_id.toString()
                                                  ));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: HexColor('ED6F53'),
                                                  onPrimary: Colors.white,
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  fixedSize: Size(70, 50), // Set the desired width and height
                                                ),
                                                child: Text(
                                                  'Chat',
                                                  style: TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1.3, // Adjust the border width as needed
                                                    ),
                                                    borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
                                                    child: Center(
                                                      child: Text(
                                                        'Wait for the Client to Schedule time \& date \n or Go to the chat to discuss work timing',
                                                        style: TextStyle(fontSize: 8 ,fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Hero(
                                                tag: 'workdone_$unique',
                                                child: Container(
                                                  height: 50,
                                                  width: 80, // Set the desired width
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _navigateToNextPage(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('777031'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(21),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Support',
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ), // Add ellipsis (...) for overflow
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 9,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition
                                                  opacity: projectData.pageContent.enter_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    // Disable or enable the button based on the condition
                                                    onPressed: projectData.pageContent.enter_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otp = int.tryParse(otpController.text) ?? 0;

                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return Container(
                                                                padding: EdgeInsets.all(16.0),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Center(child: Text('Write a \n Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                    SizedBox(height: 12,),

                                                                    Text('Take verification code from client ' , style: TextStyle(fontSize: 19, color: HexColor('706F6F') , fontWeight: FontWeight.normal),),
                                                                    SizedBox(height: 25),
                                                                    Pinput(
                                                                      length: 4, // The total length of the OTP
                                                                      controller: otpController, // The single controller for the OTP
                                                                      focusNode: focusNode1, // Current focus node
                                                                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                      onCompleted: (pin) {
                                                                        // You can use the entered OTP for verification when the user has completed entering it.
                                                                        print('Completed: $pin');
                                                                      },
                                                                      // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                      onSubmitted: (pin) {
                                                                        // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                      },
                                                                    ),

                                                                    SizedBox(height: 30),
                                                                    Center(
                                                                      child: ElevatedButton(
                                                                        onPressed:
                                                                            () {

                                                                          verify_project_schedule (widget.projectId,otp);
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
                                                                          'Confirm',
                                                                          style: TextStyle(fontSize: 18),
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
                                                    } : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('B6B021'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Text(
                                                      'With the client! Let\'s Enter the Verification Code',
                                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 9,
                                          ),


                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition for the second button
                                                  opacity: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otpaccessprojectcomplete = int.tryParse(otpControlleraccessproject.text) ?? 0;
                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                      Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                                                      SizedBox(height: 12,),

                                                                      Center(
                                                                        child: Text(
                                                                          'Take verification code from client\nTo Start Work',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: HexColor('706F6F'),
                                                                            fontWeight: FontWeight.normal,
                                                                          ),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Pinput(
                                                                        length: 4, // The total length of the OTP
                                                                        controller: otpControlleraccessproject, // The single controller for the OTP
                                                                        focusNode: focusNode1, // Current focus node
                                                                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                        onCompleted: (pin) {
                                                                          // You can use the entered OTP for verification when the user has completed entering it.
                                                                          print('Completed: $pin');
                                                                        },
                                                                        // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                        onSubmitted: (pin) {
                                                                          // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                        },
                                                                        pinAnimationType: PinAnimationType.rotation,
                                                                        defaultPinTheme: PinTheme(
                                                                          width: 60, // Example width of the field, adjust accordingly
                                                                          height: 70, // Example height of the field, adjust accordingly
                                                                          textStyle: TextStyle(
                                                                              fontSize: 24,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold // Text is bold
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                                                            borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                                                          ),
                                                                        ),),

                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: ElevatedButton(
                                                                          onPressed:
                                                                              () {

                                                                            verify_Project_complete (widget.projectId,otpaccessprojectcomplete);
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
                                                                            'Confirm',
                                                                            style: TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } : null, // The button will be disabled if the condition is false
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('317773'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Generate the Verification Code to access project complete',
                                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),



                                          SizedBox(
                                            height: 9,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: projectData.pageContent. project_complete_button == "maftoo7"
                                                      ? () {
                                                    panelController.expand();
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
            SizedBox(height: 20,),
                                          Padding(
                                            padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: Row(
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
                                          ),
                                          SizedBox(height: 12,),
                                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: projectData.bids.length,
                                  itemBuilder: (context, index) {
                                  Bid bid = projectData.bids[index];
                                  return buildListItem(bid);
                                  },
                                  ),
                                        ],
                                      );
                                    }

                                    else if (  projectData.status == 'scheduled' && projectData.pageContent.scheduleStatus == 'accepted'){
                                      activeStep=2;

                                    return  Column(
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
                                          SizedBox(height: 8,),
                                          Center(
                                            child: Container(
                                              width: double.infinity, // Set your desired width
                                              height: 86, // Set your desired height
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(20), // Half of the width or height to make it circular

                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('Date : ',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),),
                                                      SizedBox(width: 8), // Adjust spacing between text widgets
                                                      Text('${projectData.pageContent.selectedDate}',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.grey[800],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('Time (Interval): ',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),),
                                                      SizedBox(width: 8), // Adjust spacing between text widgets
                                                      Text('${projectData.pageContent.selectedInterval}',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.grey[800],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
            ,
                                          SizedBox(
                                            height: 9,
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.to(ChatScreen(
                                                        seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                        chatId: projectData.pageaccessdata!.chat_ID,
                                                        currentUser: projectData.selectworkerbid.worker_firstname,
                                                        secondUserName: projectData.clientData!.firstname,
                                                        userId: projectData.selectworkerbid.worker_id.toString()
                                                    ));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: HexColor('ED6F53'),
                                                    onPrimary: Colors.white,
                                                    elevation: 5,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    fixedSize: Size(70, 50), // Set the desired width and height
                                                  ),
                                                  child: Text(
                                                    'Chat',
                                                    style: TextStyle(fontSize: 10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              SizedBox(width: 5),
                                              Hero(
                                                tag: 'workdone_$unique',
                                                child: Container(
                                                  height: 50,
                                                  width: 80, // Set the desired width
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _navigateToNextPage(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('777031'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(21),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Support',
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ), // Add ellipsis (...) for overflow
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            height: 9,
                                          ),



                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition
                                                  opacity: projectData.pageContent.enter_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    // Disable or enable the button based on the condition
                                                    onPressed: projectData.pageContent.enter_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otp = int.tryParse(otpController.text) ?? 0;

                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                      Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                                                      SizedBox(height: 12,),

                                                                      Center(
                                                                        child: Text(
                                                                          'Take verification code from client\nTo Start Work',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: HexColor('706F6F'),
                                                                            fontWeight: FontWeight.normal,
                                                                          ),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Pinput(
                                                                        length: 4, // The total length of the OTP
                                                                        controller: otpController, // The single controller for the OTP
                                                                        focusNode: focusNode1, // Current focus node
                                                                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                        onCompleted: (pin) {
                                                                          // You can use the entered OTP for verification when the user has completed entering it.
                                                                          print('Completed: $pin');
                                                                        },
                                                                        // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                        onSubmitted: (pin) {
                                                                          // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                        },
                                                                        pinAnimationType: PinAnimationType.rotation,
                                                                        defaultPinTheme: PinTheme(
                                                                          width: 60, // Example width of the field, adjust accordingly
                                                                          height: 70, // Example height of the field, adjust accordingly
                                                                          textStyle: TextStyle(
                                                                              fontSize: 24,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold // Text is bold
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                                                            borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                                                          ),
                                                                        ),),

                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: ElevatedButton(
                                                                          onPressed:
                                                                              () {

                                                                            verify_project_schedule (widget.projectId,otp);
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
                                                                            'Confirm',
                                                                            style: TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('B6B021'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Text(
                                                      'With the client! Let\'s Enter the Verification Code',
                                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 9,
                                          ),


                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition for the second button
                                                  opacity: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otpaccessprojectcomplete = int.tryParse(otpControlleraccessproject.text) ?? 0;
                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                      Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                                                      SizedBox(height: 12,),

                                                                      Center(
                                                                        child: Text(
                                                                          'Take verification code from client\nTo Start Work',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: HexColor('706F6F'),
                                                                            fontWeight: FontWeight.normal,
                                                                          ),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Pinput(
                                                                        length: 4, // The total length of the OTP
                                                                        controller: otpControlleraccessproject, // The single controller for the OTP
                                                                        focusNode: focusNode1, // Current focus node
                                                                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                        onCompleted: (pin) {
                                                                          // You can use the entered OTP for verification when the user has completed entering it.
                                                                          print('Completed: $pin');
                                                                        },
                                                                        // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                        onSubmitted: (pin) {
                                                                          // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                        },
                                                                        pinAnimationType: PinAnimationType.rotation,
                                                                        defaultPinTheme: PinTheme(
                                                                          width: 60, // Example width of the field, adjust accordingly
                                                                          height: 70, // Example height of the field, adjust accordingly
                                                                          textStyle: TextStyle(
                                                                              fontSize: 24,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold // Text is bold
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                                                            borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                                                          ),
                                                                        ),),

                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: ElevatedButton(
                                                                          onPressed:
                                                                              () {

                                                                            verify_Project_complete (widget.projectId,otpaccessprojectcomplete);
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
                                                                            'Confirm',
                                                                            style: TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } : null, // The button will be disabled if the condition is false
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('317773'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Generate the Verification Code to access project complete',
                                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),



                                          SizedBox(height: 20,),

                                          Padding(
                                            padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: Row(
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
                                          ),
                                          SizedBox(height: 12,),
                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectData.bids.length,
                                            itemBuilder: (context, index) {
                                              Bid bid = projectData.bids[index];
                                              return buildListItem(bid);
                                            },
                                          ),


                                        ],
                                      );

                                    }
                                    else if (  projectData.status == 'processing' && projectData.pageContent.enter_complete_project_verification_code_button == 'mftoo7')
                                    {
                                      activeStep =3;

                                      return  Column(
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
                                          SizedBox(height: 8,),

                                          Center(
                                            child: Container(
                                              width: double.infinity, // Set your desired width
                                              height: 86, // Set your desired height
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(20), // Half of the width or height to make it circular

                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(height: 8,),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [

                                                      Text('Date : ',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),),
                                                      SizedBox(width: 8), // Adjust spacing between text widgets
                                                      Text('${projectData.pageContent.selectedDate}'
                                                        ,style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.grey[800],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('Time (Interval): ',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),),
                                                      SizedBox(width: 8), // Adjust spacing between text widgets
                                                      Text('${projectData.pageContent.selectedInterval}',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: Colors.grey[800],
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          ,
                                          SizedBox(
                                            height: 9,
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.to(ChatScreen(
                                                        seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                                                        chatId: projectData.pageaccessdata!.chat_ID,
                                                        currentUser: projectData.selectworkerbid.worker_firstname,
                                                        secondUserName: projectData.clientData!.firstname,
                                                        userId: projectData.selectworkerbid.worker_id.toString()
                                                    ));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: HexColor('ED6F53'),
                                                    onPrimary: Colors.white,
                                                    elevation: 5,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    fixedSize: Size(70, 50), // Set the desired width and height
                                                  ),
                                                  child: Text(
                                                    'Chat',
                                                    style: TextStyle(fontSize: 10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              SizedBox(width: 5),
                                              Hero(
                                                tag: 'workdone_$unique',
                                                child: Container(
                                                  height: 50,
                                                  width: 80, // Set the desired width
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _navigateToNextPage(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('777031'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(21),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Support',
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ), // Add ellipsis (...) for overflow
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            height: 9,
                                          ),



                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition
                                                  opacity: projectData.pageContent.enter_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    // Disable or enable the button based on the condition
                                                    onPressed: projectData.pageContent.enter_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otp = int.tryParse(otpController.text) ?? 0;

                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                      Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                                                      SizedBox(height: 12,),

                                                                      Center(
                                                                        child: Text(
                                                                          'Take verification code from client\nTo Start Work',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: HexColor('706F6F'),
                                                                            fontWeight: FontWeight.normal,
                                                                          ),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Pinput(
                                                                        length: 4, // The total length of the OTP
                                                                        controller: otpController, // The single controller for the OTP
                                                                        focusNode: focusNode1, // Current focus node
                                                                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                        onCompleted: (pin) {
                                                                          // You can use the entered OTP for verification when the user has completed entering it.
                                                                          print('Completed: $pin');
                                                                        },
                                                                        // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                        onSubmitted: (pin) {
                                                                          // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                        },
                                                                        pinAnimationType: PinAnimationType.rotation,
                                                                        defaultPinTheme: PinTheme(
                                                                          width: 60, // Example width of the field, adjust accordingly
                                                                          height: 70, // Example height of the field, adjust accordingly
                                                                          textStyle: TextStyle(
                                                                              fontSize: 24,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold // Text is bold
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                                                            borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                                                          ),
                                                                        ),),

                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: ElevatedButton(
                                                                          onPressed:
                                                                              () {

                                                                            verify_project_schedule (widget.projectId,otp);
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
                                                                            'Confirm',
                                                                            style: TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } : null,
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('B6B021'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Text(
                                                      'With the client! Let\'s Enter the Verification Code',
                                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 9,
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: Opacity(
                                                  // Change the opacity based on the condition for the second button
                                                  opacity: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                                                  child: ElevatedButton(
                                                    onPressed: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          int otpaccessprojectcomplete = int.tryParse(otpControlleraccessproject.text) ?? 0;
                                                          return StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                                                      Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                                                      SizedBox(height: 12,),

                                                                      Center(
                                                                        child: Text(
                                                                          'Take verification code from client\nTo Start Work',
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: HexColor('706F6F'),
                                                                            fontWeight: FontWeight.normal,
                                                                          ),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 25),
                                                                      Pinput(
                                                                        length: 4, // The total length of the OTP
                                                                        controller: otpControlleraccessproject, // The single controller for the OTP
                                                                        focusNode: focusNode1, // Current focus node
                                                                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                                                        onCompleted: (pin) {
                                                                          // You can use the entered OTP for verification when the user has completed entering it.
                                                                          print('Completed: $pin');
                                                                        },
                                                                        // This function will be called when the input operation is submitted (usually on the keyboard).
                                                                        onSubmitted: (pin) {
                                                                          // Don't forget to validate OTP and then send to API or whatever is required next.
                                                                        },
                                                                        pinAnimationType: PinAnimationType.rotation,
                                                                        defaultPinTheme: PinTheme(
                                                                          width: 60, // Example width of the field, adjust accordingly
                                                                          height: 70, // Example height of the field, adjust accordingly
                                                                          textStyle: TextStyle(
                                                                              fontSize: 24,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold // Text is bold
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                                                            borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                                                          ),
                                                                        ),),

                                                                      SizedBox(height: 30),
                                                                      Center(
                                                                        child: ElevatedButton(
                                                                          onPressed:
                                                                              () {

                                                                                verify_Project_complete (widget.projectId,otpaccessprojectcomplete);
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
                                                                            'Confirm',
                                                                            style: TextStyle(fontSize: 18),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } : null, // The button will be disabled if the condition is false
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('317773'),
                                                      onPrimary: Colors.white,
                                                      elevation: 8,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      fixedSize: Size(double.infinity, 50),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Generate the Verification Code to access project complete',
                                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 9,
                                          ),

                                          SizedBox(height: 20,),
                                          Padding(
                                            padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                                            child: Row(
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
                                          ),
                                          SizedBox(height: 12,),
                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectData.bids.length,
                                            itemBuilder: (context, index) {
                                              Bid bid = projectData.bids[index];
                                              return buildListItem(bid);
                                            },
                                          ),


                                        ],
                                      );


                                    }
                                    else if (  projectData.status == 'finalizing' &&  projectData.pageContent.project_complete_button == 'maftoo7')
            {
              activeStep=4;
              return  Column(
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
                  SizedBox(height: 8,),

                  Center(
                    child: Container(
            width: double.infinity, // Set your desired width
            height: 86, // Set your desired height
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20), // Half of the width or height to make it circular

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Date : ',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),),
                    SizedBox(width: 8), // Adjust spacing between text widgets
                    Text('${projectData.pageContent.selectedDate}',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Time (Interval): ',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),),
                    SizedBox(width: 8), // Adjust spacing between text widgets
                    Text('${projectData.pageContent.selectedInterval}',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),),
                  ],
                ),
              ],
            ),
                    ),
                  ),

                  SizedBox(
                  height: 9,
                  ),


                  SizedBox(
                    height: 9,
                  ),

                  Row(
                    children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(ChatScreen(
                      seconduserimage: projectData.selectworkerbid.worker_profile_pic,

                      chatId: projectData.pageaccessdata!.chat_ID,
                      currentUser: projectData.selectworkerbid.worker_firstname,
                      secondUserName: projectData.clientData!.firstname,
                      userId: projectData.selectworkerbid.worker_id.toString()
                  ));
                },
                style: ElevatedButton.styleFrom(
                  primary: HexColor('ED6F53'),
                  onPrimary: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fixedSize: Size(70, 50), // Set the desired width and height
                ),
                child: Text(
                  'Chat',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(width: 5),
            SizedBox(width: 5),
            Hero(
              tag: 'workdone_$unique',
              child: Container(
                height: 50,
                width: 80, // Set the desired width
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToNextPage(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: HexColor('777031'),
                    onPrimary: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  child: Text(
                    'Support',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Add ellipsis (...) for overflow
                  ),
                ),
              ),
            ),
                    ],
                  ),

                  SizedBox(
                    height: 9,
                  ),



                  Row(
                    children: [
            Expanded(
              child: Opacity(
                // Change the opacity based on the condition
                opacity: projectData.pageContent.enter_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                child: ElevatedButton(
                  // Disable or enable the button based on the condition
                  onPressed: projectData.pageContent.enter_verification_code_button == "mftoo7" ? () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        int otp = int.tryParse(otpController.text) ?? 0;

                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                              ),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                    Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                    SizedBox(height: 12,),

                                    Center(
                                      child: Text(
                                        'Take verification code from client\nTo Start Work',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('706F6F'),
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Pinput(
                                      length: 4, // The total length of the OTP
                                      controller: otpController, // The single controller for the OTP
                                      focusNode: focusNode1, // Current focus node
                                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                      onCompleted: (pin) {
                                        // You can use the entered OTP for verification when the user has completed entering it.
                                        print('Completed: $pin');
                                      },
                                      // This function will be called when the input operation is submitted (usually on the keyboard).
                                      onSubmitted: (pin) {
                                        // Don't forget to validate OTP and then send to API or whatever is required next.
                                      },
                                      pinAnimationType: PinAnimationType.rotation,
                                      defaultPinTheme: PinTheme(
                                        width: 60, // Example width of the field, adjust accordingly
                                        height: 70, // Example height of the field, adjust accordingly
                                        textStyle: TextStyle(
                                            fontSize: 24,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold // Text is bold
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                          borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                        ),
                                      ),),

                                    SizedBox(height: 30),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed:
                                            () {

                                          verify_project_schedule (widget.projectId,otp);
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
                                          'Confirm',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    primary: HexColor('B6B021'),
                    onPrimary: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fixedSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'With the client! Let\'s Enter the Verification Code',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
                    ],
                  ),
                  SizedBox(
                    height: 9,
                  ),

                  Row(
                    children: [
            Expanded(
              child: Opacity(
                // Change the opacity based on the condition for the second button
                opacity: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? 1.0 : 0.5,
                child: ElevatedButton(
                  onPressed: projectData.pageContent.enter_complete_project_verification_code_button == "mftoo7" ? () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        int otpaccessprojectcomplete = int.tryParse(otpControlleraccessproject.text) ?? 0;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding based on the keyboard height
                              ),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Center(child: Text('Write a ' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),
                                    Center(child: Text(' Verification Code' , style: TextStyle(fontSize: 30, color: HexColor('000000') , fontWeight: FontWeight.bold),)),

                                    SizedBox(height: 12,),

                                    Center(
                                      child: Text(
                                        'Take verification code from client\nTo Start Work',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('706F6F'),
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Pinput(
                                      length: 4, // The total length of the OTP
                                      controller: otpControlleraccessproject, // The single controller for the OTP
                                      focusNode: focusNode1, // Current focus node
                                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                      onCompleted: (pin) {
                                        // You can use the entered OTP for verification when the user has completed entering it.
                                        print('Completed: $pin');
                                      },
                                      // This function will be called when the input operation is submitted (usually on the keyboard).
                                      onSubmitted: (pin) {
                                        // Don't forget to validate OTP and then send to API or whatever is required next.
                                      },
                                      pinAnimationType: PinAnimationType.rotation,
                                      defaultPinTheme: PinTheme(
                                        width: 60, // Example width of the field, adjust accordingly
                                        height: 70, // Example height of the field, adjust accordingly
                                        textStyle: TextStyle(
                                            fontSize: 24,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold // Text is bold
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: HexColor('4D8D6E'), width: 2), // Border color as HexColor
                                          borderRadius: BorderRadius.circular(12), // Circular shape with half width/height as radius
                                        ),
                                      ),),

                                    SizedBox(height: 30),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed:
                                            () {

                                          verify_Project_complete (widget.projectId,otpaccessprojectcomplete);
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
                                          'Confirm',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } : null, // The button will be disabled if the condition is false
                  style: ElevatedButton.styleFrom(
                    primary: HexColor('317773'),
                    onPrimary: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fixedSize: Size(double.infinity, 50),
                  ),
                  child: Center(
                    child: Text(
                      'Generate the Verification Code to access project complete',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
                    ],
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Center(
                    child: Visibility(
            visible: projectData.pageContent. project_complete_button == "maftoo7",
            child: Card(
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
                      'Please wait for the client \n to end the project.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Padding(
                    padding:                                   const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
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
                  ),
                  SizedBox(height: 12,),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: projectData.bids.length,
                    itemBuilder: (context, index) {
            Bid bid = projectData.bids[index];
            return buildListItem(bid);
                    },
                  ),


                ],
              );


            }

                                    else if ( projectData.status ==
                                        'completed') {
                                      activeStep=5;
                                      return

                                        Column(
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
                                          projectData.pageContent.ratingOnWorker != '' || projectData.pageContent.reviewOnWorker != ''

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
                                          projectData.pageContent.ratingOnWorker != '' || projectData.pageContent.reviewOnWorker != ''
                                              ? Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 23,
                                                backgroundImage: NetworkImage(
                                                  projectData.clientData?.profileImage ==
                                                      'https://workdonecorp.com/images/'
                                                      ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                                                      : projectData
                                                      .clientData?.profileImage ??
                                                      'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                                                ),
                                              ),
                                              SizedBox(width: 11),
                                              TextButton(
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
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              RatingDisplay(rating: ratingonworker),
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
                                          projectData.pageContent.ratingOnClient != '' || projectData.pageContent.reviewOnClient != ''

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
                                          ): Container(),
                                          SizedBox(height: 10,),
                                          projectData.pageContent.ratingOnClient != '' || projectData.pageContent.reviewOnClient != ''
                                              ? Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 23,
                                                backgroundColor: Colors.transparent,
                                                backgroundImage: projectData.selectworkerbid.worker_profile_pic == 'https://workdonecorp.com/images/' ||projectData.selectworkerbid.worker_profile_pic == ''
                                                    ? AssetImage('assets/images/default.png') as ImageProvider
                                                    : NetworkImage(projectData.selectworkerbid.worker_profile_pic ?? 'assets/images/default.png'),
                                              ),
                                              SizedBox(width: 11),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    Get.to(ProfilePageClient(
                                                        userId: projectData
                                                            .selectworkerbid.worker_id
                                                            .toString()));
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
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),


                                              Spacer(),
                                              RatingDisplay(rating: ratingonclient),
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



                                          Visibility(
                                            visible: projectData.pageaccessdata.force_review == 'true',

                                            child: Row(
                                                                            children: [

                                                                            Expanded(
                                                                            child: Container(
                                                                            width: 220.0,
                                                                            height: 50,
                                                                            // Set the desired width
                                                                            child: ElevatedButton(
                                                                            onPressed: () {
                                                                              showModalBottomSheet(
                                                                                  context: context,
                                                                                  isScrollControlled: true,
                                                                                  builder: (context) {
                                            return SafeArea(
                                              child: SingleChildScrollView(
                                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        'The Project is Completed, make feedback about Client!',
                                                        style: GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            color: HexColor('4D8D6E'),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
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
                                                              Container(
                                                                height: 56,
                                                                width: 56,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                    image: NetworkImage(
                                                                      projectData.clientData.profileImage != 'https://workdonecorp.com/images/' &&
                                                                          projectData.clientData.profileImage.isNotEmpty
                                                                          ? projectData.clientData.profileImage
                                                                          : 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    '${projectData.clientData.firstname}',
                                                                    style: GoogleFonts.roboto(
                                                                      textStyle: TextStyle(
                                                                        color: HexColor('706F6F'),
                                                                        fontSize: 17,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8),
                                                                  RatingBar.builder(
                                                                    initialRating: 3,
                                                                    minRating: 1,
                                                                    direction: Axis.horizontal,
                                                                    allowHalfRating: true,
                                                                    itemCount: 5,
                                                                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                    itemBuilder: (context, _) => Icon(
                                                                      Icons.star,
                                                                      color: HexColor('4D8D6E'),
                                                                      size: 14,
                                                                    ),
                                                                    onRatingUpdate: (rating2) {
                                                                      rating = rating2.toString();
                                                                      print(rating);
                                                                    },
                                                                  ),
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
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15),
                                                          color: Colors.grey[100],
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          child: TextFormField(
                                                            controller: reviewcontroller,
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
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
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
                                                            child:    Center(child: RotationTransition(
                                                              turns: ciruclaranimation,
                                                              child: SvgPicture.asset(
                                                                'assets/images/Logo.svg',
                                                                semanticsLabel: 'Your SVG Image',
                                                                width: 100,
                                                                height: 130,
                                                              ),
                                                            ))

                                                          ),
                                                          successIcon: const SizedBox(
                                                            width: 55,
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.check_rounded,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                          icon: const SizedBox(
                                                            width: 55,
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.keyboard_double_arrow_right,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                          action: (controller) async {
                                                            controller.loading();
                                                            await Future.delayed(const Duration(seconds: 3));
                                                            controller.success();
                                                            Reviewproject();
                                                            await Future.delayed(const Duration(seconds: 1));
                                                            controller.reset();
                                                          },
                                                          child: const Text('Swipe To Confirm'),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20,)
                                                  ],
                                                ),
                                              ),
                                            );

                                                                                  });
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
                                                                            'Rate your Client',
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
                                          ) ,






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
                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectData.bids.length,
                                            itemBuilder: (context, index) {
                                              Bid bid = projectData.bids[index];
                                              return buildListItem(bid);
                                            },
                                          ),

                                        ],
                                      );
                                    }

                                    else if (projectData.bids.isNotEmpty) {
                                      // Render a ListView with bids
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
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
                                          SizedBox(height: 8,),

                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectData.bids.length,
                                            itemBuilder: (context, index) {
                                              Bid bid = projectData.bids[index];
                                              return buildListItem(bid);
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Render a message when there are no bids
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

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
                                },
                              ),
                              SizedBox(
                                height: 110,
                              ),
                            ]);
                      }
                    }),
              ),
            ),
          ),
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
      SlidingUpPanelWidget(

        child: Container(
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
                        panelController.collapse();
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
                Container(
                height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        selectedworkerimage != null &&
                            selectedworkerimage.isNotEmpty
                            ? selectedworkerimage
                            : 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
                      ),
                    ),
                  ),
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
                        initialRating: 3,
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
                        child:    Center(child: RotationTransition(
                          turns: ciruclaranimation,
                          child: SvgPicture.asset(
                            'assets/images/Logo.svg',
                            semanticsLabel: 'Your SVG Image',
                            width: 100,
                            height: 130,
                          ),
                        ))
                    ),
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
        ),
        controlHeight: 0.0,
        anchor: 0.0,
        minimumBound: minBound,
        upperBound: upperBound,
        panelController: panelController,
        onTap: () {
          ///Customize the processing logic
          if (SlidingUpPanelStatus.expanded == panelController.status) {
            panelController.collapse();
          } else {
            panelController.expand();
          }
        },
        enableOnTap: false,
        //Enable the onTap callback for control bar.
        dragDown: (details) {
          print('dragDown');
        },
        dragStart: (details) {
          print('dragStart');
        },
        dragCancel: () {
          print('dragCancel');
        },
        dragUpdate: (details) {
          print(
              'dragUpdate,${panelController.status == SlidingUpPanelStatus.dragging ? 'dragging' : ''}');
        },
        dragEnd: (details) {
          print('dragEnd');
        },
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
            backgroundImage: item.workerProfilePic== 'https://workdonecorp.com/images/' ||item.workerProfilePic == ''
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
                          ProfilePageClient(userId: item.workerId.toString()));
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
                  Text('0'),
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
                    workername: item.workerFirstname,
                    currentbid: currentbid,
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

class ProjectData {
  final String title;
  final List<String> images; // Images is now a List<String>
  final String projectType;
  final String postedFrom;
  final String status;
  final String desc;
  final bool liked; // Assuming the 'liked' field should be a boolean
  final int numberOfLikes;
  final String video;
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
    required this.video,
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
    page_access_data accessData = page_access_data.fromJson(jsonData['page_access_data']);

    var selectWorkerBid =
        jsonData['select_worker_bid'] as Map<String, dynamic>? ?? {};

    return ProjectData(
      title: baseData['title'] ?? 'No Title',
      images: List<String>.from(baseData['images'] ?? []),
      projectType: baseData['project_type'] ?? 'No Project Type',
      postedFrom: baseData['posted_from'] ?? 'No Post Date',
      status: baseData['status'] ?? 'No Status',
      desc: baseData['desc'] ?? 'No Description',
      video: baseData['video'] ?? '',
      liked: baseData['liked'] == 'true',
      numberOfLikes: baseData['number_of_likes'] ?? 0,
      lowestBid: baseData['lowest_bid'] ?? 'No Bids',
      timeframeStart: baseData['timeframe_start'] ?? 'No Start Time',
      timeframeEnd: baseData['timeframe_end'] ?? 'No End Time',
      bids: (baseData['bids'] as List<dynamic>? ?? [])
          .map((x) => Bid.fromJson(x as Map<String, dynamic>))
          .toList(),
      clientData: ClientData.fromJson(clientInfo),
      pageContent: PageContent.fromJson(pageContent),
      pageaccessdata: accessData,
      selectworkerbid: select_worker_bid.fromJson(selectWorkerBid),
    );
  }
}

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
      profileImage: json['profle_image'] ??
          'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png', // corrected typo from 'profle_image' to 'profile_image'
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
  final String enter_verification_code_button;
  final String enter_complete_project_verification_code_button;
  final String project_complete_button;
  final String support;
  final String schedule_vc;
  final String client_rating;
  final String reviewOnWorker;
  final String ratingOnWorker;
  final String? reviewOnClient; // 'null' signifies that this field may not be present
  final String ratingOnClient;
  final List<String> imagesAfter;

  PageContent(
      {required this.currentUserRole,
      required this.buttons,
      required this.selectedDate,
      required this.selectedInterval,
      required this.enter_complete_project_verification_code_button,
      required this.scheduleStatus,
      required this.schedule_vc,
      required this.change,
      required this.chat,
      required this.reviewOnWorker,
        required this.ratingOnWorker,
        this.reviewOnClient,
        required this.ratingOnClient,
        required this.imagesAfter,
      required this.enter_verification_code_button,
      required this.project_complete_button,
      required this.client_rating,
      required this.support});

  factory PageContent.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images_after'] != null) {
      imagesList = List<String>.from(json['images_after'] as List<dynamic>);
    }
    return PageContent(
      currentUserRole: json['current_user_role'] ?? '',
      buttons: json['buttons'] ?? '',
      selectedDate: json['selected_date'] ?? '',
      selectedInterval: json['selected_interval'] ?? '',
      scheduleStatus: json['schedule_status'] ?? '',
      schedule_vc: json['schedule_vc'] ?? '',
      change: json['change'] ?? '',
      chat: json['chat'] ?? '',
      enter_verification_code_button: json['enter_verification_code_button'] ?? '',
      enter_complete_project_verification_code_button:
          json['enter_complete_project_verification_code_button'] ?? '',
      project_complete_button: json['project_complete_button'] ?? '',
      support: json['support'] ?? '',
      reviewOnWorker: json['review_on_worker'] ?? '', // Providing default value if null
      ratingOnWorker: json['rating_on_worker'] ?? '',
      reviewOnClient: json['review_on_client']?? '',
      ratingOnClient: json['rating_on_client'] ?? '',
      imagesAfter: imagesList,
      client_rating: json['client_rating'] ?? '',
    );
  }
}

class page_access_data {
  final String chat_ID;
  final dynamic schedule_vc;
  final dynamic complete_vc;
  final dynamic force_review;

  page_access_data(
      {required this.chat_ID,
      required this.schedule_vc,
      required this.force_review,
      required this.complete_vc});

  page_access_data.empty()
      : chat_ID = '',
        schedule_vc = '',
        force_review = '',
        complete_vc = '';

  factory page_access_data.fromJson(dynamic json) {

    if (json is Map<String, dynamic>) {
      // Data is a Map, process it
      return page_access_data(
        chat_ID: json['chat_ID'] ?? '',
        schedule_vc: json['schedule_vc'].toString() ?? '',
        force_review: json['force_review'] ?? '',
        complete_vc: json['complete_vc'] ?? '',
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

  select_worker_bid(
      {required this.worker_id,
      required this.worker_firstname,
      required this.worker_profile_pic,
      required this.amount,
      required this.comment});

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

    return select_worker_bid(
        worker_id: json['worker_id'] ?? 0,
        worker_firstname: json['worker_firstname'] ?? '',
        worker_profile_pic: json['worker_profile_pic'] ?? '',
        amount: json['amount'] ?? 0,
        comment: json['comment'] ?? '');
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
    return Bid(
      workerId: json['worker_id'] as int? ?? 0,
      workerFirstname: json['worker_firstname'] ?? '',
      workerProfilePic: json['worker_profile_pic'] ??
          'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      comment: json['comment'] ?? '',
      clientData: ClientData.fromJson(
          json['client_info'] as Map<String, dynamic>? ?? {}),
      pageContent: PageContent.fromJson(
          json['page_content'] as Map<String, dynamic>? ?? {}),
    );
  }
}

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
              border: Border.all(width: 2, color: HexColor('DFE2E8')),
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
    required this.text,
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
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
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
  final double rating;

  const RatingDisplay({  required this.rating}) ;

  @override
  Widget build(BuildContext context) {
    final int ratingInt = rating.clamp(0.0, 5.0).toInt();
    final double ratingFrac = rating - ratingInt;
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