import 'dart:convert';

import 'package:action_slider/action_slider.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';
import '../InboxwithChat/ChatClient.dart';
import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../check out client/checkout.dart';
import '../homescreen/home screenClient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

import '../view profile screens/Worker profile view.dart';

class bidDetailsClient extends StatefulWidget {
  final int projectId;

  bidDetailsClient({required this.projectId});

  @override
  State<bidDetailsClient> createState() => _bidDetailsClientState();
}

class _bidDetailsClientState extends State<bidDetailsClient> {
  bool showAdditionalContent = false;
  bool showprojectcomplete = false;
  bool accessprojectcomplete = false;
  bool disableverfication = false;

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
  String projectimage = '';
  String projecttitle = '';
  String projectdesc = '';
  String owner = '';

  late ScrollController scrollController;
  late ScrollController scrollController2;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();
  SlidingUpPanelController panelController2 = SlidingUpPanelController();

  double minBound = 0;

  double upperBound = 1.0;

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
  }

  String currentbid = '24';
  final ScreenshotController screenshotController = ScreenshotController();

  String unique = 'biddetailsclient';

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

    return Stack(children: <Widget>[
      Scaffold(
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
        body: Screenshot(
          controller: screenshotController,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
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
                      ;
                      projecttitle = projectData.title.toString();
                      ;
                      projectdesc = projectData.desc.toString();
                      ;
                      owner = projectData.access!.owner.toString();
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
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5), // Set the desired opacity and color
                                borderRadius: BorderRadius.circular(12), // Optional: Set border radius
                              ),
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: NetworkImage('http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
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
                                                },
                                                child: Text(
                                                  'Ahmed',
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
                                                '23',
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
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20,),
                            FutureBuilder<ProjectData>(
                              future: fetchProjectDetails(),
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
                                      projectData.access!.owner == 'true') {
                                    if (showAdditionalContent == false) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Column(
                                          children: [
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
                                                                      _selectedDate,
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
                                                                            MonthPickerType.dropDown,
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
                                                                      ),
                                                                    ),
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
                                                                                setState(
                                                                                        () {
                                                                                          showAdditionalContent =true;

                                                                                        });
                                                                                print(showAdditionalContent);

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
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: 120.0,
                                                    height: 50,
                                                    // Set the desired width
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.to(ChatScreen(
                                                          chatId: projectData
                                                              .access!.chat_ID,
                                                          currentUser:
                                                              projectData
                                                                  .clientData!
                                                                  .firstname,
                                                          secondUserName:
                                                              'worker',
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
                                              height: 12,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 195.0,
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => ModernPopup(
                                                          text: 'Choose Schedule first then generate a Code to access Project complete',
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: HexColor('1AA251').withOpacity(0.5), // Adjust opacity here
                                                      onPrimary: Colors.white,
                                                      elevation: 3,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(12.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Project Completed',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Icon(
                                                            AntDesign.infocirlceo, // Replace with your preferred (i) icon
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ],
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
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
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


                                                      Text(
                                                        ' ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate.toLocal())}',
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
                                                      ' ${formatTime(_values.start)} - ${formatTime(_values.end)}',
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
                                                                            setState(
                                                                                    () {
                                                                                  showAdditionalContent =true;

                                                                                });
                                                                            print(showAdditionalContent);

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
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: HexColor('34446F'),
                                                  onPrimary: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Change',
                                                  style: TextStyle(fontSize: 10), // Adjust the fontSize as needed
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
                                                      Get.to(ChatScreen(
                                                        chatId: projectData
                                                            .access!.chat_ID,
                                                        currentUser:
                                                            projectData
                                                                .clientData!
                                                                .firstname,
                                                        secondUserName:
                                                            'worker',
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
                                                  onPressed: accessprojectcomplete == true || disableverfication== true
                                                      ? () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => ModernPopup(
                                                        text: 'press on project complete to generate verfication code to access it .',
                                                      ),
                                                    );

                                }
                                    : () {    showModalBottomSheet(
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
                                                                  child: OTPDisplay(digits: ["1", "2", "3", "4"]), // Replace with your API response
                                                                ),
                                                                SizedBox(height: 30),
                                                                Center(
                                                                  child: Container(
                                                                    height: 54, // Set the desired height
                                                                    width: 170, // Set the desired width
                                                                    child: ElevatedButton(
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          showprojectcomplete = true;
                                                                        });
                                                                        print(showprojectcomplete);
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

                                },
                                style: ElevatedButton.styleFrom(
                                primary:  accessprojectcomplete == true || disableverfication== true? HexColor('B6B021').withOpacity(0.5) : HexColor('B6B021'),
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
                                        if (accessprojectcomplete == true || disableverfication== true)
                                          Icon(
                                            AntDesign.questioncircleo, // Replace with your preferred icon
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                ),                                           ],
                                          ),

                                          SizedBox(
                                            height: 12,
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: 195.0,
                                                  height: 50,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      if (showprojectcomplete) {
                                                        if (!accessprojectcomplete) { // Show popup if access is false


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

                                                                          Center(child: Text('Your ',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle:
                                                                              TextStyle(
                                                                                color:
                                                                                Colors.black,
                                                                                fontSize: 27,
                                                                                fontWeight:
                                                                                FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),),
                                                                          Center(child: Text('Verification Code',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle:
                                                                              TextStyle(
                                                                                color:
                                                                                Colors.black,
                                                                                fontSize: 27,
                                                                                fontWeight:
                                                                                FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),),
                                                                          SizedBox(height: 25,),
                                                                          Center(child: Text('Worker Must take this code to',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle:
                                                                              TextStyle(
                                                                                color:
                                                                                HexColor('706F6F'),
                                                                                fontSize: 17,
                                                                                fontWeight:
                                                                                FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),),
                                                                          Center(child: Text('access project Complete',
                                                                            style: GoogleFonts
                                                                                .roboto(
                                                                              textStyle:
                                                                              TextStyle(
                                                                                color:
                                                                                HexColor('706F6F'),
                                                                                fontSize: 17,
                                                                                fontWeight:
                                                                                FontWeight.normal,
                                                                              ),
                                                                            ),
                                                                          ),),

                                                                          SizedBox(height: 25,),
                                                                          Center(
                                                                            child: OTPDisplay(digits: ["1", "2", "3", "4"]), // Replace with your API response
                                                                          ),
                                                                          SizedBox( height: 30,),

                                                                          Center(
                                                                            child: Container(
                                                                              height: 54, // Set the desired height
                                                                              width: 170, // Set the desired width
                                                                              child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  setState(
                                                                                          () {
                                                                                        showprojectcomplete =true;
                                                                                        accessprojectcomplete=true;
                                                                                         disableverfication=true;

                                                                                      });
                                                                                  print(showprojectcomplete);

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

                                                      }  else if (disableverfication == true){
                                                          panelController.expand(); // Expand panel if access is true
                                                        }
                                                      }else{
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => ModernPopup(
                                                            text: 'Generate a Code to Start Work',
                                                          ),
                                                        );

                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: accessprojectcomplete ? HexColor('1AA251') : HexColor('1AA251').withOpacity(0.5),
                                                      onPrimary: Colors.white,
                                                      elevation: 2,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(12.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'Project Completed',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 9,),
                                                          Icon(
                                                            AntDesign.questioncircleo, // Replace with your preferred (i) icon
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),


                                        ],
                                      );
                                    }
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
          ),
        ),
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
                  children: [
                    Text('Zeyad'),
                    SizedBox(width: 8),
                    // Replace the following with a RatingBar widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        Icon(Icons.star, color: Colors.yellow),
                        Icon(Icons.star, color: Colors.yellow),
                        Icon(Icons.star, color: Colors.yellow),
                        Icon(Icons.star_border, color: Colors.yellow),
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
                          ? '${item.workerFirstname.substring(0, 7)}...' // Display first 14 letters with ellipsis
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
          Visibility(
            visible: item.access!.owner == 'true',
            child: ElevatedButton(
              onPressed: () {
                Get.to(checkOutClient(
                  userId: item.access!.user,
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
              child: Text('Accept',
                  style: TextStyle(fontSize: 11, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                backgroundColor: HexColor('4D8D6E'),
                elevation: 0,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
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
      projectStatus: json['project_status'],
      project_status: json['project_status'],
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