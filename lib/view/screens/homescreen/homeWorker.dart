import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/screens/Explore/Explore%20Worker.dart';
import 'package:workdone/view/screens/notifications/notificationscreenworker.dart';
import '../Bid Details/Bid details Worker.dart';
import '../Profile (client-worker)/profilescreenworker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

import '../Reviews/reviews.dart';
import '../Support Screen/Support.dart';
import '../editProfile/editprofileworker.dart';
import '../notifications/notificationScreenclient.dart';
import '../view profile screens/Client profile view.dart';
import '../view profile screens/Reviews profile .dart';
import '../welcome/welcome_screen.dart';

class Homescreenworker extends StatefulWidget {
  final bool showCase;

  Homescreenworker({Key? key, required this.showCase}) : super(key: key);

  @override
  State<Homescreenworker> createState() => _HomescreenworkerState();
}

int currentPage = 1;

bool shouldShowNextButton(List<Item>? nextPageData) {
  // Add your condition to check if the next page is not empty here
  return nextPageData != null && nextPageData.isNotEmpty;
}


int _currentPageIndex = 0;

bool isLiked = false;
bool isLoading = true; // Initially set to true to show shimmer
int client_id = 0; // Initially set to true to show shimmer

final advancedDrawerController = AdvancedDrawerController();

late Future<List<Item>> futureProjects;
List<Item> items = [];
TextEditingController searchController = TextEditingController();

Map<int, String> likedStatusMap = {};




final StreamController<String> _likedStatusController =
    StreamController<String>();

Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
Stream<String> get likedStatusStream => _likedStatusController.stream;
List<String> likedProjects = []; // List to store liked project IDs
Map<int, String> likedProjectsMap = {};


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
      return {
        'status': 'success',
        'msg': 'Project removed from likes successfully'
      };
    } else {
      // Handle error
      print(
          'Failed to remove project from likes. Status code: ${response.statusCode}');
      return {'status': 'error', 'msg': 'Failed to remove project from likes'};
    }
  } catch (e) {
    // Handle exception
    print('Error: $e');
    return {'status': 'error', 'msg': 'An error occurred'};
  }
}

