import 'dart:convert';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _bidDetailsWorkerState extends State<bidDetailsWorker> {

  late Future<ProjectData> projectDetailsFuture;
  String client_id = '';
  String worker_id = '';
  String projectimage = '';
  String projecttitle = '';
  String projectdesc = '';
  String owner = '';

  late ScrollController scrollController;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();

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
  }

  String currentbid = '24';
  final ScreenshotController screenshotController = ScreenshotController();

  String unique= 'biddetailsclient' ;
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
      statusBarColor: HexColor('FFFFFF'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Stack(
        children: <Widget>[ Scaffold( floatingActionButton:
        FloatingActionButton(

          heroTag: 'workdone_${unique}',
          onPressed: () {
            _navigateToNextPage(context);
          },
          backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
          child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
          shape: CircleBorder(), // Make the button circular
        ),

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
            controller:screenshotController ,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
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
                                    backgroundImage: NetworkImage(
                                      projectData.clientData?.profileImage ==
                                          'https://workdonecorp.com/images/'
                                          ? 'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                                          : projectData.clientData?.profileImage ??
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
                                            userId: projectData.clientData!.clientId
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
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                              FutureBuilder<ProjectData>(
                                future: fetchProjectDetails(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
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
                                      // Render a row with buttons
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                panelController.expand();

                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                                onPrimary: Colors.white,
                                                elevation: 8,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Text('End'),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Get.to(ChatScreen(
                                                    chatId:
                                                    projectData.access!.chat_ID,
                                                    currentUser: projectData
                                                        .clientData!.firstname,
                                                    secondUserName: 'worker',
                                                    userId: projectData
                                                        .clientData!.clientId.toString(),
                                                  ));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.blue,
                                                  // Background color
                                                  onPrimary: Colors.white,
                                                  // Text color
                                                  elevation: 8,
                                                  // Elevation
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8), // Rounded corners
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Text('Chat'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
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
                              ),

                            ]);
                      }
                    }),
              ),
            ),
          ),),
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
                          shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(
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
                  SizedBox(height: screenheight*0.02,),



                  Row(
                    children: [
                      IconButton(onPressed: (){

                        panelController.collapse();


                      }, icon:Icon(Icons.expand_circle_down ,color: Colors.grey[700],)),


                      Text('End Project',
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
                    title: Text('Upload Photo Or Video',
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
                      height: 200, // Set the desired height
                      width: double.infinity, // Take the full width
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // Set the desired border color
                          width: 1.0, // Set the desired border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Set the desired border radius
                      ),
                      child: ListTile(
                        title: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image ,color: HexColor('4D8D6E'),), // Replace with the appropriate icon
                            SizedBox(height: 8),
                            Text('Upload here',style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                        onTap: () {
                          // Handle image or video selection
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenheight*0.02,),

                  ListTile(
                    title: Text('Rating',
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
                  SizedBox(height: screenheight*0.02,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, ),
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
                          maxLines: 5,
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 20),
                    child: Center(
                      child: ActionSlider.standard(
                        sliderBehavior: SliderBehavior.stretch,
                        rolling: false,
                        width: double.infinity,
                        backgroundColor: Colors.white,
                        toggleColor: HexColor ('4D8D6E'),
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
                            width: 55, child: Center(child: Icon(Icons.check_rounded,color: Colors.white,))),
                        icon: const SizedBox(
                            width: 55, child: Center(child: Icon(Icons.keyboard_double_arrow_right ,color: Colors.white,))),
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
                  SizedBox(height: screenheight*0.02,),
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



        ]

    );
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

// class ProjectDetailsResponse {
//   String status;
//   String msg;
//   Access access;
//   ClientData clientData;
//   ProjectData data;
//
//   ProjectDetailsResponse({
//     required this.status,
//     required this.msg,
//     required this.access,
//     required this.clientData,
//     required this.data,
//   });

//   factory ProjectDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return ProjectDetailsResponse(
//       status: json['status'],
//       msg: json['msg'],
//       access: Access.fromJson(json['access']),
//       clientData: ClientData.fromJson(json['client_data']),
//       data: ProjectData.fromJson(projectPost['data']),
//     );
//   }
// }

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
