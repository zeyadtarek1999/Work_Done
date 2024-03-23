import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';
import 'package:workdone/view/screens/Bid%20Details/Bid%20details%20Worker.dart';
import 'package:workdone/view/screens/notifications/notificationscreenworker.dart';
import '../Bid Details/Bid details Client.dart';
import 'package:badges/badges.dart' as badges;

import '../Support Screen/Helper.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';
import '../notifications/notificationScreenclient.dart';
import '../view profile screens/Client profile view.dart';
import 'package:http/http.dart' as http;

class exploreWorker extends StatefulWidget {
  final String userid3;

  exploreWorker({required this.userid3});
  @override
  State<exploreWorker> createState() => _exploreWorkerState();
}

class _exploreWorkerState extends State<exploreWorker> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  late Future<List<Item>> futureProjects;
  int currentPage = 0;
  void refreshProjects() {
    futureProjects = fetchProjects();
  }
  final StreamController<String> _likedStatusController = StreamController<String>();


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

  Stream<String> get likedStatusStream => _likedStatusController.stream;
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
            'time' : formattedTime,
            'id' :projectId,
            'type': 'projectclient'
            // Add other notification data as needed
          };
          print('sended notification ${[newNotification]}');

          id!= userId.toString()?     SaveNotificationToFirebase.saveNotificationsToFirestore(id.toString(), [newNotification]) :null;
          print('getting notification');
          print(' notificationwe  ${id}');
          print(' notificationwe  ${ userId.toString()}');
          // Get the user document reference
          // Get the user document reference
          // Get the user document reference
          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(id.toString()) ;