class _HomescreenworkerState extends State<Homescreenworker> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  late AnimationController ciruclaranimation;
  String truncateText(String text, int numberOfWords) {
    List<String> words = text.split(' ');

    if (words.length <= numberOfWords) {
      return text; // No need to truncate
    } else {
      // Take the first 'numberOfWords' words and concatenate with ellipsis
      return '${words.take(numberOfWords).join(' ')}...';
    }
  }
  int notificationnumber =0 ;
  // Future<void> Notificationnumber() async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     final userToken = prefs.getString('user_token') ?? '';
  //     print(userToken);
  //
  //     if (userToken.isNotEmpty) {
  //       // Replace the API endpoint with your actual endpoint
  //       final String apiUrl = 'https://workdonecorp.com/api/unread_notification_number';
  //       print(userToken);
  //
  //       final response = await http.post(
  //         Uri.parse(apiUrl),
  //         headers: {'Authorization': 'Bearer $userToken'},
  //       );
  //
  //       if (response.statusCode == 200) {
  //         Map<String, dynamic> responseData = json.decode(response.body);
  //
  //         if (responseData.containsKey('counter')) {
  //           int profileData = responseData['counter'];
  //
  //           setState(() {
  //             notificationnumber= profileData;
  //           });
  //
  //           print('Response of notification number : $profileData');
  //           print('notification number: $notificationnumber');
  //         } else {
  //           print(
  //               'Error: Response data does not contain the expected structure.');
  //           throw Exception('Failed to load notification number');
  //         }
  //       } else {
  //         // Handle error response
  //         print('Error: ${response.statusCode}, ${response.reasonPhrase}');
  //         throw Exception('Failed to load notification number');
  //       }
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (error) {
  //     // Handle errors
  //     print('Error getting notification number: $error');
  //   }
  // }
  final advancedDrawerController = AdvancedDrawerController();
  String profile_pic ='' ;
  String firstname ='' ;
  String secondname ='' ;
  String email ='' ;
  Map<int, bool> likedProjectsMap = {};
  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> profileData = responseData['data'];

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }


  Future<List<Item>> fetchProjects() async {
    try {
      await _getUserProfile();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_all_projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'filter': 'all',
          'page': currentPage.toString(),
          // Include other parameters as needed
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> projectsJson = responseData['projects'];

          List<Item> projects = projectsJson.map((json) {
            final int projectId = json['project_id'];
            final String likedStatus = json['liked'];
            client_id = json['client_id'];
            likedStatusMap[projectId] = likedStatus;
            print(client_id);
            return Item(
              projectId: json['project_id'],
              client_id:  json['client_id'],
              status:  json['status'],
              title: json['title'],
              description: json['desc'],
              imageUrl: json['images'] != null ? List<String>.from(json['images']) : [], // This creates a list from the JSON array
              postedFrom: json['posted_from'],
              client_firstname: json['client_firstname'],
              liked: json['liked'],
              numbers_of_likes:  json['numbers_of_likes'],
              isLiked: json['liked'],
              lowest_bids: json['lowest_bid'] ?? 'No Bids', // Assign "No Bids" if null
            );
          }).toList();

          print(client_id);

          print(projectsJson);
          print(Item);
          print(projects);
          return projects;
        } else {
          throw Exception('Failed to load data from API: ${responseData['msg']}');
        }
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void refreshProjects() async {
    futureProjects = fetchProjects();
  }

  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = fetchProjects();
      refreshProjects();
      // Wait for the future to complete
      // Iterate through the list of items and check if each project is liked
    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  int? userId;
  Future<void> _getUserid() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      print ('fetching user id');
      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/get_user_id_by_token';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          print ('done  user id');

          if (responseData.containsKey('user_id')) {

            userId = responseData['user_id'];

            // Now, userId contains the extracted user_id value
            print('User ID: $userId');

            // Optionally, save the user_id to SharedPreferences
            prefs.setInt('user_id', userId ?? 0);
          } else {
            print('Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserid();
    _getUserid();

    initializeProjects();
    _getUserProfile();
    // Notificationnumber();
    // const Duration fetchdata = Duration(seconds: 15);
    // Timer.periodic(fetchdata, (Timer timer) {
    //   // Fetch data at each interval
    //   Notificationnumber();
    //
    // });

    print('the show case work == ${widget.showCase}');
    if (widget.showCase == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([_two, _one ,_three ,_four]);
      });
    }

    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

    likedProjectsMap= {};
  }
  @override
  void dispose() {
    ciruclaranimation.dispose();
    super.dispose();
  }

  List<Item> items = [];
  TextEditingController searchController = TextEditingController();
  bool isLiked = false;

  List<String> likedProjects = []; // List to store liked project IDs

  Future<Map<String, dynamic>> addProjectToLikes(String projectId,String name ,String Title ,String id) async {
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

          DateTime currentTime = DateTime.now();

          // Format the current time into your desired format
          String formattedTime = DateFormat('h:mm a').format(currentTime);

          Map<String, dynamic> newNotification = {
            'title': 'New Like Received from $name 💚',
            'body': 'Your post $Title has received a new like from $name 😊',
            'time': formattedTime,
            'id' :projectId,
            'type': 'projectclient'            // Add other notification data as needed
          };
          print('sended notification ${[newNotification]}');
          SaveNotificationToFirebase.saveNotificationsToFirestore(id.toString(), [newNotification]) ;

          print('getting notification');

          // Get the user document reference
          // Get the user document reference
          // Get the user document reference
          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(id.toString()) ;

// Get the user document
          DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
          if (doc.exists ) {
            // Extract the FCM token and notifications list from the document
            String? receiverToken = doc.get('fcmToken');
            List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

            // Check if the new notification is not null and not already in the list
            if (!notifications.any((notification) => notification['id'] == newNotification['id'])) {
              // Add the new notification to the beginning of the list
              notifications.insert(0, newNotification);

              // Update the user document with the new notifications list
              await userDocRef.update({
                'notifications': notifications,
              });

              print('Notifications saved for user $id');
            }

            // Display the notifications list in the app
            print('Notifications for user $id:');
            for (var notification in notifications) {
              String? title = notification['title'];
              String? body = notification['body'];
              print('Title: $title, Body: $body');
              await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
              print('Last notification sent to ${id.toString()}');
            }
          } else {
            print('User document not found for user $id');
          }

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
        return {
          'status': 'success',
          'msg': 'Project removed from likes successfully'
        };
      } else {
        // Handle error
        print(
            'Failed to remove project from likes. Status code: ${response.statusCode}');
        return {
          'status': 'error',
          'msg': 'Failed to remove project from likes'
        };
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }

  // Future<void> checkIfProjectIsLiked(Item item) async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     final String userToken = prefs.getString('user_token') ?? '';
  //
  //     final response = await addProjectToLikes(item.projectId.toString());
  //
  //     if (response['status'] == 'success') {
  //       // Project is already liked
  //       setState(() {
  //         likedProjectsMap[item.projectId] = true;
  //       });
  //       print('Project is already liked');
  //     } else if (response['msg'] == 'This Project is Already in Likes !') {
  //       // Project is not liked
  //       setState(() {
  //         likedProjectsMap[item.projectId] = false;
  //         print(likedProjectsMap);
  //       });
  //       print('Project is not liked');
  //     } else {
  //       // Handle other error scenarios
  //       print('Error: ${response['msg']}');
  //     }
  //   } catch (e) {
  //     // Handle exception
  //     print('Error: $e');
  //   }
  // }

  List<Item> filteredItems = [];

  List<InlineSpan> _buildTextSpans(String text, String query) {
    final spans = <InlineSpan>[];
    final matches =
        RegExp(query, caseSensitive: false).allMatches(text.toLowerCase());

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    int currentIndex = 0;
    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  void filterProjects(String query, List<Item> projects) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(projects);
      } else {
        filteredItems = projects.where((project) {
          final title = project.title.toLowerCase();
          final description = project.description.toLowerCase();
          final client_firstname = project.client_firstname.toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('F0EEEE'),
      statusBarIconBrightness:
          Brightness.dark, //Change the status bar ico ns' color (dark or light)
    ));
    return AdvancedDrawer(
        openRatio: 0.6,
        backdropColor: HexColor('ECEDED'),
        controller: advancedDrawerController,
        rtlOpening: false,
        openScale: 0.89,
        childDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 1000),
        drawer: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.transparent,
                  backgroundImage: profile_pic == '' || profile_pic.isEmpty
                      || profile_pic == "https://workdonecorp.com/storage/" ||
                      !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))

                      ? AssetImage('assets/images/default.png') as ImageProvider
                      : NetworkImage(profile_pic?? 'assets/images/default.png'),
                ),
                SizedBox(
                  height: 12,
                ),
                isLoading
                    ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  '$firstname $secondname',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: HexColor('1A1D1E'),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),),
                SizedBox(
                  height: 9,
                ),
                isLoading
                    ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  '$email',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('6A6A6A'),
                        fontSize: 13,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(editProfileworker()
                      ,
                      transition: Transition.fadeIn, // You can choose a different transition
                      duration: Duration(milliseconds: 700),

                    );

                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(editProfileworker()
                            ,
                            transition: Transition.fadeIn, // You can choose a different transition
                            duration: Duration(milliseconds: 700),

                          );
                        },
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                ),


                // Row(
                //   children: [
                //     SvgPicture.asset(
                //       'assets/icons/time.svg',
                //       width: 35.0,
                //       height: 35.0,
                //     ),
                //     SizedBox(
                //       width: 8,
                //     ),
                //     // TextButton(
                //     //   onPressed: () {},
                //     //   child: Text(
                //     //     'Projects',
                //     //     style: GoogleFonts.poppins(
                //     //       textStyle: TextStyle(
                //     //           color: HexColor('1A1D1E'),
                //     //           fontSize: 15,
                //     //           fontWeight: FontWeight.normal),
                //     //     ),
                //     //   ),
                //     // )
                //   ],
                // ),

                GestureDetector(
                  onTap: (){

                    Get.to(NotificationsPageworker
                      ());

                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/notification.svg',
                        width: 35.0,
                        height: 35.0,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(NotificationsPageworker
                            ());
                        },
                        child: Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: HexColor('1A1D1E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
            GestureDetector(
              onTap: (){
                Get.to(reviewprofile(userId: '${userId}'),
                  transition: Transition.fadeIn, // You can choose a different transition
                  duration: Duration(milliseconds: 700), );

              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/portfolioicon.svg',
                    width: 35.0,
                    height: 35.0,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  TextButton(


                    onPressed: () {Get.to(reviewprofile(userId: '${userId}'),
                      transition: Transition.fadeIn, // You can choose a different transition
                      duration: Duration(milliseconds: 700), );},
                    child: Text(
                      'Review',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: HexColor('1A1D1E'),
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  )
                ],
              ),
            ),
                Spacer(),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await clearSharedPreferences(); // Call the function to clear client_id
                        Get.offAll(WelcomeScreen(),
                          transition: Transition.downToUp, // You can choose a different transition
                          duration: Duration(milliseconds: 700), );

                      },
                      child:  Text('Log Out',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          )),
                    )
                  ],
                ),
                Spacer(),
                Text('Powered by :',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('6A4141'),
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 16),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      // Calculate the size of the SVG image based on the available width
                      double svgSize = constraints.maxWidth * 0.27; // Adjust the multiplier as needed
                      return Row(
                        children: [
                          FittedBox(
                            child: SvgPicture.asset(
                              'assets/images/Logo.svg',
                              fit: BoxFit.cover,
                              width: svgSize,
                              height: svgSize,
                            ),
                          ),
                          SizedBox(width: 8,),
                          Flexible(
                            child: Text(
                              'Workdone Corp.',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: HexColor('595B5B'),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12,)
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 12,),


              ],
            ),
          ),
        ),
        child: Scaffold(
          floatingActionButton:
          widget.showCase ==true

              ?Showcase(
            blurValue: 12,
            descTextStyle: TextStyle(
              fontSize: 19,
              color: HexColor ('#333333'),
            ),
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HexColor('#0c343d'),  // Custom title color
            ),

            overlayColor: Colors.black.withOpacity(0.7),
            key: _one,
            title: 'Support',
            description: 'If you have issue click here to send a support ticket',

            child: FloatingActionButton(
              onPressed: () {
                _navigateToNextPage(context);
              },
              backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
              child: Icon(Icons.help ,color: Colors.white,), // Use the support icon
              shape: CircleBorder(), // Make the button circular
            ),
          ):FloatingActionButton(
            onPressed: () {
              _navigateToNextPage(context);
            },
            backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
            child: Icon(Icons.help ,color: Colors.white,), // Use the support icon
            shape: CircleBorder(), // Make the button circular
          ),
          backgroundColor: HexColor('F0EEEE'),
          appBar: AppBar(
            leading: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            drawerControl();
                          },
                          child: Container(
                            width: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: HexColor('4d8d6e'),
                            ),
                            child: Icon(
                              Ionicons.menu_outline,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        drawerControl();
                      },
                      child: Container(
                        width: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: HexColor('4d8d6e'),
                        ),
                        child: Icon(
                          Ionicons.menu_outline,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            centerTitle: true,
            backgroundColor: HexColor('F0EEEE'),
            title: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  );
                }
              },
            ),
            elevation: 0,
            toolbarHeight: 72,
            leadingWidth: 72,

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
                child: Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notify')
                          .doc(userId.toString())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {

                          return GestureDetector(
                            child: Icon(Ionicons.notifications, size: 26),
                            onTap: () {
                              Get.to(NotificationsPageworker());
                            },
                          ); // Show a loading indicator while waiting for data
                        } else if (snapshot.hasData && snapshot.data!.exists) {
                          // Check if 'notifications' field exists and is not null
                          if (snapshot.data!['notifications'] != null) {
                            List<dynamic> notifications = snapshot.data!['notifications'];
                            // Filter notifications where 'isRead' is not available or is false
                            int unreadCount = notifications.where((notification) =>
                            notification['isRead'] == null || notification['isRead'] == false).length;

                            return
                              unreadCount > 0 ?
                              badges.Badge(
                                badgeStyle: badges.BadgeStyle(
                                  badgeColor: unreadCount > 9 ? Colors.red : Colors.orange,
                                  shape: badges.BadgeShape.circle,
                                ),
                                position: BadgePosition.topEnd(),
                                badgeContent: Text(unreadCount > 9 ? '+9' : '${unreadCount}'
                                    , style: TextStyle(color: Colors.white)),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: GestureDetector(
                                    child: Icon(Ionicons.notifications, size: 26),
                                    onTap: () {
                                      Get.to(NotificationsPageworker());
                                    },
                                  ),
                                ),
                              ):
                              GestureDetector(
                                  child: Icon(Ionicons.notifications, size: 26),
                                  onTap: () {
                                    Get.to(NotificationsPageworker());});

                          } else {
                            // Handle the case where 'notifications' field does not exist
                            return GestureDetector(
                              child: Icon(Ionicons.notifications, size: 26),
                              onTap: () {
                                Get.to(NotificationsPageworker());
                              },
                            ); // Show a loading indicator while waiting for data
                          }
                        } else {
                          // Handle the case where the document does not exist
                          return GestureDetector(
                            child: Icon(Ionicons.notifications, size: 26),
                            onTap: () {
                              Get.to(NotificationsPageworker());
                            },
                          ); // Show a loading indicator while waiting for data
                        }
                      },
                    ),

                    SizedBox(width: 20,),
                    widget.showCase == true
                        ? Showcase(
                      blurValue: 12,
                      descTextStyle: TextStyle(
                        fontSize: 19,
                        color: HexColor('#333333'),
                      ),
                      titleTextStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#0c343d'),
                      ),
                      key: _four,
                      description: 'Tap here to View & Edit Profile',
                      title: 'Profile',
                      overlayColor: Colors.black.withOpacity(0.7),
                      child: InkWell(
                        onTap: () {
                          Get.to(ProfileScreenworker(),
                            transition: Transition.fadeIn,
                            duration: Duration(milliseconds: 500),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: profile_pic == '' || profile_pic.isEmpty
                                  || profile_pic == "https://workdonecorp.com/storage/" ||
                                  !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))
                                  ? AssetImage('assets/images/default.png') as ImageProvider
                                  : null, // Set to null to avoid showing the image immediately
                            ),
                            if (profile_pic != null && profile_pic.isNotEmpty)
                              Image.network(
                                profile_pic,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // Return the image if it's fully loaded
                                  } else {
                                    return CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    );
                                  }
                                },
                                errorBuilder: (context, exception, stackTrace) {
                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage('assets/images/default.png') as ImageProvider
                                  ); // Show default image on error
                                },
                              ),
                          ],
                        )


                      ),
                    )
                        : InkWell(
                      onTap: () {
                        Get.to(ProfileScreenworker(),
                          transition: Transition.fadeIn,
                          duration: Duration(milliseconds: 500),
                        );
                      },
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.transparent,
                        backgroundImage:profile_pic == '' || profile_pic.isEmpty
                            || profile_pic == "https://workdonecorp.com/storage/" ||
                            !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))

                            ? AssetImage('assets/images/default.png') as ImageProvider
                            : NetworkImage(profile_pic?? 'assets/images/default.png'),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),

         body: Screenshot(
            controller:screenshotController2 ,

            child: RefreshIndicator(
              color: HexColor('4D8D6E'),
              backgroundColor: Colors.white,
              onRefresh: () async {
                setState(() {
                  futureProjects = fetchProjects();
                });
                },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 23.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Featured Projects',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),

                          widget.showCase ==true

                              ?  Showcase(
                            blurValue: 12,
                            descTextStyle: TextStyle(
                              fontSize: 19,
                              color: HexColor ('#333333'),
                            ),
                            titleTextStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: HexColor('#0c343d'),  // Custom title color
                            ),

                            overlayColor: Colors.black.withOpacity(0.7),
                            key: _three,
                            description: 'Tap here to explore more project!',
                            title: 'Explore',


                              child: TextButton(
                                onPressed: () {

                                  Get.to(
                                      exploreWorker(userid3: userId.toString(),),
                                    transition: Transition.downToUp, // You can choose a different transition
                                    duration: Duration(milliseconds: 700), // Set the duration of the transition
                                  );



                                },
                                child: Text(
                                  'See all',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: HexColor('4F815A'),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ):TextButton(
                            onPressed: () {

                              Get.to(
                                exploreWorker(userid3: userId.toString(),),
                                transition: Transition.downToUp, // You can choose a different transition
                                duration: Duration(milliseconds: 700), // Set the duration of the transition
                              );



                            },
                            child: Text(
                              'See all',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: HexColor('4F815A'),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: FutureBuilder<List<Item>>(
                          future: futureProjects,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 80,
                                  ),
                                  Center(child: RotationTransition(
                                    turns: ciruclaranimation,
                                    child: SvgPicture.asset(
                                      'assets/images/Logo.svg',
                                      semanticsLabel: 'Your SVG Image',
                                      width: 70,
                                      height: 80,
                                    ),
                                  ))
                                  ,
                                  SizedBox(
                                    height: 80,
                                  )
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data != null &&
                                snapshot.data!.isEmpty) {
                              // If projects list is empty, reset current page to 0 and refresh
                              currentPage = 1;
                              refreshProjects();
                              return Center(
                                child: SvgPicture.asset(
                                  'assets/images/empty.svg',
                                  semanticsLabel: 'Your SVG Image',
                                  width: 150,
                                  height: 200,
                                ),
                              );
                            } else {
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                // Set shrinkWrap to true
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return buildListItem(snapshot.data![index]);
                                },
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'New Projects',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .grey[700], // Change the color as needed
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Get.to(
                                  exploreWorker(userid3: userId.toString(),),
                                  transition: Transition.downToUp, // You can choose a different transition
                                  duration: Duration(milliseconds: 700), // Set the duration of the transition
                                );



                              },
                              child: Text(
                                'See all',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      color: HexColor('4F815A'),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      FutureBuilder<List<Item>>(
                        future: futureProjects,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 80,
                                ),
                                Center(child: RotationTransition(
                                  turns: ciruclaranimation,
                                  child: SvgPicture.asset(
                                    'assets/images/Logo.svg',
                                    semanticsLabel: 'Your SVG Image',
                                    width: 70,
                                    height: 80,
                                  ),
                                ))
                                ,
                                SizedBox(
                                  height: 80,
                                )
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data != null &&
                              snapshot.data!.isEmpty) {
                            // If projects list is empty, reset current page to 0 and refresh
                            currentPage = 1;
                            refreshProjects();
                            return Center(
                              child: SvgPicture.asset(
                                'assets/images/empty.svg',
                                semanticsLabel: 'Your SVG Image',
                                width: 150,
                                height: 200,
                              ),
                            );
                          } else {
                            return
                              widget.showCase ==true

                            ?  Showcase(
                                blurValue: 12,
                                descTextStyle: TextStyle(
                                  fontSize: 19,
                                  color: HexColor ('#333333'),
                                ),
                                titleTextStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor('#0c343d'),  // Custom title color
                                ),

                                overlayColor: Colors.black.withOpacity(0.7),
                              key: _two,
                              title: 'Discover Projects',
                              description: 'Discover new projects to initiate your first work',
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true, // Set shrinkWrap to true
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return buildListItemNewProjects(
                                      snapshot.data![index]);
                                },
                              ),
                            ):ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true, // Set shrinkWrap to true
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return buildListItemNewProjects(
                                      snapshot.data![index]);
                                },
                              );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (currentPage > 1)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  currentPage--;
                                  refreshProjects(); // Use refreshProjects instead of fetchProjects
                                });
                              },
                              style: TextButton.styleFrom(
                               backgroundColor: Colors.redAccent,
                              ),
                              child: Text(
                                'Previous Page',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                currentPage++;
                                refreshProjects();
                              });

                              // Fetch the projects for the next page
                              List<Item>? nextPageProjects =
                                  await fetchProjects();

                              // Check if the next page is empty or no data and hide the button accordingly
                              if (!shouldShowNextButton(nextPageProjects)) {
                                setState(() {
                                  currentPage = 1;
                                  refreshProjects();
                                });
                              } else {
                                // Update the futureProjects with the fetched projects
                                futureProjects = Future.value(nextPageProjects);
                              }
                            },

                            child: Text(
                              'Next Page',
                              style: TextStyle(fontSize: 16 ,color: Colors.black45),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ]),
              ),
            ),
          ),

        )

    );

  }
  final ScreenshotController screenshotController2 = ScreenshotController();

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController2.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }

  void drawerControl() {
    advancedDrawerController.showDrawer();
  }

  Widget buildListItem(Item project) {
    return GestureDetector(
      onTap: () {
        Get.to(Get.to(() => bidDetailsWorker(projectId: project.projectId))
          ,
          transition: Transition.fadeIn, // You can choose a different transition
          duration: Duration(milliseconds: 700), );
      },
      child: Stack(
        children: [
          Container(
            // Adjust the height as needed
            width: 280,
            // Adjust the width as needed
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 19.0, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [

                    CarouselSlider(
                      options: CarouselOptions(
                        height: 130,

                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: false,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
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
                      items: project.imageUrl.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: 250,
                                height: double.infinity,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return LinearProgressIndicator(
                                    color: Colors.white,
                                    value: null,
                                    backgroundColor: Colors.grey[300],
                                    minHeight: 3,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: project.imageUrl.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () {
                            _carouselController.animateToPage(entry.key);
                          },
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == entry.key ? Colors.white : Colors.grey[300],
                            ),
                          ),
                        );
                      }).toList(),
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
                                    "${project.numbers_of_likes}",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  iconSize: 22,
                                  icon: Icon(
                                    likedProjectsMap[project.projectId] ?? project.liked == "true"
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likedProjectsMap[project.projectId] ?? project.liked == "true"
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    try {
                                      if (likedProjectsMap[project.projectId] ?? project.liked == "true") {
                                        // If liked, remove like
                                        final response = await removeProjectFromLikes(project.projectId.toString());

                                        if (response['status'] == 'success') {
                                          // If successfully removed from likes
                                          setState(() {
                                            likedProjectsMap[project.projectId] = false;
                                            project.numbers_of_likes = (project.numbers_of_likes ?? 0) - 1;
                                          });
                                          print('Project removed from likes');
                                        } else {
                                          // Handle the case where the project is not removed from likes
                                          print('Error: ${response['msg']}');
                                        }
                                      } else {
                                        // If not liked, add like
                                        final response = await addProjectToLikes(project.projectId.toString(),firstname ,project.title,project.client_id.toString());

                                        if (response['status'] == 'success') {
                                          // If successfully added to likes
                                          setState(() {
                                            likedProjectsMap[project.projectId] = true;
                                            project.numbers_of_likes = (project.numbers_of_likes ?? 0) + 1;
                                          });
                                          print('Project added to likes');
                                        } else if (response['msg'] == 'This Project is Already in Likes !') {
                                          // If the project is already liked, switch to Icons.favorite_border
                                          setState(() {
                                            likedProjectsMap[project.projectId] = false;
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
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            project.title.length > 12
                                ? '${project.title.substring(0, 12)}...' // Truncate to 14 characters and add ellipsis
                                : project.title,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('131330'),
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Lowest Bid',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'By',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 35.5),
                              // Adjust the maximum width as needed
                              child: TextButton(
                                  onPressed: () {
                                    Get.to(ProfilePageClient(userId:project.client_id.toString()),
                                      transition: Transition.fadeIn, // You can choose a different transition
                                      duration: Duration(milliseconds: 700), );
                                  },
                                  child: Text(
                                    project.client_firstname,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                        color: HexColor('43745C'),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,

                                      ),

                                    ),
                                  ))),
                          Spacer(),
                          Text(
                            '\$ ' + '${project.lowest_bids}',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,

                              ),

                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                          ),
                          SizedBox(width: 2,),
                          Text(
                            project.postedFrom,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Spacer(),
                          Container(
                            padding: EdgeInsets
                                .symmetric(
                                horizontal: 7.0),
                            height: 36,
                            decoration: BoxDecoration(
                              color: HexColor('4D8D6E'),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  () => bidDetailsWorker(
                                      projectId: project.projectId),
                                  transition: Transition.fadeIn, // You can choose a different transition
                                  duration: Duration(milliseconds: 700),
                                );
                              },
                              child: Text(
                                'Bid',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                                elevation: 0,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left:0,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 12),
              padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 6),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow.shade400,
                    Colors.orange.shade900,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),              ),
              child: Center(
                child: Text(
                  '${project.status}',

                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,

                  ),

                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget buildListItemNewProjects(Item item) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => bidDetailsWorker(projectId: item.projectId),
          transition: Transition.fadeIn, // You can choose a different transition
          duration: Duration(milliseconds: 700),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 13),
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: false,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
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
                      items: item.imageUrl.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: double.infinity,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return LinearProgressIndicator(
                                    color: Colors.white,
                                    value: null,
                                    backgroundColor: Colors.grey[300],
                                    minHeight: 3,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            // Add the dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: item.imageUrl.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () {
                            _carouselController.animateToPage(entry.key);
                          },
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == entry.key ? Colors.white : Colors.grey[300],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(), // Pushes the container to the right
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
                                    "${item.numbers_of_likes}",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  iconSize: 22,
                                  icon: Icon(
                                    likedProjectsMap[item.projectId] ?? item.liked == "true"
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likedProjectsMap[item.projectId] ?? item.liked == "true"
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    try {
                                      if (likedProjectsMap[item.projectId] ?? item.liked == "true") {
                                        // If liked, remove like
                                        final response = await removeProjectFromLikes(item.projectId.toString());

                                        if (response['status'] == 'success') {
                                          // If successfully removed from likes
                                          setState(() {
                                            likedProjectsMap[item.projectId] = false;
                                            item.numbers_of_likes = (item.numbers_of_likes ?? 0) - 1;
                                          });
                                          print('Project removed from likes');
                                        } else {
                                          // Handle the case where the project is not removed from likes
                                          print('Error: ${response['msg']}');
                                        }
                                      } else {
                                        // If not liked, add like
                                        final response = await addProjectToLikes(item.projectId.toString(),firstname ,item.title,item.client_id.toString());

                                        if (response['status'] == 'success') {
                                          // If successfully added to likes
                                          setState(() {
                                            likedProjectsMap[item.projectId] = true;
                                            item.numbers_of_likes = (item.numbers_of_likes ?? 0) + 1;
                                          });
                                          print('Project added to likes');
                                        } else if (response['msg'] == 'This Project is Already in Likes !') {
                                          // If the project is already liked, switch to Icons.favorite_border
                                          setState(() {
                                            likedProjectsMap[item.projectId] = false;
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
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            item.title.length > 17
                                ? '${item.title.substring(0, 17)}...' // Truncate to 14 characters and add ellipsis
                                : item.title,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('131330'),
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'By',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            height: 30,
                            width: 60,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Get.to(ProfilePageClient(userId:item.client_id.toString())
                                  ,
                                  transition: Transition.fadeIn, // You can choose a different transition
                                  duration: Duration(milliseconds: 700), );

                              },
                              style: TextButton.styleFrom(
                                fixedSize: Size(50, 30),
                                // Adjust the size as needed
                                padding: EdgeInsets.zero,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: _buildTextSpans(
                                      item.client_firstname, searchController.text),
                                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
                                // Use the client name from the fetched data
                                style: TextStyle(
                                  color: HexColor('4D8D6E'),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: _buildTextSpans(item.description, searchController.text),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: HexColor('393B3E'),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 7,),
                          Column(
                            children: [
                              Text(
                                'Lowest Bid',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('393B3E'), // Adjust color as needed
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6,),
                              item.lowest_bids != 'No Bids'
                                  ? Text( '\$ '+
                                item.lowest_bids.toString() , // Use 'N/A' or any preferred default text
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('393B3E'),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              )
                                  : Text(
                                'No Bids Yet',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
            ,
                      SizedBox(height: 9),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: HexColor('777778'),
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            item.postedFrom,
                            // Use the posted time from the fetched data
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('777778'),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          Spacer(),
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: HexColor('4D8D6E'),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  () => bidDetailsWorker(projectId: item.projectId),
                                  transition: Transition.fadeIn, // You can choose a different transition
                                  duration: Duration(milliseconds: 700),
                                );
                                // Handle button press
                              },
                              child: Text(
                                'Details',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                                elevation: 0,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left:0,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 13),
              padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 6),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade400,
                    Colors.lightGreen.shade900,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),              ),
              child: Center(
                child: Text(
                  '${item.status}',

                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,

                  ),

                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class Item {
  final int projectId;
  final int client_id;
  final String title;
  final String status;
  final String client_firstname;
  late  String liked;
  final String description;
  final List<String> imageUrl;
  int numbers_of_likes;
  final String postedFrom;
  String isLiked;
  dynamic lowest_bids;


  Item({
    required this.projectId,
    required this.client_id,
    required this.lowest_bids,
    required this.title,
    required this.status,
    required this.client_firstname,
    required this.description,
    required this.liked,
    required this.numbers_of_likes,
    required this.imageUrl,
    required this.postedFrom,
    required this. isLiked,
  }): assert(lowest_bids != null);
}