// Get the user document
          DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
          if (doc.exists &&  id!= userId.toString()) {
            // Extract the FCM token and notifications list from the document
            String? receiverToken = doc.get('fcmToken');
            List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

            // Check if the new notification is not null and not already in the list
            if (newNotification != null && !notifications.any((notification) => notification['id'] == newNotification['id'])) {
              // Add the new notification to the beginning of the list
              notifications.insert(0, newNotification);

              // Update the user document with the new notifications list
              await userDocRef.update({
                'notifications': notifications.last,
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



  bool shouldShowNextButton(List<Item>? nextPageData) {
    // Add your condition to check if the next page is not empty here
    return nextPageData != null && nextPageData.isNotEmpty;
  }
  Timer? searchDebouncer;
  int notificationnumber =0 ;  Future<void> Notificationnumber() async {
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
  Future<List<Item>> fetchProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_all_projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'filter': 'search', // Set filter to 'search'
          'search_key': searchController.text, // Include the search key
          'page': currentPage.toString(),
          // Include other parameters as needed
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> projectsJson = responseData['projects'];

          List<Item> projects = projectsJson.map((json) {
            return Item(
              client_id: json['client_id'],
              projectId: json['project_id'],
              title: json['title'],
              description: json['desc'],
              imageUrl: json['images'] != null ? List<String>.from(json['images']) : [], // This creates a list from the JSON array

              postedFrom: json['posted_from'],
              client_firstname: json['client_firstname'],
              liked: json['liked'],
              numbers_of_likes: json['numbers_of_likes'],
              isLiked: json['liked'],
              lowest_bids: json['lowest_bid'] ?? 'No Bids', // Assign "No Bids" if null
            );
          }).toList();

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
  final ScreenshotController screenshotController = ScreenshotController();


  List<Item> filteredItems = [];
  late AnimationController ciruclaranimation;
  String firstname = '';

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
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },

        );

        if (response.statusCode == 200) {
          Map<dynamic, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<dynamic, dynamic> profileData = responseData['data'];

            String languageString;

            setState(() {
              firstname = profileData['firstname'] ?? '';


              // Add this line
            });

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
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }
  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects();
    _getUserid();
    _getUserProfile();
    // Notificationnumber();
    // const Duration fetchdata = Duration(seconds: 15);
    // Timer.periodic(fetchdata, (Timer timer) {
    //   // Fetch data at each interval
    //   Notificationnumber();
    //
    // });
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

  }
  @override
  void dispose() {
    ciruclaranimation.dispose();
    super.dispose();
  }

  List<InlineSpan> _buildTextSpans(String text, String query) {
    final spans = <InlineSpan>[];
    final matches = RegExp(query, caseSensitive: false).allMatches(text.toLowerCase());

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

          return title.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('F9F9F9'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));



    String unique= 'exploreworker' ;
    void _navigateToNextPage(BuildContext context) async {
      Uint8List? imageBytes = await screenshotController.capture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
        ),
      );
    }
    return Scaffold(
        floatingActionButton:
        FloatingActionButton(    heroTag: 'workdone_${unique}',



          onPressed: () {
            _navigateToNextPage(context);

          },
          backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
  child: Icon(Icons.help ,color: Colors.white,), // Use the support icon          shape: CircleBorder(), // Make the button circular
        ),
        backgroundColor: HexColor('F9F9F9'),
        appBar: AppBar(systemOverlayStyle:SystemUiOverlayStyle.dark ,
          toolbarHeight: 70,
          backgroundColor: HexColor('F9F9F9'),
          elevation: 0,
          // leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_sharp ,color: Colors.black,size: 30,)),
          title: Text('Explore',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                  color: HexColor('393B3E'),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
          actions: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notify')
                    .doc('${widget.userid3}')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return GestureDetector(
                      onTap: (){NotificationsPageworker();},
                      child: SvgPicture.asset(
                        'assets/icons/iconnotification.svg',
                        width: 48.0,
                        height:48.0,
                      ),
                    );// Show a loading indicator while waiting for data
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
                              child: SvgPicture.asset(
                                'assets/icons/iconnotification.svg',
                                width: 48.0,
                                height:48.0,
                              ),
                              onTap: () {
                                Get.to(NotificationsPageworker());
                              },
                            ),
                          ),
                        ):
                        GestureDetector(
                            child: SvgPicture.asset(
                              'assets/icons/iconnotification.svg',
                              width: 48.0,
                              height:48.0,
                            ),
                            onTap: () {
                              Get.to(NotificationsPageworker());});

                    } else {
                      // Handle the case where 'notifications' field does not exist
                      return SvgPicture.asset(
                        'assets/icons/iconnotification.svg',
                        width: 48.0,
                        height:48.0,
                      ); // Show a loading indicator while waiting for data
                    }
                  } else {
                    // Handle the case where the document does not exist
                    return SvgPicture.asset(
                      'assets/icons/iconnotification.svg',
                      width: 48.0,
                      height:48.0,
                    ); // Show a loading indicator while waiting for data
                  }
                },
              ),
            ),

          ],

        ),

        body:
        Screenshot(
          controller:screenshotController ,
          child:  RefreshIndicator(
            color: HexColor('4D8D6E'),
            backgroundColor: Colors.white,

            onRefresh: () async {
              setState(() {
                futureProjects = fetchProjects();
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Color of the shadow
                              spreadRadius: 2, // Spread radius
                              blurRadius: 4, // Blur radius
                              offset: Offset(0, 2), // Offset in the x and y direction
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: HexColor('4D8D6E'),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'All',
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15 ,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: HexColor('878A8E'),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        onChanged: (query) {
                                          // Use a debounce mechanism to delay the refresh and avoid unnecessary API calls
                                          if (searchDebouncer?.isActive ?? false) {
                                            searchDebouncer!.cancel();
                                          }

                                          searchDebouncer = Timer(Duration(milliseconds: 500), () {

                                            setState(() {
                                              refreshProjects();

                                            }); // Trigger the refresh after a delay (e.g., 500 milliseconds)
                                          });
                                        },
                                        onSubmitted: (query) {
                                          // Trigger the refresh when the user presses "Done" on the keyboard
                                          setState(() {
                                            refreshProjects();

                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search',
                                          hintStyle: TextStyle(color: HexColor('878A8E')),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      )


                                      ,

                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    FutureBuilder<List<Item>>(
                      future: futureProjects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            children: [
                              SizedBox(height: 80,),       Center(child: RotationTransition(
                                turns: ciruclaranimation,
                                child: SvgPicture.asset(
                                  'assets/images/Logo.svg',
                                  semanticsLabel: 'Your SVG Image',
                                  width: 70,
                                  height: 80,
                                ),
                              ))
                              ,SizedBox(height: 80,)
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                          // If projects list is empty, reset current page to 0 and refresh
                          currentPage = 0;
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
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return buildListItem(snapshot.data![index]);
                            },
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (currentPage > 0)
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
                              style: TextStyle(fontSize: 16, ),
                            ),
                          ),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              currentPage++;
                              refreshProjects();
                            });

                            // Fetch the projects for the next page
                            List<Item>? nextPageProjects = await fetchProjects();

                            // Check if the next page is empty or no data and hide the button accordingly
                            if (!shouldShowNextButton(nextPageProjects)) {
                              setState(() {
                                currentPage = 0;
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
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          ),
        )



    );
  }

  Widget buildListItem(Item item) {
    return GestureDetector(
      onTap: () {
        Get.to(bidDetailsWorker(projectId: item.projectId,));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
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
                    pageSnapping: true,

                    height: 170,
                    aspectRatio: 16/9,
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
                          ),
                        );
                      },
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
                                    final response = await addProjectToLikes(item.projectId.toString(),firstname,item.title,item.client_id.toString());

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
                      Text.rich(
                        TextSpan(
                          children: _buildTextSpans(
                            item.title.length > 17
                                ? '${item.title.substring(0, 16)}...' // Truncate to 14 characters and add ellipsis
                                : item.title,
                            searchController.text,
                          ),
                        ),
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
                      SizedBox(width: 4,),
                      Container(
                        height: 30,
                        width: 60,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(ProfilePageClient(userId: item.client_id.toString()));
                          },
                          style: TextButton.styleFrom(
                            fixedSize: Size(50, 30), // Adjust the size as needed
                            padding: EdgeInsets.zero,
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: _buildTextSpans(item.client_firstname, searchController.text),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis, // Use the client name from the fetched data
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
                              ? Text(
                            item.lowest_bids.toString(), // Use 'N/A' or any preferred default text
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
                  ),
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
                        item.postedFrom, // Use the posted time from the fetched data
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
                        width: 85,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(bidDetailsWorker(projectId: item.projectId,));
                          },
                          child: Text('Bid',style: TextStyle(color: Colors.white,fontSize: 12),),
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
    );
  }
}
class Item {
  final int projectId;
  final String title;
  final String client_firstname;
  final int client_id;

  final String liked;
  final String description;
  final List<String> imageUrl;
   int numbers_of_likes;
  final String postedFrom;
  String isLiked;
  dynamic? lowest_bids;

  Item({
    required this.projectId,
    required this.lowest_bids,
    required this.title,
    required this.client_id,
    required this.client_firstname,
    required this.description,
    required this.liked,
    required this.numbers_of_likes,
    required this.imageUrl,
    required this.postedFrom,
    required this. isLiked,
  }) ;
}